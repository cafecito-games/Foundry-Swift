//
//  MacroFoundryExportSubgroupTests.swift
//  FoundrySwiftMacrosTests
//
//  Created by Estevan Hernandez on 1/20/24.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import FoundrySwiftMacroLibrary

final class MacroFoundryExportSubroupTests: MacroFoundryTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Foundry": FoundryMacro.self,
            "Export": FoundryExport.self,
            "exportGroup": FoundryMacroExportGroup.self,
            "exportSubgroup": FoundryMacroExportSubgroup.self
        ]
    }
    
    func testFoundryExportSubgroupWithAndWithoutPrefixWithGroup() {
        assertExpansion(
            of: """
            @Foundry class Car: Node {
                #exportGroup("Vehicle")
                #exportSubgroup("VIN")
                @Export var vin: String = ""
                #exportSubgroup("YMMS", prefix: "ymms_")
                @Export var ymms_year: Int = 1998
                @Export var ymms_make: String = "Honda"
                @Export var ymms_model: String = "Odyssey"
                @Export var ymms_series: String = "LX"
            }
            """
        )
    }
}
