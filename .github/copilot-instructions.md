# AI Coding Agent Instructions

This is a **Rails 8 multiplayer card game application** (Basra - a traditional Middle Eastern card game). Use these instructions to be immediately productive.

## Architecture Overview

### Core Domain Model
- **Game**: Manages game state (deck, table cards, status, players). Uses JSON text fields for `deck_state` and `table_cards` (always convert with `.to_json` / `JSON.parse`).
- **User**: Devise authentication; tracks stats via `wins_count` and `losses_count` methods.
- **Gameplayer**: Junction model linking User→Game with hand cards and score. Hand cards stored as JSON in `hand_cards` field.
- **Move**: Records player actions; stores captured cards as JSON. `basra` boolean marks special capture (all table cards).
- **Invitation**: Pending game invites with token-based acceptance flow.

### Game Rules Engine
**`lib/basra/engine.rb`** - Encapsulates all game logic:
- `apply_rules(table_cards, card_code)` → Returns `{captured_cards:, basra:}`. Core logic for card matching by rank or numeric sum.
- **Jack (J)**: Clears nothing; special behavior.
- **7♦**: Captures all cards if total value equals 7 OR only one card on table (triggers basra bonus).
- Other cards: Match same rank OR disjoint sum combinations equaling card value.
- `deal_initial(game)` & `deal_next_hand(game)`: Manages deck distribution.

## Developer Workflows

### Start Development
```bash
bin/server       # Rails server on port 3000
bin/dev          # Alternative dev server
```

### Run Tests
```bash
bundle exec rspec spec/         # Full test suite (RSpec + Capybara integration tests)
```

### Database
- **Adapter**: PostgreSQL (via `DATABASE_URL` env var)
- **Migrations**: `db/migrate/` - always run pending: `rails db:migrate`
- **Schema**: Auto-generated in `db/schema.rb` - never edit directly

### Code Quality
```bash
bin/rubocop      # Omakase style checks (Rails opinionated config)
bin/brakeman     # Security scanning
```

## Critical Patterns & Conventions

### JSON Field Serialization
**Always use helper methods** - models define `*_array` accessors:
```ruby
game.table_cards_array = ["2H", "3D"]  # Converts to JSON
table = game.table_cards_array         # Parses JSON back to array
```
Affected fields: `Game.deck_state`, `Game.table_cards`, `Gameplayer.hand_cards`, `Move.captured_cards`.

### Route Convention
Routes use explicit style: `get("/path", {controller:, action:})` not RESTful resources. Match this pattern when adding routes.

### View Organization
- `app/views/game_templates/` - Game play views (index, show, join, winner)
- `app/views/home_templates/` - Home & onboarding
- Use ERB templates; minimal JavaScript (Turbo disabled by default: `Turbo.session.drive = false`)

### Authentication & Authorization
- Devise handles user auth (email + password)
- Checks in controllers: `if current_user.nil? → redirect_to("/new_user")`
- Games track creator via `creator_id` and current player via `current_player_id`

### Real-Time Communication
- **Action Cable**: `GameChannel` streams game updates to subscribed clients
- Subscription logic: `stream_for game` in `subscribed` callback (game_id param-based)
- Used for multiplayer synchronization (move broadcasts)

### Generators Disabled
`config/application.rb` disables: tests, factories, stylesheets, helpers, JS, system tests. When scaffolding, models only.

## Key File References

| File | Purpose |
|------|---------|
| `app/controllers/moves_controller.rb` | Core game logic; calls `Basra::Engine.apply_rules` |
| `app/controllers/games_controller.rb` | Game CRUD; initial deck setup |
| `lib/basra/engine.rb` | Card matching rules; deck management |
| `config/routes.rb` | All route definitions (explicit style) |
| `spec/rails_helper.rb` | RSpec + Capybara setup; Chrome headless browser |

## Common Modifications

### Adding a Game Rule
1. Implement logic in `Basra::Engine`
2. Call from `MovesController#create` (test with existing `apply_rules` calls)
3. Update `Move` model if new field required (use migration)

### Adding User Stats
1. Add method to `User` model (e.g., `losses_count` as reference)
2. Call from view templates or leaderboard endpoints
3. Test with database fixtures

### Real-Time Game Updates
1. Add public method to `Game` model if state changes
2. Broadcast via `GameChannel.broadcast_to(game, message:)` from controller
3. Subscribe clients to `game_id` in channel

## Notes for AI Agents

- **No factory_bot**: Use direct model creation (`Model.create!`) in specs
- **Minimal CSS**: Focus on logic; styling is secondary
- **Database-first**: Prefer model methods over controller logic
- **Explicit routes**: Always use controller/action style, not resource routing
