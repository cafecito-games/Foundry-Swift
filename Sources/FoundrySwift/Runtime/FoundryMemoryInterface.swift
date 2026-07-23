//
//  File 2.swift
//  
//
//  Created by Miguel de Icaza on 3/25/23.
//

func gmem_alloc (_ size: Int) -> UnsafeMutableRawPointer? {
    gi.mem_alloc2 (size, 0)
}

func gmem_realloc (_ ptr: UnsafeMutableRawPointer?, size: Int) -> UnsafeMutableRawPointer? {
    return gi.mem_realloc2 (ptr, size, 0)
}

func gmem_free (_ ptr: UnsafeMutableRawPointer?) {
    return gi.mem_free2 (ptr, 0)
}

func gprintError (_ description: String, message: String? = nil, function: String, file: String, line: Int32, editorNotify: Bool) {
    if let message {
        gi.print_error_with_message (description, message, function, file, line, editorNotify ? 1 : 0)
    } else {
        gi.print_error (description, function, file, line, editorNotify ? 1 : 0)
    }
}

func gprintWarning (_ description: String, message: String? = nil, function: String, file: String, line: Int32, editorNotify: Bool) {
    if let message {
        gi.print_warning_with_message (description, message, function, file, line, editorNotify ? 1 : 0)
    } else {
        gi.print_warning (description, function, file, line, editorNotify ? 1 : 0)
    }
}

func gprintScriptError (_ description: String, message: String? = nil, function: String, file: String, line: Int32, editorNotify: Bool) {
    if let message {
        gi.print_script_error_with_message (description, message, function, file, line, editorNotify ? 1 : 0)
    } else {
        gi.print_script_error (description, function, file, line, editorNotify ? 1 : 0)
    }
}

func gGetNativeStructSize (name: String) -> UInt64 {
    return gi.get_native_struct_size (name)
}

/// Adds the type described by `name` as an Editor plugin.
///
/// You typically invoke this method from the `setupScene` method when initializing
/// the `.editor` level.   The type specified must subclass `EditorPlugin` and
/// should have been declared with `@Foundry(.tool)`.
public func editorAddPlugin(name: StringName) {
    withUnsafeMutablePointer(to: &name.content) { namePtr in
        gi.editor_add_plugin(namePtr)
    }
}

//
///* variant general */
//void (*variant_new_copy)(FoundryExtensionVariantPtr r_dest, FoundryExtensionConstVariantPtr p_src);
//void (*variant_new_nil)(FoundryExtensionVariantPtr r_dest);
//void (*variant_destroy)(FoundryExtensionVariantPtr p_self);
//
///* variant type */
//void (*variant_call)(FoundryExtensionVariantPtr p_self, FoundryExtensionConstStringNamePtr p_method, const FoundryExtensionConstVariantPtr *p_args, FoundryExtensionInt p_argument_count, FoundryExtensionVariantPtr r_return, FoundryExtensionCallError *r_error);
//void (*variant_call_static)(FoundryExtensionVariantType p_type, FoundryExtensionConstStringNamePtr p_method, const FoundryExtensionConstVariantPtr *p_args, FoundryExtensionInt p_argument_count, FoundryExtensionVariantPtr r_return, FoundryExtensionCallError *r_error);
//void (*variant_evaluate)(FoundryExtensionVariantOperator p_op, FoundryExtensionConstVariantPtr p_a, FoundryExtensionConstVariantPtr p_b, FoundryExtensionVariantPtr r_return, FoundryExtensionBool *r_valid);
//void (*variant_set)(FoundryExtensionVariantPtr p_self, FoundryExtensionConstVariantPtr p_key, FoundryExtensionConstVariantPtr p_value, FoundryExtensionBool *r_valid);
//void (*variant_set_named)(FoundryExtensionVariantPtr p_self, FoundryExtensionConstStringNamePtr p_key, FoundryExtensionConstVariantPtr p_value, FoundryExtensionBool *r_valid);
//void (*variant_set_keyed)(FoundryExtensionVariantPtr p_self, FoundryExtensionConstVariantPtr p_key, FoundryExtensionConstVariantPtr p_value, FoundryExtensionBool *r_valid);
//void (*variant_set_indexed)(FoundryExtensionVariantPtr p_self, FoundryExtensionInt p_index, FoundryExtensionConstVariantPtr p_value, FoundryExtensionBool *r_valid, FoundryExtensionBool *r_oob);
//void (*variant_get)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionConstVariantPtr p_key, FoundryExtensionVariantPtr r_ret, FoundryExtensionBool *r_valid);
//void (*variant_get_named)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionConstStringNamePtr p_key, FoundryExtensionVariantPtr r_ret, FoundryExtensionBool *r_valid);
//void (*variant_get_keyed)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionConstVariantPtr p_key, FoundryExtensionVariantPtr r_ret, FoundryExtensionBool *r_valid);
//void (*variant_get_indexed)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionInt p_index, FoundryExtensionVariantPtr r_ret, FoundryExtensionBool *r_valid, FoundryExtensionBool *r_oob);
//FoundryExtensionBool (*variant_iter_init)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionVariantPtr r_iter, FoundryExtensionBool *r_valid);
//FoundryExtensionBool (*variant_iter_next)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionVariantPtr r_iter, FoundryExtensionBool *r_valid);
//void (*variant_iter_get)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionVariantPtr r_iter, FoundryExtensionVariantPtr r_ret, FoundryExtensionBool *r_valid);
//FoundryExtensionInt (*variant_hash)(FoundryExtensionConstVariantPtr p_self);
//FoundryExtensionInt (*variant_recursive_hash)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionInt p_recursion_count);
//FoundryExtensionBool (*variant_hash_compare)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionConstVariantPtr p_other);
//FoundryExtensionBool (*variant_booleanize)(FoundryExtensionConstVariantPtr p_self);
//void (*variant_duplicate)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionVariantPtr r_ret, FoundryExtensionBool p_deep);
//void (*variant_stringify)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionStringPtr r_ret);
//
//FoundryExtensionVariantType (*variant_get_type)(FoundryExtensionConstVariantPtr p_self);
//FoundryExtensionBool (*variant_has_method)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionConstStringNamePtr p_method);
//FoundryExtensionBool (*variant_has_member)(FoundryExtensionVariantType p_type, FoundryExtensionConstStringNamePtr p_member);
//FoundryExtensionBool (*variant_has_key)(FoundryExtensionConstVariantPtr p_self, FoundryExtensionConstVariantPtr p_key, FoundryExtensionBool *r_valid);
//void (*variant_get_type_name)(FoundryExtensionVariantType p_type, FoundryExtensionStringPtr r_name);
//FoundryExtensionBool (*variant_can_convert)(FoundryExtensionVariantType p_from, FoundryExtensionVariantType p_to);
//FoundryExtensionBool (*variant_can_convert_strict)(FoundryExtensionVariantType p_from, FoundryExtensionVariantType p_to);
//
///* ptrcalls */
//FoundryExtensionVariantFromTypeConstructorFunc (*get_variant_from_type_constructor)(FoundryExtensionVariantType p_type);
//FoundryExtensionTypeFromVariantConstructorFunc (*get_variant_to_type_constructor)(FoundryExtensionVariantType p_type);
//FoundryExtensionPtrOperatorEvaluator (*variant_get_ptr_operator_evaluator)(FoundryExtensionVariantOperator p_operator, FoundryExtensionVariantType p_type_a, FoundryExtensionVariantType p_type_b);
//FoundryExtensionPtrBuiltInMethod (*variant_get_ptr_builtin_method)(FoundryExtensionVariantType p_type, FoundryExtensionConstStringNamePtr p_method, FoundryExtensionInt p_hash);
//FoundryExtensionPtrConstructor (*variant_get_ptr_constructor)(FoundryExtensionVariantType p_type, int32_t p_constructor);
//FoundryExtensionPtrDestructor (*variant_get_ptr_destructor)(FoundryExtensionVariantType p_type);
//void (*variant_construct)(FoundryExtensionVariantType p_type, FoundryExtensionVariantPtr p_base, const FoundryExtensionConstVariantPtr *p_args, int32_t p_argument_count, FoundryExtensionCallError *r_error);
//FoundryExtensionPtrSetter (*variant_get_ptr_setter)(FoundryExtensionVariantType p_type, FoundryExtensionConstStringNamePtr p_member);
//FoundryExtensionPtrGetter (*variant_get_ptr_getter)(FoundryExtensionVariantType p_type, FoundryExtensionConstStringNamePtr p_member);
//FoundryExtensionPtrIndexedSetter (*variant_get_ptr_indexed_setter)(FoundryExtensionVariantType p_type);
//FoundryExtensionPtrIndexedGetter (*variant_get_ptr_indexed_getter)(FoundryExtensionVariantType p_type);
//FoundryExtensionPtrKeyedSetter (*variant_get_ptr_keyed_setter)(FoundryExtensionVariantType p_type);
//FoundryExtensionPtrKeyedGetter (*variant_get_ptr_keyed_getter)(FoundryExtensionVariantType p_type);
//FoundryExtensionPtrKeyedChecker (*variant_get_ptr_keyed_checker)(FoundryExtensionVariantType p_type);
//void (*variant_get_constant_value)(FoundryExtensionVariantType p_type, FoundryExtensionConstStringNamePtr p_constant, FoundryExtensionVariantPtr r_ret);
//FoundryExtensionPtrUtilityFunction (*variant_get_ptr_utility_function)(FoundryExtensionConstStringNamePtr p_function, FoundryExtensionInt p_hash);
//
///*  extra utilities */
//void (*string_new_with_latin1_chars)(FoundryExtensionStringPtr r_dest, const char *p_contents);
//void (*string_new_with_utf8_chars)(FoundryExtensionStringPtr r_dest, const char *p_contents);
//void (*string_new_with_utf16_chars)(FoundryExtensionStringPtr r_dest, const char16_t *p_contents);
//void (*string_new_with_utf32_chars)(FoundryExtensionStringPtr r_dest, const char32_t *p_contents);
//void (*string_new_with_wide_chars)(FoundryExtensionStringPtr r_dest, const wchar_t *p_contents);
//void (*string_new_with_latin1_chars_and_len)(FoundryExtensionStringPtr r_dest, const char *p_contents, FoundryExtensionInt p_size);
//void (*string_new_with_utf8_chars_and_len)(FoundryExtensionStringPtr r_dest, const char *p_contents, FoundryExtensionInt p_size);
//void (*string_new_with_utf16_chars_and_len)(FoundryExtensionStringPtr r_dest, const char16_t *p_contents, FoundryExtensionInt p_size);
//void (*string_new_with_utf32_chars_and_len)(FoundryExtensionStringPtr r_dest, const char32_t *p_contents, FoundryExtensionInt p_size);
//void (*string_new_with_wide_chars_and_len)(FoundryExtensionStringPtr r_dest, const wchar_t *p_contents, FoundryExtensionInt p_size);
///* Information about the following functions:
// * - The return value is the resulting encoded string length.
// * - The length returned is in characters, not in bytes. It also does not include a trailing zero.
// * - These functions also do not write trailing zero, If you need it, write it yourself at the position indicated by the length (and make sure to allocate it).
// * - Passing NULL in r_text means only the length is computed (again, without including trailing zero).
// * - p_max_write_length argument is in characters, not bytes. It will be ignored if r_text is NULL.
// * - p_max_write_length argument does not affect the return value, it's only to cap write length.
// */
//FoundryExtensionInt (*string_to_latin1_chars)(FoundryExtensionConstStringPtr p_self, char *r_text, FoundryExtensionInt p_max_write_length);
//FoundryExtensionInt (*string_to_utf8_chars)(FoundryExtensionConstStringPtr p_self, char *r_text, FoundryExtensionInt p_max_write_length);
//FoundryExtensionInt (*string_to_utf16_chars)(FoundryExtensionConstStringPtr p_self, char16_t *r_text, FoundryExtensionInt p_max_write_length);
//FoundryExtensionInt (*string_to_utf32_chars)(FoundryExtensionConstStringPtr p_self, char32_t *r_text, FoundryExtensionInt p_max_write_length);
//FoundryExtensionInt (*string_to_wide_chars)(FoundryExtensionConstStringPtr p_self, wchar_t *r_text, FoundryExtensionInt p_max_write_length);
//char32_t *(*string_operator_index)(FoundryExtensionStringPtr p_self, FoundryExtensionInt p_index);
//const char32_t *(*string_operator_index_const)(FoundryExtensionConstStringPtr p_self, FoundryExtensionInt p_index);
//
//void (*string_operator_plus_eq_string)(FoundryExtensionStringPtr p_self, FoundryExtensionConstStringPtr p_b);
//void (*string_operator_plus_eq_char)(FoundryExtensionStringPtr p_self, char32_t p_b);
//void (*string_operator_plus_eq_cstr)(FoundryExtensionStringPtr p_self, const char *p_b);
//void (*string_operator_plus_eq_wcstr)(FoundryExtensionStringPtr p_self, const wchar_t *p_b);
//void (*string_operator_plus_eq_c32str)(FoundryExtensionStringPtr p_self, const char32_t *p_b);
//
///*  XMLParser extra utilities */
//
//FoundryExtensionInt (*xml_parser_open_buffer)(FoundryExtensionObjectPtr p_instance, const uint8_t *p_buffer, size_t p_size);
//
///*  FileAccess extra utilities */
//
//void (*file_access_store_buffer)(FoundryExtensionObjectPtr p_instance, const uint8_t *p_src, uint64_t p_length);
//uint64_t (*file_access_get_buffer)(FoundryExtensionConstObjectPtr p_instance, uint8_t *p_dst, uint64_t p_length);
//
///*  WorkerThreadPool extra utilities */
//
//int64_t (*worker_thread_pool_add_native_group_task)(FoundryExtensionObjectPtr p_instance, void (*p_func)(void *, uint32_t), void *p_userdata, int p_elements, int p_tasks, FoundryExtensionBool p_high_priority, FoundryExtensionConstStringPtr p_description);
//int64_t (*worker_thread_pool_add_native_task)(FoundryExtensionObjectPtr p_instance, void (*p_func)(void *), void *p_userdata, FoundryExtensionBool p_high_priority, FoundryExtensionConstStringPtr p_description);
//
///* Packed array functions */
//
//uint8_t *(*packed_byte_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedByteArray
//const uint8_t *(*packed_byte_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedByteArray
//
//FoundryExtensionTypePtr (*packed_color_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedColorArray, returns Color ptr
//FoundryExtensionTypePtr (*packed_color_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedColorArray, returns Color ptr
//
//float *(*packed_float32_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedFloat32Array
//const float *(*packed_float32_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedFloat32Array
//double *(*packed_float64_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedFloat64Array
//const double *(*packed_float64_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedFloat64Array
//
//int32_t *(*packed_int32_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedInt32Array
//const int32_t *(*packed_int32_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedInt32Array
//int64_t *(*packed_int64_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedInt32Array
//const int64_t *(*packed_int64_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedInt32Array
//
//FoundryExtensionStringPtr (*packed_string_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedStringArray
//FoundryExtensionStringPtr (*packed_string_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedStringArray
//
//FoundryExtensionTypePtr (*packed_vector2_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedVector2Array, returns Vector2 ptr
//FoundryExtensionTypePtr (*packed_vector2_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedVector2Array, returns Vector2 ptr
//FoundryExtensionTypePtr (*packed_vector3_array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedVector3Array, returns Vector3 ptr
//FoundryExtensionTypePtr (*packed_vector3_array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be a PackedVector3Array, returns Vector3 ptr
//
//FoundryExtensionVariantPtr (*array_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionInt p_index); // p_self should be an Array ptr
//FoundryExtensionVariantPtr (*array_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionInt p_index); // p_self should be an Array ptr
//void (*array_ref)(FoundryExtensionTypePtr p_self, FoundryExtensionConstTypePtr p_from); // p_self should be an Array ptr
//void (*array_set_typed)(FoundryExtensionTypePtr p_self, FoundryExtensionVariantType p_type, FoundryExtensionConstStringNamePtr p_class_name, FoundryExtensionConstVariantPtr p_script); // p_self should be an Array ptr
//
///* Dictionary functions */
//
//FoundryExtensionVariantPtr (*dictionary_operator_index)(FoundryExtensionTypePtr p_self, FoundryExtensionConstVariantPtr p_key); // p_self should be an Dictionary ptr
//FoundryExtensionVariantPtr (*dictionary_operator_index_const)(FoundryExtensionConstTypePtr p_self, FoundryExtensionConstVariantPtr p_key); // p_self should be an Dictionary ptr
//
///* OBJECT */
//
//void (*object_method_bind_call)(FoundryExtensionMethodBindPtr p_method_bind, FoundryExtensionObjectPtr p_instance, const FoundryExtensionConstVariantPtr *p_args, FoundryExtensionInt p_arg_count, FoundryExtensionVariantPtr r_ret, FoundryExtensionCallError *r_error);
//void (*object_method_bind_ptrcall)(FoundryExtensionMethodBindPtr p_method_bind, FoundryExtensionObjectPtr p_instance, const FoundryExtensionConstTypePtr *p_args, FoundryExtensionTypePtr r_ret);
//void (*object_destroy)(FoundryExtensionObjectPtr p_o);
//FoundryExtensionObjectPtr (*global_get_singleton)(FoundryExtensionConstStringNamePtr p_name);
//
//void *(*object_get_instance_binding)(FoundryExtensionObjectPtr p_o, void *p_token, const FoundryExtensionInstanceBindingCallbacks *p_callbacks);
//void (*object_set_instance_binding)(FoundryExtensionObjectPtr p_o, void *p_token, void *p_binding, const FoundryExtensionInstanceBindingCallbacks *p_callbacks);
//
//void (*object_set_instance)(FoundryExtensionObjectPtr p_o, FoundryExtensionConstStringNamePtr p_classname, FoundryExtensionClassInstancePtr p_instance); /* p_classname should be a registered extension class and should extend the p_o object's class. */
//
//FoundryExtensionObjectPtr (*object_cast_to)(FoundryExtensionConstObjectPtr p_object, void *p_class_tag);
//FoundryExtensionObjectPtr (*object_get_instance_from_id)(GDObjectInstanceID p_instance_id);
//GDObjectInstanceID (*object_get_instance_id)(FoundryExtensionConstObjectPtr p_object);
//
///* REFERENCE */
//
//FoundryExtensionObjectPtr (*ref_get_object)(FoundryExtensionConstRefPtr p_ref);
//void (*ref_set_object)(FoundryExtensionRefPtr p_ref, FoundryExtensionObjectPtr p_object);
//
///* SCRIPT INSTANCE */
//
//FoundryExtensionScriptInstancePtr (*script_instance_create)(const FoundryExtensionScriptInstanceInfo *p_info, FoundryExtensionScriptInstanceDataPtr p_instance_data);
//
///* CLASSDB */
//
//FoundryExtensionObjectPtr (*classdb_construct_object)(FoundryExtensionConstStringNamePtr p_classname); /* The passed class must be a built-in foundry class, or an already-registered extension class. In both case, object_set_instance should be called to fully initialize the object. */
//FoundryExtensionMethodBindPtr (*classdb_get_method_bind)(FoundryExtensionConstStringNamePtr p_classname, FoundryExtensionConstStringNamePtr p_methodname, FoundryExtensionInt p_hash);
//void *(*classdb_get_class_tag)(FoundryExtensionConstStringNamePtr p_classname);
//
///* CLASSDB EXTENSION */
//
///* Provided parameters for `classdb_register_extension_*` can be safely freed once the function returns. */
//void (*classdb_register_extension_class)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionConstStringNamePtr p_class_name, FoundryExtensionConstStringNamePtr p_parent_class_name, const FoundryExtensionClassCreationInfo *p_extension_funcs);
//void (*classdb_register_extension_class_method)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionConstStringNamePtr p_class_name, const FoundryExtensionClassMethodInfo *p_method_info);
//void (*classdb_register_extension_class_integer_constant)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionConstStringNamePtr p_class_name, FoundryExtensionConstStringNamePtr p_enum_name, FoundryExtensionConstStringNamePtr p_constant_name, FoundryExtensionInt p_constant_value, FoundryExtensionBool p_is_bitfield);
//void (*classdb_register_extension_class_property)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionConstStringNamePtr p_class_name, const FoundryExtensionPropertyInfo *p_info, FoundryExtensionConstStringNamePtr p_setter, FoundryExtensionConstStringNamePtr p_getter);
//void (*classdb_register_extension_class_property_group)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionConstStringNamePtr p_class_name, FoundryExtensionConstStringPtr p_group_name, FoundryExtensionConstStringPtr p_prefix);
//void (*classdb_register_extension_class_property_subgroup)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionConstStringNamePtr p_class_name, FoundryExtensionConstStringPtr p_subgroup_name, FoundryExtensionConstStringPtr p_prefix);
//void (*classdb_register_extension_class_signal)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionConstStringNamePtr p_class_name, FoundryExtensionConstStringNamePtr p_signal_name, const FoundryExtensionPropertyInfo *p_argument_info, FoundryExtensionInt p_argument_count);
//void (*classdb_unregister_extension_class)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionConstStringNamePtr p_class_name); /* Unregistering a parent class before a class that inherits it will result in failure. Inheritors must be unregistered first. */
//
//void (*get_library_path)(FoundryExtensionClassLibraryPtr p_library, FoundryExtensionStringPtr r_path);
