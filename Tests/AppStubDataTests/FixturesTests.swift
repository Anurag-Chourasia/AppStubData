import XCTest
@testable import AppStubData

final class FixturesTests: XCTestCase {
    func testAllFixturesContainValidJSON() throws {
        let fixtureNames = (0...8).map({ "showbook-\($0)" }) + [
            "mytv-channels",
            "mytv-channels-positive",
            "mytv-streams-positive",
            "mytv-logos-positive",
            "mytv-channels-empty",
            "mytv-streams-empty",
            "mytv-logos-empty",
            "mytv-channels-negative",
            "mytv-streams-negative",
            "mytv-error-response",
            "mytv-offline-error"
        ]

        for name in fixtureNames {
            let data = try Fixtures.data(name)
            XCTAssertNotNil(try JSONSerialization.jsonObject(with: data), "Fixture \(name) should be valid JSON")
        }
    }

    func testPositiveScenariosHaveData() throws {
        let channelsData = try Fixtures.data("mytv-channels-positive")
        guard let channels = try JSONSerialization.jsonObject(with: channelsData) as? [[String: Any]] else {
            XCTFail("mytv-channels-positive should be an array of objects")
            return
        }
        XCTAssertGreaterThan(channels.count, 0)

        let streamsData = try Fixtures.data("mytv-streams-positive")
        guard let streams = try JSONSerialization.jsonObject(with: streamsData) as? [[String: Any]] else {
            XCTFail("mytv-streams-positive should be an array of objects")
            return
        }
        XCTAssertGreaterThan(streams.count, 0)
    }

    func testEmptyScenariosAreEmptyArrays() throws {
        let emptyChannels = try JSONSerialization.jsonObject(with: try Fixtures.data("mytv-channels-empty")) as? [Any]
        XCTAssertEqual(emptyChannels?.count, 0)

        let emptyStreams = try JSONSerialization.jsonObject(with: try Fixtures.data("mytv-streams-empty")) as? [Any]
        XCTAssertEqual(emptyStreams?.count, 0)

        let emptyLogos = try JSONSerialization.jsonObject(with: try Fixtures.data("mytv-logos-empty")) as? [Any]
        XCTAssertEqual(emptyLogos?.count, 0)
    }

    func testNegativeScenariosContainErrorPayloads() throws {
        let errorData = try Fixtures.data("mytv-error-response")
        guard let errorDict = try JSONSerialization.jsonObject(with: errorData) as? [String: Any] else {
            XCTFail("mytv-error-response should be a JSON dictionary")
            return
        }
        XCTAssertEqual(errorDict["code"] as? Int, 500)
    }

    func testMissingFixtureThrows() {
        XCTAssertThrowsError(try Fixtures.data("missing"))
    }
}
