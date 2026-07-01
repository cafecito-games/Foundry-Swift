//
//  FoundrySwiftInitFoundryExtensionMacroTests.swift
//  FoundrySwift
//
//  Created by Marquis Kurt on 6/9/23.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import FoundrySwift
import FoundrySwiftMacroLibrary

final class InitFoundryExtensionMacroTests: MacroFoundryTestCase {
    override class var macros: [String : any Macro.Type] {
        ["initFoundryExtension": InitFoundryExtensionMacro.self]
    }
    
    func testInitWithFoundryExtensionMacroWithTypes() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point", types: [ChrysalisNode.self, CaterpillarNode.self, ButterflyNode.self])            
            """
        )
    }
    
    func testInitFoundryExtensionMacroWithUnspecifiedTypes() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point")
            """
        )
    }

    func testInitFoundryExtensionMacroWithEmptyTypes() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point", types: [])
            """
        )
    }

    func testInitFoundryExtensionMacroWithSceneTypesOnly() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point", sceneTypes: [ChrysalisNode.self]
            """
        )
    }

    func testInitFoundryExtensionMacroWithEditorTypes() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point", editorTypes: [CaterpillarNode.self])
            """
        )
    }

    func testInitFoundryExtensionMacroWithCoreTypes() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point", coreTypes: [ChrysalisNode.self]
            """
        )
    }

    func testInitFoundryExtensionMacroWithServerTypes() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point", serverTypes: [ButterflyNode.self])
            """
        )
    }

    func testInitFoundryExtensionMacroWithEnums() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point", types: [Demo.self], enums: [MyEnum.self])
            """
        )
    }

    func testInitFoundryExtensionMacroWithAllTypes() {
        assertExpansion(of: """
            #initFoundryExtension(cdecl: "libchrysalis_entry_point", coreTypes: [EggNode.self], editorTypes: [CaterpillarNode.self], sceneTypes: [ChrysalisNode.self], serverTypes: [ButterflyNode.self])
            """
        )
    }
}
