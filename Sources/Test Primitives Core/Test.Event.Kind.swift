//
//  Test.Event.Kind.swift
//  swift-test-primitives
//
//  Event categories.
//

import Tagged_Primitives_Standard_Library_Integration

extension Test.Event {
    /// Categories of events that occur during testing.
    ///
    /// `Kind` is a `Tagged` string discriminant, enabling extensibility.
    /// New event kinds can be added from any layer via constrained extension
    /// without modifying this file.
    ///
    /// ## Extensibility
    ///
    /// ```swift
    /// extension Tagged where Tag == Test.Event, Underlying == Swift.String {
    ///     public static let myCustomKind: Self = "myCustomKind"
    /// }
    /// ```
    public typealias Kind = Tagged<Test.Event, Swift.String>
}

// MARK: - Known Kinds

extension Tagged where Tag == Test.Event, Underlying == Swift.String {

    // MARK: - Run Lifecycle

    /// The test run started.
    public static let runStarted: Self = "runStarted"

    /// The execution plan was created.
    public static let planCreated: Self = "planCreated"

    /// The test run ended.
    public static let runEnded: Self = "runEnded"

    // MARK: - Test Lifecycle

    /// A test started executing.
    public static let testStarted: Self = "testStarted"

    /// A test case started (for parameterized tests).
    ///
    /// The test case is available via ``Test/Event/testCase``.
    public static let caseStarted: Self = "caseStarted"

    /// A test case ended.
    ///
    /// The test case is available via ``Test/Event/testCase``.
    public static let caseEnded: Self = "caseEnded"

    /// A test ended.
    ///
    /// The result is available via ``Test/Event/result``.
    public static let testEnded: Self = "testEnded"

    /// A test was skipped.
    ///
    /// The skip reason is available via ``Test/Event/reason``.
    public static let testSkipped: Self = "testSkipped"

    // MARK: - Assertions

    /// An expectation was checked.
    ///
    /// The expectation is available via ``Test/Event/expectation``.
    public static let expectationChecked: Self = "expectationChecked"

    // MARK: - Issues

    /// An issue was recorded.
    ///
    /// The issue is available via ``Test/Event/issue``.
    public static let issueRecorded: Self = "issueRecorded"
}
