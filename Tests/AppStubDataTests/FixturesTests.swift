import XCTest
@testable import AppStubData
final class FixturesTests: XCTestCase {
    func testAllFixturesContainValidJSON() throws {
        for name in (0...8).map({ "showbook-\($0)" }) + ["mytv-channels"] {
            XCTAssertNotNil(try JSONSerialization.jsonObject(with: Fixtures.data(name)))
        }
    }
    func testMissingFixtureThrows() {
        XCTAssertThrowsError(try Fixtures.data("missing"))
    }
}
