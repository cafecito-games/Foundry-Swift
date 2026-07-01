# Working in VS Code

Develop and debug FoundrySwift Code in Visual Studio Code

## Overview

Visual Studio Code provides a compelling alternative to Xcode for FoundrySwift
developers on macOS.


### Prerequisites

To develop with FoundrySwift in Visual Studio Code, you will need the following
prerequisites:

1. Foundry Engine without .NET support from the [official Foundry website](https://foundryengine.org/download/). 

2. Visual Studio Code from the [official Visual Studio Code website](https://code.visualstudio.com/Download). 

3. Install Swift from the [official Swift website](https://www.swift.org/install/).  

### Configuring Visual Studio Code

The Swift Extension for Visual Studio Code from the Swift Server Work Group 
provides code completion, code navigation, build task creation, and integration 
with LLDB for debugging, along with many other features for devloping code with
Swift.

Install the Swift Extension for Visual Studio from the 
[Visual Studio
Marketplace](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang),
or search for Swift on the Extensions tab in Visual Studio Code.

Installing the Swift Extension will automatically install the CodeLLDB Extension
as a dependency for Visual Studio Code for debugging support.

### Create a Swift library package for your project

Create a folder on disk in a file location near the Foundry project that you want 
to use with FoundrySwift.  For this article, we will assume you are working
against the sample project and code from the [Meet FoundrySwift Tutorial](https://migueldeicaza.github.io/FoundrySwiftDocs/tutorials/foundryswift-tutorials)

On the commmand line, change directories into the folder you created and run the
swift package command to initialize a new library package:

`swift package init --type library`

You can now open your package folder in Visual Studio Code:

`code .`

Or use the "Open Folder..." File menu option in Visual Studio Code.

### Setup FoundrySwift in Package.swift

Inside Visual Studio Code, open Package.swift


Set the minimum platform target to macOS 13 and set your library type to dynamic by adding `type: .dynamic,` to the products library section of your package configuration. E.g.,

```swift
platforms: [.macOS(.v13)],
products: [
   .library(
      name: "SimpleRunnerDriver",
      type: .dynamic,
      targets: ["SimpleRunnerDriver"]),
]
```

Add the FoundrySwift dependency to your package.


```swift
dependencies: [
   .package(url: "https://github.com/migueldeicaza/FoundrySwift", branch: "main")
],
```

Modify your library target to reference the FoundrySwift dependency, and add
necessary swift compiler and linker settings:


```swift
.target(
   name: "SimpleRunnerDriver",
   dependencies: [
         "FoundrySwift",
   ],
   swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
),
```

At this point, you should be able to follow the Meet FoundrySwift Tutorial
beginning in Section 2.

### Building your FoundrySwift package

When you are ready to build your FoundrySwift package, the Swift Extension
provides a default Build task you can execute with Visual Studio Code's Build
Shortcut - Ctrl+Shift+B (or Cmd+Shift+B on Mac).  

The initial build may take a very long time.

### Setting up your foundry_extension 

When creating your `foundry_extension` file, your configuration file will need to
contain macOS settings, and you will need to copy the libraries to the `bin`
folder inside your Foundry project:

```
[libraries]
macos.debug = "res://bin/libSimpleRunnerDriver.dylib"

[dependencies]
macos.debug = {"res://bin/libFoundrySwift.dylib" : ""}
```

You can copy these files to your Foundry projects `bin` folder from the build 
output folder located in `.build/debug/` inside the directory where you
initialized your Swift package.


### Debugging your FoundrySwift code

You can debug your FoundrySwift code on macOS using the CodeLLDB Extension to
launch your game directly from Visual Studio Code.

In order to do this, you will need to add a Launch 
task to your project.
In Visual Sutdio Code, switch to the "Run and Debug" tab.

Create a `launch.json` file by tapping on "create a launch.json file"
and selecting "LLDB", which should be the first suggested option.

In the newly created launch.json file, you should modify the existing
lldb task to support launching as follows:

1. Change the value for `name` to `Launch Foundry Game`
2. Add a line for `program` with the path to your Foundry executable
3. Add a line for `args` with any necessary arguments to launch your game,
   such as the path to your foundry project
4. specify the `cwd` (current working directory)

Your launch configuration for lldb should now look like this:

```json
{
   "type": "lldb",
   "request": "launch",
   "name": "Launch Foundry Game",
   "program": "path/to/your/Foundry/executable",
   "args": ["--path", "path/to/your/game/project"],
   "cwd": "${workspaceFolder}"
}
```

Once you save this file, "Launch Foundry Game" will appear as the default debug
task in the "Run and Debug" sidebar.
To run this task, click on the green play button next to
"Launch Foundry Game" in the "Run and Debug" sidebar.
This action will launch the game with the LLDB debugger attached.

At this point, Visual Studio Code should now stop on any breakpoints you have
set, and you should be able to inspect Variables, set Watches, etc.

#### (Optional) Add a `Attach` Debug task

1. Open the launch.json file.
2. Add a comma after the last closing brace `}` of the existing configuration.
3. Paste the following configuration:

```json
{
    "type": "lldb",
    "request": "attach",
    "name": "Attach to PID",
    "pid": "${command:pickProcess}"
}
```

Your `launch.json` should now look something like this:

```json
{
   "version": "0.2.0",
   "configurations": [
      {
         "type": "lldb",
         "request": "launch",
         "name": "Launch Foundry Game",
         "program": "path/to/your/Foundry/executable",
         "args": ["--path", "path/to/your/game/project"],
         "cwd": "${workspaceFolder}"
      },
      {
         "type": "lldb",
         "request": "attach",
         "name": "Attach to PID",
         "pid": "${command:pickProcess}"
      }
   ]
}
```

Once you save this file, "Attach to PID" should appear in the debug options list.

To debug your app using "Attach to PID", follow these steps: 

1. First, take note of running Foundry process PIDs by running "Attach to PID" 
and searching for Foundry. 

2. Launch your game from Foundry

3. Return to Visual Studio and press F5 to run "Attach to PID" again.

4. Search again for Foundry and select the PID for your game, which should be the
   only process that wasn't listed in step (1) above.  

> On macOS, it may be possible to differentiate your game's PID from other Foundry
> PIDs by looking at the additional information Visual Studio Code lists about
> each process, including command line options.

> Warning: 
> On Mac, you will need to make your Foundry engine debuggable following the steps from
> this article [Debug in Xcode](https://migueldeicaza.github.io/FoundrySwiftDocs/documentation/foundryswift/debuginxcode)
