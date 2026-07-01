class OtherThing: FoundrySwift.Node {            
    var foo: Int = 0

    static func _mproxy_set_foo(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling setter for foo: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        FoundrySwift._invokeSetter(arguments, "foo", object.foo) {
            object.foo = $0
        }
        return nil
    }

    static func _mproxy_get_foo(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling getter for foo: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return FoundrySwift._invokeGetter(object.foo)
    }

    func get_foo() -> MyThing? {
        return nil
    }

    static func _mproxy_get_foo(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_foo`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return FoundrySwift._wrapCallableResult(object.get_foo())

    }
    static func _pproxy_get_foo(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_foo`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        FoundrySwift.RawReturnWriter.writeResult(returnValue, object.get_foo()) 

    }
}
