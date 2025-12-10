# AI Coding Agent Instructions

This is a **Rails 8 multiplayer card game application** (Basra - a traditional Middle Eastern card game). Use these instructions to be immediately productive.

## Architecture Overview

### Core Domain Model
- **Game**: Manages game state (deck, table cards, status, players). Uses JSON text fields for `deck_state` and `table_cards` (always convert with `.to_json` / `JSON.parse`). Auto-generates unique `room_code` via `SecureRandom.alphanumeric(6)` on create.
- **User**: Devise authentication; tracks stats via `wins_count` and `losses_count` methods. Includes `leaderboard` class method that aggregates wins/losses across all users.
- **Gameplayer**: Junction model linking User→Game with hand cards and score. Hand cards stored as JSON in `hand_cards` field. Uses `counter_cache: true` to update `Game.gameplayers_count`.
- **Move**: Records player actions; stores captured cards as JSON. `basra` boolean marks special capture (clearing all table cards). Note: `card_played` aliased to `card_player` field.
- **Invitation**: Pending game invites with token-based acceptance flow and `recipient_email` field.

### Game Rules Engine
**`lib/basra/engine.rb`** - Encapsulates all game logic:
- `apply_rules(table_cards, card_code)` → Returns `{captured_cards:, basra:}`. Core logic for card matching by rank or numeric sum.
- **Jack (J)**: Captures ALL table cards (no basra bonus).
- **7♦**: Captures all cards if total value equals 7 OR only one card on table (triggers basra bonus).
- Other cards: Match same rank OR disjoint sum combinations equaling card value using backtracking algorithm (`find_best_disjoint_sum_combos`).
- `deal_initial(game)` deals 4 cards to each player + 4 to table; shuffles J or 7♦ back into deck if drawn to table initially.
- `deal_next_hand(game)` deals next 4 cards to players when hands empty.
- Card notation: `"<RANK><SUIT>"` e.g., `"2H"`, `"KD"`, `"AC"` (Suits: H/D/C/S, Ranks: A/2-10/J/Q/K).

### Game Flow Logic
**Turn-based play** managed in `MovesController#create`:
1. Validates player's turn via `game.current_player_id` check.
2. Removes played card from `gameplayer.hand_cards_array`.
3. Calls `Basra::Engine.apply_rules` to determine captures.
4. If captures: removes from table; if none: adds played card to table.
5. Creates `Move` record with `captured_cards` JSON and `basra` boolean.
6. Advances `game.current_player_id` to next player (circular via seat_number).
7. When all hands empty AND deck empty: triggers round-end scoring (card majorities, basra bonuses).

## Developer Workflows

### Start Development
```bash
bin/server       # Kills existing port 3000, starts Rails server on 0.0.0.0:3000
bin/dev          # Alternative dev server (via gem 'dev_toolbar')
```

### Run Tests
```bash
bundle exec rspec spec/         # Full test suite (RSpec + Capybara integration tests)
```
Test files in `spec/features/` use Capybara with headless Chrome (`spec/support/headless_chrome.rb`). No factories—use `Model.create!` directly.

### Database
- **Adapter**: PostgreSQL (via `DATABASE_URL` env var)
- **Migrations**: `db/migrate/` - always run pending: `rails db:migrate`
- **Schema**: Auto-generated in `db/schema.rb` - never edit directly
- **Solid Stack**: Uses Solid Cable, Solid Cache, Solid Queue (Rails 8 defaults)

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

**Never** access raw JSON fields directly—always use `*_array` methods to avoid parsing errors.

### Route Convention
Routes use **explicit hash syntax** (NOT RESTful resources):
```ruby
get("/path", { controller: "games", action: "show" })
post("/insert_move", { controller: "moves", action: "create" })
```
Match this pattern when adding routes. All routes manually defined in `config/routes.rb`.

### View Organization
- `app/views/game_templates/` - Game play views (index, show, join, winner)
- `app/views/home_templates/` - Home & onboarding
- ERB templates; minimal JavaScript (standard Rails Turbo/Stimulus, no custom disable)

### Authentication & Authorization
- Devise handles user auth (email + password via standard flows)
- Auth checks in controllers: `if current_user.nil? → redirect_to("/new_user", { alert: "..." })`
- Games track creator via `creator_id` and current player via `current_player_id`
- No pundit/authorization gem—manual checks in controllers

### Real-Time Communication
- **Action Cable**: `GameChannel` streams game updates to subscribed clients
- Subscription logic: `stream_for game` in `subscribed` callback (game_id from params)
- Used for multiplayer synchronization (move broadcasts to all players in game)
- Broadcast pattern: `GameChannel.broadcast_to(game, { message: "..." })` from controllers

### Generators Disabled
`config/application.rb` disables: tests, factories, stylesheets, helpers, JS, system tests. When scaffolding, models only.

### AppDev Ecosystem
- Uses `appdev_support` gem with `action_dispatch: true`, `active_record: true`, `pryrc: :minimal`
- `grade_runner` gem for automated grading (dev/test only)
- `draft_generators` from GitHub (branch: bp-summer-2025-update)
- Many AppDev gems: `ai-chat`, `active_link_to`, `simple_form`, `ransack`, `pagy`, etc.

## Key File References

| File | Purpose |
|------|---------|
| `app/controllers/moves_controller.rb` | Core game logic; calls `Basra::Engine.apply_rules`; handles turn validation and round-end scoring |
| `app/controllers/games_controller.rb` | Game CRUD; initial deck setup via `initial_deck.to_json` |
| `lib/basra/engine.rb` | Card matching rules; deck management; backtracking algorithm for disjoint sum combos |
| `config/routes.rb` | All route definitions (explicit hash style, not resources) |
| `spec/rails_helper.rb` | RSpec + Capybara setup; Chrome headless browser via Selenium |
| `app/models/user.rb` | Devise auth; `wins_count`, `losses_count`, `leaderboard` methods |
| `app/channels/game_channel.rb` | Action Cable subscription for real-time game updates |

## Common Modifications

### Adding a Game Rule
1. Implement logic in `Basra::Engine` (e.g., new card behavior in `apply_rules`)
2. Call from `MovesController#create` (uses existing `apply_rules` pattern)
3. Update `Move` model if new field required (add migration, update schema)
4. Test with direct model creation (`Move.create!(...)`) in specs

### Adding User Stats
1. Add method to `User` model (see `losses_count` for SQL join pattern)
2. Call from view templates (`<%= current_user.wins_count %>`)
3. Update leaderboard if needed (`User.leaderboard` returns sorted array of hashes)

### Real-Time Game Updates
1. Add public method to `Game` model for state changes
2. Broadcast from controller: `GameChannel.broadcast_to(@game, { type: "update", data: {...} })`
3. Clients auto-subscribe to `game_id` channel (see `game_channel.rb`)

## Notes for AI Agents

- **No factory_bot**: Use direct model creation (`Model.create!(...)`) in specs—factory gem disabled
- **Database-first**: Prefer model methods over controller logic (see `User.leaderboard`, `User#wins_count`)
- **Explicit routes**: Always use `controller:`/`action:` hash style, not resource routing
- **JSON serialization**: Never access `game.deck_state` directly—use `game.deck_state_array`
- **Move field alias**: `Move#card_played` reads from `card_player` column (schema inconsistency)
- **AppDev patterns**: Follows AppDev curriculum conventions (explicit routes, minimal JS, model-focused)
