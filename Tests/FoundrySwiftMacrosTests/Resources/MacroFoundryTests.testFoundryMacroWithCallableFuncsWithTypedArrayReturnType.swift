class SomeNode: Node {
    func getIntegerCollection() -> TypedArray<Int> {
        let result: TypedArray<Int> = [0, 1, 1, 2, 3, 5, 8]
        return result
    }

    static func _mproxy_getIntegerCollection(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `getIntegerCollection`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return FoundrySwift._wrapCallableResult(object.getIntegerCollection())

    }
    static func _pproxy_getIntegerCollection(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `getIntegerCollection`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        FoundrySwift.RawReturnWriter.writeResult(returnValue, object.getIntegerCollection()) 

    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: SomeNode.self) else {
            return
        }
        let className = StringName("SomeNode")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        FoundrySwift._registerMethod(
            className: className,
            name: "getIntegerCollection",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(TypedArray<Int>.self),
            arguments: [

            ],
            function: SomeNode._mproxy_getIntegerCollection,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                SomeNode._pproxy_getIntegerCollection (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
