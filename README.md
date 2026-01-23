# RGA Dashboard

A Flutter application showcasing Clean Architecture principles, reactive state management, and a component-based design system.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Design System](#design-system)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Testing Strategy](#testing-strategy)
- [Architecture Decision Records](#architecture-decision-records)

---

## Architecture Overview

This application implements **Clean Architecture** with strict layer separation, ensuring testability, maintainability, and independence from external frameworks.

### Layer Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    Pages    │  │   Widgets   │  │   State Management  │  │
│  │  (Screens)  │  │ (Components)│  │    (Business UI)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │ depends on
┌────────────────────────────▼────────────────────────────────┐
│                      Domain Layer                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Entities   │  │  Use Cases  │  │ Repository Contracts │  │
│  │   (Models)  │  │  (Actions)  │  │    (Interfaces)     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │ depends on
┌────────────────────────────▼────────────────────────────────┐
│                       Data Layer                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Models    │  │ Data Sources│  │ Repository Impls    │  │
│  │  (DTOs)     │  │(Local/Remote)│  │  (Concrete)        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action → Page → State Manager → Use Case → Repository → Data Source
                ↑                                                  │
                └──────────── State Update ←───────────────────────┘
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

## Design System

The presentation layer implements **Atomic Design** methodology, providing a scalable component library.

### Component Hierarchy

| Level | Purpose | Components |
|-------|---------|------------|
| **Atoms** | Fundamental UI elements | `PrimaryButton`, `SecondaryButton`, `AppTextField`, `ThemedIcon` |
| **Molecules** | Composite components | `BaseCard`, `CardHeader`, `IconListItem`, `StatusBadge`, `ChangeIndicatorBadge` |
| **Organisms** | Feature-complete sections | `ConfirmationDialog`, `ErrorStateView`, `LoadingView`, `AppSnackbar` |

### Theme System

Centralized color management through `AppColors`:

```dart
import 'package:rga_dashboard/core/presentation/design_system/design_system.dart';

// Semantic colors
AppColors.primary
AppColors.success
AppColors.danger
AppColors.warning

// With opacity
AppColors.successWithOpacity(0.2)
```

### Usage Example

```dart
import 'package:rga_dashboard/core/presentation/design_system/design_system.dart';

// Atoms
PrimaryButton(
  label: 'Submit',
  onPressed: _handleSubmit,
  isLoading: state.isLoading,
)

// Molecules
BaseCard(
  child: CardHeader(title: 'Weather', icon: Icons.cloud),
)

// Organisms
ErrorStateView(
  message: 'Failed to load data',
  onRetry: _handleRetry,
)
```

---

## Features

### Authentication

- Form validation handled in state management layer
- Session persistence across application restarts
- Graceful error handling with user feedback

**Test Credentials:**
- Email: `test@example.com`
- Password: `password123`

### Dashboard

- **Widget Types**: Weather, Stock Ticker, News Summary, Calendar, Quick Notes
- **Drag & Drop Reordering**: Smooth animations with optimistic updates
- **State Persistence**: Widget order preserved across sessions
- **Type-Safe Widget Data**: Sealed classes for compile-time exhaustiveness

### Responsive Layout

- Adaptive column count based on viewport width
- Material 3 design language

---

## Project Structure

```
lib/
├── core/
│   ├── database/           # Database configuration
│   ├── error/              # Exception definitions
│   ├── presentation/
│   │   └── design_system/  # Atomic Design components
│   │       ├── atoms/      # Buttons, inputs, icons
│   │       ├── molecules/  # Cards, list items, badges
│   │       ├── organisms/  # Dialogs, feedback components
│   │       └── theme/      # Color system (AppColors)
│   ├── result/             # Result<T> type (Success/Failure)
│   └── usecases/           # Base use case contracts
│
├── features/
│   ├── auth/
│   │   ├── data/           # Models, data sources, repository impl
│   │   ├── domain/         # Entities, repository contract, use cases
│   │   └── presentation/   # State management, pages
│   │
│   └── dashboard/
│       ├── data/           # Models, data sources, repository impl
│       ├── domain/         # Entities, repository contract, use cases
│       └── presentation/   # State management, pages, widget cards
│
├── injection_container.dart  # Dependency injection configuration
└── main.dart                 # Application entry point

test/
├── core/
│   ├── error/              # Exception tests
│   ├── result/             # Result type tests
│   └── usecases/           # Use case contract tests
│
└── features/
    ├── auth/
    │   ├── data/           # Model, data source, repository tests
    │   ├── domain/         # Entity, use case tests
    │   └── presentation/   # State management, page tests
    │
    └── dashboard/
        ├── data/           # Model, data source, repository tests
        ├── domain/         # Entity, use case tests
        └── presentation/   # State management, page, widget tests
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2+
- Dart SDK 3.9.2+

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/rga_dashboard.git
cd rga_dashboard

# Install dependencies
flutter pub get

# Run application
flutter run
```

---

## Testing Strategy

### Test Categories

| Category | Location | Purpose |
|----------|----------|---------|
| **Unit Tests** | `test/**/domain/`, `test/**/data/` | Business logic, data transformations |
| **State Tests** | `test/**/presentation/cubit/` | State transitions, side effects |
| **Widget Tests** | `test/**/presentation/pages/`, `widgets/` | UI rendering, user interactions |

### Running Tests

```bash
# All tests
flutter test

# With coverage report
flutter test --coverage

# Specific test file
flutter test test/features/auth/presentation/cubit/auth_cubit_test.dart
```

### Coverage Visualization

This project supports [Coverage Gutters](https://marketplace.visualstudio.com/items?itemName=ryanluker.vscode-coverage-gutters) for VS Code:

1. Generate coverage: `flutter test --coverage`
2. Open Command Palette: `Ctrl+Shift+P`
3. Run: "Coverage Gutters: Display Coverage"

---

## Architecture Decision Records

This section documents key architectural decisions made during development, providing rationale for technology and pattern choices.

### ADR-001: Result Type Pattern

**Context:** Operations that can fail need a consistent way to communicate success or failure states without relying on exceptions for control flow.

**Decision:** Implement a sealed `Result<T>` class with `Success<T>` and `Failure` variants, supporting functional operations (`fold`, `map`, `getOrElse`).

**Rationale:**
- Compile-time exhaustiveness checking via sealed classes
- No external dependencies required
- Forces explicit error handling at call sites
- Supports typed failure categories for granular error handling

**Consequences:** All repository methods and use cases return `Result<T>`, making error paths explicit and testable.

---

### ADR-002: State Management Approach

**Context:** The application requires reactive UI updates based on asynchronous operations with support for loading, success, and error states.

**Decision:** Use a lightweight state management solution with method-based actions rather than event-driven patterns.

**Rationale:**
- Reduced boilerplate compared to event-driven alternatives
- Direct method calls provide better IDE support (autocomplete, refactoring)
- State classes remain simple data containers
- Easier onboarding for new team members

**Consequences:** Business logic validation moved to state management layer, keeping UI components stateless and focused on rendering.

---

### ADR-003: Optimistic UI Updates

**Context:** Drag-and-drop reordering requires immediate visual feedback; waiting for persistence creates perceptible lag.

**Decision:** Update UI state immediately upon user action, then persist asynchronously. Revert state if persistence fails.

**Rationale:**
- Maintains 60fps interaction responsiveness
- Aligns with user expectations from native applications
- Failure case (revert) is rare and acceptable trade-off

**Consequences:** State management must track both optimistic state and original state for potential rollback.

---

### ADR-004: Repository Pattern

**Context:** Data access logic needs abstraction to support testing, multiple data sources, and potential future changes to storage mechanisms.

**Decision:** Define repository interfaces in the domain layer; implement concrete repositories in the data layer.

**Rationale:**
- Domain layer remains independent of data access details
- Easy substitution of mock repositories for testing
- Supports composition of multiple data sources (local + remote)
- Clear contract for data operations

**Consequences:** Additional interface definitions required, but provides flexibility and testability benefits.

---

### ADR-005: Atomic Design System

**Context:** UI components need consistent styling and behavior across the application while remaining maintainable and reusable.

**Decision:** Organize presentation components following Atomic Design principles (atoms, molecules, organisms).

**Rationale:**
- Clear hierarchy of component complexity
- Promotes composition over inheritance
- Facilitates design system documentation
- Enables independent component testing

**Consequences:** Initial setup overhead, but improved maintainability and consistency long-term.

---

### ADR-006: Centralized Color System

**Context:** Direct usage of color constants throughout the codebase leads to inconsistency and makes theme changes difficult.

**Decision:** Define all colors in a single `AppColors` class; prohibit direct color constant usage in widgets.

**Rationale:**
- Single source of truth for color palette
- Semantic naming improves code readability
- Simplifies theme customization and dark mode support
- Enables compile-time checking for color usage

**Consequences:** Requires discipline to use `AppColors` consistently; enforced through code review.

---

### ADR-007: Type-Safe Widget Data

**Context:** Dashboard widgets have different data requirements (weather needs temperature, stocks need price changes, etc.).

**Decision:** Use sealed classes for widget data types with exhaustive pattern matching.

**Rationale:**
- Compile-time verification of data handling for all widget types
- Self-documenting data requirements per widget type
- IDE support for handling all cases
- Prevents runtime type errors

**Consequences:** Adding new widget types requires updating switch expressions, but compiler ensures completeness.

---

## License

MIT License - see LICENSE file for details.
