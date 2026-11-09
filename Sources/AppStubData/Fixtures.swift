import Foundation

public enum Fixtures {

    // MARK: - Projects Enum

    /// Supported application projects that consume shared fixtures.
    /// Extend this enum when adding new projects to the submodule.
    public enum Project: String, CaseIterable, Sendable {
        case myTV = "mytv"
        case showBook = "showbook"
        case motivationDaily = "motivationdaily"

        public var displayName: String {
            switch self {
            case .myTV: return "myTV"
            case .showBook: return "ShowBook"
            case .motivationDaily: return "Motivation Daily"
            }
        }

        public var prefix: String { rawValue }
    }

    // MARK: - Scenarios

    public enum Scenario: String, CaseIterable, Sendable {
        case positive
        case empty
        case negative
    }

    // MARK: - Real Brand Endpoints

    /// Real endpoints utilized in the myTV project (IPTV catalog, streams, logos, categories, feeds, etc.).
    public enum MyTVEndpoint: String, CaseIterable, Sendable {
        case channels = "channels"
        case streams = "streams"
        case logos = "logos"
        case categories = "categories"
        case feeds = "feeds"
        case languages = "languages"
        case countries = "countries"
        case regions = "regions"
        case allStreams = "allstreams"
    }

    /// Real endpoints utilized in the ShowBook project (search, discover, subjects, work, editions, etc.).
    public enum ShowBookEndpoint: String, CaseIterable, Sendable {
        case search = "search"
        case discover = "discover"
        case subjects = "subjects"
        case work = "work"
        case editions = "editions"
        case edition = "edition"
        case countries = "countries"
        case ip = "ip"
    }

    /// Real endpoints utilized in the Motivation Daily project (quotes, authors, wallpapers).
    public enum MotivationDailyEndpoint: String, CaseIterable, Sendable {
        case quotes = "quotes"
        case authors = "authors"
        case wallpapers = "wallpapers"
    }

    // MARK: - Strongly Typed Brand Phantom Binding

    public struct Brand<Endpoint: RawRepresentable & CaseIterable & Sendable>: Sendable where Endpoint.RawValue == String {
        public let project: Project
        public var prefix: String { project.prefix }
        public var displayName: String { project.displayName }

        public init(project: Project) {
            self.project = project
        }
    }

    // Backward-compatible typealias
    public typealias ProjectScope<Endpoint: RawRepresentable & CaseIterable & Sendable> = Brand<Endpoint> where Endpoint.RawValue == String

    // MARK: - Core Loaders

    public static func data(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try Data(contentsOf: url)
    }

    public static func string(_ name: String) throws -> String {
        String(decoding: try data(name), as: UTF8.self)
    }

    // MARK: - Fluent Query Builders: Fixtures.data(for: .brand).endpoint(.ep).scenario(.sc)

    public static func data<E>(for brand: Brand<E>) -> BrandDataQuery<E> {
        BrandDataQuery(brand: brand)
    }

    public static func string<E>(for brand: Brand<E>) -> BrandStringQuery<E> {
        BrandStringQuery(brand: brand)
    }

    public struct BrandDataQuery<E: RawRepresentable & CaseIterable & Sendable>: Sendable where E.RawValue == String {
        public let brand: Brand<E>

        public func endpoint(_ endpoint: E) -> ScenarioDataQuery {
            ScenarioDataQuery(prefix: brand.prefix, endpointName: endpoint.rawValue)
        }

        public func fixture(_ name: String) throws -> Data {
            try Fixtures.data("\(brand.prefix)-\(name)")
        }
    }

    public struct ScenarioDataQuery: Sendable {
        public let prefix: String
        public let endpointName: String

        public func scenario(_ scenario: Scenario) throws -> Data {
            try Fixtures.data("\(prefix)-\(endpointName)-\(scenario.rawValue)")
        }

        public func scenarioString(_ scenario: Scenario) throws -> String {
            try Fixtures.string("\(prefix)-\(endpointName)-\(scenario.rawValue)")
        }
    }

    public struct BrandStringQuery<E: RawRepresentable & CaseIterable & Sendable>: Sendable where E.RawValue == String {
        public let brand: Brand<E>

        public func endpoint(_ endpoint: E) -> ScenarioStringQuery {
            ScenarioStringQuery(prefix: brand.prefix, endpointName: endpoint.rawValue)
        }

        public func fixture(_ name: String) throws -> String {
            try Fixtures.string("\(brand.prefix)-\(name)")
        }
    }

    public struct ScenarioStringQuery: Sendable {
        public let prefix: String
        public let endpointName: String

        public func scenario(_ scenario: Scenario) throws -> String {
            try Fixtures.string("\(prefix)-\(endpointName)-\(scenario.rawValue)")
        }
    }

    // MARK: - Project Enum-Based Loaders

    public static func data(for project: Project, endpoint: String, scenario: Scenario) throws -> Data {
        try data("\(project.prefix)-\(endpoint)-\(scenario.rawValue)")
    }

    public static func string(for project: Project, endpoint: String, scenario: Scenario) throws -> String {
        try string("\(project.prefix)-\(endpoint)-\(scenario.rawValue)")
    }

    public static func data(for project: Project, name: String) throws -> Data {
        try data("\(project.prefix)-\(name)")
    }

    public static func string(for project: Project, name: String) throws -> String {
        try string("\(project.prefix)-\(name)")
    }

    // MARK: - Direct / String Dynamic Loaders

    public static func data(for prefix: String, endpoint: String, scenario: Scenario) throws -> Data {
        try data("\(prefix)-\(endpoint)-\(scenario.rawValue)")
    }

    public static func string(for prefix: String, endpoint: String, scenario: Scenario) throws -> String {
        try string("\(prefix)-\(endpoint)-\(scenario.rawValue)")
    }

    // MARK: - Typed Helper Shortcuts

    public static func showbook(endpoint: ShowBookEndpoint, scenario: Scenario) throws -> Data {
        try data(for: .showBook).endpoint(endpoint).scenario(scenario)
    }

    public static func showbookString(endpoint: ShowBookEndpoint, scenario: Scenario) throws -> String {
        try string(for: .showBook).endpoint(endpoint).scenario(scenario)
    }

    // MARK: - ShowBook Typed Accessors & Namespace

    public enum ShowBook {
        public static func data(endpoint: ShowBookEndpoint, scenario: Scenario = .positive) throws -> Data {
            try Fixtures.data(for: .showBook).endpoint(endpoint).scenario(scenario)
        }

        public static func string(endpoint: ShowBookEndpoint, scenario: Scenario = .positive) throws -> String {
            try Fixtures.string(for: .showBook).endpoint(endpoint).scenario(scenario)
        }

        public static func developerResponses() throws -> Data {
            try Fixtures.data("showbook-developer-responses")
        }

        public static func developerResponse(scenario: String, route: String) throws -> Data {
            let catalogData = try developerResponses()
            guard let catalog = try JSONSerialization.jsonObject(with: catalogData) as? [String: [String: Any]],
                  let payload = catalog[scenario]?[route] else {
                throw CocoaError(.fileNoSuchFile)
            }
            return try JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys])
        }

        public static func search(scenario: Scenario = .positive) throws -> Data {
            try data(endpoint: .search, scenario: scenario)
        }

        public static func discover(scenario: Scenario = .positive) throws -> Data {
            try data(endpoint: .discover, scenario: scenario)
        }

        public static func subjects(scenario: Scenario = .positive) throws -> Data {
            try data(endpoint: .subjects, scenario: scenario)
        }

        public static func work(scenario: Scenario = .positive) throws -> Data {
            try data(endpoint: .work, scenario: scenario)
        }

        public static func editions(scenario: Scenario = .positive) throws -> Data {
            try data(endpoint: .editions, scenario: scenario)
        }

        public static func edition(scenario: Scenario = .positive) throws -> Data {
            try data(endpoint: .edition, scenario: scenario)
        }

        public static func countries(scenario: Scenario = .positive) throws -> Data {
            try data(endpoint: .countries, scenario: scenario)
        }

        public static func ip(scenario: Scenario = .positive) throws -> Data {
            try data(endpoint: .ip, scenario: scenario)
        }

        public static func books() throws -> Data {
            try Fixtures.data("showbook-books")
        }
    }

    public static func showbookDeveloperResponses() throws -> Data {
        try ShowBook.developerResponses()
    }

    public static func showbookDeveloperResponsesString() throws -> String {
        try string("showbook-developer-responses")
    }

    public static func mytv(endpoint: MyTVEndpoint, scenario: Scenario) throws -> Data {
        try data(for: .myTV).endpoint(endpoint).scenario(scenario)
    }

    public static func mytvString(endpoint: MyTVEndpoint, scenario: Scenario) throws -> String {
        try string(for: .myTV).endpoint(endpoint).scenario(scenario)
    }

    public static func motivationDaily(endpoint: MotivationDailyEndpoint, scenario: Scenario) throws -> Data {
        try data(for: .motivationDaily).endpoint(endpoint).scenario(scenario)
    }

    public static func motivationDailyString(endpoint: MotivationDailyEndpoint, scenario: Scenario) throws -> String {
        try string(for: .motivationDaily).endpoint(endpoint).scenario(scenario)
    }

    public static func mytvErrorResponse() throws -> Data {
        try data("mytv-error-response")
    }

    public static func mytvOfflineError() throws -> Data {
        try data("mytv-offline-error")
    }
}

// MARK: - Brand Static Definitions

extension Fixtures.Brand where Endpoint == Fixtures.MyTVEndpoint {
    public static var myTV: Fixtures.Brand<Fixtures.MyTVEndpoint> {
        Fixtures.Brand(project: .myTV)
    }

    public static var MyTV: Fixtures.Brand<Fixtures.MyTVEndpoint> {
        myTV
    }
}

extension Fixtures.Brand where Endpoint == Fixtures.ShowBookEndpoint {
    public static var showBook: Fixtures.Brand<Fixtures.ShowBookEndpoint> {
        Fixtures.Brand(project: .showBook)
    }

    public static var ShowBook: Fixtures.Brand<Fixtures.ShowBookEndpoint> {
        showBook
    }
}

extension Fixtures.Brand where Endpoint == Fixtures.MotivationDailyEndpoint {
    public static var motivationDaily: Fixtures.Brand<Fixtures.MotivationDailyEndpoint> {
        Fixtures.Brand(project: .motivationDaily)
    }

    public static var MotivationDaily: Fixtures.Brand<Fixtures.MotivationDailyEndpoint> {
        motivationDaily
    }
}
