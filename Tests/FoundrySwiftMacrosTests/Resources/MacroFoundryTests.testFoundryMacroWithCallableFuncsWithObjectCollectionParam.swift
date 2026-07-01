
class SomeNode: Node {
    func printNames(of nodes: TypedArray<Node>) {
        nodes.forEach { print($0.name) }
    }

    static func _mproxy_printNames(pInstance: UnsafeRawPointer?, arguments: borrowing FoundrySwift.Arguments) -> FoundrySwift.FastVariant? {
        do { // safe arguments access scope
            guard let object = FoundrySwift._unwrap(self, pInstance: pInstance) else {
                FoundrySwift.Foundry.printErr("Error calling `printNames`: failed to unwrap instance \(String(describing: pInstance))")
                return nil
            }
            let arg0 = try arguments.argument(ofType: TypedArray<Node>.self, at: 0)
            return FoundrySwift._wrapCallableResult(object.printNames(of: arg0))

        } catch {
            FoundrySwift.Foundry.printErr("Error calling `printNames`: \(error.description)")
        }

        return nil
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
            name: "printNames",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(Swift.Void.self),
            arguments: [
                FoundrySwift._argumentPropInfo(TypedArray<Node>.self, name: "nodes")
            ],
            function: SomeNode._mproxy_printNames
        )
    } ()
}
