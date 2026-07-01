//
//  Errors.swift
//

import Foundation

/// Errors that can occur during macro expansion
public enum FoundrySwiftTestMacroError: Error, CustomStringConvertible {
    case notAFunction
    case notAClass

    public var description: String {
        switch self {
        case .notAFunction:
            return "@FoundrySwiftTest can only be applied to functions"
        case .notAClass:
            return "@FoundrySwiftTestSuite can only be applied to classes"
        }
    }
}
