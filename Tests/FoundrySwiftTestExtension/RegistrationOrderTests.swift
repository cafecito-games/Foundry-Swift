//
//  RegistrationOrderTests.swift
//  FoundrySwiftTestExtension
//
//  Tests that classes are registered in the correct initialization level order
//

import FoundrySwift

// MARK: - Test classes registered at different initialization levels
// Declaration order is intentionally mixed to test that registration respects initialization levels

/// Class at .scene level (declared first, but depends on CoreLevelClass)
@Foundry
class SceneLevelClass: ServersLevelClass {
    override class var classInitializationLevel: ExtensionInitializationLevel { .scene }
}

/// Another class at .scene level
@Foundry
class AnotherSceneLevelClass: SceneLevelClass {
}

/// Class at .core level (declared in the middle, but should be registered first)
@Foundry
class CoreLevelClass: RefCounted {
    override class var classInitializationLevel: ExtensionInitializationLevel { .core }
}

/// Class at .servers level (depends on CoreLevelClass)
@Foundry
class ServersLevelClass: CoreLevelClass {
    override class var classInitializationLevel: ExtensionInitializationLevel { .servers }
}

/// Yet another class at .scene level to test multiple classes at same level
@Foundry
class ThirdSceneLevelClass: RefCounted {
}

// MARK: - Tests

@FoundrySwiftTestSuite
final class RegistrationOrderTests {
    @FoundrySwiftTest
    func testRegisteredClassesExistInClassDB() {
        // Verify that all test classes are actually registered in Foundry's ClassDB
        XCTAssertTrue(ClassDB.classExists(class: "CoreLevelClass"), "CoreLevelClass should exist in ClassDB")
        XCTAssertTrue(ClassDB.classExists(class: "ServersLevelClass"), "ServersLevelClass should exist in ClassDB")
        XCTAssertTrue(ClassDB.classExists(class: "SceneLevelClass"), "SceneLevelClass should exist in ClassDB")
        XCTAssertTrue(ClassDB.classExists(class: "AnotherSceneLevelClass"), "AnotherSceneLevelClass should exist in ClassDB")
        XCTAssertTrue(ClassDB.classExists(class: "ThirdSceneLevelClass"), "ThirdSceneLevelClass should exist in ClassDB")
    }

    @FoundrySwiftTest
    func testClassInheritanceIsCorrect() {
        // Verify that the inheritance chain is correct in ClassDB
        XCTAssertEqual(ClassDB.getParentClass("CoreLevelClass"), "RefCounted")
        XCTAssertEqual(ClassDB.getParentClass("ServersLevelClass"), "CoreLevelClass")
        XCTAssertEqual(ClassDB.getParentClass("SceneLevelClass"), "ServersLevelClass")
        XCTAssertEqual(ClassDB.getParentClass("AnotherSceneLevelClass"), "SceneLevelClass")
        XCTAssertEqual(ClassDB.getParentClass("ThirdSceneLevelClass"), "RefCounted")
    }

    @FoundrySwiftTest
    func testInstancesReportCorrectClassName() {
        // Verify that instances report their correct class name via Foundry's type system
        let coreInstance = CoreLevelClass()
        XCTAssertEqual(coreInstance.getClass(), "CoreLevelClass")

        let serversInstance = ServersLevelClass()
        XCTAssertEqual(serversInstance.getClass(), "ServersLevelClass")

        let sceneInstance = SceneLevelClass()
        XCTAssertEqual(sceneInstance.getClass(), "SceneLevelClass")

        let anotherSceneInstance = AnotherSceneLevelClass()
        XCTAssertEqual(anotherSceneInstance.getClass(), "AnotherSceneLevelClass")

        let thirdSceneInstance = ThirdSceneLevelClass()
        XCTAssertEqual(thirdSceneInstance.getClass(), "ThirdSceneLevelClass")
    }

    @FoundrySwiftTest
    func testClassesHaveCorrectInitializationLevels() {
        XCTAssertEqual(CoreLevelClass.classInitializationLevel, .core)
        XCTAssertEqual(ServersLevelClass.classInitializationLevel, .servers)
        XCTAssertEqual(SceneLevelClass.classInitializationLevel, .scene)
        XCTAssertEqual(AnotherSceneLevelClass.classInitializationLevel, .scene)
        XCTAssertEqual(ThirdSceneLevelClass.classInitializationLevel, .scene)
    }
}
