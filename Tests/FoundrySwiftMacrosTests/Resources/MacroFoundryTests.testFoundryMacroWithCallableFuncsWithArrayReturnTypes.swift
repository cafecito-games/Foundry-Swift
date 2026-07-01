class CallableCollectionsNode: Node {
    func get_ages() -> [Int] {
        [1, 2, 3, 4]
    }

    static func _mproxy_get_ages(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_ages`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return FoundrySwift._wrapCallableResult(object.get_ages())

    }
    static func _pproxy_get_ages(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_ages`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        FoundrySwift.RawReturnWriter.writeResult(returnValue, object.get_ages()) 

    }
    func get_markers() -> [Marker3D] {
        [.init(), .init(), .init()]
    }

    static func _mproxy_get_markers(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_markers`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return FoundrySwift._wrapCallableResult(object.get_markers())

    }
    static func _pproxy_get_markers(        
    _ pInstance: UnsafeMutableRawPointer?,
    _ rargs: FoundrySwift.RawArguments,
    _ returnValue: UnsafeMutableRawPointer?) {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `get_markers`: failed to unwrap instance \(String(describing: pInstance))")
            return
        }
        FoundrySwift.RawReturnWriter.writeResult(returnValue, object.get_markers()) 

    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: CallableCollectionsNode.self) else {
            return
        }
        let className = StringName("CallableCollectionsNode")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        FoundrySwift._registerMethod(
            className: className,
            name: "get_ages",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo([Int].self),
            arguments: [

            ],
            function: CallableCollectionsNode._mproxy_get_ages,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                CallableCollectionsNode._pproxy_get_ages (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
        FoundrySwift._registerMethod(
            className: className,
            name: "get_markers",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo([Marker3D].self),
            arguments: [

            ],
            function: CallableCollectionsNode._mproxy_get_markers,
            ptrFunction: { udata, classInstance, argsPtr, retValue in
                guard let argsPtr else {
                    Foundry.print("Foundry is not passing the arguments");
                    return
                }
                CallableCollectionsNode._pproxy_get_markers (classInstance, RawArguments(args: argsPtr), retValue)
            }

        )
    }
}
