import XCTest
import FoundryExtensionC
@testable import FoundrySwift

final class EntryPointTests: XCTestCase {
    func testLoadsAlpha7InterfaceWithoutDeprecatedFunctions() {
        requestedSymbols.removeAll()
        let procAddress: FoundryExtensionInterfaceGetProcAddress = alpha7ProcAddress

        loadFoundryInterface(procAddress)

        XCTAssertEqual(
            requestedSymbols.filter { $0.hasPrefix("mem_") },
            ["mem_alloc2", "mem_realloc2", "mem_free2"]
        )
        XCTAssertFalse(
            requestedSymbols.contains {
                [
                    "callable_custom_create",
                    "classdb_construct_object",
                    "classdb_register_extension_class2",
                ].contains($0)
            }
        )
    }
}

private nonisolated(unsafe) var requestedSymbols = [String]()

private func alpha7ProcAddress(_ name: UnsafePointer<CChar>?) -> FoundryExtensionInterfaceFunctionPtr? {
    guard let name else { return nil }
    let symbol = String(cString: name)
    requestedSymbols.append(symbol)
    if [
        "mem_alloc",
        "mem_realloc",
        "mem_free",
        "callable_custom_create",
        "classdb_construct_object",
        "classdb_register_extension_class2",
    ].contains(symbol) {
        return nil
    }
    return alpha7Sentinel
}

private func alpha7Sentinel() {}
