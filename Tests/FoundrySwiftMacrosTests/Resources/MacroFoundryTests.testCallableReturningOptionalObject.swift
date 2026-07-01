class MyThing: FoundrySwift.RefCounted {

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: MyThing.self) else {
            return
        }
        let className = StringName("MyThing")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
    }

}

class OtherThing: FoundrySwift.Node {
    func get_thing() -> MyThing? {
        return nil
    }

    static func _mproxy_get_thing(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_thing`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return FoundrySwift._wrapCallableResult(object.get_thing())

    }
    static func _pproxy_get_thing(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_thing`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        FoundrySwift.RawReturnWriter.writeResult(returnValue, object.get_thing()) 

    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: OtherThing.self) else {
            return
        }
        let className = StringName("OtherThing")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        FoundrySwift._registerMethod(
            className: className,
            name: "get_thing",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(MyThing?.self),
            arguments: [

            ],
            function: OtherThing._mproxy_get_thing,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                OtherThing._pproxy_get_thing (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
