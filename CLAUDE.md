# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pacering is a macOS productivity tracking application built with SwiftUI. It monitors active applications and tracks work time against daily goals, providing insights into productivity patterns.

## Build and Development Commands

This is an Xcode project for macOS. Common commands:

- **Build**: Open `pacering.xcodeproj` in Xcode and press Cmd+B, or use `xcodebuild -project pacering.xcodeproj -scheme pacering build`
- **Run**: Press Cmd+R in Xcode or use `xcodebuild -project pacering.xcodeproj -scheme pacering run`
- **Test**: Press Cmd+U in Xcode or use `xcodebuild -project pacering.xcodeproj -scheme pacering test`
- **Clean**: Press Cmd+Shift+K in Xcode or use `xcodebuild -project pacering.xcodeproj -scheme pacering clean`

## Code Architecture

### Core Components

- **`paceringApp.swift`**: Main application entry point that initializes the ActivityLogger and starts monitoring
- **`ContentView.swift`**: Main UI with navigation sidebar containing Today, Pacering, Profile, and Work Apps views
- **`Item.swift`**: Core data model containing ActivityRecord and ActivityLogger classes
- **`WorkAppsView.swift`**: Interface for selecting which applications count as "work apps"

### Key Architecture Patterns

- **SwiftUI + Combine**: Uses `@ObservedObject` and `@Published` for reactive UI updates
- **Persistent Storage**: Uses UserDefaults for lightweight data persistence (activity records, work apps, daily goals)
- **Timer-Based Monitoring**: Uses NSWorkspace to monitor frontmost application changes at configurable intervals
- **Session Management**: Tracks daily sessions with UUID-based session IDs that reset at midnight

### Data Flow

1. ActivityLogger monitors active applications via NSWorkspace
2. Creates ActivityRecord entries with start/end times and duration
3. Records are filtered by "work apps" for productivity calculations
4. Daily progress is calculated against configurable work time goals
5. UI views reactively update based on @Published properties

### UI Structure

- Navigation-based layout with sidebar (Today, Pacering, Profile, Work Apps)
- Today view: Hourly breakdown of application usage
- Pacering view: Progress circle and daily history charts
- Profile view: Settings for work time goals and update intervals
- Work Apps view: Selection interface for productivity tracking

## Key Files

- `pacering/paceringApp.swift`: App initialization and ActivityLogger setup
- `pacering/ContentView.swift`: Main UI views and navigation
- `pacering/Item.swift`: ActivityRecord model and ActivityLogger core logic
- `pacering/WorkAppsView.swift`: Work app selection interface
- `pacering/pacering.entitlements`: Sandboxing disabled for system monitoring
- `pacering.xcodeproj/`: Xcode project configuration

## Testing

- Unit tests: `paceringTests/paceringTests.swift` (basic XCTest structure)
- UI tests: `paceringUITests/` directory with launch tests
- Run tests via Xcode (Cmd+U) or xcodebuild

## Platform Requirements

- macOS 13.0+ (uses macOS-specific APIs like NSWorkspace and ServiceManagement)
- SwiftUI for UI framework
- Requires accessibility permissions for application monitoring