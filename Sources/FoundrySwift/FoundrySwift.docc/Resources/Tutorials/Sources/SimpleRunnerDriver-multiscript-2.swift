// The Swift Programming Language
// https://docs.swift.org/swift-book

import FoundrySwift

let allNodes: [Object.Type] = [PlayerController.self, MainLevel.self]

#initFoundryExtension(cdecl: "swift_entry_point", types: allNodes)
