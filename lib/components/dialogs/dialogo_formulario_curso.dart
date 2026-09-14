import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test_project/model/curso/preferencia_periodo.dart';
import 'package:flutter_test_project/model/curso/carga_curso_materia.dart';
import 'package:flutter_test_project/model/sala/sala.dart';
import 'package:flutter_test_project/model/materia/materia.dart';

class ResultadoFormularioCurso {
  const ResultadoFormularioCurso({
    required this.nome,
    required this.cargas,
    this.idSala,
    this.preferenciaPeriodo = PreferenciaPeriodo.manha,
  });

  final String nome;
  final String? idSala;
  final PreferenciaPeriodo preferenciaPeriodo;
  final List<CargaCursoMateria> cargas;
}

class _LinhaCarga {
  _LinhaCarga({
    this.idMateria,
    int quantidadeAulas = 1,
    this.tamanhoBloco = 1,
  })  : controladorQuantidade = TextEditingController(text: '$quantidadeAulas');

  String? idMateria;
  final TextEditingController controladorQuantidade;
  int tamanhoBloco;

  void dispose() => controladorQuantidade.dispose();
}

Future<ResultadoFormularioCurso?> mostrarDialogoFormularioCurso(
  BuildContext context, {
  required String titulo,
  required List<Materia> materias,
  required List<Sala> salas,
  String? nomeInicial,
  String? idSalaInicial,
  PreferenciaPeriodo preferenciaPeriodoInicial =
      PreferenciaPeriodo.manha,
  List<CargaCursoMateria> cargasIniciais = const [],
  String idCurso = '0',
}) {
  return showDialog<ResultadoFormularioCurso>(
    context: context,
    builder: (context) => _CourseFormDialog(
      titulo: titulo,
      materias: materias,
      salas: salas,
      nomeInicial: nomeInicial,
      idSalaInicial: idSalaInicial,
      preferenciaPeriodoInicial: preferenciaPeriodoInicial,
      cargasIniciais: cargasIniciais,
      idCurso: idCurso,
    ),
  );
}

class _CourseFormDialog extends StatefulWidget {
  const _CourseFormDialog({
    required this.titulo,
    required this.materias,
    required this.salas,
    this.nomeInicial,
    this.idSalaInicial,
    required this.preferenciaPeriodoInicial,
    required this.cargasIniciais,
    required this.idCurso,
  });

  final String titulo;
  final List<Materia> materias;
  final List<Sala> salas;
  final String? nomeInicial;
  final String? idSalaInicial;
  final PreferenciaPeriodo preferenciaPeriodoInicial;
  final List<CargaCursoMateria> cargasIniciais;
  final String idCurso;

  @override
  State<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<_CourseFormDialog> {
  late final TextEditingController _controladorNome;
  late final List<_LinhaCarga> _linhas;
  String? _idSala;
  late PreferenciaPeriodo _preferenciaPeriodo;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _controladorNome = TextEditingController(text: widget.nomeInicial ?? '');
    _idSala = widget.idSalaInicial;
    _preferenciaPeriodo = widget.preferenciaPeriodoInicial;
    if (widget.cargasIniciais.isEmpty) {
      _linhas = [_LinhaCarga()];
    } else {
      _linhas = widget.cargasIniciais
          .map(
            (load) => _LinhaCarga(
              idMateria: load.idMateria,
              quantidadeAulas: load.quantidadeAulas,
              tamanhoBloco: load.tamanhoBloco,
            ),
          )
          .toList();
    }
  }

  @override
  void dispose() {
    _controladorNome.dispose();
    for (final row in _linhas) {
      row.dispose();
    }
    super.dispose();
  }

  void _adicionarLinha() => setState(() => _linhas.add(_LinhaCarga()));

  void _removerLinha(int index) {
    setState(() {
      _linhas[index].dispose();
      _linhas.removeAt(index);
      if (_linhas.isEmpty) _linhas.add(_LinhaCarga());
    });
  }

  void _enviar() {
    final nome = _controladorNome.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = 'Informe o nome do curso');
      return;
    }

    final cargas = <CargaCursoMateria>[];
    final seenSubjects = <String>{};

    for (final row in _linhas) {
      final idMateria = row.idMateria;
      if (idMateria == null) continue;

      final count = int.tryParse(row.controladorQuantidade.text.trim());
      if (count == null || count < 1) {
        setState(() => _erro = 'Quantidade de aulas deve ser um número ≥ 1');
        return;
      }
      if (!seenSubjects.add(idMateria)) {
        setState(() => _erro = 'Cada matéria só pode aparecer uma vez');
        return;
      }

      cargas.add(
        CargaCursoMateria(
          idCurso: widget.idCurso,
          idMateria: idMateria,
          quantidadeAulas: count,
          tamanhoBloco: row.tamanhoBloco,
        ),
      );
    }

    setState(() => _erro = null);
    Navigator.of(context).pop(
      ResultadoFormularioCurso(
        nome: nome,
        idSala: _idSala,
        preferenciaPeriodo: _preferenciaPeriodo,
        cargas: cargas,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titulo),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controladorNome,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nome do curso',
                errorText: _erro,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PreferenciaPeriodo>(
              key: ValueKey('period-$_preferenciaPeriodo'),
              initialValue: _preferenciaPeriodo,
              decoration: const InputDecoration(
                labelText: 'Período das aulas',
              ),
              items: PreferenciaPeriodo.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.rotulo),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _preferenciaPeriodo = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey('room-$_idSala'),
              initialValue: _idSala,
              decoration: const InputDecoration(
                labelText: 'Sala padrão (opcional)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Nenhuma'),
                ),
                ...widget.salas.map(
                  (room) => DropdownMenuItem<String?>(
                    value: room.id,
                    child: Text('Sala ${room.numero}'),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _idSala = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Matérias, carga e blocos',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.materias.isEmpty ? null : _adicionarLinha,
                  icon: const Icon(Icons.add),
                  label: const Text('Linha'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Bloco: aulas consecutivas no mesmo dia (1 ou 2).',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            if (widget.materias.isEmpty)
              const Text('Cadastre matérias antes de definir a carga horária.')
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < _linhas.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(
                                    'load-$i-${_linhas[i].idMateria}',
                                  ),
                                  initialValue: _linhas[i].idMateria,
                                  decoration: const InputDecoration(
                                    labelText: 'Matéria',
                                    isDense: true,
                                  ),
                                  items: widget.materias
                                      .map(
                                        (subject) => DropdownMenuItem(
                                          value: subject.id,
                                          child: Text(subject.nome),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() => _linhas[i].idMateria = value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _linhas[i].controladorQuantidade,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'Aulas',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  key: ValueKey(
                                    'block-$i-${_linhas[i].tamanhoBloco}',
                                  ),
                                  initialValue: _linhas[i].tamanhoBloco,
                                  decoration: const InputDecoration(
                                    labelText: 'Bloco',
                                    isDense: true,
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 1, child: Text('1')),
                                    DropdownMenuItem(value: 2, child: Text('2')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _linhas[i].tamanhoBloco = value);
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () => _removerLinha(i),
                                tooltip: 'Remover linha',
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
