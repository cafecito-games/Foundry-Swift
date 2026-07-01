
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
            name: "square",
            flags: .default,
            returnValue: FoundrySwift._returnValuePropInfo(TypedArray<Int>.self),
            arguments: [
                FoundrySwift._argumentPropInfo(TypedArray<Int>.self, name: "integers")
            ],
            function: SomeNode._mproxy_square
        )
    } ()
}
