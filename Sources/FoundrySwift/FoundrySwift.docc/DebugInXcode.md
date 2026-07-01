# Debug in Xcode

Debug Swift code written for Foundry in Xcode.

## Overview

Debugging your FoundrySwift-based extensions using Xcode can either be done with a
binary Foundry executable that you got directly from the Foundry project, or using
your own build of Foundry.

### Make an Official Foundry Engine debuggable

These steps are only required if you are using an official Foundry built.  If you
compiled your own Foundry locally, you do not need to do folow any of these steps.

1. Download Foundry Engine without .Net support version in the [official website](https://foundryengine.org/download/macos/).

2. Add `com.apple.security.get-task-allow` entitlement and resign it.

```shell
mkdir -p /tmp/Foundry
cp -R ~/Downloads/Foundry.app /tmp/Foundry/
cd /tmp/Foundry/
codesign --display --xml --entitlements Foundry.entitlements Foundry.app
open Foundry.entitlements 
# By default Finder will choose Xcode to open .entitlements file.
# You can open and edit it through any other application which can handle xml.
# Add <key>com.apple.security.get-task-allow</key><true/> in the opened Editor Application
codesign -s - --deep --force --options=runtime --entitlements Foundry.entitlements Foundry.app
cp -Rf ./Foundry.app ~/Downloads/Foundry.app
```

> Warning:
> Alternatively you can also [disable macOS's
> SIP](https://developer.apple.com/documentation/security/disabling_and_enabling_system_integrity_protection)
> to allow debugging anything. Use at your risk.

### Debug Swift code

1. Launch the re-signed Foundry app, choose our target project and open it in
   Foundry.

2. Open our Swift Package via Xcode and add breakpoints.

3. Choose Debug -> Attach to Process in the menu bar of Xcode and locate the
   existing Foundry process here (Remember the pids of the existing Foundry
   process).

4. Go to Foundry Editor and launch the game.

5. Choose Debug -> Attach to Process in the menu bar of Xcode again and choose
   the new Foundry process whose pid is not in the pids list we get in Step 3.

6. Trigger some event if needed and we'll hit the breakpoints we have added in
   Step 2.

![Screenshot of Xcode hitting a breakpoint](debug.png)
