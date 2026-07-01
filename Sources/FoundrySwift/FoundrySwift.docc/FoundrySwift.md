# ``FoundrySwift``

Framework to write Foundry Game Extensions using the Swift Programming Language.

FoundrySwift provides a binding that allows developers to use the Swift language
to author code in Swift that can be used in a game (these are called "Foundry
Extension"), and can also be used to drive Foundry directly from Swift (the
companion library "FoundrySwiftKit" provides a simple interface to embed and host
Foundry into an existing application).

The benefit is using a safe, high-performance language, along with its ecosystem
of libraries with your Foundry game.   And it runs side-by-side with FoundryScript or
your existing C# code.

FoundrySwift works by supporting the public extension API from Foundry and mapping
that API to Swift idioms.   If you are familiar with Foundry and the FoundryScript
language, you can read the <doc:Differences> document to get a taste on how
things are done in this binding.

## Topics

### Developing with FoundrySwift

Guides to get you started with FoundrySwift, and work in either Xcode or Visual
Studio Code on macOS:

- <doc:FoundrySwift-Tutorials>
- <doc:DebugInXcode>
- <doc:WorkingInVsCode>

### Articles and Tutorials

Going in depth with FoundrySwift:

- <doc:Differences>
- <doc:Variants>
- <doc:Exports>
- <doc:Signals>
- <doc:RemoteProcedureCalls>
- <doc:CustomTypes>
- <doc:Singletons>
- <doc:BindingNodes>
- <doc:RunningInEditor>
- <doc:MemoryManagement>
- <doc:TypesTranslation>
- <doc:Documentation>

### Platform Integration

- <doc:iOS>

### Foundry Nodes

Some interesting Foundry types:

- ``Node``
  - ``Viewport``
    - ``Window``
    - ``SubViewport``
  - ``CanvasItem``
    - ``Node2D``
    - ``Control``
  - ``Node3D``
  - ``AnimationPlayer``
  - ``AnimationTree``
  - ``AudioStreamPlayer``
  - ``CanvasLayer``
  - ``HTTPRequest``
  - ``MultiplayerSpawner``
  - ``MultiplayerSynchronizer``
  - ``NavigationAgent2D``
  - ``NavigationAgent3D``
  - ``NavigationObstacle2D``
  - ``NavigationObstacle3D``
  - ``ResourcePreloader``
  - ``ShaderGlobalsOverride``
  - ``SkeletonIK3D``
  - ``Timer``
  - ``WorldEnvironment``
- ``Resource``
