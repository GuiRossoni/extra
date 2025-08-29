# Controle de Gastos de Viagem (offline-first)

Protótipo Flutter com Shared Preferences e SQLite para controle de despesas durante viagens.

## Recursos
- Configurações (SharedPreferences): moeda padrão e limite diário persistentes.
- Despesas (SQLite): adicionar, listar, editar, exclusão com swipe (soft delete).
- Arquitetura preparada para sincronização futura com `updated_at` e `is_deleted`.
- Estratégia de conflito documentada em `desafio.txt`.

## Estrutura
- `lib/models/expense.dart`: modelo de dados.
- `lib/db/app_database.dart`: inicialização do SQLite.
- `lib/repositories/expense_repository.dart`: acesso aos dados.
- `lib/services/preferences_service.dart`: preferências do usuário.
- `lib/screens/expense_list_screen.dart`: lista de despesas.
- `lib/screens/settings_screen.dart`: configurações.
- `lib/widgets/expense_tile.dart`: item reutilizável da lista.

## Como executar
No PowerShell (Windows):

```powershell
flutter pub get; flutter run
```

Para rodar os testes:

```powershell
flutter test
```

## Notas
- Primeira execução pode criar o banco local `travel_expenses.db`.
- Alterar a moeda em Configurações atualiza a exibição dos valores.
- Criado por Anne e Guilherme.
