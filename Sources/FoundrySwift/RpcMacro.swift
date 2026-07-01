//
//  RpcMacro.swift
//  FoundrySwift
//
//  Created by Claude on 2025-01-02.
//

/// Marks a function for RPC (Remote Procedure Call) in Foundry's multiplayer system.
///
/// When this attribute is applied to a function, the `@Foundry` macro will register the RPC configuration
/// for the method using `Node.rpcConfig(method:config:)`.
///
/// Usage:
/// ```swift
/// @Foundry class MyNode: Node {
///     @Callable @Rpc(mode: .anyPeer, transferMode: .reliable)
///     func syncPosition(_ position: Vector3) {
///         // Handle synced position
///     }
/// }
/// ```
///
/// - Parameter mode: The RPC mode determining who can call this method. Defaults to `.authority`.
/// - Parameter callLocal: If `true`, the method will also be called locally when RPC is invoked. Defaults to `false`.
/// - Parameter transferMode: The transfer mode for the RPC packets. Defaults to `.unreliable`.
/// - Parameter transferChannel: The channel to send the RPC on. Defaults to `0`.
@attached(peer)
public macro Rpc(
    mode: MultiplayerAPI.RPCMode = .authority,
    callLocal: Bool = false,
    transferMode: MultiplayerPeer.TransferMode = .unreliable,
    transferChannel: Int = 0
) = #externalMacro(module: "FoundrySwiftMacroLibrary", type: "FoundryRpc")
