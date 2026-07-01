class MultiplierNode: Node {
    func multiply(_ integers: [Int]) -> Int {
        integers.reduce(into: 1) { $0 *= $1 }
    }

    static func _mproxy_multiply(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        do { // safe arguments access scope
            guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `multiply`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: [Int].self, at: 0)
            return FoundrySwift._wrapCallableResult(object.multiply(arg0))

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `multiply`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_multiply(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `multiply`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: [Int] = try rargs.fetchArgument(at: 0)
            FoundrySwift.RawReturnWriter.writeResult(returnValue, object.multiply(arg0)) 

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `multiply`: \(String(describing: error))")                    
        }
    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: MultiplierNode.self) else {
            return
        }
        let className = StringName("MultiplierNode")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        FoundrySwift._registerMethod(
            className: className,
            name: "multiply",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(Int.self),
            arguments: [
                FoundrySwift._argumentPropInfo([Int].self, name: "integers")
            ],
            function: MultiplierNode._mproxy_multiply,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                MultiplierNode._pproxy_multiply (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
