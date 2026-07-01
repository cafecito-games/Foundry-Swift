//
//  FoundrySwiftTestSuiteProtocol.swift
//

import FoundrySwift

/// Protocol that defines the interface for a test suite.
///
/// Classes decorated with @FoundrySwiftTestSuite automatically conform to this protocol.
/// The protocol provides default implementations for all optional members.
@MainActor
public protocol FoundrySwiftTestSuiteProtocol: AnyObject {
    /// The display name of the test suite.
    /// Defaults to the class name.
    static var name: String { get }

    /// Foundry subclasses that need to be registered before running tests.
    /// Override to return types that should be registered with ClassDB.
    static var registeredTypes: [Object.Type] { get }

    /// Array of all tests in this suite.
    /// Generated automatically by @FoundrySwiftTestSuite macro.
    var allTests: [FoundrySwiftTestInvocation] { get }
}

// MARK: - Default Implementations

public extension FoundrySwiftTestSuiteProtocol {
    /// Default implementation returns the class name.
    static var name: String {
        String(describing: self)
    }

    /// Default implementation returns an empty array.
    static var registeredTypes: [Object.Type] {
        []
    }
}
