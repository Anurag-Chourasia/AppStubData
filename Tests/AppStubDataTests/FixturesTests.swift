import XCTest
@testable import AppStubData

final class FixturesTests: XCTestCase {

    func testProjectEnumProperties() {
        XCTAssertEqual(Fixtures.Project.myTV.prefix, "mytv")
        XCTAssertEqual(Fixtures.Project.myTV.displayName, "myTV")
        XCTAssertEqual(Fixtures.Project.showBook.prefix, "showbook")
        XCTAssertEqual(Fixtures.Project.showBook.displayName, "ShowBook")
        XCTAssertEqual(Set(Fixtures.Project.allCases.map(\.rawValue)), Set(["mytv", "showbook"]))
    }

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
                // Test typed loader
                let data = try Fixtures.showbook(endpoint: endpoint, scenario: scenario)
                XCTAssertFalse(data.isEmpty, "ShowBook \(endpoint.rawValue) [\(scenario.rawValue)] data should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data), "ShowBook \(endpoint.rawValue) [\(scenario.rawValue)] should be valid JSON")
                let str = try Fixtures.showbookString(endpoint: endpoint, scenario: scenario)
                XCTAssertFalse(str.isEmpty)

                // Test Project-scoped loader
                let scopedData = try Fixtures.data(for: .showBook, endpoint: endpoint.rawValue, scenario: scenario)
                XCTAssertEqual(scopedData, data)
                let scopedStr = try Fixtures.string(for: .showBook, endpoint: endpoint.rawValue, scenario: scenario)
                XCTAssertEqual(scopedStr, str)
            }
        }
    }

    func testMyTVEndpointsAndScenariosContainValidJSON() throws {
        for endpoint in Fixtures.MyTVEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                // Test typed loader
                let data = try Fixtures.mytv(endpoint: endpoint, scenario: scenario)
                XCTAssertFalse(data.isEmpty, "MyTV \(endpoint.rawValue) [\(scenario.rawValue)] data should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data), "MyTV \(endpoint.rawValue) [\(scenario.rawValue)] should be valid JSON")
                let str = try Fixtures.mytvString(endpoint: endpoint, scenario: scenario)
                XCTAssertFalse(str.isEmpty)

                // Test Project-scoped loader
                let scopedData = try Fixtures.data(for: .myTV, endpoint: endpoint.rawValue, scenario: scenario)
                XCTAssertEqual(scopedData, data)
                let scopedStr = try Fixtures.string(for: .myTV, endpoint: endpoint.rawValue, scenario: scenario)
                XCTAssertEqual(scopedStr, str)
            }
        }
    }

    func testProjectNamedFixture() throws {
        let channelsData = try Fixtures.data(for: .myTV, name: "channels")
        XCTAssertFalse(channelsData.isEmpty)
        XCTAssertNotNil(try JSONSerialization.jsonObject(with: channelsData))

        let channelsStr = try Fixtures.string(for: .myTV, name: "channels")
        XCTAssertFalse(channelsStr.isEmpty)
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
        XCTAssertThrowsError(try Fixtures.data(for: .myTV, endpoint: "nonexistent", scenario: .positive))
        XCTAssertThrowsError(try Fixtures.data(for: .showBook, name: "missing"))
    }
}
