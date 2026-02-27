public import Test_Primitives

// MARK: - Source.Location Factory

extension Source.Location {
    /// Creates a test source location with sensible defaults.
    ///
    /// Use this in tests to avoid verbose `Source.Location` construction:
    /// ```swift
    /// let location = Source.Location.stub()
    /// let location = Source.Location.stub(line: 42)
    /// ```
    public static func stub(
        fileID: String = "TestModule/File.swift",
        filePath: String? = nil,
        line: Int = 1,
        column: Int = 1
    ) -> Self {
        .init(fileID: fileID, filePath: filePath, line: line, column: column)
    }
}

// MARK: - Test.ID Factory

extension Test.ID {
    /// Creates a test ID with sensible defaults.
    ///
    /// Use this in tests to avoid verbose `Test.ID` construction:
    /// ```swift
    /// let id = Test.ID.stub("myTest")
    /// let id = Test.ID.stub("myTest", module: "MyModule")
    /// ```
    public static func stub(
        _ name: String,
        module: String = "TestModule",
        suite: String? = nil,
        line: Int = 1
    ) -> Self {
        .init(
            module: module,
            suite: suite,
            name: name,
            sourceLocation: .stub(line: line)
        )
    }
}

// MARK: - Test.Text Factory

extension Test.Text {
    /// Creates a plain text value for test assertions.
    ///
    /// ```swift
    /// let text = Test.Text.stub("expected true")
    /// ```
    public static func stub(_ string: String) -> Self {
        Self(string)
    }
}

// MARK: - Test.Trait Factories

extension Test.Trait {
    /// Creates a tag trait for test filtering.
    ///
    /// ```swift
    /// let trait = Test.Trait.stubTag("smoke")
    /// ```
    public static func stubTag(_ name: String) -> Self {
        .tag(name)
    }

    /// Creates a time limit trait.
    ///
    /// ```swift
    /// let trait = Test.Trait.stubTimeLimit(.seconds(30))
    /// ```
    public static func stubTimeLimit(_ duration: Duration) -> Self {
        .timeLimit(duration)
    }
}

