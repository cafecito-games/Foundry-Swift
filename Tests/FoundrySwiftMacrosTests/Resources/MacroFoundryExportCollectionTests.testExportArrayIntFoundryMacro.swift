class SomeNode: Node {
    var someNumbers: TypedArray<Int> = []

    static func _mproxy_set_someNumbers(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling setter for someNumbers: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        FoundrySwift._invokeSetter(arguments, "someNumbers", object.someNumbers) {
            object.someNumbers = $0
        }
        return nil
    }

    static func _mproxy_get_someNumbers(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling getter for someNumbers: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return FoundrySwift._invokeGetter(object.someNumbers)
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
        FoundrySwift._registerPropertyWithGetterSetter(
            className: className,
            info: FoundrySwift._propInfo(
                at: \SomeNode.someNumbers,
                name: "some_numbers",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_some_numbers",
            setterName: "set_some_numbers",
            getterFunction: SomeNode._mproxy_get_someNumbers,
            setterFunction: SomeNode._mproxy_set_someNumbers
        )
    }
}
