
class Car: Node {
    var makes: TypedArray<Node> = []

    static func _mproxy_set_makes(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling getter for makes: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        FoundrySwift._invokeSetter(arguments, "makes", object.makes) {
            object.makes = $0
        }
        return nil
    }

    static func _mproxy_get_makes(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling getter for makes: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return FoundrySwift._invokeGetter(object.makes)
    }
    var model: TypedArray<Node> = []

    static func _mproxy_set_model(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling getter for model: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        FoundrySwift._invokeSetter(arguments, "model", object.model) {
            object.model = $0
        }
        return nil
    }

    static func _mproxy_get_model(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = _unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling getter for model: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }

        return FoundrySwift._invokeGetter(object.model)
    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("Car")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<Car> (name: className)
        FoundrySwift._addPropertyGroup(className: className, name: "Vehicle", prefix: "")
        FoundrySwift._registerPropertyWithGetterSetter(
            className: className,
            info: FoundrySwift._propInfo(
                at: \Car.makes,
                name: "makes",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_makes",
            setterName: "set_makes",
            getterFunction: Car._mproxy_get_makes,
            setterFunction: Car._mproxy_set_makes
        )
        FoundrySwift._registerPropertyWithGetterSetter(
            className: className,
            info: FoundrySwift._propInfo(
                at: \Car.model,
                name: "model",
                userHint: nil,
                userHintStr: nil,
                userUsage: nil
            ),
            getterName: "get_model",
            setterName: "set_model",
            getterFunction: Car._mproxy_get_model,
            setterFunction: Car._mproxy_set_model
        )
    } ()
}
