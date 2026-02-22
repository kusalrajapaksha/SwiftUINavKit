# Changelog

All notable changes to SwiftUINavKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-02-22

### Fixed
- Fixed critical bug where `popToRoot()` was not working correctly
- Improved navigation stack validation to prevent edge cases
- Enhanced error handling for root view controller access

## [1.0.0] - 2026-02-14

### Added
- Initial release of SwiftUINavKit
- `NavigationRouter` class for programmatic navigation
- `NavigationContainer` for UIKit integration
- Type-safe view navigation with `popToView(_:)`
- Route identification system for deep linking
- Stack inspection utilities:
  - `containsRoute(id:)`
  - `containsView(_:)`
  - `stackDepth`
  - `debugStack`
  - `debugStackDetailed`
- Navigation operations:
  - `push(_:routeID:animated:injectRouter:)`
  - `pop(animated:)`
  - `pop(levels:animated:)`
  - `popToRoot(animated:)`
  - `popToView(_:animated:)`
  - `popToRoute(id:animated:)`
- SwiftUI environment integration
- Full documentation and usage guide
- Example project demonstrating all features

### Fixed
- Type erasure issue with `AnyView` wrapping
- `popToView` now correctly identifies view types even when wrapped
- Stack inspection now shows original view types instead of "AnyView"

## [Unreleased]

### Planned
- Custom transition animations
- Navigation coordinator pattern
- Improved tab bar integration
- SwiftUI previews support
