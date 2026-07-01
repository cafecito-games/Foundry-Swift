//
//  Plugin.swift
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FoundrySwiftTestMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FoundrySwiftTestMacro.self,
        FoundrySwiftTestSuiteMacro.self,
    ]
}
