//
//  FoundrySwiftTestMacro.swift
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

/// Peer macro that marks a method as a test to be collected by @FoundrySwiftTestSuite.
/// This macro doesn't generate any code - it just serves as a marker that @FoundrySwiftTestSuite can detect.
public struct FoundrySwiftTestMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Validate it's attached to a function
        guard declaration.is(FunctionDeclSyntax.self) else {
            throw FoundrySwiftTestMacroError.notAFunction
        }
        return []  // No code generation needed - just a marker
    }
}
