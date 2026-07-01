class Garage: Node {
    var bar: TypedArray<Bool> = [false]

    static func _mproxy_set_bar(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling setter for bar: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        FoundrySwift._invokeSetter(arguments, "bar", object.bar) {
            object.bar = $0
        }
        return nil
    }

    static func _mproxy_get_bar(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling getter for bar: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return FoundrySwift._invokeGetter(object.bar)
    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        MainActor.assumeIsolated {
            _initializeClass()
        }
    }

    private static func _initializeClass() {
        guard foundrySwiftShouldInitializeClass(type: Garage.self) else {
            return
        }
        let className = StringName("Garage")
        if classInitializationLevel.rawValue >= ExtensionInitializationLevel.scene.rawValue {
            // ClassDB singleton is not available prior to `.scene` level
            assert(ClassDB.classExists(class: className))
        }
        FoundrySwift._addPropertyGroup(className: className, name: "Example", prefix: "example")
        FoundrySwift._registerPropertyWithGetterSetter(
            className: className,
            info: FoundrySwift._propInfo(
                at: \Garage.bar,
                name: "bar",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_bar",
            setterName: "set_bar",
            getterFunction: Garage._mproxy_get_bar,
            setterFunction: Garage._mproxy_set_bar
        )
    }
}
