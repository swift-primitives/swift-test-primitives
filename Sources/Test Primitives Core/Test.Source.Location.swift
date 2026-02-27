//
//  Test.Source.Location.swift
//  swift-test-primitives
//
//  Source code location identifier.
//

extension Test.Source {
    /// A location in source code.
    ///
    /// Captures the file, line, and column where a test element is defined
    /// or where an assertion was evaluated.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let location = Test.Source.Location(
    ///     fileID: #fileID,
    ///     line: #line,
    ///     column: #column
    /// )
    /// ```
    ///
    /// ## Capturing Locations
    ///
    /// Use `#fileID`, `#line`, and `#column` literals at the call site.
    /// The `filePath` parameter is optional and defaults to `#filePath`.
    public struct Location: Sendable, Hashable, Codable {
        /// The file identifier (module/file format from `#fileID`).
        public let fileID: String

        /// The full file path (from `#filePath`), if available.
        public let filePath: String?

        /// The line number (1-indexed).
        public let line: Int

        /// The column number (1-indexed).
        public let column: Int

        /// Creates a source location.
        ///
        /// - Parameters:
        ///   - fileID: The file identifier from `#fileID`.
        ///   - filePath: The full file path from `#filePath`. Defaults to `nil`.
        ///   - line: The line number from `#line`.
        ///   - column: The column number from `#column`.
        public init(
            fileID: String,
            filePath: String? = nil,
            line: Int,
            column: Int
        ) {
            self.fileID = fileID
            self.filePath = filePath
            self.line = line
            self.column = column
        }
    }
}

// MARK: - Comparable

extension Test.Source.Location: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.fileID != rhs.fileID {
            return lhs.fileID < rhs.fileID
        }
        if lhs.line != rhs.line {
            return lhs.line < rhs.line
        }
        return lhs.column < rhs.column
    }
}

// MARK: - CustomStringConvertible

extension Test.Source.Location: CustomStringConvertible {
    public var description: String {
        "\(fileID):\(line):\(column)"
    }
}
