# Types Translation

This document contains information on how type translation happens between Swift and Foundry.

Scenarios when Foundry to/from Swift translations happen:

* `@Callable`
    - `argument` when called by Foundry: Foundry -> Swift
    - `return value` when called by Foundry: Swift -> Foundry
* `@Export`
    - `gotten value` when called by Foundry: Swift -> Foundry
    - `set value` when called by Foundry: Foundry -> Swift
* `Callable` type:
    ```swift
    let callable = Callable { (int: Int, bool: Bool) -> String in 
        "\(int)\(bool)"
    }
    ```    
    - `argument when` called: Foundry -> Swift
    - `return value` called: Swift -> Foundry

    Calling such callable is identical to Foundry calling `@Callable` function.

If nothing in the type section is specified about the scenarios, it means the type is allowed in all of those.

`Toll-free bridging` means that performance cost of translation is negligible.
# Swift types

#### Swift ``Bool`` – Foundry `bool`
Toll-free bridging.
```swift
@Foundry class CustomNode: Node {
    @Export var variable = true 
    // Foundry will see `bool variable`
}
```
#### Swift `Bool?` – Foundry `Variant`
Toll-free bridging.
```swift
@Foundry class CustomNode: Node {
    @Export var variable: Bool? = nil 
    // Foundry will see `Variant variable`
}
```
---
#### Swift `String` – Foundry `String` (FoundrySwift `GString`)
_NOT_ toll-free bridging (`Swift.String` <-> `GString` conversion requires allocation and parsing the underlying utf8)

Original Foundry API declaring usage of Foundry `String` uses Swift ``String``. Conversion happens automatically.

```swift
@Foundry class CustomNode: Node {
    @Export var variable = "Hello"
    // Foundry will see `String variable`
}
```
#### Swift `String?` – Foundry `Variant`
_NOT_ toll-free bridging (`Swift.String` <-> `GString` conversion requires allocation and parsing the underlying utf8)

```swift
@Foundry class CustomNode: Node {
    @Export var variable: String? = "Hello"
    // Foundry will see `Variant variable`
}
```
---
#### Swift ``BinaryInteger`` - Foundry `int`
Toll-free bridging.
Concrete types: ``Int``, ``UInt``, ``Int64``, ``Int32``, ``Int16``, ``Int8``, ``UInt64``, ``UInt32``, ``UInt16``, ``UInt8``

Foundry uses `Int64` as a storage. 

If Foundry calls Swift and passes a value that doesn't fit the declared integer width,
unwrapping fails:
```
Int32.fromVariant(Int.max.toVariant()) // is `nil`
```

```swift
@Foundry class CustomNode: Node {
    @Export var variable = 130
    // Foundry will see `int variable`

    @Callable
    func foo(a: Int32, b: UInt16, c: Int, d: UInt) {
    }
    // Foundry will see `void foo(a: int, b: int, c: int, d: int)`
}
```
#### Swift `BinaryInteger?` – Foundry `Variant`
```swift
@Foundry class CustomNode: Node {
    @Export var variable: Int? = 150
    // Foundry will see `Variant variable`    
}
```
---

#### Swift ``BinaryFloatingPoint`` - Foundry `float`
Toll-free bridging.
Concrete types: ``Double``, ``Float``
Foundry uses ``Double`` as a storage. 

```swift
@Foundry class CustomNode: Node {
    @Export var variable = 42.0
    // Foundry will see `float variable`

    @Callable
    func foo(a: Float, b: Double) {
    }
    // Foundry will see `void foo(a: float, b: float)`
}
```

#### Swift `BinaryFloatingPoint?` - Foundry `Variant`

```swift
@Foundry class CustomNode: Node {
    @Export var variable: Float? = 42.0
    // Foundry will see `Variant variable`
}
```
---
#### Swift closure - Foundry `Callable`
_NOT_ toll-free bridging:
1. Each `get` requires allocation of a wrapping `Callable` value.
1. Each `set` requires allocation of a Swift closure wrapping passed `Callable`.

Calling it from Foundry is cheap.

Only closures taking ``VariantConvertible`` arguments are allowed.
Only closures returning a ``VariantConvertible`` or `Void` are allowed.
No `async` and `throw` specifiers are allowed.

##### Scenarios allowed:
- `@Export`
- `Callable.init(closure)`

```swift
@Foundry class CustomNode: Node {
    @Export var variable = { (lhs: Int, rhs: Int) -> Int in 
        lhs + rhs
    }
    // Foundry will see `Callable variable`

    @Export var variable1 = { (lhs: Int, rhs: Int) in 
        print(lhs + rhs)
    }
    // Foundry will see `Callable variable1`
}
```
---
#### Swift `Void` (aka empty tuple `()`) 
Toll-free bridging.
##### Scenarios allowed:
- Returned value from `@Callable` function
- Returned value from Swift closure
---
#### Swift ``Array`` - Foundry `Array[type]` 
Only ``Swift.Array`` with `Element`s of Foundry builtin types or *optional*(!) ``Object``-derived types are allowed.
Expensive bridging, operations takes O(n) during each translation.

Implemented via ``FoundryBuiltinConvertible``

Prefer using `TypedArray` for frequent operations

```swift
@Foundry class CustomNode: Node {
    @Export var variable0: TypedArray<Vector3> = []
    // Foundry will see `Array[Vector3] variable0`

    @Export var variable1: TypedArray<Object?> = []
    // Foundry will see `Array[Object] variable1`
}
```

#### Swift Optional ``Array`` - Foundry `Variant`
Only ``Swift.Array`` with `Element`s of Foundry builtin types or *optional*(!) ``Object``-derived types are allowed.
Expensive bridging, operations takes O(n) during each translation.

Implemented via ``FoundryBuiltinConvertible``

Prefer using `TypedArray` for frequent operations

```swift
@Foundry class CustomNode: Node {
    @Export var variable0: TypedArray<Vector3>? = []
    // Foundry will see `Variant variable0`

    @Export var variable1: TypedArray<Object?>? = []
    // Foundry will see `Variant variable1`
}
```

---
#### Swift enum - Foundry `int`, Foundry `String`, Foundry `bool`
Toll-free bridging, but:
* If `RawValue` == `String` - requires `Swift.String` <-> `FoundrySwift.GString` conversion and `Hashable` lookup to decide if enum indeed has a case represented by such string.

Only ``RawRepresentable`` enums are allowed. `RawValue` must be ``BinaryInteger``, ``String`` or ``Bool``

``CaseIterable`` enum with ``RawValue: BinaryInteger`` also generate a named picker in Editor.

```swift
enum BoolEnum: Bool {
    case absolutelyTrue = true
    case undeniablyFalse = false
}

enum IntEnum: Int {
    case zero = 0
    case one = 1
    case two = 2
}

enum OrwellEnum: String {
    case war = "peace"
    case freedom = "slavery"
}

enum SelectionEnum: Int, CaseIterable {
    case the
    case house
    case that
    case jack
    case built
}

@Foundry class CustomNode: Node {
    @Export var variable0 = BoolEnum.absolutelyTrue
    // Foundry will see `bool variable0`

    @Export var variable1 = IntEnum.one
    // Foundry will see `int variable1`

    @Export var variable2 = OrwellEnum.war
    // Foundry will see `String variable2`

    @Export var variable3 = SelectionEnum.jack
    // Foundry will see `int variable3`, 
    // Editor will provide a selection from `the`, `house`, `that`, `jack`, `built` for the property
}
```

# FoundrySwift types

#### FoundrySwift ``Variant`` - Foundry `Variant`
_NOT_ toll-free bridging. Requires a heap allocation of `Variant` every time value is translated from Foundry.

Guaranteed to contain non-nil Foundry value.

```swift
@Foundry class CustomNode: Node {
    @Export var variable = 42.toVariant()
    // Foundry will see `Variant variable`
}
```
#### FoundrySwift ``Variant?`` - Foundry `Variant`
_NOT_ toll-free bridging. Requires a heap allocation of `Variant` every time non-nil value is translated from Foundry.

`Variant?.some` - Foundry `Variant` containing non-`null` value.

`Variant?.none`, aka `nil` - Foundry `Variant` containing `null`.

```swift
@Foundry class CustomNode: Node {
    @Export var variable: Variant? = nil
    // Foundry will see `Variant variable`
}
```

---

#### FoundrySwift dumb types - Corresponding Foundry builtin types
Toll-free bridging.
All dumb Foundry builtin types such as: ``Projection``, ``Vector3``, that basically just contain numbers and are represented as Swift `struct`.

```swift
@Foundry class CustomNode: Node {
    @Export var variable = Vector3()
    // Foundry will see `Array variable`
}
```

#### FoundrySwift ``Optional`` dumb types - Foundry `Variant`
Toll-free bridging.
```swift
@Foundry class CustomNode: Node {
    @Export var variable: Vector3? = nil 
    // Foundry will see `Variant variable`
}
```
---
#### FoundrySwift non-`Object` reference types - Corresponding Foundry builtin types
_NOT_ toll-free bridging. Requires a heap allocation of the Swift wrapper every time the value is translated from `Foundry` to `Swift`.

All built-in types of Foundry which are represented as Swift `class` such as: ``VariantArray``, ``VariantDictionary``, ``RID``, ``PackedFloat32Array``, etc.

These types appear exactly as they are in Foundry except `GString`(Foundry `String`), `VariantArray` (Foundry `Array`), and `VariantDictionary`(Foundry `Dictionary`), which are renamed to avoid collision with native Swift types.

```swift
@Foundry class CustomNode: Node {
    @Export var variable = VariantArray()
    // Foundry will see `Array variable`
}
```

#### FoundrySwift ``Optional`` reference types - Foundry `Variant`
_NOT_ toll-free bridging. Requires a heap allocation of the Swift wrapper every time the non-nil value is translated from `Foundry` to `Swift`.
```swift
@Foundry class CustomNode: Node {
    @Export var variable: VariantArray? = nil 
    // Foundry will see `Variant variable`
}
```
---

#### FoundrySwift ``Object``-derived types - Corresponding Foundry types
_Almost_ toll-free bridging:
Allocation only happens when Foundry object never seen by Swift shows up during Foundry -> Swift translation.

All Foundry class types such as: ``Object``, ``Node``, ``Camera3D``, ``Resource``, etc.

These types appear exactly as they are in Foundry, no exceptions!

Guaranteed to be non-nil.

```swift
@Foundry class CustomNode: Node {
    @Export var variable = Camera3D()
    // Foundry will see `Camera3D variable`
}
```

#### FoundrySwift ``Optional`` ``Object``-derived types - Foundry `Object`-derived types
_Almost_ toll-free bridging:
Allocation only happens when Foundry object never seen by Swift shows up during Foundry -> Swift translation.

```swift
@Foundry class CustomNode: Node {
    @Export var variable: Camera3D? = nil
    // Foundry will see `Camera3D variable`
}
```

---

#### FoundrySwift `TypedArray` - Foundry `Array[type]`
_NOT_ toll-free bridging. Requires a heap allocation of the Swift wrapper every time the value is translated from `Foundry` to `Swift`.

```swift
@Foundry class CustomNode: Node {
    @Export var variable0: TypedArray<Int> = []
    // Foundry will see `Array[int] variable0`

    @Export var variable1: TypedArray<Object?> = []
    // Foundry will see `Array[int] variable1`
}
```


#### FoundrySwift Optional `TypedArray` - Foundry `Variant`
_NOT_ toll-free bridging. Requires a heap allocation of the Swift wrapper every time the value is translated from `Foundry` to `Swift`.

```swift
@Foundry class CustomNode: Node {
    @Export var variable0: TypedArray<Int>? = []
    // Foundry will see `Variant variable0`

    @Export var variable1: TypedArray<Object?>? = []
    // Foundry will see `Variant variable1`
}
```
---

# Your custom types
#### ``Optional`` and non-optional `@Foundry` classes - Foundry `Object`-derived types
_Almost_ toll-free bridging.
Allocation only happens when type is initialized. That's how classes work in Swift.

All classes using `@Foundry` will be visible in Foundry exactly as you name it.
```swift
@Foundry class CustomNode: Node {    
}

@Foundry class AnotherNode: Node {
    @Export var variable0: AnotherNode? = nil
    // Foundry will see `AnotherNode variable`

    @Export var variable1 = CustomNode()
    // Foundry will see `CustomNode variable`
}
```

#### ``Optional`` and non-optional VariantConvertible - Foundry `Variant`
_Maybe_ toll-free bridging:
1. The conversion runtime doesn't require allocations.
2. Cost of conversions depends on how expensive your `VariantConvertible` implementation is. Conversion will happened every time the type is translated back and forth between Swift and Foundry.

You can conform your own types to `VariantConvertible`. They will be visible as `Variant`.
```swift
extension Date: VariantConvertible {
    public func toFastVariant() -> FastVariant? {
        timeIntervalSince1970.toFastVariant()
    }

    public static func fromFastVariantOrThrow(_ variant: borrowing FastVariant) throws(VariantConversionError) -> Date {
        Date(timeIntervalSince1970: try TimeInterval.fromFastVariantOrThrow(variant))
    }
}

@Foundry class CustomNode: Node {
    @Export var variable0: Date? = nil
    // Foundry will see `Variant variable0`

    @Export var variable1 = Date.now
    // Foundry will see `Variant variable1`
}
```

#### ``FoundryBuiltinConvertible`` - Corresponding Foundry builtin types 
_Maybe_ toll-free bridging:
1. The conversion runtime doesn't require allocations.
2. Cost of conversions depends on how expensive your `FoundryBuiltinConvertible` implementation is. Conversion will happened every time the type is translated back and forth between Swift and Foundry.

You can conform your own types to `FoundryBuiltinConvertible`. They will be visible as type corresponding to `FoundryBuiltinConvertible.FoundryBuiltin`.
```swift
extension Date: FoundryBuiltinConvertible {
    public func toFoundryBuiltin() -> Double {
        timeIntervalSince1970
    }

    public static func fromFoundryBuiltinOrThrow(_ value: Double) throws(VariantConversionError) -> Self {
        Date(timeIntervalSince1970: value)
    }
}

@Foundry class CustomNode: Node {
    @Export var variable0 = Date.now
    // Foundry will see `float variable0`
}
```

#### `Optional` ``FoundryBuiltinConvertible`` - Foundry `Variant`
_Maybe_ toll-free bridging:
1. The conversion runtime doesn't require allocations.
2. Cost of conversions depends on how expensive your `FoundryBuiltinConvertible` implementation is. Conversion will happened every time the type is translated back and forth between Swift and Foundry.

You can conform your own types to `FoundryBuiltinConvertible`. They will be visible as type corresponding to `FoundryBuiltinConvertible.FoundryBuiltin`.
```swift
extension Date: FoundryBuiltinConvertible {
    public func toFoundryBuiltin() -> Double {
        timeIntervalSince1970
    }

    public static func fromFoundryBuiltinOrThrow(_ value: Double) throws(VariantConversionError) -> Self {
        Date(timeIntervalSince1970: value)
    }
}

@Foundry class CustomNode: Node {
    @Export var variable0: Date? = Date.now
    // Foundry will see `Variant variable0`
}
```

