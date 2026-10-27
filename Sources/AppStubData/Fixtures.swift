import Foundation

public enum Fixtures {

    // MARK: - Scenarios

    public enum Scenario: String, CaseIterable, Sendable {
        case positive
        case empty
        case negative
    }

    // MARK: - Brand / Project Endpoints

    public enum MyTVEndpoint: String, CaseIterable, Sendable {
        case loadTV = "loadtv"
        case channels = "channels"
        case streams = "streams"
        case logos = "logos"
        case categories = "categories"
    }

    public enum ShowBookEndpoint: String, CaseIterable, Sendable {
        case search = "search"
        case discover = "discover"
        case work = "work"
        case editions = "editions"
        case edition = "edition"
        case countries = "countries"
        case ip = "ip"
    }

    public enum MotivationDailyEndpoint: String, CaseIterable, Sendable {
        case quotes = "quotes"
        case authors = "authors"
    }

    // MARK: - Strongly Typed Brand Project Definition

    public struct Project<Endpoint: RawRepresentable & CaseIterable & Sendable>: Sendable where Endpoint.RawValue == String {
        public let prefix: String
        public let displayName: String

        public init(prefix: String, displayName: String) {
            self.prefix = prefix
            self.displayName = displayName
        }
    }

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

    public static func data<E>(for project: Project<E>) -> ProjectDataQuery<E> {
        ProjectDataQuery(project: project)
    }

    public static func string<E>(for project: Project<E>) -> ProjectStringQuery<E> {
        ProjectStringQuery(project: project)
    }

    public struct ProjectDataQuery<E: RawRepresentable & CaseIterable & Sendable>: Sendable where E.RawValue == String {
        public let project: Project<E>

        public func endpoint(_ endpoint: E) -> ScenarioDataQuery {
            ScenarioDataQuery(prefix: project.prefix, endpointName: endpoint.rawValue)
        }

        public func fixture(_ name: String) throws -> Data {
            try Fixtures.data("\(project.prefix)-\(name)")
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

    public struct ProjectStringQuery<E: RawRepresentable & CaseIterable & Sendable>: Sendable where E.RawValue == String {
        public let project: Project<E>

        public func endpoint(_ endpoint: E) -> ScenarioStringQuery {
            ScenarioStringQuery(prefix: project.prefix, endpointName: endpoint.rawValue)
        }

        public func fixture(_ name: String) throws -> String {
            try Fixtures.string("\(project.prefix)-\(name)")
        }
    }

    public struct ScenarioStringQuery: Sendable {
        public let prefix: String
        public let endpointName: String

        public func scenario(_ scenario: Scenario) throws -> String {
            try Fixtures.string("\(prefix)-\(endpointName)-\(scenario.rawValue)")
        }
    }

    // MARK: - Direct / String Dynamic Loaders

    public static func data(for prefix: String, endpoint: String, scenario: Scenario) throws -> Data {
        try data("\(prefix)-\(endpoint)-\(scenario.rawValue)")
    }

    public static func string(for prefix: String, endpoint: String, scenario: Scenario) throws -> String {
        try string("\(prefix)-\(endpoint)-\(scenario.rawValue)")
    }

    // MARK: - Legacy / Helper Typed Shortcuts

    public static func showbook(endpoint: ShowBookEndpoint, scenario: Scenario) throws -> Data {
        try data(for: .showBook).endpoint(endpoint).scenario(scenario)
    }

    public static func showbookString(endpoint: ShowBookEndpoint, scenario: Scenario) throws -> String {
        try string(for: .showBook).endpoint(endpoint).scenario(scenario)
    }

    public static func mytv(endpoint: MyTVEndpoint, scenario: Scenario) throws -> Data {
        try data(for: .myTV).endpoint(endpoint).scenario(scenario)
    }

    public static func mytvString(endpoint: MyTVEndpoint, scenario: Scenario) throws -> String {
        try string(for: .myTV).endpoint(endpoint).scenario(scenario)
    }

    public static func mytvErrorResponse() throws -> Data {
        try data("mytv-error-response")
    }

    public static func mytvOfflineError() throws -> Data {
        try data("mytv-offline-error")
    }
}

// MARK: - Project Brand Definitions

extension Fixtures.Project where Endpoint == Fixtures.MyTVEndpoint {
    public static var myTV: Fixtures.Project<Fixtures.MyTVEndpoint> {
        Fixtures.Project<Fixtures.MyTVEndpoint>(prefix: "mytv", displayName: "myTV")
    }
}

extension Fixtures.Project where Endpoint == Fixtures.ShowBookEndpoint {
    public static var showBook: Fixtures.Project<Fixtures.ShowBookEndpoint> {
        Fixtures.Project<Fixtures.ShowBookEndpoint>(prefix: "showbook", displayName: "ShowBook")
    }

    public static var ShowBook: Fixtures.Project<Fixtures.ShowBookEndpoint> {
        showBook
    }
}

extension Fixtures.Project where Endpoint == Fixtures.MotivationDailyEndpoint {
    public static var motivationDaily: Fixtures.Project<Fixtures.MotivationDailyEndpoint> {
        Fixtures.Project<Fixtures.MotivationDailyEndpoint>(prefix: "motivationdaily", displayName: "Motivation Daily")
    }
}
