//
//  MacroFoundryExportEnumTests.swift
//  FoundrySwiftMacrosTests
//
//  Created by Estevan Hernandez on 11/29/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import FoundrySwiftMacroLibrary

final class MacroFoundryExportEnumTests: MacroFoundryTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Foundry": FoundryMacro.self,
            "Export": FoundryExport.self,
        ]
    }
    
    func testExportEnumFoundry() {
        assertExpansion(
            of: """
            enum Demo: Int, CaseIterable {
                case first
            }
            enum Demo64: Int64, CaseIterable {
                case first
            }
            @Foundry
            class SomeNode: Node {
                @Export(.enum) var demo: Demo
                @Export(.enum) var demo64: Demo64
            }
            """
        )
    }
}
