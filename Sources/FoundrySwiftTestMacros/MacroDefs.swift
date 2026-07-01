//
//  MacroDefs.swift
//

/// Marks a method as a test to be collected by @FoundrySwiftTestSuite.
///
/// Use this attribute on test methods within a @FoundrySwiftTestSuite class:
/// ```swift
/// @FoundrySwiftTestSuite
/// class MyTests {
///     @FoundrySwiftTest
///     func testSomething() {
///         // test code
///     }
/// }
/// ```
@attached(peer)
public macro FoundrySwiftTest() = #externalMacro(
    module: "FoundrySwiftTestMacrosLibrary",
    type: "FoundrySwiftTestMacro"
)

/// Adds FoundrySwiftTestSuiteProtocol conformance and generates allTests property.
///
/// This macro:
/// - Adds conformance to FoundrySwiftTestSuiteProtocol
/// - Generates `allTests` computed property containing all @FoundrySwiftTest methods
///
/// Usage:
/// ```swift
/// @FoundrySwiftTestSuite
/// class MyTests {
///     @FoundrySwiftTest
///     func testFoo() { }
///
///     @FoundrySwiftTest
///     func testBar() { }
/// }
/// ```
///
/// Generates:
/// ```swift
/// extension MyTests: FoundrySwiftTestSuiteProtocol {}
///
/// // Inside class:
/// var allTests: [FoundrySwiftTestInvocation] {
///     [
///         FoundrySwiftTestInvocation(name: "testFoo", run: testFoo),
///         FoundrySwiftTestInvocation(name: "testBar", run: testBar),
///     ]
/// }
/// ```
@attached(member, names: named(allTests))
@attached(extension, conformances: FoundrySwiftTestSuiteProtocol)
@attached(memberAttribute)
public macro FoundrySwiftTestSuite() = #externalMacro(
    module: "FoundrySwiftTestMacrosLibrary",
    type: "FoundrySwiftTestSuiteMacro"
)
