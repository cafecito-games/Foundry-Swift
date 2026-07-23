//
//  main.swift
//  FoundrySwiftTestRunner
//
//  CLI tool that builds the test extension, launches Foundry, and reports results
//

import Foundation

@main
struct FoundrySwiftTestRunner {
    static func main() async {
        let projectPath = "Tests/FoundrySwiftTestProject"
        let resultsPath = "Tests/FoundrySwiftTestProject/test_results.json"
        let extensionTarget = "FoundrySwiftTestExtension"
        let buildConfiguration = "debug"

        print("FoundrySwift Test Runner")
        print(String(repeating: "=", count: 60))

        let cwd = FileManager.default.currentDirectoryPath
        let absoluteProjectPath = projectPath.hasPrefix("/") ? projectPath : "\(cwd)/\(projectPath)"
        let absoluteResultsPath = resultsPath.hasPrefix("/") ? resultsPath : "\(cwd)/\(resultsPath)"
        print("\nPaths:")
        print("  Working directory: \(cwd)")
        print("  Project path:      \(absoluteProjectPath)")
        print("  Results path:      \(absoluteResultsPath)")
        print("  Extension target:  \(extensionTarget)")
        print("  Build config:      \(buildConfiguration)")

        // Find swift executable from PATH
        let whichSwiftProcess = Process()
        whichSwiftProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        whichSwiftProcess.arguments = ["swift"]
        let whichSwiftPipe = Pipe()
        whichSwiftProcess.standardOutput = whichSwiftPipe
        whichSwiftProcess.standardError = whichSwiftPipe
        do {
            try whichSwiftProcess.run()
            whichSwiftProcess.waitUntilExit()
        } catch {
            print("      Failed to find swift: \(error)")
            exit(1)
        }
        if whichSwiftProcess.terminationStatus != 0 {
            print("      Swift not found in PATH")
            exit(1)
        }
        let swiftPathData = whichSwiftPipe.fileHandleForReading.readDataToEndOfFile()
        let swiftPath = String(data: swiftPathData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "swift"

        // 1. Build the test extension and dependencies
        print("\n[1/5] Building test extension...")
        let products = [extensionTarget, "FoundrySwift"]
        for product in products {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: swiftPath)
            process.arguments = ["build", "--product", product, "-c", buildConfiguration]
            process.currentDirectoryURL = URL(fileURLWithPath: cwd)
            process.standardOutput = FileHandle.standardOutput
            process.standardError = FileHandle.standardError
            do {
                try process.run()
                process.waitUntilExit()
                if process.terminationStatus != 0 {
                    print("      Build failed for \(product)")
                    exit(1)
                }
            } catch {
                print("      Build failed: \(error)")
                exit(1)
            }
        }
        print("      Build successful")

        // 2. Copy built libraries to Foundry project
        print("\n[2/5] Copying libraries to test project...")
        let fm = FileManager.default
        let destDir = "\(projectPath)/bin"
        do {
            try fm.createDirectory(atPath: destDir, withIntermediateDirectories: true)
        } catch {
            print("      Failed to create bin directory: \(error)")
            exit(1)
        }

        let libPrefix = "lib"
        let libExt = "dylib"
        #if arch(arm64)
        let platformDir = "arm64-apple-macosx"
        #else
        let platformDir = "x86_64-apple-macosx"
        #endif

        let libraryNames = [extensionTarget, "FoundrySwift"]
        let platformBuildDir = ".build/\(platformDir)/\(buildConfiguration)"
        let simpleBuildDir = ".build/\(buildConfiguration)"

        for name in libraryNames {
            let libName = "\(libPrefix)\(name).\(libExt)"
            let platformSource = "\(platformBuildDir)/\(libName)"
            let simpleSource = "\(simpleBuildDir)/\(libName)"

            let source: String
            if fm.fileExists(atPath: platformSource) {
                source = platformSource
            } else if fm.fileExists(atPath: simpleSource) {
                source = simpleSource
            } else {
                print("      Library not found: \(platformSource) or \(simpleSource)")
                exit(1)
            }

            let dest = "\(destDir)/\(libName)"
            do {
                if fm.fileExists(atPath: dest) {
                    try fm.removeItem(atPath: dest)
                }
                try fm.copyItem(atPath: source, toPath: dest)
                print("      Copied \(libName)")
            } catch {
                print("      Copy failed: \(error)")
                exit(1)
            }
        }
        print("      Copy successful")

        for stalePath in [resultsPath, "\(projectPath)/.foundry"] where fm.fileExists(atPath: stalePath) {
            do {
                try fm.removeItem(atPath: stalePath)
            } catch {
                print("      Failed to remove stale test state at \(stalePath): \(error)")
                exit(1)
            }
        }

        let foundryCommand = ProcessInfo.processInfo.environment["FOUNDRY_BIN"].flatMap { $0.isEmpty ? nil : $0 } ?? "foundry"
        let foundryPath: String
        if foundryCommand.contains("/") {
            guard fm.isExecutableFile(atPath: foundryCommand) else {
                print("      FOUNDRY_BIN is not executable: \(foundryCommand)")
                exit(1)
            }
            foundryPath = foundryCommand
        } else {
            let whichProcess = Process()
            whichProcess.executableURL = URL(fileURLWithPath: "/usr/bin/which")
            whichProcess.arguments = [foundryCommand]
            let whichPipe = Pipe()
            whichProcess.standardOutput = whichPipe
            whichProcess.standardError = whichPipe
            do {
                try whichProcess.run()
                whichProcess.waitUntilExit()
            } catch {
                print("      Failed to find Foundry executable: \(error)")
                exit(1)
            }
            if whichProcess.terminationStatus != 0 {
                print("      Foundry executable not found in PATH: \(foundryCommand)")
                exit(1)
            }
            let foundryPathData = whichPipe.fileHandleForReading.readDataToEndOfFile()
            foundryPath = String(data: foundryPathData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? foundryCommand
        }

        // 3. Tell Foundry which extension to load. A headless runtime launch
        // reads this cache file but does not scan the project for new extension
        // resources; using the editor import path just to populate it can trip
        // editor-only doc generation in local development builds.
        print("\n[3/5] Preparing Foundry extension list...")
        let foundryCacheDir = "\(projectPath)/.foundry"
        let extensionListPath = "\(foundryCacheDir)/extension_list.cfg"
        do {
            try fm.createDirectory(atPath: foundryCacheDir, withIntermediateDirectories: true)
            try "res://SwiftTests.foundryextension\n".write(toFile: extensionListPath, atomically: true, encoding: .utf8)
        } catch {
            print("      Failed to prepare extension list: \(error)")
            exit(1)
        }
        print("      Extension list ready")

        // 4. Launch Foundry
        print("\n[4/5] Running tests in Foundry...")
        let foundryProcess = Process()
        foundryProcess.executableURL = URL(fileURLWithPath: foundryPath)
        foundryProcess.arguments = [
            "--headless", "--verbose", "project", "run", "--project", absoluteProjectPath
        ]
        foundryProcess.currentDirectoryURL = URL(fileURLWithPath: absoluteProjectPath)
        foundryProcess.standardOutput = FileHandle.standardOutput
        foundryProcess.standardError = FileHandle.standardError
        var foundryExitCode: Int32 = 0
        do {
            try foundryProcess.run()
            foundryProcess.waitUntilExit()
            foundryExitCode = foundryProcess.terminationStatus
            print("      Foundry exited with code: \(foundryExitCode)")
        } catch {
            print("      Foundry launch failed: \(error)")
            exit(1)
        }

        // 5. Read and report results
        print("\n[5/5] Reading results...")
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: absoluteResultsPath))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let results = try decoder.decode(TestResults.self, from: data)

            print("\n" + String(repeating: "=", count: 60))
            print("Test Results")
            print(String(repeating: "=", count: 60))

            for suite in results.suites {
                print("\n\(suite.name):")
                for test in suite.tests {
                    let icon = test.status == .passed ? "+" : (test.status == .failed ? "x" : "-")
                    let duration = test.duration >= 1.0 ? String(format: "%.2fs", test.duration) : String(format: "%.2fms", test.duration * 1000)
                    print("  [\(icon)] \(test.name) (\(duration))")
                    if let failure = test.failure {
                        print("      \(failure.message)")
                        print("      at \(failure.file):\(failure.line)")
                    }
                }
            }

            let totalDuration = results.duration >= 1.0 ? String(format: "%.2fs", results.duration) : String(format: "%.2fms", results.duration * 1000)
            print("\n" + String(repeating: "-", count: 60))
            print("Summary: \(results.summary.passed) passed, \(results.summary.failed) failed, \(results.summary.skipped) skipped")
            print("Total time: \(totalDuration)")
            print(String(repeating: "=", count: 60))

            // Use Foundry's exit code if non-zero, otherwise use test results
            let testExitCode: Int32 = results.summary.failed > 0 ? 1 : 0
            exit(foundryExitCode != 0 ? foundryExitCode : testExitCode)
        } catch {
            print("      Failed to read results: \(error)")
            print("      Foundry exit code was: \(foundryExitCode)")
            exit(foundryExitCode != 0 ? foundryExitCode : 1)
        }
    }
}
