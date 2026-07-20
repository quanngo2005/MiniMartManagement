````markdown
# MiniMart — AGENT.md

> **Ponytail principle**: Think like the laziest senior dev in the room.
> The best code is the code you never wrote.
> Before adding anything — check if it already exists. Before inventing a pattern — find the existing one and clone it.

---

## Project Overview

Two separate repositories communicating via REST API with JWT authentication:

| Repo | Stack | Role |
|------|-------|------|
| `MiniMart` | ASP.NET 8 Web API | Backend — business logic, data, auth |
| `mini_mart_management_mobile_app` | Flutter | Frontend — mobile management app |

**Auth**: JWT issued by backend, stored and sent by Flutter on every authenticated request.

---

## 🦴 Ponytail Rules (Read This First)

1. **Search before creating** — use graph tools or grep before writing any new class, service, or widget
2. **Clone the existing pattern** — every layer has conventions; find one and follow it exactly
3. **No gold-plating** — implement what was asked, nothing more
4. **DTOs already exist** — check `Dtos/` before defining any new response shape
5. **One change at a time** — don't refactor while fixing a bug; don't rename while adding a feature
6. **If you're unsure about project structure, ask** — don't guess and scaffold

---

## 🗺️ Code Review Graph (MCP Tools)

**ALWAYS use graph tools before Grep/Glob/Read — faster, cheaper (fewer tokens), and gives structural context file scanning cannot.**

| Tool | Use when |
|------|----------|
| `semantic_search_nodes` | Finding functions/classes by name or keyword |
| `query_graph` | Tracing callers, callees, imports, tests, dependencies |
| `detect_changes` | Reviewing code changes — gives risk-scored analysis |
| `get_review_context` | Need source snippets — token-efficient |
| `get_impact_radius` | Understanding blast radius of a change |
| `get_affected_flows` | Finding which execution paths are impacted |
| `get_architecture_overview` | High-level codebase structure |
| `refactor_tool` | Planning renames, finding dead code |

**Workflow for every code review:**
1. `detect_changes` → risk-scored diff overview
2. `get_affected_flows` → understand execution path impact
3. `query_graph` pattern=`tests_for` → check coverage
4. Fall back to Grep/Glob/Read **only** if graph doesn't cover what you need

---

## 🖥️ Backend — MiniMart (ASP.NET 8)

### Architecture: N-Layer + Repository Pattern

```
Controllers/         → thin HTTP layer only — no business logic
Services/            → business logic; depends on IRepository, never on DbContext directly
Repositories/
  Interfaces/        → IRepository<T> contracts
  Implementations/   → EF Core queries only — no raw SQL unless unavoidable
Data/                → DbContext, seed data, entity configurations
Models/
  Base/              → base entity (Id, timestamps, soft-delete if used)
  Enums/             → shared enums — add here, not inline
Dtos/                → request/response shapes — NEVER return raw Model entities
Mapping/             → AutoMapper profiles — never map manually if AutoMapper covers it
Middleware/          → global error handling, logging, request pipeline
Shared/
  Authorization/     → JWT policies, role requirements — add policies here only
  Exceptions/        → custom exception types — throw here, caught by Middleware
  Extensions/        → IServiceCollection / IApplicationBuilder extension methods
  Settings/          → strongly-typed config (IOptions<T>) — no IConfiguration["key"] inline
```

### Conventions

- **Controllers**: `[Authorize]` by default unless explicitly public. Route: `api/[controller]`. Return `ActionResult<ResponseDto>`.
- **Services**: depend only on `IRepository<T>` interfaces, never `DbContext`.
- **Repositories**: EF Core queries only. No business logic, no HTTP concerns.
- **Exceptions**: defined in `Shared/Exceptions/`, thrown from Services, caught globally by Middleware. No `try/catch` in Controllers.
- **DTOs**: `CreateDto`, `UpdateDto`, `ResponseDto` per entity. Check `Dtos/` before adding a new one.
- **Mapping**: add profiles to `Mapping/`. Never `new ResponseDto { Prop = entity.Prop }` by hand.
- **Auth**: roles/policies defined in `Shared/Authorization/`. Don't define new policies inline in Controllers.
- **Config**: new settings → `Shared/Settings/` as `IOptions<T>`, registered in an extension in `Shared/Extensions/`.

### Adding a feature — Backend checklist

- [ ] Model in `Models/` (inherit base entity if it has Id/timestamps)
- [ ] Migration: `dotnet ef migrations add <DescriptiveName>`
- [ ] Interface in `Repositories/Interfaces/`
- [ ] Implementation in `Repositories/Implementations/`
- [ ] Service in `Services/`
- [ ] DTOs in `Dtos/` (Create, Update, Response as needed)
- [ ] Mapping profile in `Mapping/`
- [ ] Controller in `Controllers/`
- [ ] Register via extension in `Shared/Extensions/` — not scattered in `Program.cs`

### Mandatory Rules: Repository Pattern & Dependency Injection (DI)

**Repository Pattern**:
- **Strict adherence**: All data access **MUST** go through `IRepository<T>` interfaces and their implementations. 
- No direct `DbContext` usage outside `Repositories/Implementations/`.
- Services **never** query the database directly — they only call repository methods.
- Every entity must have its corresponding `IRepository<T>` if it needs persistence.
- Use generic `IRepository<T>` where possible; create specific methods in interfaces only when needed (e.g., `IProductRepository : IRepository<Product>`).
- Query logic stays in repositories — no business rules or complex joins in Services that should be repository methods.

**Dependency Injection (DI)**:
- **Always use constructor injection** for all dependencies (Repositories into Services, Services into Controllers).
- Register all services, repositories, and other components using extensions in `Shared/Extensions/` (e.g., `AddRepositories()`, `AddServices()`).
- Never use `new` keyword for instantiating services/repositories in production code (except for DTOs or simple value objects).
- Use `IServiceCollection` extensions for proper lifetime management (Scoped for Repositories/Services, Singleton for caches/config, Transient where appropriate).
- Controllers should only depend on Services via DI — no manual instantiation.
- Follow ASP.NET Core built-in DI container best practices. Avoid third-party containers unless already in the project.

**Violation Consequences**:
- Direct DbContext access or manual `new` = immediate refactor required.
- Always verify with `query_graph` that dependencies flow correctly through DI.

---

## 📱 Flutter App — mini_mart_management_mobile_app

### Architecture: Provider + Repository Pattern

```
lib/
  config/       → base URL, environment constants, router/routes — no hardcoded URLs elsewhere
  core/         → base classes, utilities, shared logic, error handling
  models/       → Dart model classes that mirror backend DTOs exactly
  services/     → HTTP layer (Dio/http) — sends requests, attaches JWT, returns raw data
  repositories/ → calls services, parses responses, throws typed exceptions — no HTTP code
  providers/    → state management (ChangeNotifier/Provider) — calls repositories, holds UI state
  screens/      → full pages/routes — consume providers only, no direct service calls
  widgets/      → reusable UI components — stateless where possible
  assets/       → images, fonts, icons
```

### Conventions

- **Models**: mirror backend DTOs exactly. If a backend DTO changes, update the Flutter model in the same change.
- **Services**: only HTTP calls + JWT header attachment. No business logic, no state.
- **Repositories**: call services, parse/validate responses, throw typed exceptions from `core/`. No HTTP code.
- **Providers**: call repositories, expose state + loading/error flags. No HTTP calls.
- **Screens**: `context.watch` / `Consumer` only. No business logic, no service calls, no raw HTTP.
- **Widgets**: accept typed parameters — never raw `Map<String, dynamic>`.

### JWT Flow

1. Login → `services/` POSTs credentials → backend returns token
2. Token persisted securely (FlutterSecureStorage preferred over plain SharedPreferences)
3. Every authenticated request: service layer reads token, adds `Authorization: Bearer <token>` header
4. On 401 response → clear stored token, redirect to login screen

### Adding a feature — Flutter checklist

- [ ] Model in `models/` matching backend DTO
- [ ] Method in `services/` for the HTTP call
- [ ] Method in `repositories/` calling the service
- [ ] Provider in `providers/` exposing state + loading/error
- [ ] Screen in `screens/` consuming the provider
- [ ] Reusable UI pieces extracted to `widgets/`
- [ ] Route registered in `config/`

---

## 🎨 Flutter — Coding Rules & Component Reuse

> **Ponytail**: Before writing a widget, open `widgets/` and look for 30 seconds. Most of the time, it already exists.

### 1. When to Extract a Widget

Extract immediately when **any** of these are true:

| Condition | Action |
|-----------|--------|
| A UI block appears more than once | Extract to `widgets/` |
| A widget subtree exceeds ~40–50 lines | Extract to a private method or new file |
| A subtree has its own independent state | Extract to its own `StatefulWidget` |
| A widget is used across more than one screen | Move to `widgets/` (not inline in a screen file) |
| A `Column`/`Row` child is getting deeply nested | Extract the child |

**The smell test**: if you're scrolling to find where a widget ends, it needs to be extracted.

---

### 2. Widget File & Naming Conventions

```
widgets/
  buttons/
    primary_button.dart        → PrimaryButton
    secondary_button.dart      → SecondaryButton
    icon_action_button.dart    → IconActionButton
  cards/
    product_card.dart          → ProductCard
    order_summary_card.dart    → OrderSummaryCard
  inputs/
    labeled_text_field.dart    → LabeledTextField
    search_bar.dart            → AppSearchBar
  feedback/
    loading_overlay.dart       → LoadingOverlay
    error_banner.dart          → ErrorBanner
    empty_state.dart           → EmptyState
  layout/
    section_header.dart        → SectionHeader
    divider_with_label.dart    → DividerWithLabel
```

**Naming rules:**
- Widget class: `PascalCase` + descriptive suffix (`Card`, `Button`, `Sheet`, `Dialog`, `List`, `Tile`, `Banner`)
- File: `snake_case` matching the class name exactly
- Private helpers inside a screen: prefix with `_` (`_buildHeaderSection`)

---

### 3. Widget Design — Typed, Explicit, Composable

**✅ Do — typed required parameters:**
```dart
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showStock = true,
  });

  final Product product;
  final VoidCallback onTap;
  final bool showStock;

  @override
  Widget build(BuildContext context) { ... }
}
```

**❌ Don't — raw Map, dynamic, or too many primitives:**
```dart
// Bad: caller has no idea what keys are valid
ProductCard(data: {'name': ..., 'price': ...})

// Bad: 6 loose primitives instead of a model
ProductCard(name: n, price: p, stock: s, image: img, id: id, category: c)
```

**Rules:**
- Always pass a typed model instead of multiple primitive fields
- `required` for data the widget cannot function without
- `this.x = defaultValue` for optional presentation toggles
- Every widget with a `const`-capable constructor **must** have `const ProductCard({super.key, ...})`
- Never accept `Map<String, dynamic>` as a parameter

---

### 4. Stateless vs Stateful — Default to Stateless

```dart
// ✅ Stateless: no internal mutable state
class OrderStatusBadge extends StatelessWidget { ... }

// ✅ Stateful only when the widget owns its own ephemeral UI state
// (e.g. text field focus, local toggle, animation controller)
class QuantitySelector extends StatefulWidget { ... }
```

**Never make a widget Stateful just to call a Provider** — use `context.watch` or `Consumer` inside a `StatelessWidget`.

---

### 5. Provider Consumption — Use the Right Method

```dart
// context.watch — rebuild on every change (use inside build())
final products = context.watch<ProductProvider>().products;

// context.read — one-time read, no rebuild (use in callbacks/handlers)
onPressed: () => context.read<CartProvider>().add(product),

// context.select — rebuild only when the selected value changes (prefer for performance)
final isLoading = context.select<ProductProvider, bool>((p) => p.isLoading);

// Consumer — when only part of the tree should rebuild
Consumer<ProductProvider>(
  builder: (context, provider, child) => Text(provider.count.toString()),
  child: ExpensiveStaticWidget(), // not rebuilt
)
```

**Rule**: always prefer `context.select` over `context.watch` when you only need one field from a large provider.

---

### 6. Styling — Never Hardcode, Always Use Theme

```dart
// ✅ Theme-aware
Text(
  'Total',
  style: Theme.of(context).textTheme.titleMedium,
)
Container(
  color: Theme.of(context).colorScheme.primary,
)

// ✅ Named style from theme extension or constants in core/
Text('Label', style: AppTextStyles.label)

// ❌ Never hardcode colors or text styles inline
Text('Total', style: TextStyle(fontSize: 16, color: Color(0xFF333333)))
Container(color: Colors.blue)
```

**Where styles live:**
- Color palette → `core/` or theme definition in `config/`
- Text styles → `ThemeData.textTheme` or a `AppTextStyles` constants class in `core/`
- Spacing → constants in `core/` (e.g. `AppSpacing.md = 16.0`) — no magic numbers

---

### 7. Layout — Prefer Specific over Generic

```dart
// ✅ SizedBox for spacing — clear intent
const SizedBox(height: 16)
const SizedBox(width: 8)

// ✅ Padding widget for padding
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: content,
)

// ❌ Container for spacing or padding only — too heavy
Container(height: 16)
Container(padding: EdgeInsets.all(8), child: ...)

// ✅ const wherever the subtree is static
const Icon(Icons.check, color: Colors.green)
const SizedBox(height: 24)
```

**Layout rules:**
- `SizedBox` for gaps and fixed sizes, `Padding` for padding — not `Container`
- `Expanded` and `Flexible` inside `Row`/`Column`, never fixed widths for fluid layouts
- `ListView.builder` for any list — never `Column` with `.map()` for scrollable content
- `const` on every widget and constructor where possible — the analyzer will warn you

---

### 8. Loading / Error / Empty — Reuse the Standard Widgets

Every async list or data screen follows this exact pattern:

```dart
@override
Widget build(BuildContext context) {
  final provider = context.watch<ProductProvider>();

  if (provider.isLoading) return const LoadingOverlay();
  if (provider.error != null) return ErrorBanner(message: provider.error!);
  if (provider.items.isEmpty) return const EmptyState(message: 'No products found');

  return ListView.builder(
    itemCount: provider.items.length,
    itemBuilder: (_, i) => ProductCard(product: provider.items[i]),
  );
}
```

- `LoadingOverlay`, `ErrorBanner`, `EmptyState` live in `widgets/feedback/`
- Never inline a `CircularProgressIndicator` or error `Text` in a screen — use these widgets
- If a feedback widget doesn't exist yet, create it in `widgets/feedback/` before using it

---

### 9. Screen Structure — Consistent Skeleton

Every screen file follows this order:

```dart
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),     // 1. AppBar
      body: _buildBody(context),         // 2. Body (main content)
      floatingActionButton: _buildFab(), // 3. FAB if needed
    );
  }

  // Private builder methods — each returns a Widget
  PreferredSizeWidget _buildAppBar(BuildContext context) { ... }

  Widget _buildBody(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    if (provider.isLoading) return const LoadingOverlay();
    if (provider.error != null) return ErrorBanner(message: provider.error!);
    return _buildList(provider.products);
  }

  Widget _buildList(List<Product> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    );
  }

  Widget _buildFab() { ... }
}
```

**Rules:**
- Each screen has **one** `build()` method — complexity goes into private `_build*` methods or extracted widgets
- Private builder methods are acceptable for screen-specific UI that won't be reused
- If a `_build*` method would be useful in another screen → promote it to `widgets/`
- Screens do not have `Column` with 200 lines of children — break it up
- After code, run only `dart format lib` and `dart analyze lib` for verify
---

### 10. Reuse Checklist — Before Writing Any Widget

- [ ] Check `widgets/` — does something similar already exist?
- [ ] Check the screen files — is it already extracted somewhere nearby?
- [ ] Run `semantic_search_nodes` with the widget concept (e.g. "card", "button", "badge")
- [ ] If reusing: pass it typed params, don't copy-paste and modify
- [ ] If creating new: put it in the right `widgets/` subfolder, make the constructor `const`, accept a typed model

---

## 🔌 API Contract

- Backend base URL lives in `lib/config/` — **never hardcoded** in any screen or service
- All endpoints follow `/api/[controller]` prefix
- Auth header: `Authorization: Bearer <jwt_token>`
- Standard response shape: check existing service methods before assuming envelope format
- If backend changes an endpoint or DTO → Flutter model + service must be updated in the same branch

---

## ❌ Never Do These

**Backend**
- Call `DbContext` directly from a Controller or Service
- Return raw `Model` entities from Controllers — always use DTOs
- Define policies or roles inline in `[Authorize]` attributes — use `Shared/Authorization/`
- Add new config keys as `IConfiguration["raw.key"]` inline — use `IOptions<T>`
- Create a new exception type if a fitting one exists in `Shared/Exceptions/`
- Map DTOs by hand if AutoMapper covers it
- Instantiate services/repositories with `new` keyword

**Flutter**
- Hardcode the API URL anywhere outside `lib/config/`
- Call HTTP services from Screens or Widgets
- Put business logic inside Providers — it belongs in Repositories or Services
- Store sensitive tokens in plain SharedPreferences without encryption
- Duplicate a model instead of referencing the existing one

---

## When in Doubt

- **Unsure about existing patterns?** → run `semantic_search_nodes` or `query_graph` first
- **Unsure about project structure?** → ask before scaffolding anything
- **Something already exists that almost fits?** → adapt it, don't duplicate it
````

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **MiniMartManagement** (4847 symbols, 11485 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/MiniMartManagement/context` | Codebase overview, check index freshness |
| `gitnexus://repo/MiniMartManagement/clusters` | All functional areas |
| `gitnexus://repo/MiniMartManagement/processes` | All execution flows |
| `gitnexus://repo/MiniMartManagement/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
