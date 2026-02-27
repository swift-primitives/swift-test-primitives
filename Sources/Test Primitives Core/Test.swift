//
//  Test.swift
//  swift-test-primitives
//
//  Root namespace for all test primitive types.
//

/// Root namespace for test primitive types.
///
/// This enum serves as a namespace container and is never instantiated.
/// All test-related types are nested within this namespace.
///
/// ## Tier 1 Primitives (this package)
///
/// These types form the interchange format between test frameworks:
/// - ``Test/Source``: Source code location types
/// - ``Test/Text``: Structured text with styled segments
/// - ``Test/ID``: Composite test identifier
/// - ``Test/Expression``: Captured expressions and values
/// - ``Test/Expectation``: Evaluated expectations and failures
/// - ``Test/Issue``: Neutral issue carrier
/// - ``Test/Trait``: Test trait values
/// - ``Test/Event``: Test event envelope
///
/// All Tier 1 types are:
/// - `Sendable` (safe for concurrent access)
/// - `Hashable` (except `Event` which is append-only)
/// - Free of Foundation dependencies
public enum Test {}
