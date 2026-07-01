class DebugThing: FoundrySwift.Object {
    var livesChanged: SignalWithArguments<Swift.Int> {
        get {
            SignalWithArguments<Swift.Int>(target: self, signalName: "lives_changed")
        }
    }
    func do_thing(value: FoundrySwift.Variant?) -> FoundrySwift.Variant? {
        return nil
    }

    static func _mproxy_do_thing(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        do { // safe arguments access scope
            guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `do_thing`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: FoundrySwift.Variant?.self, at: 0)
            return FoundrySwift._wrapCallableResult(object.do_thing(value: arg0))

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `do_thing`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_do_thing(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `do_thing`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: FoundrySwift.Variant? = try rargs.fetchArgument(at: 0)
            FoundrySwift.RawReturnWriter.writeResult(returnValue, object.do_thing(value: arg0)) 

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `do_thing`: \(String(describing: error))")                    
        }
    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: DebugThing.self) else {
            return
        }
        let className = StringName("DebugThing")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SignalWithArguments<Swift.Int>.register(as: "lives_changed", in: className, names: [])
        FoundrySwift._registerMethod(
            className: className,
            name: "do_thing",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(FoundrySwift.Variant?.self),
            arguments: [
                FoundrySwift._argumentPropInfo(FoundrySwift.Variant?.self, name: "value")
            ],
            function: DebugThing._mproxy_do_thing,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                DebugThing._pproxy_do_thing (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
