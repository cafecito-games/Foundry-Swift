//
//  InitializationLevel.swift
//  FoundrySwift
//
//  Created by Miguel de Icaza on 10/16/25.
//

import FoundryExtensionC

public enum ExtensionInitializationLevel: Int64, Sendable {
    /// The library is initialized at the same time as the core features of the engine.
    case core = 0
    /// The library is initialized at the same time as the engine's servers (such as ``RenderingServer`` or ``PhysicsServer3D``).
    case servers = 1
    /// The library is initialized at the same time as the engine's scene-related classes.
    case scene = 2
    // /The library is initialized at the same time as the engine's editor classes.
    /// Only happens when loading the FoundryExtension in the editor.
    case editor = 3
}

public typealias FoundryInitializationLevel = ExtensionInitializationLevel

extension ExtensionInitializationLevel {
    init?(cLevel: FoundryExtensionInitializationLevel) {
        self.init(rawValue: Int64(cLevel.rawValue))
    }

    var cLevel: FoundryExtensionInitializationLevel {
        FoundryExtensionInitializationLevel(UInt32(rawValue))
    }
}
