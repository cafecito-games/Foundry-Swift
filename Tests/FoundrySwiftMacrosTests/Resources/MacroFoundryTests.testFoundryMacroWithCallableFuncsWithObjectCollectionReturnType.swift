
class SomeNode: Node {
    func getNodeCollection() -> TypedArray<Node> {
        let result: TypedArray<Node> = [Node(), Node()]
        return result
    }

    static func _mproxy_getNodeCollection(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
            FoundrySwift.Foundry.printErr("Error calling `getNodeCollection`: failed to unwrap instance \(String(describing: pInstance))")
            return nil
        }
        return FoundrySwift._wrapCallableResult(object.getNodeCollection())

    }

    nonisolated override open class var classInitializer: Void {
        let _ = super.classInitializer
        return _initializeClass
    }

    private static let _initializeClass: Void = {
        let className = StringName("SomeNode")
        assert(ClassDB.classExists(class: className))
        let classInfo = ClassInfo<SomeNode> (name: className)
        FoundrySwift._registerMethod(
            className: className,
            name: "getNodeCollection",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(TypedArray<Node>.self),
            arguments: [

            ],
            function: SomeNode._mproxy_getNodeCollection
        )
    } ()
}
