//
//  BuiltinConvertible.swift
//  FoundrySwift
//
//  Created by Elijah Semyonov on 21/04/2025.
//

/// This is a type which you can use if you want to export your custom type as specific builtin Foundry type such as
/// `VariantArray`, `TypedArray`, `VariantDictionary`, etc.
/// Unlike ``VariantConvertible`` instances of your types will be visible in Foundry not as `Variant`, but specific builtin you chose.
public protocol FoundryBuiltinConvertible: _FoundryBridgeableBuiltin {
    /// The exact builtin type which is used as a proxy to represent this type in Foundry world
    associatedtype FoundryBuiltin: _FoundryBridgeableBuiltin
    
    /// Convert to `FoundryBuiltin`
    func toFoundryBuiltin() -> FoundryBuiltin
    
    /// Convert `FoundryBuiltin` to `Self`. If it's impossible, throw a ``VariantConversionError``. For example:
    /// ```
    /// struct MyTypeConversionError: Error {
    /// }
    ///
    /// throw VariantConversionError.custom(MyTypeConversionError())
    ///
    /// throw VariantConversionError.custom(nil) // or just nil
    /// ```
    ///
    static func fromFoundryBuiltinOrThrow(_ value: FoundryBuiltin) throws(VariantConversionError) -> Self
}

extension FoundryBuiltinConvertible {
    /// Internal API. Reads this type from a raw argument pointer by reading the underlying FoundryBuiltin and converting.
    @inline(__always)
    public static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        let builtin = try FoundryBuiltin._fromRawArgument(ptr)
        do {
            return try Self.fromFoundryBuiltinOrThrow(builtin)
        } catch {
            throw .variantConversionError(error)
        }
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public static var _variantType: Variant.GType {
        FoundryBuiltin._variantType
    }
    
    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public static var _builtinOrClassName: String {
        FoundryBuiltin._builtinOrClassName
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public static func _argumentPropInfo(name: String) -> PropInfo {
        FoundryBuiltin._argumentPropInfo(name: name)
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public static var _returnValuePropInfo: PropInfo {
        FoundryBuiltin._returnValuePropInfo
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public static func _propInfo(name: String, hint: PropertyHint?, hintStr: String?, usage: PropertyUsageFlags?) -> PropInfo {
        FoundryBuiltin._propInfo(name: name, hint: hint, hintStr: hintStr, usage: usage)
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Self {
        try fromFoundryBuiltinOrThrow(
            FoundryBuiltin.fromFastVariantOrThrow(variant)
        )
    }

    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public func toFastVariant() -> FastVariant? {
        toFoundryBuiltin().toFastVariant()
    }
    
    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public static func fromVariantOrThrow(_ variant: Variant) throws(VariantConversionError) -> Self {
        try fromFoundryBuiltinOrThrow(
            FoundryBuiltin.fromVariantOrThrow(variant)
        )
    }
    
    /// Internal API. Default implementation.
    /// Proxy the required low-level implementation via `FoundryBuiltin`.
    public func toVariant() -> Variant? {
        toFoundryBuiltin().toVariant()
    }
}

extension Array: FoundryBuiltinConvertible, _FoundryBridgeableBuiltin, _FoundryBridgeable, _FoundryContainerTypingParameter, VariantConvertible where Element: _FoundryContainerTypingParameter {
    @inline(__always)
    public static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        try Array(TypedArray<Element>._fromRawArgument(ptr))
    }

    /// Converts `[Element]` into `TypedArray<Element>`
    ///
    /// This is O(n) operation.
    ///
    /// Foundry array will be created and copied per-element.
    public func toFoundryBuiltin() -> TypedArray<Element> {
        TypedArray(self)
    }

    /// Convert `TypedArray<Element>` into Swift `[Element]`
    ///
    /// This is O(n) operation.
    ///
    /// Swift array will be created and copied per-element.
    public static func fromFoundryBuiltinOrThrow(_ value: TypedArray<Element>) throws(VariantConversionError) -> [Element] {
        // Via Swift.Array.init<S>(_ s: S) where Element == S.Element, S : Sequence
        Array(value)
    }
}

extension Dictionary: FoundryBuiltinConvertible, _FoundryBridgeableBuiltin, _FoundryBridgeable, _FoundryContainerTypingParameter, VariantConvertible where Key: _FoundryContainerTypingParameter & Hashable, Value: _FoundryContainerTypingParameter {
    @inline(__always)
    public static func _fromRawArgument(_ ptr: UnsafeRawPointer) throws(ArgumentAccessError) -> Self {
        try Dictionary(uniqueKeysWithValues: TypedDictionary<Key, Value>._fromRawArgument(ptr))
    }

    /// Converts `[Key: Value]` into `TypedDictionary<Key, Value>`
    ///
    /// This is O(n) operation.
    ///
    /// Foundry dictionary will be created and copied per-element.
    public func toFoundryBuiltin() -> TypedDictionary<Key, Value> {
        let result = TypedDictionary<Key, Value>(_wrapping: VariantDictionary())
        for (key, value) in self {
            _ = result.set(key: key, value: value)
        }
        return result
    }

    /// Convert `TypedDictionary<Key, Value>` into Swift `[Key: Value]`
    ///
    /// This is O(n) operation.
    ///
    /// Swift dictionary will be created and copied per-element.
    public static func fromFoundryBuiltinOrThrow(_ value: TypedDictionary<Key, Value>) throws(VariantConversionError) -> [Key: Value] {
        // TypedDictionary is Sequence<Key, Value>
        Dictionary(uniqueKeysWithValues: value)
    }
}
