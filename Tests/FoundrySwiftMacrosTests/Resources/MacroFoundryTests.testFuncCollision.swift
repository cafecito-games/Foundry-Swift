class OtherThing: FoundrySwift.Node {            
    func foo(value: Int?) { }

    static func _mproxy_foo(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        do { // safe arguments access scope
            guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: Int?.self, at: 0)
            return FoundrySwift._wrapCallableResult(object.foo(value: arg0))

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
        let arg0: Int? = try rargs.fetchArgument(at: 0)
            FoundrySwift.RawReturnWriter.writeResult(returnValue, object.foo(value: arg0)) 

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `foo`: \(String(describing: error))")                    
        }
    }

    func foo() -> MyThing? {
        return nil
    }

    static func _mproxy_foo(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return FoundrySwift._wrapCallableResult(object.foo())

    }
    static func _pproxy_foo(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `foo`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        FoundrySwift.RawReturnWriter.writeResult(returnValue, object.foo()) 

    }
}
