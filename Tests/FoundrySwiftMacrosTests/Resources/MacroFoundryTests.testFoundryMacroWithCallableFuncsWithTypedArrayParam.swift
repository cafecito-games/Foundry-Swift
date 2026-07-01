class SomeNode: Node {
    func square(_ integers: TypedArray<Int>) -> TypedArray<Int> {
        integers.map { $0 * $0 }.reduce(into: TypedArray<Int>()) { $0.append(value: $1) }
    }

    static func _mproxy_square(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        do { // safe arguments access scope
            guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `square`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: TypedArray<Int>.self, at: 0)
            return FoundrySwift._wrapCallableResult(object.square(arg0))

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `square`: \(error.description)")
        }

        return nil
    }
    static func _pproxy_square(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        do { // safe arguments access scope
                    guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `square`: failed to unwrap instance \(String(describing: pInstance))")
                return
            }
        let arg0: TypedArray<Int> = try rargs.fetchArgument(at: 0)
            FoundrySwift.RawReturnWriter.writeResult(returnValue, object.square(arg0)) 

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `square`: \(String(describing: error))")                    
        }
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
            name: "square",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(TypedArray<Int>.self),
            arguments: [
                FoundrySwift._argumentPropInfo(TypedArray<Int>.self, name: "integers")
            ],
            function: SomeNode._mproxy_square,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                SomeNode._pproxy_square (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
