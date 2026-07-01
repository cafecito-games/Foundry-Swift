var greetings: TypedArray<Node3D> = []

static func _mproxy_set_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
    guard let object = _unwrap(self, pInstance: pInstance) else {
        FoundrySwift.Foundry.printErr("Error calling getter for greetings: failed to unwrap instance \(String(describing: pInstance))")
        return nil
    }

    FoundrySwift._invokeSetter(arguments, "greetings", object.greetings) {
        object.greetings = $0
    }
    return nil
}

static func _mproxy_get_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
    guard let object = _unwrap(self, pInstance: pInstance) else {
        FoundrySwift.Foundry.printErr("Error calling getter for greetings: failed to unwrap instance \(String(describing: pInstance))")
        return nil
    }

    return FoundrySwift._invokeGetter(object.greetings)
}
