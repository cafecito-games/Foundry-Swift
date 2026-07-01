//
//  FoundrySwiftTestSuiteMacro.swift
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

/// Macro that adds FoundrySwiftTestSuiteProtocol conformance and generates allTests property.
/// Scans the class for methods decorated with @FoundrySwiftTest and generates the allTests array.
public struct FoundrySwiftTestSuiteMacro: MemberMacro, ExtensionMacro, MemberAttributeMacro {

    // MARK: - MemberMacro: Generates allTests property

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard declaration.is(ClassDeclSyntax.self) else {
            throw FoundrySwiftTestMacroError.notAClass
        }

        // Find all methods with @FoundrySwiftTest attribute
        let testMethods = declaration.memberBlock.members.compactMap { member -> String? in
            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
                return nil
            }

            let hasTestAttribute = funcDecl.attributes.contains { attribute in
                guard let attr = attribute.as(AttributeSyntax.self),
                      let identifierType = attr.attributeName.as(IdentifierTypeSyntax.self) else {
                    return false
                }
                return identifierType.name.text == "FoundrySwiftTest"
            }

            guard hasTestAttribute else { return nil }
            return funcDecl.name.text
        }

        let testEntries: String
        if testMethods.isEmpty {
            testEntries = ""
        } else {
            testEntries = testMethods.map { name in
                "FoundrySwiftTestInvocation(name: \"\(name)\", run: \(name))"
            }.joined(separator: ",\n            ")
        }

        let allTestsDecl: DeclSyntax = """
            @MainActor var allTests: [FoundrySwiftTestInvocation] {
                [
                    \(raw: testEntries)
                ]
            }
            """

        return [allTestsDecl]
    }

    // MARK: - MemberAttributeMacro: Adds @MainActor to @FoundrySwiftTest methods

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let funcDecl = member.as(FunctionDeclSyntax.self) else {
            return []
        }
        let hasTestAttribute = funcDecl.attributes.contains { attribute in
            guard let attr = attribute.as(AttributeSyntax.self),
                  let identifierType = attr.attributeName.as(IdentifierTypeSyntax.self) else {
                return false
            }
            return identifierType.name.text == "FoundrySwiftTest"
        }
        guard hasTestAttribute else { return [] }
        return [AttributeSyntax(attributeName: IdentifierTypeSyntax(name: .identifier("MainActor")))]
    }

    // MARK: - ExtensionMacro: Adds protocol conformance

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let ext = try ExtensionDeclSyntax("extension \(type): FoundrySwiftTestSuiteProtocol {}")
        return [ext]
    }
}
