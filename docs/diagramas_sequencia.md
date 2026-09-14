# Diagramas de sequência — Timetable

App Flutter + Riverpod + Supabase para montagem de horários escolares.

---

## 1. Visão geral dos fluxos

```mermaid
sequenceDiagram
    actor U as Usuário
    participant P1 as Página 1
    participant P2 as Página 2
    participant P3 as Página 3
    participant Prov as Providers
    participant Repo as Repositórios
    participant SB as Supabase
    participant Ger as GeradorHorario
    participant Val as ValidadorHorario
    participant PDF as ExportadorHorarioPdf

    Note over U,SB: 1. Cadastro (Página 1)
    U->>P1: Cria salas, matérias, professores, cursos
    P1->>Repo: adicionar / atualizar
    Repo->>SB: INSERT/UPDATE
    SB-->>Repo: OK
    Repo-->>P1: invalidate providers
    Prov-->>P1: listas atualizadas

    Note over U,SB: 2. Indisponibilidade (Página 2)
    U->>P2: Seleciona professor e marca células
    P2->>Repo: adicionar/excluir indisponibilidade
    Repo->>SB: INSERT/DELETE
    SB-->>P2: OK (salvo)

    Note over U,PDF: 3. Gerar horários (Página 3)
    U->>P3: Clica "Gerar" (todas as turmas)
    P3->>U: Confirma regeneração
    U-->>P3: Confirma
    P3->>Repo: excluirTodas (aulas)
    Repo->>SB: DELETE tb_aula
    P3->>Ger: gerarTodos(cursos, cargas, professores, indisponibilidades)
    Ger-->>P3: novasAulas + falhas
    loop Cada aula gerada
        P3->>Repo: adicionar(aula)
        Repo->>SB: INSERT tb_aula
    end
    P3->>Prov: invalidate provedorAulas
    Prov->>Repo: observar/buscar aulas
    Repo->>SB: SELECT
    SB-->>P3: aulas
    P3->>Val: validarCurso(turma selecionada)
    Val-->>P3: Sem problemas / lista de erros
    P3-->>U: Grade + painel de validação

    Note over U,SB: 4. Editar célula (Página 3)
    U->>P3: Toca célula
    P3->>U: Dialog matéria / professor / sala
    U-->>P3: Salvar ou Excluir
    alt Excluir
        P3->>Repo: excluir(aula)
    else Salvar
        P3->>P3: validarSalvarAula (regras)
        P3->>Repo: adicionar ou atualizar
    end
    Repo->>SB: escrita
    P3->>Prov: invalidate
    P3->>Val: validarCurso
    Val-->>U: painel atualizado

    Note over U,PDF: 5. Exportar PDF
    U->>P3: Clica "PDF"
    P3->>PDF: gerar(todas turmas, aulas, nomes)
    PDF-->>P3: bytes do PDF (paisagem, 1 pág/turma)
    P3-->>U: Preview / impressão (Printing)
```

---

## 2. Detalhe — Gerador de horário

```mermaid
sequenceDiagram
    participant P3 as Página 3
    participant Ger as GeradorHorario

    P3->>Ger: gerarTodos()
    Ger->>Ger: Ordena cursos (maior carga primeiro)

    loop Cada curso
        Ger->>Ger: Para cada matéria da carga
        Ger->>Ger: Quebra em blocos 1 ou 2
        Ger->>Ger: Filtra períodos (manhã / tarde / contraturno)

        loop Cada bloco
            Ger->>Ger: Percorre dias e horários
            Ger->>Ger: Checa turma livre, professor, sala, 1 bloco/matéria/dia
            alt Cabe
                Ger->>Ger: Coloca bloco em memória
            else Não cabe
                Ger->>Ger: Registra falha
            end
        end
    end

    Ger-->>P3: ResultadoGeracaoCompleta
```

---

## 3. Detalhe — Cadastro de curso (Página 1)

```mermaid
sequenceDiagram
    actor U as Usuário
    participant Col as ColunaCurso
    participant Dialog as DialogoFormularioCurso
    participant Repo as RepositorioCurso
    participant SB as Supabase
    participant Prov as Providers

    U->>Col: Adicionar / Editar curso
    Col->>Dialog: abrir (nome, período, sala, matérias, blocos)
    U->>Dialog: Preenche e Salvar
    Dialog-->>Col: ResultadoFormularioCurso
    Col->>Repo: adicionar / atualizar + definirCargas
    Repo->>SB: tb_curso + tb_curso_materia
    SB-->>Repo: OK
    Col->>Prov: invalidate cursos e cargas
    Prov-->>Col: lista atualizada
```

---

## 4. Participantes (resumo)

| Participante | Papel |
|--------------|--------|
| Página 1 | CRUD de salas, matérias, professores e cursos |
| Página 2 | Indisponibilidade de professores na grade |
| Página 3 | Visualizar, gerar, editar aulas e exportar PDF |
| Providers | Riverpod — streams e repositórios |
| Repositórios | Acesso REST/Realtime ao Supabase |
| GeradorHorario | Aloca blocos respeitando regras |
| ValidadorHorario | Avisos na faixa abaixo da grade |
| ExportadorHorarioPdf | PDF paisagem, uma página por turma |

---

## Como visualizar

- **GitHub / GitLab:** o Mermaid renderiza no próprio `.md`
- **VS Code / Cursor:** extensão “Markdown Preview Mermaid Support” ou preview nativo
- **Online:** [mermaid.live](https://mermaid.live) — cole os blocos `mermaid`
