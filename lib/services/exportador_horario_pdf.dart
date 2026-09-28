import 'dart:typed_data';

import 'package:flutter_test_project/components/grade_horaria.dart';
import 'package:flutter_test_project/model/aula/aula.dart';
import 'package:flutter_test_project/model/curso/curso.dart';
import 'package:flutter_test_project/model/materia/materia.dart';
import 'package:flutter_test_project/model/professor/professor.dart';
import 'package:flutter_test_project/model/sala/sala.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Gera PDF paisagem: uma página por turma (incluindo grades vazias).
class ExportadorHorarioPdf {
  const ExportadorHorarioPdf();

  Future<Uint8List> gerar({
    required List<Curso> cursos,
    required List<Aula> aulas,
    required List<Materia> materias,
    required List<Professor> professores,
    required List<Sala> salas,
  }) async {
    final doc = pw.Document();
    final mapaMaterias = {for (final m in materias) m.id: m.nome};
    final mapaProfessores = {for (final p in professores) p.id: p.nome};
    final mapaSalas = {for (final s in salas) s.id: s};

    final listaCursos = List<Curso>.from(cursos)
      ..sort((a, b) => a.nome.compareTo(b.nome));

    for (final curso in listaCursos) {
      final porCelula = <CelulaGrade, List<Aula>>{};
      for (final a in aulas.where((a) => a.idCurso == curso.id)) {
        porCelula.putIfAbsent(a.celula, () => []).add(a);
      }
      for (final lista in porCelula.values) {
        lista.sort((a, b) => a.grupo.compareTo(b.grupo));
      }
      final salaPadrao = curso.idSala == null ? null : mapaSalas[curso.idSala!];

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                curso.nome,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (salaPadrao != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  'Sala padrão: ${salaPadrao.numero}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ],
              pw.SizedBox(height: 12),
              pw.Expanded(
                child: _tabelaGrade(
                  porCelula: porCelula,
                  mapaMaterias: mapaMaterias,
                  mapaProfessores: mapaProfessores,
                  mapaSalas: mapaSalas,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (listaCursos.isEmpty) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) => pw.Center(
            child: pw.Text('Nenhum curso cadastrado.'),
          ),
        ),
      );
    }

    return doc.save();
  }

  pw.Widget _tabelaGrade({
    required Map<CelulaGrade, List<Aula>> porCelula,
    required Map<String, String> mapaMaterias,
    required Map<String, String> mapaProfessores,
    required Map<String, Sala> mapaSalas,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(42),
        for (var i = 1; i <= GradeHoraria.dias.length; i++)
          i: const pw.FlexColumnWidth(),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _cabecalho(''),
            ...GradeHoraria.dias.map(_cabecalho),
          ],
        ),
        for (var i = 0; i < GradeHoraria.quantidadePeriodosManha; i++)
          _linhaPeriodo(
            rotulo: GradeHoraria.periodos[i],
            indicePeriodo: i,
            porCelula: porCelula,
            mapaMaterias: mapaMaterias,
            mapaProfessores: mapaProfessores,
            mapaSalas: mapaSalas,
          ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _celulaTexto('Almoço', negrito: true, centralizado: true),
            for (var d = 0; d < GradeHoraria.dias.length; d++)
              _celulaTexto('', centralizado: true),
          ],
        ),
        for (var i = GradeHoraria.inicioTarde;
            i < GradeHoraria.inicioContraturno;
            i++)
          _linhaPeriodo(
            rotulo: GradeHoraria.periodos[i],
            indicePeriodo: i,
            porCelula: porCelula,
            mapaMaterias: mapaMaterias,
            mapaProfessores: mapaProfessores,
            mapaSalas: mapaSalas,
          ),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _celulaTexto('Contraturno', negrito: true, centralizado: true),
            for (var d = 0; d < GradeHoraria.dias.length; d++)
              _celulaTexto('', centralizado: true),
          ],
        ),
        for (var i = GradeHoraria.inicioContraturno;
            i < GradeHoraria.periodos.length;
            i++)
          _linhaPeriodo(
            rotulo: GradeHoraria.periodos[i],
            indicePeriodo: i,
            porCelula: porCelula,
            mapaMaterias: mapaMaterias,
            mapaProfessores: mapaProfessores,
            mapaSalas: mapaSalas,
          ),
      ],
    );
  }

  pw.TableRow _linhaPeriodo({
    required String rotulo,
    required int indicePeriodo,
    required Map<CelulaGrade, List<Aula>> porCelula,
    required Map<String, String> mapaMaterias,
    required Map<String, String> mapaProfessores,
    required Map<String, Sala> mapaSalas,
  }) {
    return pw.TableRow(
      children: [
        _celulaTexto(rotulo, negrito: true, centralizado: true),
        for (var dia = 0; dia < GradeHoraria.dias.length; dia++)
          _celulaAulas(
            porCelula[CelulaGrade(indiceDia: dia, indicePeriodo: indicePeriodo)] ??
                const [],
            mapaMaterias: mapaMaterias,
            mapaProfessores: mapaProfessores,
            mapaSalas: mapaSalas,
          ),
      ],
    );
  }

  pw.Widget _cabecalho(String texto) => _celulaTexto(
        texto,
        negrito: true,
        centralizado: true,
      );

  pw.Widget _celulaTexto(
    String texto, {
    bool negrito = false,
    bool centralizado = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        texto,
        textAlign: centralizado ? pw.TextAlign.center : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _celulaAulas(
    List<Aula> aulas, {
    required Map<String, String> mapaMaterias,
    required Map<String, String> mapaProfessores,
    required Map<String, Sala> mapaSalas,
  }) {
    if (aulas.isEmpty) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(3),
        child: pw.SizedBox(height: 28),
      );
    }

    return pw.Container(
      color: PdfColors.green50,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          for (final aula in aulas) ...[
            pw.Text(
              'G${aula.grupo} ${mapaMaterias[aula.idMateria] ?? 'Matéria'}',
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              mapaProfessores[aula.idProfessor] ?? 'Professor',
              textAlign: pw.TextAlign.center,
              maxLines: 1,
              style: const pw.TextStyle(fontSize: 6),
            ),
          ],
        ],
      ),
    );
  }
}
