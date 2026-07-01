class Thing: FoundrySwift.Object {
    var value: Int64 = 0

    static func _mproxy_set_value(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling setter for value: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        FoundrySwift._invokeSetter(arguments, "value", object.value) {
            object.value = $0
        }
        return nil
    }

    static func _mproxy_get_value(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling getter for value: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return FoundrySwift._invokeGetter(object.value)
    }

    func get_some() -> Int64 { 10 }

    static func _mproxy_get_some(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_some`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return FoundrySwift._wrapCallableResult(object.get_some())

    }
    static func _pproxy_get_some(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_some`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        FoundrySwift.RawReturnWriter.writeResult(returnValue, object.get_some()) 

    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: Thing.self) else {
            return
        }
        let className = StringName("Thing")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        FoundrySwift._registerPropertyWithGetterSetter(
            className: className,
            info: FoundrySwift._propInfo(
                at: \Thing.value,
                name: "value",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_value",
            setterName: "set_value",
            getterFunction: Thing._mproxy_get_value,
            setterFunction: Thing._mproxy_set_value
        )
        FoundrySwift._registerMethod(
            className: className,
            name: "get_some",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(Int64.self),
            arguments: [

            ],
            function: Thing._mproxy_get_some,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                Thing._pproxy_get_some (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
