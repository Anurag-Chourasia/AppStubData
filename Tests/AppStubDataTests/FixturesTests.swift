import XCTest
@testable import AppStubData

final class FixturesTests: XCTestCase {

    func testProjectEnumProperties() {
        XCTAssertEqual(Fixtures.Project.myTV.prefix, "mytv")
        XCTAssertEqual(Fixtures.Project.myTV.displayName, "myTV")
        XCTAssertEqual(Fixtures.Project.showBook.prefix, "showbook")
        XCTAssertEqual(Fixtures.Project.showBook.displayName, "ShowBook")
        XCTAssertEqual(Fixtures.Project.motivationDaily.prefix, "motivationdaily")
        XCTAssertEqual(Fixtures.Project.motivationDaily.displayName, "Motivation Daily")
        XCTAssertEqual(Set(Fixtures.Project.allCases.map(\.rawValue)), Set(["mytv", "showbook", "motivationdaily"]))
    }

    func testUserRequestedBrandEndpointScenarios() throws {
        // Motivation Daily quotes positive
        let quotesData = try Fixtures.data(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
        XCTAssertFalse(quotesData.isEmpty)
        let quotes = try JSONSerialization.jsonObject(with: quotesData) as? [[String: Any]]
        XCTAssertEqual(quotes?.count, 3)

        // myTV real endpoint negative (channels malformed scenario)
        let tvChannelsNegativeData = try Fixtures.data(for: .myTV).endpoint(.channels).scenario(.negative)
        XCTAssertFalse(tvChannelsNegativeData.isEmpty)
        let malformedChannels = try JSONSerialization.jsonObject(with: tvChannelsNegativeData) as? [[String: Any]]
        XCTAssertEqual(malformedChannels?.first?["unexpected_field"] as? Int, 12345)

        // ShowBook real endpoint empty (.ShowBook and .showBook)
        let searchEmptyData = try Fixtures.data(for: .ShowBook).endpoint(.search).scenario(.empty)
        XCTAssertFalse(searchEmptyData.isEmpty)
        let searchEmpty = try JSONSerialization.jsonObject(with: searchEmptyData) as? [String: Any]
        XCTAssertEqual(searchEmpty?["numFound"] as? Int, 0)

        let searchEmptyDataLower = try Fixtures.data(for: .showBook).endpoint(.search).scenario(.empty)
        XCTAssertEqual(searchEmptyDataLower, searchEmptyData)
    }

    func testAllShowBookEndpointsAndScenarios() throws {
        for endpoint in Fixtures.ShowBookEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                let data = try Fixtures.data(for: .showBook).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(data.isEmpty, "ShowBook \(endpoint.rawValue) [\(scenario.rawValue)] should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data))

                let dataCapitalized = try Fixtures.data(for: .ShowBook).endpoint(endpoint).scenario(scenario)
                XCTAssertEqual(dataCapitalized, data)

                let str = try Fixtures.string(for: .showBook).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(str.isEmpty)
            }
        }
    }

    func testAllMyTVEndpointsAndScenarios() throws {
        for endpoint in Fixtures.MyTVEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                let data = try Fixtures.data(for: .myTV).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(data.isEmpty, "MyTV \(endpoint.rawValue) [\(scenario.rawValue)] should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data))

                let dataCapitalized = try Fixtures.data(for: .MyTV).endpoint(endpoint).scenario(scenario)
                XCTAssertEqual(dataCapitalized, data)

                let str = try Fixtures.string(for: .myTV).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(str.isEmpty)
            }
        }
    }

    func testAllMotivationDailyEndpointsAndScenarios() throws {
        for endpoint in Fixtures.MotivationDailyEndpoint.allCases {
            for scenario in Fixtures.Scenario.allCases {
                let data = try Fixtures.data(for: .motivationDaily).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(data.isEmpty, "MotivationDaily \(endpoint.rawValue) [\(scenario.rawValue)] should not be empty")
                XCTAssertNotNil(try JSONSerialization.jsonObject(with: data))

                let str = try Fixtures.string(for: .motivationDaily).endpoint(endpoint).scenario(scenario)
                XCTAssertFalse(str.isEmpty)
            }
        }
    }

    func testProjectEnumScopedLoader() throws {
        let channelsData = try Fixtures.data(for: .myTV, endpoint: "channels", scenario: .positive)
        XCTAssertFalse(channelsData.isEmpty)

        let searchData = try Fixtures.data(for: .showBook, endpoint: "search", scenario: .positive)
        XCTAssertFalse(searchData.isEmpty)

        let quotesData = try Fixtures.data(for: .motivationDaily, endpoint: "quotes", scenario: .positive)
        XCTAssertFalse(quotesData.isEmpty)

        let channelsNameData = try Fixtures.data(for: .myTV, name: "channels")
        XCTAssertFalse(channelsNameData.isEmpty)
    }

    func testStringFluentQueries() throws {
        let quoteString = try Fixtures.string(for: .motivationDaily).endpoint(.quotes).scenario(.positive)
        XCTAssertTrue(quoteString.contains("Steve Jobs"))

        let tvChannelsString = try Fixtures.string(for: .myTV).endpoint(.channels).scenario(.negative)
        XCTAssertTrue(tvChannelsString.contains("unexpected_field"))

        let feedsNegativeString = try Fixtures.string(for: .myTV).endpoint(.feeds).scenario(.negative)
        XCTAssertTrue(feedsNegativeString.contains("FeedsFetchFailed"))
    }

    func testMyTVErrorAndOfflineShortcuts() throws {
        let errData = try Fixtures.mytvErrorResponse()
        let errJSON = try JSONSerialization.jsonObject(with: errData) as? [String: Any]
        XCTAssertEqual(errJSON?["code"] as? Int, 500)

        let offlineData = try Fixtures.mytvOfflineError()
        let offlineJSON = try JSONSerialization.jsonObject(with: offlineData) as? [String: Any]
        XCTAssertEqual(offlineJSON?["code"] as? Int, -1009)
        XCTAssertEqual(offlineJSON?["domain"] as? String, "NSURLErrorDomain")
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
        XCTAssertThrowsError(try Fixtures.data(for: .myTV, endpoint: "nonexistent", scenario: .positive))
    }

    func testShowBookTypedAccessors() throws {
        let searchData = try Fixtures.ShowBook.search()
        XCTAssertFalse(searchData.isEmpty)
        let search = try JSONSerialization.jsonObject(with: searchData) as? [String: Any]
        XCTAssertEqual(search?["numFound"] as? Int, 1)

        let discoverData = try Fixtures.ShowBook.discover()
        XCTAssertFalse(discoverData.isEmpty)

        let subjectsData = try Fixtures.ShowBook.subjects()
        XCTAssertFalse(subjectsData.isEmpty)

        let workData = try Fixtures.ShowBook.work()
        XCTAssertFalse(workData.isEmpty)

        let editionsData = try Fixtures.ShowBook.editions()
        XCTAssertFalse(editionsData.isEmpty)

        let editionData = try Fixtures.ShowBook.edition()
        XCTAssertFalse(editionData.isEmpty)

        let countriesData = try Fixtures.ShowBook.countries()
        XCTAssertFalse(countriesData.isEmpty)

        let ipData = try Fixtures.ShowBook.ip()
        XCTAssertFalse(ipData.isEmpty)

        let booksData = try Fixtures.ShowBook.books()
        XCTAssertFalse(booksData.isEmpty)
        let books = try JSONSerialization.jsonObject(with: booksData) as? [String: Any]
        let docs = try XCTUnwrap(books?["docs"] as? [[String: Any]])
        XCTAssertEqual(docs.first?["title"] as? String, "Fixture Book")

        let devCatalogData = try Fixtures.showbookDeveloperResponses()
        XCTAssertFalse(devCatalogData.isEmpty)

        let devCatalogString = try Fixtures.showbookDeveloperResponsesString()
        XCTAssertTrue(devCatalogString.contains("showcase"))

        let payload = try Fixtures.ShowBook.developerResponse(scenario: "success", route: "search")
        XCTAssertFalse(payload.isEmpty)

        let searchStr = try Fixtures.ShowBook.string(endpoint: .search, scenario: .positive)
        XCTAssertTrue(searchStr.contains("The Hobbit"))
    }

    func testMyTVTypedAccessors() throws {
        let channels = try Fixtures.MyTV.channels()
        XCTAssertFalse(channels.isEmpty)

        let streams = try Fixtures.MyTV.streams()
        XCTAssertFalse(streams.isEmpty)

        let allStreams = try Fixtures.MyTV.allStreams()
        XCTAssertFalse(allStreams.isEmpty)

        let logos = try Fixtures.MyTV.logos()
        XCTAssertFalse(logos.isEmpty)

        let categories = try Fixtures.MyTV.categories()
        XCTAssertFalse(categories.isEmpty)

        let feeds = try Fixtures.MyTV.feeds()
        XCTAssertFalse(feeds.isEmpty)

        let languages = try Fixtures.MyTV.languages()
        XCTAssertFalse(languages.isEmpty)

        let countries = try Fixtures.MyTV.countries()
        XCTAssertFalse(countries.isEmpty)

        let regions = try Fixtures.MyTV.regions()
        XCTAssertFalse(regions.isEmpty)

        let devCatalog = try Fixtures.MyTV.developerCatalog()
        XCTAssertFalse(devCatalog.isEmpty)

        let devCatalogStr = try Fixtures.MyTV.developerCatalogString()
        XCTAssertTrue(devCatalogStr.contains("showcase"))

        let showcaseStreams = try Fixtures.MyTV.showcaseStreams()
        XCTAssertFalse(showcaseStreams.isEmpty)
        let streamObjects = try XCTUnwrap(JSONSerialization.jsonObject(with: showcaseStreams) as? [[String: Any]])
        XCTAssertEqual(streamObjects.count, 2)

        let err = try Fixtures.MyTV.errorResponse()
        XCTAssertFalse(err.isEmpty)

        let offline = try Fixtures.MyTV.offlineError()
        XCTAssertFalse(offline.isEmpty)

        let topDevCatalog = try Fixtures.mytvDeveloperCatalog()
        XCTAssertEqual(topDevCatalog, devCatalog)

        let topShowcaseStreams = try Fixtures.mytvShowcaseStreams()
        XCTAssertEqual(topShowcaseStreams, showcaseStreams)
    }

    func testMotivationDailyTypedAccessors() throws {
        let quotes = try Fixtures.MotivationDaily.quotes()
        XCTAssertFalse(quotes.isEmpty)

        let authors = try Fixtures.MotivationDaily.authors()
        XCTAssertFalse(authors.isEmpty)

        let wallpapers = try Fixtures.MotivationDaily.wallpapers()
        XCTAssertFalse(wallpapers.isEmpty)

        let uiFixtures = try Fixtures.MotivationDaily.uiFixtures()
        XCTAssertFalse(uiFixtures.isEmpty)

        let uiFixturesStr = try Fixtures.MotivationDaily.uiFixturesString()
        XCTAssertTrue(uiFixturesStr.contains("gradientPalettes"))

        let zenQuotes = try Fixtures.MotivationDaily.zenQuotes()
        XCTAssertFalse(zenQuotes.isEmpty)
        let zenList = try XCTUnwrap(JSONSerialization.jsonObject(with: zenQuotes) as? [[String: Any]])
        XCTAssertEqual(zenList.first?["a"] as? String, "Steve Jobs")

        let quotable = try Fixtures.MotivationDaily.quotable()
        XCTAssertFalse(quotable.isEmpty)
        let quotableObj = try XCTUnwrap(JSONSerialization.jsonObject(with: quotable) as? [String: Any])
        XCTAssertEqual(quotableObj["author"] as? String, "John Lennon")

        let adviceSlip = try Fixtures.MotivationDaily.adviceSlip()
        XCTAssertFalse(adviceSlip.isEmpty)
        let adviceObj = try XCTUnwrap(JSONSerialization.jsonObject(with: adviceSlip) as? [String: Any])
        XCTAssertNotNil(adviceObj["slip"])

        let topUIFixtures = try Fixtures.motivationDailyUIFixtures()
        XCTAssertEqual(topUIFixtures, uiFixtures)
    }
}
