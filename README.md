# RGA Dashboard

A Flutter dashboard application implementing Clean Architecture, reactive state management, and Atomic Design.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Running Tests](#running-tests)
- [AI Workflow](#ai-workflow)

---

## Architecture Overview

This application implements **Clean Architecture** with strict layer separation, ensuring testability, maintainability, and independence from external frameworks.

### Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    Pages    │  │   Widgets   │  │   State Management  │  │
│  │  (Screens)  │  │ (Components)│  │    (Business UI)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │ depends on
┌────────────────────────────▼────────────────────────────────┐
│                      Domain Layer                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Entities   │  │  Use Cases  │  │ Repository Contracts│  │
│  │   (Models)  │  │  (Actions)  │  │    (Interfaces)     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │ depends on
┌────────────────────────────▼────────────────────────────────┐
│                       Data Layer                            │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────────┐ │
│  │   Models    │  │ Data Sources │  │ Repository Impls    │ │
│  │  (DTOs)     │  │(Local/Remote)│  │  (Concrete)         │ │
│  └─────────────┘  └──────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Principles

| Principle | Implementation |
|-----------|----------------|
| **Dependency Inversion** | Domain layer defines interfaces; Data layer implements them |
| **Single Responsibility** | Each use case handles exactly one business operation |
| **Separation of Concerns** | UI logic in state managers, business logic in use cases, data access in repositories |
| **Immutability** | All entities and state objects are immutable |
| **Type Safety** | Sealed classes for exhaustive pattern matching on results and states |

---

## Project Structure

```
lib/
├── core/
│   ├── database/              # SQLite configuration
│   ├── error/                 # Exception definitions
│   ├── ui/                    # Atoms, Molecules, Organisms, Theme
│   ├── result/                # Result<T> type (Success/Failure)
│   └── usecases/              # Base use case contracts
│
├── features/{feature_name}/   # auth, dashboard
│   ├── data/                  # Models, data sources, repository impl
│   ├── domain/                # Entities, repository contract, use cases
│   └── presentation/          # Cubit, states, pages, widgets
│
└── dependency_injection.dart  # Dependency injection (GetIt)
```

---

## Getting Started

```bash
flutter pub get
flutter run
```

**Test Credentials:** `test@example.com` / `password123`

---

## Running Tests

```bash
flutter test                  # All tests
flutter test --coverage       # With coverage report
```

---

## AI Workflow

This section documents key architectural decisions made during development, providing rationale for technology and pattern choices.

### Prompt #1: Clean Architecture & Layered Structure

**Context:** The application needs a scalable architecture that separates business logic from UI concerns, enabling independent testing and future modifications without cascading changes.

**Decision:** Implement Clean Architecture with three distinct layers (Presentation, Domain, Data) where dependencies point inward. Business logic resides in the Domain layer through Use Cases, completely decoupled from UI and framework-specific code.

**Rationale:**
- Business logic remains testable without UI framework dependencies
- Each layer has a single responsibility and clear boundaries
- Domain layer defines interfaces; outer layers provide implementations
- Supports future platform expansion (web, desktop) without rewriting core logic

**Consequences:** All features follow the layered structure with entities, use cases, and repository contracts in Domain; DTOs, data sources, and repository implementations in Data; and state management with UI components in Presentation.

---

### Prompt #2: BLoC Pattern with Cubit

**Context:** The application requires reactive UI updates based on asynchronous operations with support for loading, success, and error states.

**Decision:** Implement state management using the BLoC pattern with Cubit, a lightweight variant that uses method-based actions rather than event streams. States are immutable classes extending Equatable for predictable rebuilds.

**Rationale:**
- Cubit reduces boilerplate compared to full BLoC event-driven approach
- Direct method calls provide better IDE support (autocomplete, refactoring)
- Immutable states with `copyWith` ensure predictable state transitions
- Built-in support for `BlocBuilder`, `BlocListener`, and `BlocSelector` for fine-grained UI updates

**Consequences:** Business logic validation moved to Cubit layer, keeping UI components stateless and focused on rendering. All state transitions are traceable and testable.

---

### Prompt #3: Core Features Implementation

**Context:** The application requires two core features with specific architectural and persistence requirements.

**Decision:** Implement both features following Clean Architecture:

**A. The Login Screen (Simulated Auth)**
- Implement a Login page with simulated asynchronous authentication (add a fake delay of 1-2 seconds)
- Architecture: Use a proper Repository pattern to abstract the authentication logic
- Error Handling: Handle timeouts or "wrong password" errors gracefully with proper UI feedback (snackbar notifications)
- Persistence: The user session should persist. If the app restarts after logging in, it should go straight to the Home page

**B. The Homepage (Persistent Movable Widgets)**
- The Dashboard: Render a grid or list of "Smart Widgets" (e.g., Weather Card, Stock Ticker, News Summary, Calendar, Quick Notes)
- Interaction: Users must be able to drag and drop to reorder these widgets
- Persistence: The new order of the widgets must be saved locally using SQLite. If the list is reordered and the app restarts, the order must be preserved
- AI Requirement: Use AI to generate the boilerplate for the widget models and the card layout logic

**Rationale:**
- Simulated delay provides realistic async UX without backend dependency
- Repository abstraction enables easy swap to real API in production
- SQLite chosen over SharedPreferences for relational data and complex queries
- `ReorderableListView` provides native Flutter drag-and-drop with minimal custom code

**Consequences:** `AuthCubit` manages login state with `checkAuthStatus()` on app launch to restore sessions. `DashboardCubit` loads widgets in persisted order and saves new order on every reorder action. Test credentials: `test@example.com` / `password123`.

---

### Prompt #4: Responsive Drag-and-Drop Reordering

**Context:** Drag-and-drop reordering requires immediate visual feedback; waiting for persistence creates perceptible lag that degrades user experience.

**Decision:** Implement optimistic UI updates where state changes are emitted immediately upon user action, then persisted asynchronously. If persistence fails, state reverts to the original order.

**Rationale:**
- Maintains 60fps interaction responsiveness during drag operations
- Aligns with user expectations from native applications
- Failure case (revert) is rare and acceptable trade-off
- Provides instant feedback while ensuring data consistency

**Consequences:** State management must track both optimistic state and original state for potential rollback. The `DashboardCubit` emits a `reordering` state before async persistence completes.

---

### Prompt #5: Repository Pattern with Local & Remote Data Sources

**Context:** Data access logic needs abstraction to support testing, and the application requires both persistent local storage and remote data fetching capabilities.

**Decision:** Define repository interfaces in the Domain layer; implement concrete repositories in the Data layer with two types of data sources:

**A. Local Data Sources**
- **sqflite**: SQLite database for relational data (widget order, complex configurations)
- **SharedPreferences**: Key-value storage for simple data (user session, preferences)

**B. Remote Data Sources**
- **Mock JSON Asset Files**: JSON files in `assets/` directory simulating backend API responses for dashboard data (weather, stocks, news, calendar events)
- Enables development without a live backend while maintaining realistic data structures

**Rationale:**
- Domain layer remains independent of storage mechanism (SQLite, SharedPreferences, API)
- Easy substitution of mock repositories for testing without database setup
- sqflite provides reliable, transactional local storage with SQL query support
- SharedPreferences offers lightweight persistence for simple key-value data
- Mock JSON assets simulate real API responses, enabling seamless transition to actual backend
- Repository abstraction allows future migration to different storage solutions

**Consequences:** `DatabaseHelper` manages SQLite connections and schema. Each feature has local data sources for persistence and remote data sources that read from JSON asset files, with repositories orchestrating data flow between domain entities and data models.

---

### Prompt #6: Design System with Atomic Design & Centralized Theming

**Context:** UI components need consistent styling and behavior across the application while remaining maintainable and reusable. Direct usage of color constants throughout the codebase leads to inconsistency.

**Decision:** Organize presentation components following Atomic Design principles (atoms, molecules, organisms) with a centralized `AppColors` class for all color definitions. Components are exported through a single `ui.dart` barrel file.

**Rationale:**
- Clear hierarchy of component complexity (atoms → molecules → organisms)
- Single source of truth for color palette with semantic naming
- Promotes composition over inheritance for UI building
- Simplifies theme customization and future dark mode support
- Enables independent component testing

**Consequences:** All UI elements use design system components and `AppColors`. Direct color constant usage is prohibited in feature widgets, enforced through code review.

---

### Prompt #7: Type-Safe Widget Data

**Context:** Dashboard widgets have different data requirements (weather needs temperature, stocks need price changes, etc.).

**Decision:** Use sealed classes for widget data types with exhaustive pattern matching.

**Rationale:**
- Compile-time verification of data handling for all widget types
- Self-documenting data requirements per widget type
- IDE support for handling all cases
- Prevents runtime type errors

**Consequences:** Adding new widget types requires updating switch expressions, but compiler ensures completeness.

---

### Prompt #8: Testing Strategy with Mocked Dependencies

**Context:** The application requires comprehensive test coverage for business logic, state management, and UI components without depending on real databases or external services.

**Decision:** Implement unit tests using mocktail for dependency mocking and bloc_test for Cubit state verification. Mock implementations replace repositories and use cases during testing, with predefined test data for consistent assertions.

**Rationale:**
- Mocktail provides simple, type-safe mocking without code generation
- bloc_test enables declarative testing of state sequences with `expect()` lists
- Mock data ensures deterministic test results independent of database state
- Tests run fast without I/O operations or network calls

**Consequences:** Each layer has dedicated tests: domain tests verify use case logic with mocked repositories, presentation tests verify Cubit state transitions with mocked use cases, and widget tests verify UI rendering with mocked Cubits.
