import XCTest
@testable import DimigoinKit

final class DimigoinKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(DimigoinKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
