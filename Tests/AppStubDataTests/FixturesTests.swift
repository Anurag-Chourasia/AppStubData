import XCTest
@testable import AppStubData

final class FixturesTests: XCTestCase {

    func testAllLegacyFixturesContainValidJSON() throws {
        for name in (0...8).map({ "showbook-\($0)" }) + ["mytv-channels"] {
            let data = try Fixtures.data(name)
            XCTAssertFalse(data.isEmpty)
            XCTAssertNotNil(try JSONSerialization.jsonObject(with: data))
            let str = try Fixtures.string(name)
            XCTAssertFalse(str.isEmpty)
        }
    }

    func testShowBookEndpointsAndScenariosContainValidJSON() throws {
        for endpoint in Fixtures.ShowBookEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                let data = try Fixtures.showbook(endpoint: endpoint, scenario: scenario)
                XCTAssertFalse(data.isEmpty, "ShowBook \(endpoint.rawValue) [\(scenario.rawValue)] data should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data), "ShowBook \(endpoint.rawValue) [\(scenario.rawValue)] should be valid JSON")
                let str = try Fixtures.showbookString(endpoint: endpoint, scenario: scenario)
                XCTAssertFalse(str.isEmpty)
            }
        }
    }

    func testMyTVEndpointsAndScenariosContainValidJSON() throws {
        for endpoint in Fixtures.MyTVEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                let data = try Fixtures.mytv(endpoint: endpoint, scenario: scenario)
                XCTAssertFalse(data.isEmpty, "MyTV \(endpoint.rawValue) [\(scenario.rawValue)] data should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data), "MyTV \(endpoint.rawValue) [\(scenario.rawValue)] should be valid JSON")
                let str = try Fixtures.mytvString(endpoint: endpoint, scenario: scenario)
                XCTAssertFalse(str.isEmpty)
            }
        }
    }

    func testMyTVErrorAndOfflineFixtures() throws {
        let errData = try Fixtures.mytvErrorResponse()
        let errJSON = try JSONSerialization.jsonObject(with: errData) as? [String: Any]
        XCTAssertEqual(errJSON?["code"] as? Int, 500)

        let offData = try Fixtures.mytvOfflineError()
        let offJSON = try JSONSerialization.jsonObject(with: offData) as? [String: Any]
        XCTAssertEqual(offJSON?["code"] as? Int, -1009)
    }

    func testMissingFixtureThrows() {
        XCTAssertThrowsError(try Fixtures.data("nonexistent_fixture_file"))
    }
}
