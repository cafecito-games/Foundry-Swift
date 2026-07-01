// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 31/10/24.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct SignalAttachmentMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            throw FoundryMacroError.signalMacroNotOnVariable
        }
        
        var result: [AccessorDeclSyntax] = []
        
        if varDecl.bindings.count > 1 {
            throw FoundryMacroError.signalMacroMultipleBindings
        }
        
        for binding in varDecl.bindings {
            guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                throw FoundryMacroError.noIdentifier(binding)
            }
            
            guard let type = binding.typeAnnotation?.type else {
                throw FoundryMacroError.signalMacroNoType(identifier)
            }
            
            if binding.accessorBlock != nil {
                throw FoundryMacroError.signalMacroAccessorBlock(identifier)
            }
            
            if binding.initializer != nil {
                throw FoundryMacroError.signalMacroInitializer(identifier)
            }
            
            result.append("""
            get { \(raw: type.trimmedDescription)(target: self, signalName: \"\(raw: identifier.camelCaseToSnakeCase())\") }
            """)
        }
    
        return result
    }
}
