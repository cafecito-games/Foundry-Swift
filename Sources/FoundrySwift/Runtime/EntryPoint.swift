//
//  EntryPoint.swift: This is where Foundry calls initially into the plugin
//
//  Created by Miguel de Icaza on 3/24/23.
//
//

import FoundryExtensionC

public protocol ExtensionInterface {
    func initClass(type: AnyClass) -> Bool

    func initClasses()

    func variantShouldDeinit(variant: Variant?, content: UnsafeRawPointer) -> Bool

    func objectShouldDeinit(object: Wrapped) -> Bool

    func objectInited(object: Wrapped)

    func objectDeinited(object: Wrapped)

    func variantInited(variant: Variant, content: UnsafeMutableRawPointer)

    func variantDeinited(variant: Variant, content: UnsafeMutableRawPointer)

    func getLibrary() -> UnsafeMutableRawPointer

    func getProcAddr() -> OpaquePointer

    func sameDomain(handle: UnsafeRawPointer) -> Bool

    func getCurrenDomain() -> UInt8

    var classDBReady: Bool { get set }

    var pendingInitializers: [()->()] { get set }
}

public extension ExtensionInterface {
    func initClass(type: AnyClass) -> Bool {
        true
    }

    // Register any general Foundry classes/methods here
    func initClasses() {
        SignalProxy.initClass()
    }
}

class LibFoundryExtensionInterface: ExtensionInterface {

    /// If your application is crashing due to the Variant leak fixes, please
    /// enable this flag, and provide me with a test case, so I can find that
    /// pesky scenario.
    public let  experimentalDisableVariantUnref = false

    private let library: FoundryExtensionClassLibraryPtr
    private let getProcAddrFun: FoundryExtensionInterfaceGetProcAddress
    private var initedClasses = Set<ObjectIdentifier>()

    public init(library: FoundryExtensionClassLibraryPtr, getProcAddrFun: FoundryExtensionInterfaceGetProcAddress) {
        self.library = library
        self.getProcAddrFun = getProcAddrFun
    }

    public func initClass(type: AnyClass) -> Bool {
        initedClasses.insert(ObjectIdentifier(type)).inserted
    }

    public func variantShouldDeinit(variant: Variant?, content: UnsafeRawPointer) -> Bool {
        return !experimentalDisableVariantUnref
    }

    public func objectShouldDeinit(object: Wrapped) -> Bool {
        return true
    }

    public func objectInited(object: Wrapped) {}

    public func objectDeinited(object: Wrapped) {}

    public func variantInited(variant: Variant, content: UnsafeMutableRawPointer) {}

    public func variantDeinited(variant: Variant, content: UnsafeMutableRawPointer) {}

    public func sameDomain(handle: UnsafeRawPointer) -> Bool { true }

    public func getLibrary() -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(mutating: library)
    }

    public func getProcAddr() -> OpaquePointer {
        return unsafeBitCast(getProcAddrFun, to: OpaquePointer.self)
    }

    func getCurrenDomain() -> UInt8 {
        0
    }

    /// Tracks the active initialization level
    var classDBReady = false
    var pendingInitializers: [()->()] = []
}

/// The pointer to the Foundry Extension Interface
nonisolated(unsafe) var extensionInterface: ExtensionInterface!

public func foundrySwiftShouldInitializeClass(type: AnyClass) -> Bool {
    extensionInterface.initClass(type: type)
}

/// This variable is used to trigger a reloading of the method definitions in Foundry, this is only needed
/// for scenarios where FoundrySwift is being used with multiple active Foundry runtimes in the same process
public nonisolated(unsafe) var swiftFoundryLibraryGeneration: UInt16 = 0

nonisolated(unsafe) var extensionInitCallbacks: [OpaquePointer: ((ExtensionInitializationLevel) -> Void)] = [:]
nonisolated(unsafe) var extensionDeInitCallbacks: [OpaquePointer: ((ExtensionInitializationLevel) -> Void)] = [:]

func loadFunctions(loader: FoundryExtensionInterfaceGetProcAddress) {

}

///
/// This method is used to configure the extension interface for FoundrySwift to
/// operate.   It is only used when you use FoundrySwift embedded into an
/// application - as opposed to using FoundrySwift purely as an extension
///
public func setExtensionInterface(interface: ExtensionInterface) {
    extensionInterface = interface
    loadFoundryInterface(unsafeBitCast(interface.getProcAddr(), to: FoundryExtensionInterfaceGetProcAddress.self))
}

// Extension initialization callback
func extension_initialize(userData: UnsafeMutableRawPointer?, l: FoundryExtensionInitializationLevel) {
    //print ("SWIFT: extension_initialize")
    guard let level = ExtensionInitializationLevel(rawValue: Int64(exactly: l.rawValue)!) else { return }
    if level == .scene {
        extensionInterface.classDBReady = true
        for initializer in extensionInterface.pendingInitializers {
            initializer()
        }
        extensionInterface.pendingInitializers.removeAll()
        extensionInterface.initClasses()
    }
    guard let userData else { return }
    guard let callback = extensionInitCallbacks[OpaquePointer(userData)] else { return }
    callback(level)
}

// Extension deinitialization callback
func extension_deinitialize(userData: UnsafeMutableRawPointer?, l: FoundryExtensionInitializationLevel) {
    //print ("SWIFT: extension_deinitialize")
    guard let userData else { return }
    let key = OpaquePointer(userData)
    guard let callback = extensionDeInitCallbacks[key] else { return }
    guard let level = ExtensionInitializationLevel(rawValue: Int64(exactly: l.rawValue)!) else { return }
    callback(level)
    if level == .core {
        // Last one, remove
        extensionDeInitCallbacks.removeValue(forKey: key)
    }
}

/// Error types returned by Foundry when invoking a method
public enum CallErrorType: Error, Sendable {
    /// No error
    case ok
    case invalidMethod
    case invalidArgument
    case tooFewArguments
    case tooManyArguments
    case instanceIsNull
    case methodNotConst

    /// A new error was introduced into Foundry, and the FoundrySwift bindings are out of sync
    case unknown
}

func toCallErrorType(_ foundryCallError: FoundryExtensionCallErrorType) -> CallErrorType {
    switch foundryCallError {
    case FOUNDRY_EXTENSION_CALL_OK:
        return .ok
    case FOUNDRY_EXTENSION_CALL_ERROR_INVALID_METHOD:
        return .invalidMethod
    case FOUNDRY_EXTENSION_CALL_ERROR_INVALID_ARGUMENT:
        return .invalidArgument
    case FOUNDRY_EXTENSION_CALL_ERROR_INSTANCE_IS_NULL:
        return .instanceIsNull
    case FOUNDRY_EXTENSION_CALL_ERROR_METHOD_NOT_CONST:
        return .methodNotConst
    case FOUNDRY_EXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS:
        return .tooFewArguments
    case FOUNDRY_EXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS:
        return .tooManyArguments
    default:
        return .unknown
    }
}

@_spi(FoundrySwiftRuntimePrivate) public struct FoundryInterface {
    public let  mem_alloc2: FoundryExtensionInterfaceMemAlloc2
    public let  mem_realloc2: FoundryExtensionInterfaceMemRealloc2
    public let  mem_free2: FoundryExtensionInterfaceMemFree2

    public let  print_error: FoundryExtensionInterfacePrintError
    public let  print_error_with_message: FoundryExtensionInterfacePrintErrorWithMessage
    public let  print_warning: FoundryExtensionInterfacePrintWarning
    public let  print_warning_with_message: FoundryExtensionInterfacePrintWarningWithMessage
    public let  print_script_error: FoundryExtensionInterfacePrintScriptError
    public let  print_script_error_with_message: FoundryExtensionInterfacePrintScriptErrorWithMessage
    public let  string_new_with_utf8_chars: FoundryExtensionInterfaceStringNewWithUtf8Chars
    public let  string_to_utf8_chars: FoundryExtensionInterfaceStringToUtf8Chars
    public let  string_name_new_with_latin1_chars: FoundryExtensionInterfaceStringNameNewWithLatin1Chars

    public let  get_native_struct_size: FoundryExtensionInterfaceGetNativeStructSize

    public let  classdb_construct_object: FoundryExtensionInterfaceClassdbConstructObject
    public let  classdb_get_method_bind: FoundryExtensionInterfaceClassdbGetMethodBind
    public let  classdb_get_class_tag: FoundryExtensionInterfaceClassdbGetClassTag
    public let  classdb_register_extension_class: FoundryExtensionInterfaceClassdbRegisterExtensionClass2
    public let  classdb_register_extension_class_signal: FoundryExtensionInterfaceClassdbRegisterExtensionClassSignal
    public let  classdb_register_extension_class_method: FoundryExtensionInterfaceClassdbRegisterExtensionClassMethod
    public let  classdb_register_extension_class_property: FoundryExtensionInterfaceClassdbRegisterExtensionClassProperty
    public let  classdb_register_extension_class_property_group: FoundryExtensionInterfaceClassdbRegisterExtensionClassPropertyGroup
    public let  classdb_register_extension_class_property_subgroup: FoundryExtensionInterfaceClassdbRegisterExtensionClassPropertySubgroup
    public let  classdb_register_extension_class_integer_constant: FoundryExtensionInterfaceClassdbRegisterExtensionClassIntegerConstant
    public let  classdb_unregister_extension_class: FoundryExtensionInterfaceClassdbUnregisterExtensionClass

    public let  object_set_instance: FoundryExtensionInterfaceObjectSetInstance
    public let  object_get_instance_binding: FoundryExtensionInterfaceObjectGetInstanceBinding
    public let  object_set_instance_binding: FoundryExtensionInterfaceObjectSetInstanceBinding
    public let  object_free_instance_binding: FoundryExtensionInterfaceObjectFreeInstanceBinding
    public let  object_get_class_name: FoundryExtensionInterfaceObjectGetClassName

    public let  object_method_bind_ptrcall: FoundryExtensionInterfaceObjectMethodBindPtrcall
    public let  object_destroy: FoundryExtensionInterfaceObjectDestroy
    public let  object_has_script_method: FoundryExtensionInterfaceObjectHasScriptMethod?
    public let  object_call_script_method: FoundryExtensionInterfaceObjectCallScriptMethod?

    // @convention(c) (FoundryExtensionMethodBindPtr?, FoundryExtensionObjectPtr?, UnsafePointer<FoundryExtensionConstTypePtr?>?, FoundryExtensionTypePtr?) -> Void
    @inline(__always)
    internal func object_method_bind_ptrcall_v(
        _ method: FoundryExtensionMethodBindPtr?,
        _ object: FoundryExtensionObjectPtr?,
        _ result: FoundryExtensionTypePtr?,
        _ _args: UnsafeMutableRawPointer?...
    ) {
        object_method_bind_ptrcall(method, object, unsafeBitCast(_args, to: [UnsafeRawPointer?].self), result)
    }

    public let  global_get_singleton: FoundryExtensionInterfaceGlobalGetSingleton
    public let  ref_get_object: FoundryExtensionInterfaceRefGetObject
    public let  ref_set_object: FoundryExtensionInterfaceRefSetObject
    public let  object_method_bind_call: FoundryExtensionInterfaceObjectMethodBindCall

    // @convention(c) (FoundryExtensionMethodBindPtr?, FoundryExtensionObjectPtr?, UnsafePointer<FoundryExtensionConstVariantPtr?>?, FoundryExtensionInt, FoundryExtensionUninitializedVariantPtr?, UnsafeMutablePointer<FoundryExtensionCallError>?) -> Void
    @inline(__always)
    internal func object_method_bind_call_v(
        _ method: FoundryExtensionMethodBindPtr?,
        _ object: FoundryExtensionObjectPtr?,
        _ result: FoundryExtensionUninitializedVariantPtr?,
        _ error: UnsafeMutablePointer<FoundryExtensionCallError>?,
        _ _args: UnsafeMutableRawPointer?...
    ) {
        object_method_bind_call(method, object, unsafeBitCast(_args, to: [UnsafeRawPointer?].self), FoundryExtensionInt(_args.count), result, error)
    }

    public let  variant_new_nil: FoundryExtensionInterfaceVariantNewNil

    public let  variant_new_copy: @convention(c) (
        /* pDstVariant */ UnsafeMutableRawPointer?,
        /* pSrcVariant */UnsafeRawPointer?
    ) -> Void
    
    let variant_evaluate: FoundryExtensionInterfaceVariantEvaluate
    let variant_hash: FoundryExtensionInterfaceVariantHash

    public let  variant_destroy: @convention(c) (
        /* pDstVariant */ UnsafeMutableRawPointer?
    ) -> Void
    
    public let  variant_get: FoundryExtensionInterfaceVariantGet
    public let  variant_set: FoundryExtensionInterfaceVariantSet
    public let  variant_get_type: FoundryExtensionInterfaceVariantGetType
    public let  variant_get_type_name: FoundryExtensionInterfaceVariantGetTypeName
    public let  variant_stringify: FoundryExtensionInterfaceVariantStringify
    public let  variant_call: FoundryExtensionInterfaceVariantCall
    public let  variant_call_static: FoundryExtensionInterfaceVariantCallStatic
    public let  variant_get_indexed: FoundryExtensionInterfaceVariantGetIndexed
    public let  variant_set_indexed: FoundryExtensionInterfaceVariantSetIndexed
    public let  variant_construct: FoundryExtensionInterfaceVariantConstruct
    public let  variant_get_ptr_constructor: FoundryExtensionInterfaceVariantGetPtrConstructor
    public let  variant_get_ptr_builtin_method: FoundryExtensionInterfaceVariantGetPtrBuiltinMethod
    public let  variant_get_ptr_operator_evaluator: FoundryExtensionInterfaceVariantGetPtrOperatorEvaluator
    public let  variant_get_ptr_utility_function: FoundryExtensionInterfaceVariantGetPtrUtilityFunction
    public let  variant_get_ptr_destructor: FoundryExtensionInterfaceVariantGetPtrDestructor
    public let  variant_get_ptr_indexed_getter: FoundryExtensionInterfaceVariantGetPtrIndexedGetter
    public let  variant_get_ptr_indexed_setter: FoundryExtensionInterfaceVariantGetPtrIndexedSetter
    public let  variant_get_ptr_keyed_checker: FoundryExtensionInterfaceVariantGetPtrKeyedChecker
    public let  variant_get_ptr_keyed_getter: FoundryExtensionInterfaceVariantGetPtrKeyedGetter
    public let  variant_get_ptr_keyed_setter: FoundryExtensionInterfaceVariantGetPtrKeyedSetter
    public let  variant_get_named: FoundryExtensionInterfaceVariantGetNamed
    public let  get_variant_from_type_constructor: FoundryExtensionInterfaceGetVariantFromTypeConstructor
    public let  get_variant_to_type_constructor: FoundryExtensionInterfaceGetVariantToTypeConstructor

    public let  array_operator_index: FoundryExtensionInterfaceArrayOperatorIndex
    public let  array_set_typed: FoundryExtensionInterfaceArraySetTyped

    public let  packed_string_array_operator_index: FoundryExtensionInterfacePackedStringArrayOperatorIndex
    public let  packed_string_array_operator_index_const: FoundryExtensionInterfacePackedStringArrayOperatorIndexConst
    public let  packed_byte_array_operator_index: FoundryExtensionInterfacePackedByteArrayOperatorIndex
    public let  packed_byte_array_operator_index_const: FoundryExtensionInterfacePackedByteArrayOperatorIndexConst
    public let  packed_color_array_operator_index: FoundryExtensionInterfacePackedColorArrayOperatorIndex
    public let  packed_color_array_operator_index_const: FoundryExtensionInterfacePackedColorArrayOperatorIndexConst
    public let  packed_float32_array_operator_index: FoundryExtensionInterfacePackedFloat32ArrayOperatorIndex
    public let  packed_float32_array_operator_index_const: FoundryExtensionInterfacePackedFloat32ArrayOperatorIndexConst
    public let  packed_float64_array_operator_index: FoundryExtensionInterfacePackedFloat64ArrayOperatorIndex
    public let  packed_float64_array_operator_index_const: FoundryExtensionInterfacePackedFloat64ArrayOperatorIndexConst
    public let  packed_int32_array_operator_index: FoundryExtensionInterfacePackedInt32ArrayOperatorIndex
    public let  packed_int32_array_operator_index_const: FoundryExtensionInterfacePackedInt32ArrayOperatorIndexConst
    public let  packed_int64_array_operator_index: FoundryExtensionInterfacePackedInt64ArrayOperatorIndex
    public let  packed_int64_array_operator_index_const: FoundryExtensionInterfacePackedInt64ArrayOperatorIndexConst
    public let  packed_vector2_array_operator_index: FoundryExtensionInterfacePackedVector2ArrayOperatorIndex
    public let  packed_vector2_array_operator_index_const: FoundryExtensionInterfacePackedVector2ArrayOperatorIndexConst
    public let  packed_vector3_array_operator_index: FoundryExtensionInterfacePackedVector3ArrayOperatorIndex
    public let  packed_vector3_array_operator_index_const: FoundryExtensionInterfacePackedVector3ArrayOperatorIndexConst
    public let  packed_vector4_array_operator_index: FoundryExtensionInterfacePackedVector4ArrayOperatorIndex?
    public let  packed_vector4_array_operator_index_const: FoundryExtensionInterfacePackedVector4ArrayOperatorIndexConst?

    public let  callable_custom_create: FoundryExtensionInterfaceCallableCustomCreate

    public let  editor_add_plugin: FoundryExtensionInterfaceEditorAddPlugin
    public let  editor_remove_plugin: FoundryExtensionInterfaceEditorRemovePlugin

    public let get_library_path: FoundryExtensionInterfaceGetLibraryPath
    public let editor_help_load_xml_from_utf8_chars: FoundryExtensionsInterfaceEditorHelpLoadXmlFromUtf8Chars?
    public let editor_help_load_xml_from_utf8_chars_and_len: FoundryExtensionsInterfaceEditorHelpLoadXmlFromUtf8CharsAndLen?
}

@_spi(FoundrySwiftRuntimePrivate) public nonisolated(unsafe) var gi: FoundryInterface!

func loadFoundryInterface(_ foundryGetProcAddrPtr: FoundryExtensionInterfaceGetProcAddress) {

    func load<T>(_ name: String) -> T {
        let rawPtr = foundryGetProcAddrPtr(name)

        guard let rawPtr else {
            fatalError("Can not load method \(name) from Foundry's interface")
        }
        return unsafeBitCast(rawPtr, to: T.self)
        //
        //        let ass = rawPtr.assumingMemoryBound(to: T.self).pointee
        //        print ("For \(name) got the address \(rawPtr) and assigning \(ass)")
        //        return rawPtr.assumingMemoryBound(to: T.self).pointee
    }

    func loadOptional<T>(_ name: String) -> T? {
        guard let rawPtr = foundryGetProcAddrPtr(name) else {
            return nil
        }
        return unsafeBitCast(rawPtr, to: T.self)
    }

    gi = FoundryInterface(
        mem_alloc2: load("mem_alloc2"),
        mem_realloc2: load("mem_realloc2"),
        mem_free2: load("mem_free2"),

        print_error: load("print_error"),
        print_error_with_message: load("print_error_with_message"),
        print_warning: load("print_warning"),
        print_warning_with_message: load("print_warning_with_message"),
        print_script_error: load("print_script_error"),
        print_script_error_with_message: load("print_script_error_with_message"),

        string_new_with_utf8_chars: load("string_new_with_utf8_chars"),
        string_to_utf8_chars: load("string_to_utf8_chars"),
        string_name_new_with_latin1_chars: load("string_name_new_with_latin1_chars"),

        get_native_struct_size: load("get_native_struct_size"),

        classdb_construct_object: load("classdb_construct_object"),
        classdb_get_method_bind: load("classdb_get_method_bind"),
        classdb_get_class_tag: load("classdb_get_class_tag"),

        classdb_register_extension_class: load("classdb_register_extension_class2"),
        classdb_register_extension_class_signal: load("classdb_register_extension_class_signal"),
        classdb_register_extension_class_method: load("classdb_register_extension_class_method"),
        classdb_register_extension_class_property: load("classdb_register_extension_class_property"),
        classdb_register_extension_class_property_group: load("classdb_register_extension_class_property_group"),
        classdb_register_extension_class_property_subgroup: load("classdb_register_extension_class_property_subgroup"),
        classdb_register_extension_class_integer_constant: load("classdb_register_extension_class_integer_constant"),
        classdb_unregister_extension_class: load("classdb_unregister_extension_class"),
        
        object_set_instance: load("object_set_instance"),
        object_get_instance_binding: load("object_get_instance_binding"),
        object_set_instance_binding: load("object_set_instance_binding"),
        object_free_instance_binding: load("object_free_instance_binding"),
        object_get_class_name: load("object_get_class_name"),
        object_method_bind_ptrcall: load("object_method_bind_ptrcall"),
        object_destroy: load("object_destroy"),

        object_has_script_method: loadOptional("object_has_script_method"),
        object_call_script_method: loadOptional("object_call_script_method"),

        global_get_singleton: load("global_get_singleton"),
        ref_get_object: load("ref_get_object"),
        ref_set_object: load("ref_set_object"),
        object_method_bind_call: load("object_method_bind_call"),

        variant_new_nil: load("variant_new_nil"),
        variant_new_copy: load("variant_new_copy"),
        variant_evaluate: load("variant_evaluate"),
        variant_hash: load("variant_hash"),
        variant_destroy: load("variant_destroy"),
        variant_get: load("variant_get"),
        variant_set: load("variant_set"),
        variant_get_type: load("variant_get_type"),
        variant_get_type_name: load("variant_get_type_name"),
        variant_stringify: load("variant_stringify"),
        variant_call: load("variant_call"),
        variant_call_static: load("variant_call_static"),
        variant_get_indexed: load("variant_get_indexed"),
        variant_set_indexed: load("variant_set_indexed"),
        variant_construct: load("variant_construct"),
        variant_get_ptr_constructor: load("variant_get_ptr_constructor"),
        variant_get_ptr_builtin_method: load("variant_get_ptr_builtin_method"),
        variant_get_ptr_operator_evaluator: load("variant_get_ptr_operator_evaluator"),
        variant_get_ptr_utility_function: load("variant_get_ptr_utility_function"),
        variant_get_ptr_destructor: load("variant_get_ptr_destructor"),
        variant_get_ptr_indexed_getter: load("variant_get_ptr_indexed_getter"),
        variant_get_ptr_indexed_setter: load("variant_get_ptr_indexed_setter"),
        variant_get_ptr_keyed_checker: load("variant_get_ptr_keyed_checker"),
        variant_get_ptr_keyed_getter: load("variant_get_ptr_keyed_getter"),
        variant_get_ptr_keyed_setter: load("variant_get_ptr_keyed_setter"),
        variant_get_named: load("variant_get_named"),
        get_variant_from_type_constructor: load("get_variant_from_type_constructor"),
        get_variant_to_type_constructor: load("get_variant_to_type_constructor"),
        array_operator_index: load("array_operator_index"),
        array_set_typed: load("array_set_typed"),

        packed_string_array_operator_index: load("packed_string_array_operator_index"),
        packed_string_array_operator_index_const: load("packed_string_array_operator_index_const"),
        packed_byte_array_operator_index: load("packed_byte_array_operator_index"),
        packed_byte_array_operator_index_const: load("packed_byte_array_operator_index_const"),
        packed_color_array_operator_index: load("packed_color_array_operator_index"),
        packed_color_array_operator_index_const: load("packed_color_array_operator_index_const"),
        packed_float32_array_operator_index: load("packed_float32_array_operator_index"),
        packed_float32_array_operator_index_const: load("packed_float32_array_operator_index_const"),
        packed_float64_array_operator_index: load("packed_float64_array_operator_index"),
        packed_float64_array_operator_index_const: load("packed_float64_array_operator_index_const"),
        packed_int32_array_operator_index: load("packed_int32_array_operator_index"),
        packed_int32_array_operator_index_const: load("packed_int32_array_operator_index_const"),
        packed_int64_array_operator_index: load("packed_int64_array_operator_index"),
        packed_int64_array_operator_index_const: load("packed_int64_array_operator_index_const"),
        packed_vector2_array_operator_index: load("packed_vector2_array_operator_index"),
        packed_vector2_array_operator_index_const: load("packed_vector2_array_operator_index_const"),
        packed_vector3_array_operator_index: load("packed_vector3_array_operator_index"),
        packed_vector3_array_operator_index_const: load("packed_vector3_array_operator_index_const"),
        packed_vector4_array_operator_index: loadOptional("packed_vector4_array_operator_index"),
        packed_vector4_array_operator_index_const: loadOptional("packed_vector4_array_operator_index_const"),

        callable_custom_create: load("callable_custom_create"),
        editor_add_plugin: load("editor_add_plugin"),
        editor_remove_plugin: load("editor_remove_plugin"),

        get_library_path: load("get_library_path"),
        editor_help_load_xml_from_utf8_chars: loadOptional("editor_help_load_xml_from_utf8_chars"),
        editor_help_load_xml_from_utf8_chars_and_len: loadOptional("editor_help_load_xml_from_utf8_chars_and_len")
    )
}

///
/// For use in extensions created for a Foundry project
///
/// Call this function from your declared Swift entry point passing the three
/// pointers that you receive from Foundry and passing a method that will
/// be invoked during the various stages of the initialization.
///
/// This routine takes OpaquePointers to help you simplify the declaration of
/// your Swift entry point, which can look like this:
///
/// ```
/// @cdecl("swift_entry_point")
/// public func swift_entry_point (i: OpaquePointer?, l: OpaquePointer?, e: OpaquePointer?) -> UInt8 {
///     guard let iface, let lib, let ext else {
///         return 0
///     }
///     initializeSwiftModule (iface, lib, ext, initHook: myInit, deInitHook: myDeinit)
///     return 1
/// }
///
/// func myInit (level: ExtensionInitializationLevel) {
///    if level == .scene {
///       registerType (MySpinningCube.self)
///    }
/// }
///
/// func myDeInit (level: ExtensionInitializationLevel) {
///     if level == .scene {
///         print ("Deinitialized")
///     }
/// }
/// ```
/// - Parameters:
///  - foundryGetProcAddrPtr: the first parameter you got on your entry point, it points to the API in Foundry to request pointers to the engine functions.
///  - libraryPtr: the second parameter you entry point gets, it is of type FoundryExtensionClassLibraryPtr
///  - extensionPtr: the third parameter you get, it is of type FoundryExtensionInitialization and it is filled with our callbacks
///  - initHook: this method is invoked repeatedly during the various stages of the extension
///  initialization
///  - deInitHook: this method is invoked repeatedly when various stages of the extension are wrapped up
///  - minimumInitializationLevel: How early does this extension need to be activated? The default "scene" level should be sufficient for most cases,
///    but if your Extension is only an Editor tool you could set this higher to .tool. If you need to extend base functionality set .core or .server.
public func initializeSwiftModule(
    _ foundryGetProcAddrPtr: OpaquePointer,
    _ libraryPtr: OpaquePointer,
    _ extensionPtr: OpaquePointer,
    initHook: @escaping (ExtensionInitializationLevel) -> (),
    deInitHook: @escaping (ExtensionInitializationLevel) -> (),
    minimumInitializationLevel: ExtensionInitializationLevel = .scene
) {
    let getProcAddrFun = unsafeBitCast(foundryGetProcAddrPtr, to: FoundryExtensionInterfaceGetProcAddress.self)
    loadFoundryInterface(getProcAddrFun)

    // For now, we will only initialize the library once, so all of the FoundrySwift
    // modules are bundled together.   This is not optimal, see this bug
    // with a description of what we should be doing:
    // https://github.com/migueldeicaza/FoundrySwift/issues/72
    if extensionInterface == nil {
        extensionInterface = LibFoundryExtensionInterface(library: FoundryExtensionClassLibraryPtr(libraryPtr), getProcAddrFun: getProcAddrFun)
    }
    extensionInitCallbacks[libraryPtr] = initHook
    extensionDeInitCallbacks[libraryPtr] = deInitHook
    let initialization = UnsafeMutablePointer<FoundryExtensionInitialization>(extensionPtr)
    initialization.pointee.deinitialize = extension_deinitialize
    initialization.pointee.initialize = extension_initialize
    initialization.pointee.minimum_initialization_level = FoundryExtensionInitializationLevel(UInt32(minimumInitializationLevel.rawValue))
    initialization.pointee.userdata = UnsafeMutableRawPointer(libraryPtr)
}

/*
 Cannot assign value of type 'UnsafePointer<FoundryExtensionInterfaceVariantGetPtrConstructor>'  to type 'FoundryExtensionInterfaceVariantGetPtrConstructor'

 (aka '@convention(c) (FoundryExtensionVariantType, Int32) -> Optional<@convention(c) (Optional<UnsafeMutableRawPointer>, Optional<UnsafePointer<Optional<UnsafeRawPointer>>>) -> ()>')
 */

func withArgPointers(_ _args: UnsafeMutableRawPointer?..., body: ([UnsafeRawPointer?]) -> Void) {
    body(unsafeBitCast(_args, to: [UnsafeRawPointer?].self))
}
