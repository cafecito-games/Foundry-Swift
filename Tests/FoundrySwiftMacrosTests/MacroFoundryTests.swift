//
//  MacroFoundryTests.swift
//  
//
//  Created by Padraig O Cinneide on 2023-09-28.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import FoundrySwiftMacroLibrary

// Note when editing: use spaces for indentation, check that Xcode has following settings, if some tests fail without an obvious actual and expected output difference
// Text Editing / Indentation
// Prefer Indent Using = Spaces
// Tab Key = Indents in leading whitespace

final class MacroFoundryTests: MacroFoundryTestCase {
    override class var macros: [String: Macro.Type] {
        [
            "Foundry": FoundryMacro.self,
            "Callable": FoundryCallable.self,
            "Export": FoundryExport.self,
            "Rpc": FoundryRpc.self,
            "signal": SignalMacro.self,
            "Signal": SignalAttachmentMacro.self
        ]
    }
    
    func testFoundryMacro() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
            }
            """
        )
    }

    func testFoundryMacroWithFinalClass() {
        assertExpansion(
            of: """
            @Foundry final class Hi: Node {
                override func _hasPoint(_ point: Vector2) -> Bool { false }
            }
            """
        )
    }

    func testFoundryVirtualMethodsMacro() {
        assertExpansion(
            of: """
            @Foundry(.tool) class Hi: Control {
                override func _hasPoint(_ point: Vector2) -> Bool { false }
            }
            """
        )
    }
    
    func testFoundryMacroWithNonCallableFunc() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
                func hi() {
                }
            }
            """
        )
    }
    func testFoundryMacroStaticSignal() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
                #signal("picked_up_item", arguments: ["kind": String.self])
                #signal("scored")
                #signal("different_init", arguments: [:])
                #signal("different_init2", arguments: .init())
            }
            """
        )
    }
    
    func testFoundryMacroWithCallableFuncWithObjectParams() {
        assertExpansion(
            of: """
            @Foundry class Castro: Node {
                @Callable func deleteEpisode() {}
                @Callable func subscribe(podcast: Podcast) {}
                @Callable func perhapsSubscribe(podcast: Podcast?) {}
                @Callable func removeSilences(from: Variant) {}
                @Callable func getLatestEpisode(podcast: Podcast) -> Episode {}
                @Callable func queue(_ podcast: Podcast, after preceedingPodcast: Podcast) {}
            }
            """
        )
    }
    
    func testWarningAvoidance() {
        assertExpansion(
            of: """
            @Foundry
            final class MyData: Resource {}
            
            @Foundry
            final class MyClass: Node {
                @Export var data: MyData = .init()
            }
            """
        )
    }
    
    func testFoundryMacroWithCallableFuncsWithTypedArrayReturnType() {
        assertExpansion(
            of: """
            @Foundry
            class SomeNode: Node {
                @Callable
                func getIntegerCollection() -> TypedArray<Int> {
                    let result: TypedArray<Int> = [0, 1, 1, 2, 3, 5, 8]
                    return result
                }
            }
            """
        )
    }
    
    func testFoundryMacroWithCallableFuncsWithTypedArrayParam() {
        assertExpansion(
            of: """
            @Foundry
            class SomeNode: Node {
                @Callable
                func square(_ integers: TypedArray<Int>) -> TypedArray<Int> {
                    integers.map { $0 * $0 }.reduce(into: TypedArray<Int>()) { $0.append(value: $1) }
                }
            }
            """
        )
    }   
    
    func testFoundryMacroWithCallableFuncsWithArrayParam() {
        assertExpansion(
            of: """
            @Foundry
            class MultiplierNode: Node {
                @Callable
                func multiply(_ integers: [Int]) -> Int {
                    integers.reduce(into: 1) { $0 *= $1 }
                }
            }
            """
        )
    }
    
    func testFoundryMacroWithCallableFuncHavingVariantsInSignature() {
        assertExpansion(
            of: """
            @Foundry
            private class TestNode: Node {
                @Callable
                func foo(variant: Variant?) -> Variant? {
                    return variant
                }
            }
            """
        )
    }
    
    func testFoundryMacroWithCallableFuncsWithArrayReturnTypes() {
        assertExpansion(
            of: """
            @Foundry
            class CallableCollectionsNode: Node {
                @Callable
                func get_ages() -> [Int] {
                    [1, 2, 3, 4]
                }
            
                @Callable
                func get_markers() -> [Marker3D] {
                    [.init(), .init(), .init()]
                }
            }
            """
        )
    }

    func testFoundryMacroWithCallableFuncsWithGenericArrayParam() {
        assertExpansion(
            of: """
            @Foundry
            class MultiplierNode: Node {
                @Callable
                func multiply(_ integers: Array<Int>) -> Int {
                    integers.reduce(into: 1) { $0 *= $1 }
                }
            }
            """
        )
    }
    
    func testFoundryMacroWithCallableFuncsWithGenericArrayReturnTypes() {
        assertExpansion(
            of: """
            @Foundry
            class CallableCollectionsNode: Node {
                @Callable
                func get_ages() -> Array<Int> {
                    [1, 2, 3, 4]
                }
            
                @Callable
                func get_markers() -> Array<Marker3D> {
                    [.init(), .init(), .init()]
                }
            }
            """
        )
    }
    
    func testFoundryMacroWithCallableFuncWithValueParams() {
        assertExpansion(
            of: """
            @Foundry class MathHelper: Node {
                @Callable func multiply(_ a: Int, by b: Int) -> Int { a * b}
                @Callable func divide(_ a: Float, by b: Float) -> Float { a / b }
                @Callable func areBothTrue(_ a: Bool, and b: Bool) -> Bool { a == b }
            }
            """
        )
    }
    
    func testNewSignalMacro() {
        assertExpansion(
            of: """
            @Foundry
            class Demo: Node3D {
                @Signal var burp: SimpleSignal
            
                @Signal var livesChanged: SignalWithArguments<Int>
            }

            """
        )
    }
    
    func testExportFoundryUsage() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
                @Export(usage: [.editor, .array]) var goodName: String = "Supertop"
            }
            """
        )
    }
    
    func testExportedInt64() {
        assertExpansion(
            of: """
            @Foundry
            class Thing: FoundrySwift.Object {
                @Export
                var value: Int64 = 0
            
                @Callable func get_some() -> Int64 { 10 }
            }
            """
        )
    }

    func testExportFoundryMacro() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
                @Export var goodName: String = "Supertop"
            }
            """
        )
    }
    
    // Victory, no longer needed!   We now support statics!
//    func testStaticFunction() {
//        assertExpansion(
//            of: """
//            @Foundry class Hi: Node {
//                @Callable static func get_some() -> Int64 { 10 }
//            }
//            """,
//            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
//        )
//    }

    // Victory, no longer needed!   We now support statics!
//    func testClassFunction() {
//        assertExpansion(
//            of: """
//            @Foundry class Hi: Node {
//                @Callable class func get_some() -> Int64 { 10 }
//            }
//            """,
//            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
//        )
//    }
//    
    func testStaticExport() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
                @Export
                static var int = 10
            }
            """,
            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
        )
    }
    
    func testClassExport() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
                @Export
                class var int = 10
            }
            """,
            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
        )
    }
    
    func testClassSignal() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
                @Signal
                class var int: SimpleSignal
            }
            """,
            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
        )
    }
    
    func testStaticSignal() {
        assertExpansion(
            of: """
            @Foundry class Hi: Node {
                @Signal
                static var int: SimpleSignal
            }
            """,
            diagnostics: [.init(message: "`static` or `class` member is not supported", line: 1, column: 1)]
        )
    }
    
    func testDebugThing() {
        assertExpansion(
            of: """
            @Foundry
            class DebugThing: FoundrySwift.Object {
                @Signal var livesChanged: SignalWithArguments<Swift.Int>
            
                @Callable
                func do_thing(value: FoundrySwift.Variant?) -> FoundrySwift.Variant? {
                    return nil
                }
            }
            """
        )
    }
    
    func testCallableReturningOptionalObject() {
        assertExpansion(
            of: """
            @Foundry class MyThing: FoundrySwift.RefCounted {

            }

            @Foundry class OtherThing: FoundrySwift.Node {
                @Callable func get_thing() -> MyThing? {
                    return nil
                }
            }
            """
        )
    }
    
    func testCallableTakingOptionalBuiltin() {
        assertExpansion(
            of: """
            @Foundry class MyThing: FoundrySwift.RefCounted {

            }

            @Foundry class OtherThing: FoundrySwift.Node {
                @Callable func do_string(value: String?) { }
            
                @Callable func do_int(value: Int?) {  }
            
                @Callable func get_thing() -> MyThing? {
                    return nil
                }
            }
            """
        )
    }
    
    func testFuncCollision() {
        assertExpansion(
            of: """
            @Foundry class OtherThing: FoundrySwift.Node {            
                @Callable func foo(value: Int?) { }
            
                @Callable func foo() -> MyThing? {
                    return nil
                }
            }
            """,
            diagnostics: [
                .init(message: "Same name `foo` for two different declarations. FoundryScript doesn't support it.", line: 1, column: 1)
            ]
        )
    }
    
    func testFuncAndGetterCollision() {
        assertExpansion(
            of: """
            @Foundry class OtherThing: FoundrySwift.Node {            
                @Export
                var foo: Int = 0
            
                @Callable func get_foo() -> MyThing? {
                    return nil
                }
            }
            """,
            diagnostics: [
                .init(message: "Same name `get_foo` for two different declarations. FoundryScript doesn't support it.", line: 1, column: 1)
            ]
        )
    }
    
    func testMultipleSignalBindings() {
        assertExpansion(
            of: """
            @Foundry class OtherThing: FoundrySwift.Node {            
                @Signal var signal0: SimpleSignal, signal1: SimpleSignal
            }
            """,
            diagnostics: [
                .init(message: "accessor macro can only be applied to a single variable", line: 2, column: 5)
            ]
        )
    }
    
    func testCallableAutoSnakeCase() {
        assertExpansion(
            of: """
            @Foundry class TestClass: Node {
                @Callable(autoSnakeCase: true)
                func noNeedToSnakeCaseFunctionsNow() {}
            
                @Callable(autoSnakeCase: false)
                func or_is_there() {}
            
                @Callable(autoSnakeCase: false)
                func thatIsHideous() {}

                @Callable
                func defaultIsLegacyCompatible() {}
            }
            """
        )
    }
    
    func testNoTypeAnnotationTrivia() {
        assertExpansion(
            of: """
            @Foundry(
            .tool) // like this
            class TestClass: Node {     
                /* comment */@Signal/* comment */ var/* comment */ signal/* comment */: /* comment */ SimpleSignal // Comment
                @Callable/* comment */
                public func /* comment */foo/* comment */(
                    /* can do that too -> */var /* comment */lala: Int // COMMENT            
                ) -> /* comment */ Int // COMMENT
                {
                    0
                }            
            }
            """
        )
    }

    func testRpcMacro() {
        assertExpansion(
            of: """
            @Foundry class MultiplayerNode: Node {
                @Callable @Rpc(mode: .anyPeer, transferMode: .reliable)
                func syncPosition(_ position: Vector3) {
                }

                @Callable @Rpc
                func defaultRpc() {
                }

                @Callable @Rpc(mode: .authority, callLocal: true, transferMode: .unreliableOrdered, transferChannel: 2)
                func fullConfig() {
                }
            }
            """
        )
    }

    func testRpcMacroNotOnFunction() {
        assertExpansion(
            of: """
            @Foundry class MultiplayerNode: Node {
                @Rpc
                var notAFunction: Int = 0
            }
            """,
            diagnostics: [.init(message: "@Rpc attribute can only be applied to functions", line: 2, column: 5)]
        )
    }

}
