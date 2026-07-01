//
//  MacroFoundryExportCollectionTests.swift
//  FoundrySwiftMacrosTests
//
//  Created by Estevan Hernandez on 11/29/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import FoundrySwiftMacroLibrary

final class MacroFoundryExportCollectionTests: MacroFoundryTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Foundry": FoundryMacro.self,
            "Export": FoundryExport.self,
        ]
    }

    func testExportGenericArrayStringFoundryMacro() {
        assertExpansion(
            of: """
            @Foundry
            class SomeNode: Node {
                @Export
                var greetings: TypedArray<String> = []
            }
            """
        )
    }
    
    func testExportArrayStringMacro() {        
        assertExpansion(
            of: """
            @Export var greetings: TypedArray<String> = []
            """
        )
    }
    
    func testExportGenericArrayStringMacro() {
        assertExpansion(
            of: """
            @Export var greetings: TypedArray<String> = []
            """
        )
    }
    
    func testExportConstantGenericArrayStringMacro() {
        assertExpansion(
            of: """
            @Export let greetings: TypedArray<String> = []
            """
        )
    }
    
    func testExportVariantArray() {
        assertExpansion(
            of: """
            @Foundry
            class SomeNode: Node {
                @Export var someArray: VariantArray = VariantArray()
            }
            """
        )
    }
    
    func testExportArrayIntFoundryMacro() {
        assertExpansion(of: """
            @Foundry
            class SomeNode: Node {
                @Export var someNumbers: TypedArray<Int> = []
            }
            """
        )
    }

    func testExportArraysIntFoundryMacro() throws {
        assertExpansion(
            of: """
            @Foundry
            class SomeNode: Node {
                @Export var someNumbers: TypedArray<Int> = []
                @Export var someOtherNumbers: TypedArray<Int> = []
            }
            """
        )
    }
    
    func testFoundryExportTwoStringArrays() throws {
        assertExpansion(
            of: """
            import FoundrySwift

            @Foundry
            class ArrayTest: Node {
               @Export var firstNames: TypedArray<String> = ["Thelonius"]
               @Export var lastNames: TypedArray<String> = ["Monk"]
            }
            """
        )
    }
    
    func testExportTypedArray() throws {
        assertExpansion(
            of: """
            @Export var greetings: TypedArray<Node3D> = []
            """
        )
    }
    
    func testFoundryExportTypedArray() throws {
        assertExpansion(
            of: """
            @Foundry
            class SomeNode: Node {
                @Export var greetings: TypedArray<Node3D> = []
            }
            """
        )
    }
}
