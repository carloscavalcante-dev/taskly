### Tabela USERS (Usuários)

| Campo | Tipo | Restrições/Notas |
| :--- | :--- | :--- |
| `id` | `UUID` | PK. Identificador único do usuário. |
| `name` | `VARCHAR(255)` | NOT NULL. Nome do usuário. |
| `email` | `VARCHAR(255)` | NOT NULL, UNIQUE. Email do usuário para autenticação. |
| `password` | `VARCHAR(255)` | NOT NULL. Hash da senha. |
| `created_at` | `TIMESTAMP` | DEFAULT NOW(). Data de criação. |
| `updated_at` | `TIMESTAMP` | DEFAULT NOW(). Data da última atualização. |

### Tabela LISTS (Listas)

| Campo | Tipo | Restrições/Notas |
| :--- | :--- | :--- |
| `id` | `UUID` | PK. Identificador único da lista. |
| `user_id` | `UUID` | FK (USERS). Cada lista pertence a um usuário [1]. |
| `name` | `VARCHAR(255)` | NOT NULL. Nome da lista (contêiner organizacional) [1]. |
| `color` | `VARCHAR(50)` | Cor da lista (opcional). |
| `created_at` | `TIMESTAMP` | DEFAULT NOW(). Data de criação. |
| `updated_at` | `TIMESTAMP` | DEFAULT NOW(). Data da última atualização. |

### Tabela TASKS (Tarefas)

| Campo | Tipo | Restrições/Notas |
| :--- | :--- | :--- |
| `id` | `UUID` | PK. Identificador único da tarefa. |
| `list_id` | `UUID` | FK (LISTS). A tarefa pertence a uma lista [1]. |
| `user_id` | `UUID` | FK (USERS). A tarefa pertence a um usuário [1]. |
| `parent_task_id` | `UUID` | Usado para rastrear a instância original de tarefas recorrentes [2]. |
| `name` | `VARCHAR(255)` | NOT NULL. Nome da tarefa. |
| `description` | `TEXT` | Descrição detalhada (opcional). |
| `color` | `VARCHAR(50)` | Cor associada. |
| `file_url` | `VARCHAR(255)` | URL para arquivo anexado (opcional). |
| `start_date` | `TIMESTAMP` | Data de início da validade da tarefa [3, 5]. |
| `due_date` | `TIMESTAMP` | Data limite para conclusão [3, 5]. **Obrigatório se `is_recurring` é TRUE** [6]. |
| `is_recurring` | `BOOLEAN` | Indica se a tarefa é recorrente [2]. |
| `recurrence_type` | `ENUM("fixed_day", "interval")` | Tipo de recorrência [3]. Valores possíveis: `interval` (baseado em tempo) ou `fixed_day` (baseado em dia fixo). |
| `recurrence_interval` | `INTEGER` | Quantidade de unidades de tempo entre repetições (usado com `interval`) [3, 4]. |
| `recurrence_unit` | `ENUM("hour", "day", "week", "month")` | Unidade de tempo para a recorrência por intervalo [4]. |
| `recurrence_day` | `VARCHAR(50)` | Dia específico (do mês ou da semana) para repetição (usado com `fixed_day`) [4]. |
| `status` | `ENUM("expired", "done", "in progress")` | Status da tarefa [3]. Padrão ao criar: `in_progress` [7, 8]. |
| `completed_at` | `TIMESTAMP` | Momento em que a tarefa foi concluída [3, 9]. |
| `created_at` | `TIMESTAMP` | DEFAULT NOW(). Data de criação. |
| `updated_at` | `TIMESTAMP` | DEFAULT NOW(). Data da última atualização. |

### Tabela SUB_TASKS (Subtarefas)

| Campo | Tipo | Restrições/Notas |
| :--- | :--- | :--- |
| `id` | `UUID` | PK. Identificador único da subtarefa. |
| `task_id` | `UUID` | FK (TASKS). A subtarefa pertence à tarefa principal [1, 10]. |
| `name` | `VARCHAR(255)` | NOT NULL. Nome da subtarefa. |
| `status` | `ENUM("done", "in progress")` | Status próprio da subtarefa. Não possui status `expired` [11]. |
| `created_at` | `TIMESTAMP` | DEFAULT NOW(). Data de criação. |
| `updated_at` | `TIMESTAMP` | DEFAULT NOW(). Data da última atualização. |

### Tabela NOTIFICATIONS (Notificações)

| Campo | Tipo | Restrições/Notas |
| :--- | :--- | :--- |
| `id` | `UUID` | PK. Identificador único da notificação. |
| `task_id` | `UUID` | FK (TASKS). Chave da tarefa associada [12]. **Apenas uma notificação ativa por `task_id`** [13]. |
| `user_id` | `UUID` | FK (USERS). A notificação pertence ao usuário [12]. |
| `remind_at` | `TIMESTAMP` | Data e hora programada para o lembrete [3, 12]. |
| `sent_at` | `TIMESTAMP` | Data e hora em que a notificação foi disparada [13]. |
| `channel` | `ENUM("app", "email", "push")` | Canal de entrega da notificação. |
| `message` | `TEXT` | Conteúdo da notificação. |
| `created_at` | `TIMESTAMP` | DEFAULT NOW(). Data de criação. |
| `updated_at` | `TIMESTAMP` | DEFAULT NOW(). Data da última atualização. |