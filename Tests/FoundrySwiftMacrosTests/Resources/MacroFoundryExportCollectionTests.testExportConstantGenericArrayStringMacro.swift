let greetings: TypedArray<String> = []

static func _mproxy_get_greetings(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
    guard let object = _unwrap(self, pInstance: pInstance) else {
        FoundrySwift.Foundry.printErr("Error calling getter for greetings: failed to unwrap instance \(String(describing: pInstance))")
        return nil
    }

    return FoundrySwift._invokeGetter(object.greetings)
}
