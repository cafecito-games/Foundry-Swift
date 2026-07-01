// like this
class TestClass: Node {     
    /* comment *//* comment */ var/* comment */ signal/* comment */: /* comment */ SimpleSignal // Comment {
        get {
            SimpleSignal(target: self, signalName: "signal")
        }
    }
    /* comment */
    public func /* comment */foo/* comment */(
        /* can do that too -> */var /* comment */lala: Int // COMMENT            
    ) -> /* comment */ Int // COMMENT
    {
        0
    }            

    static func _mproxy_foo(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        do { // safe arguments access scope
            guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Int.self, at: 0)
            return FoundrySwift._wrapCallableResult(object.foo(var: arg0))

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `foo`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_foo(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: Int = try rargs.fetchArgument(at: 0)
            FoundrySwift.RawReturnWriter.writeResult(returnValue, object.foo(var: arg0)) 

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `foo`: \(String(describing: error))")                    
        }
    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: TestClass.self) else {
            return
        }
        let className = StringName("TestClass")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        SimpleSignal.register(as: "signal", in: className, names: [])
        FoundrySwift._registerMethod(
            className: className,
            name: "foo",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(Int.self),
            arguments: [
                FoundrySwift._argumentPropInfo(Int.self, name: "lala")
            ],
            function: TestClass._mproxy_foo,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                TestClass._pproxy_foo (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
