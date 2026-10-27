import XCTest
@testable import AppStubData

final class FixturesTests: XCTestCase {

    func testUserRequestedBrandEndpointScenarios() throws {
        // Line 1: try Fixtures.data(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
        let quotesData = try Fixtures.data(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
        XCTAssertFalse(quotesData.isEmpty)
        let quotes = try JSONSerialization.jsonObject(with: quotesData) as? [[String: Any]]
        XCTAssertEqual(quotes?.count, 3)

        // Line 2: try Fixtures.data(for: .myTV).endpoint(.loadTV).scenario(.negative)
        let loadTVData = try Fixtures.data(for: .myTV).endpoint(.loadTV).scenario(.negative)
        XCTAssertFalse(loadTVData.isEmpty)
        let loadTVError = try JSONSerialization.jsonObject(with: loadTVData) as? [String: Any]
        XCTAssertEqual(loadTVError?["code"] as? Int, 500)

        // Line 3: try Fixtures.data(for: .ShowBook).endpoint(.search).scenario(.empty)
        let searchEmptyData = try Fixtures.data(for: .ShowBook).endpoint(.search).scenario(.empty)
        XCTAssertFalse(searchEmptyData.isEmpty)
        let searchEmpty = try JSONSerialization.jsonObject(with: searchEmptyData) as? [String: Any]
        XCTAssertEqual(searchEmpty?["numFound"] as? Int, 0)
    }

    func testBrandSpecificEndpointScoping() {
        // Verifies Project metadata
        XCTAssertEqual(Fixtures.Project.myTV.prefix, "mytv")
        XCTAssertEqual(Fixtures.Project.myTV.displayName, "myTV")
        XCTAssertEqual(Fixtures.Project.showBook.prefix, "showbook")
        XCTAssertEqual(Fixtures.Project.ShowBook.prefix, "showbook")
        XCTAssertEqual(Fixtures.Project.motivationDaily.prefix, "motivationdaily")
    }

    func testAllShowBookEndpointsAndScenarios() throws {
        for endpoint in Fixtures.ShowBookEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                let data = try Fixtures.data(for: .showBook).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(data.isEmpty, "ShowBook \(endpoint.rawValue) [\(scenario.rawValue)] should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data))
            }
        }
    }

    func testAllMyTVEndpointsAndScenarios() throws {
        for endpoint in Fixtures.MyTVEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                let data = try Fixtures.data(for: .myTV).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(data.isEmpty, "MyTV \(endpoint.rawValue) [\(scenario.rawValue)] should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data))
            }
        }
    }

    func testAllMotivationDailyEndpointsAndScenarios() throws {
        for endpoint in Fixtures.MotivationDailyEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                let data = try Fixtures.data(for: .motivationDaily).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(data.isEmpty, "MotivationDaily \(endpoint.rawValue) [\(scenario.rawValue)] should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data))
            }
        }
    }

    func testStringFluentQueries() throws {
        let quoteString = try Fixtures.string(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
        XCTAssertTrue(quoteString.contains("Steve Jobs"))

        let tvString = try Fixtures.string(for: .myTV).endpoint(.loadTV).scenario(.negative)
        XCTAssertTrue(tvString.contains("LoadTVFailed"))
    }

    func testAllLegacyFixturesContainValidJSON() throws {
        for name in (0...8).map({ "showbook-\($0)" }) + ["mytv-channels"] {
            let data = try Fixtures.data(name)
            XCTAssertFalse(data.isEmpty)
            XCTAssertNotNil(try JSONSerialization.jsonObject(with: data))
        }
    }

    func testMissingFixtureThrows() {
        XCTAssertThrowsError(try Fixtures.data("nonexistent_fixture_file"))
    }
}
