import Foundation
import XCTest
@testable import AppStubData

final class DeveloperCatalogTests: XCTestCase {
    private func catalog(_ name: String) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: Fixtures.data(name)) as? [String: Any])
    }

    func testShowBookScenariosPreserveResponseShapesAndIdentities() throws {
        let data = try catalog("showbook-developer-responses")
        for scenario in ["success", "empty", "showcase"] {
            let responses = try XCTUnwrap(data[scenario] as? [String: Any])
            XCTAssertEqual(Set(responses.keys), ["subjects", "search", "editions", "work", "edition", "countries"])
            let search = try XCTUnwrap(responses["search"] as? [String: Any])
            let docs = try XCTUnwrap(search["docs"] as? [[String: Any]])
            XCTAssertEqual(docs.count, scenario == "empty" ? 0 : scenario == "showcase" ? 4 : 1)
            let work = try XCTUnwrap(responses["work"] as? [String: Any])
            XCTAssertEqual(work["key"] as? String, scenario == "showcase" ? "/works/OL1001W" : "/works/OL45804W")
            let countries = try XCTUnwrap(responses["countries"] as? [String: Any])
            let entries = try XCTUnwrap(countries["data"] as? [String: Any])
            XCTAssertNotNil(entries[scenario == "showcase" ? "US" : "IN"])
        }
    }

    func testMyTVCatalogKeepsStreamEligibilityAndChannelSpecificTemplates() throws {
        let data = try catalog("mytv-developer-catalog")
        let success = try XCTUnwrap(data["success"] as? [[String: Any]])
        let showcase = try XCTUnwrap(data["showcase"] as? [[String: Any]])
        XCTAssertEqual(success.count, 2)
        XCTAssertEqual(showcase.count, 8)
        XCTAssertEqual(Set((success + showcase).compactMap { $0["id"] as? String }).count, 10)
        XCTAssertTrue(success.allSatisfy { $0["hasStreams"] as? Bool == false })
        XCTAssertTrue(showcase.allSatisfy { $0["hasStreams"] as? Bool == true })
        let streams = try XCTUnwrap(data["showcaseStreams"] as? [[String: Any]])
        XCTAssertEqual(streams.compactMap { $0["idSuffix"] as? String }, ["-1080p", "-720p"])
        for stream in streams {
            let url = try XCTUnwrap(URL(string: try XCTUnwrap(stream["url"] as? String)))
            XCTAssertEqual(url.scheme, "https")
            XCTAssertEqual(url.host, "devstreaming-cdn.apple.com")
        }
    }

    func testMotivationFixturePaletteAndSeedDataAreWellFormed() throws {
        let data = try catalog("motivationdaily-ui-fixtures")
        let palettes = try XCTUnwrap(data["gradientPalettes"] as? [[[Double]]])
        XCTAssertEqual(palettes.count, 4)
        for palette in palettes {
            XCTAssertEqual(palette.count, 2)
            for color in palette {
                XCTAssertEqual(color.count, 4)
                XCTAssertTrue(color.allSatisfy { (0...1).contains($0) })
                XCTAssertEqual(color.last, 1)
            }
        }
        let favorite = try XCTUnwrap(data["favorite"] as? [String: String])
        XCTAssertEqual(favorite["id"], "uitest-seed-favorite")
        XCTAssertEqual(data["randomQuoteCount"] as? Int, 24)
        let categories = try XCTUnwrap(data["categories"] as? [[String: Any]])
        XCTAssertEqual(categories.compactMap { $0["key"] as? String }, ["focus", "growth"])
    }
}
