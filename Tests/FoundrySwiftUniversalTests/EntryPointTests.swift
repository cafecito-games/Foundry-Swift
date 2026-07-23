import XCTest
import FoundryExtensionC
@testable import FoundrySwift

final class EntryPointTests: XCTestCase {
    func testLoadsAlpha7InterfaceWithoutDeprecatedMemoryFunctions() {
        requestedSymbols.removeAll()
        let procAddress: FoundryExtensionInterfaceGetProcAddress = alpha7ProcAddress

        loadFoundryInterface(procAddress)

        XCTAssertEqual(
            requestedSymbols.filter { $0.hasPrefix("mem_") },
            ["mem_alloc2", "mem_realloc2", "mem_free2"]
        )
    }
}

private nonisolated(unsafe) var requestedSymbols = [String]()

private func alpha7ProcAddress(_ name: UnsafePointer<CChar>?) -> FoundryExtensionInterfaceFunctionPtr? {
    guard let name else { return nil }
    let symbol = String(cString: name)
    requestedSymbols.append(symbol)
    if symbol == "mem_alloc" || symbol == "mem_realloc" || symbol == "mem_free" {
        return nil
    }
    return alpha7Sentinel
}

private func alpha7Sentinel() {}
