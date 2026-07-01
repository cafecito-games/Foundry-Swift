//
//  UtilityGen.swift
//  Generator
//
//  Created by Miguel de Icaza on 5/14/23.
//

import ExtensionApi
import Foundation

@MainActor func generateUtility(values: [JFoundryUtilityFunction], outputDir: String?) async {
    let p = await PrinterFactory.shared.initPrinter("utility", withPreamble: true)
    defer {
        if let outputDir {
            p.save(outputDir + "utility.swift")
        }
    }

    let emptyUsedMethods = Set<String>()

    p("public class Foundry") {
        for method in values {
            // We ignore the request for virtual methods, should not happen for these
            if omittedMethodsList["utility_functions"]?.contains(method.name) == true {
                continue
            }

            performExplaniningNonCriticalErrors {
                _ = try generateMethod(p, method: method, className: "Foundry", cdef: nil, usedMethods: emptyUsedMethods, generatedMethodKind: .utilityFunction, asSingleton: false)
            }
        }
    }
}
