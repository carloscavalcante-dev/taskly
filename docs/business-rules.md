# Regras de negócio detalhadas

## 1️⃣ Estrutura básica da plataforma

A plataforma permite que usuários autenticados criem e gerenciem listas, tarefas e subtarefas.

Cada tarefa pertence a uma **lista** e a um **usuário**.

Subtarefas pertencem a uma tarefa principal.

## 2️⃣ Listas

As **listas** funcionam como contêineres organizacionais para agrupar tarefas relacionadas.
Cada lista pertence a um usuário e pode conter **várias tarefas** (simples ou recorrentes).

O objetivo das listas é permitir ao usuário organizar **tarefas por contexto**, como “Trabalho”, “Pessoal”, “Estudos” ou “Projetos”.

### ⚙️ Comportamento do sistema

- O usuário pode criar, editar, renomear e excluir listas a qualquer momento.
- A exclusão de uma lista **remove todas as tarefas e subtarefas associadas** a ela.
- O sistema vai exibir listas padrões como: Atribuido a mim (mostra todas as tarefas que o usuário possui), meu dia (mostra as tarefas do dia).

> **Nota**: As listas são o primeiro nível de organização dentro da plataforma, garantindo que as tarefas sejam agrupadas de forma lógica e fácil de navegar.

## 3️⃣ Tipos de tarefas

Existem dois tipos de tarefas:

- **Tarefas simples**: executadas uma única vez.

- **Tarefas recorrentes**: repetidas automaticamente após a conclusão.

## 4️⃣ Tarefas recorrentes

Ao criar uma tarefa, o usuário pode marcá-la como recorrente.

Quando uma tarefa recorrente é marcada como concluída, o sistema automaticamente:

Cria uma nova tarefa idêntica, copiando todos os campos da original (nome, descrição, cor, data, etc.);

Atualiza a data de vencimento (`due_date`) conforme a regra de recorrência definida pelo usuário .

- O usuário pode escolher o tipo de recorrência:

  - **Por intervalo**: ex. a cada 2 dias, 1 semana, 1 mês.
    > **Adendo:** Se a unidade de repetição for semanal, o usuário pode opcionalmente definir o dia da semana específico para fixar o vencimento.

  - **Por dias fixos**: ex. toda segunda e quarta-feira, ou todo dia 10 do mês.

> **Nota:** Isso garante que tarefas rotineiras, como “fazer backup semanal”, se recriem automaticamente.


### ⚙️ Comportamento do sistema

- A tarefa é criada como **em progresso** (`in_progress`) por padrão.
- Se a data/hora atual ultrapassar `due_date` e o status ainda for `in_progress`, o sistema altera para **expirada** (`expired`).
- A nova instância herda os dados da tarefa anterior.
- Se a tarefa for recorrente “por intervalo”, usa `recurrence_interval` e `recurrence_unit`. Se o `recurrence_unit` for semanal (`week`), o campo `recurrence_day` é usado para fixar o dia da semana da nova `due_date`.
- Se for “por dias fixos”, usa `recurrence_days`.

- Ao marcar a tarefa como concluída, o sistema:
  - Atualiza o status da instância anterior para `done`;
  - Registra `completed_at`;
  - Remove a notificação associada (se existir);
  - Cria uma nova tarefa com os campos herdados da anterior, inclusive notificações.

  ### Mais informações 

- [Fluxo de tarefas recorrentes](./flows/task-recurring-creation.md)


## 5️⃣ Tarefas simples

São tarefas únicas, executadas apenas uma vez.
O usuário pode criar uma tarefa simples para registrar compromissos pontuais, atividades não recorrentes ou tarefas avulsas.

Ao concluir, a tarefa é encerrada definitivamente e **não gera novas instâncias**.

O usuário **pode** definir:

- Uma data de início (`start_date`) — indicando quando a tarefa começa a valer.
- Uma data de vencimento (`due_date`) — determinando quando ela deve ser finalizada.
- Uma notificação associada — que é feita de forma manual pelo usuário.

Se a tarefa atingir o vencimento e ainda não estiver concluída, o sistema poderá marcá-la como expirada (`expired`).

> **Nota:** Tarefas simples são ideais para ações pontuais, como “entregar relatório na sexta” ou “consultar médico amanhã”.

### ⚙️ Comportamento do sistema
- A tarefa é criada como **em progresso** (`in_progress`) por padrão.
- Se a data/hora atual ultrapassar `due_date` e o status ainda for `in_progress`, o sistema altera para `expired`.

- Ao marcar a tarefa como concluída, o sistema:
  - Atualiza o status para `done`;
  - Registra `completed_at`;
  - Remove a notificação associada (se existir).

### Mais informações 

- [Fluxo de tarefas simples](./flows/task-simple-creation.md)


## 6️⃣ Notificações

Cada tarefa (simples ou recorrente) pode ter **apenas uma única notificação associada**.
As notificações servem para alertar o usuário sobre o vencimento de uma tarefa ou sobre um evento programado.

O usuário pode definir **quando deseja ser notificado**, de duas formas:

- **Manual**: selecionando uma data e hora específicas (`remind_at`);

- **Automática (atalhos)**: escolhendo opções pré-definidas como:
  - “1 hora antes”
  - “1 dia antes”
  - “1 semana antes”

> **Regra**: o usuário só pode definir notificações automáticas se a tarefa possuir um `due_date` configurado.

### ⚙️ Comportamento do sistema

- As notificações **sempre pertencem a uma tarefa** (`task_id`) e a um usuário (`user_id`).
- Uma tarefa nunca pode ter mais de uma notificação ativa.
- Se a tarefa for concluída, a notificação associada é **removida automaticamente**.
- Se a tarefa for recorrente, ao criar a nova instância da tarefa, o **sistema replica a configuração da notificação** (mantendo a lógica de lembrete).
- Se a notificação for através dos atalhos pré-definidos, caso o usuário edite o `due_date` da tarefa, o `remind_at` é automaticamente ajustado conforme o novo vencimento.
- Se o horário atual ultrapassar `remind_at`, o sistema dispara a notificação e atualiza `sent_at`.

> **Nota**: As notificações **não são recorrentes por si só** — elas dependem diretamente da tarefa.
Isso mantém o sistema previsível, evitando notificações órfãs ou duplicadas.

## 7️⃣ Subtarefas

Uma tarefa pode conter **várias subtarefas**, permitindo que o usuário divida atividades complexas em etapas menores e mais gerenciáveis.
Cada subtarefa pertence exclusivamente a uma tarefa principal (`task_id`).

Cada subtask possui **status próprio**, podendo estar:

- `in_progress` — em andamento
- `done` — concluída

> **Nota**: Subtarefas não possuem status **“expired”**, pois a expiração é controlada apenas pela tarefa principal.

### ⚙️ Comportamento do sistema

- Subtarefas são sempre vinculadas a uma tarefa principal (`task_id`).
-Ao criar uma tarefa principal, o usuário pode adicionar subtarefas imediatamente ou depois.
- A exclusão de uma tarefa principal remove todas as subtarefas associadas.


## 🔹 Glossário de Campos-Chave

- `start_date`: Data e hora em que a tarefa se torna ativa.
- `due_date`: Data e hora limite para conclusão.
- `remind_at`: Data e hora da notificação programada.
- `completed_at`: Momento em que a tarefa foi concluída.
- `status`: Pode assumir `in_progress`, `done`, `expired`.
- `recurrence_type`: Tipo de recorrência da tarefa; valores possíveis:
  - `interval` → recorrência baseada em intervalo de tempo (ex: a cada 2 dias)
  - `fixed_day` → recorrência em dias fixos (ex: toda segunda-feira ou todo dia 10 do mês)
- `recurrence_interval`: Quantidade de unidades de tempo entre cada repetição (usado quando `recurrence_type = interval`).
  - Exemplo: `2` com `recurrence_unit = day` significa “a cada 2 dias”.
- `recurrence_unit`: Unidade de tempo da recorrência; valores possíveis: `hour`, `day`, `week`, `month`.
- `recurrence_day`: Dia específico do mês ou data no calendário que determina quando a tarefa recorrente deve se repetir (usado quando `recurrence_type = fixed_day`).
  - Exemplo: se o usuário definir dia 20, a tarefa será criada automaticamente todo dia 20 de cada mês.
  - Para recorrência semanal, poderia ser representado como dia da semana, ex.: toda segunda-feira.
