import Foundation

public enum Fixtures {
    /// Supported application projects that consume shared fixtures.
    /// Extend this enum when adding new projects to the submodule.
    public enum Project: String, CaseIterable, Sendable {
        case myTV = "mytv"
        case showBook = "showbook"

        public var displayName: String {
            switch self {
            case .myTV: return "myTV"
            case .showBook: return "ShowBook"
            }
        }

        public var prefix: String { rawValue }
    }

    public enum Scenario: String, CaseIterable, Sendable {
        case positive
        case empty
        case negative
    }

    public enum ShowBookEndpoint: String, CaseIterable, Sendable {
        case search
        case discover
        case work
        case editions
        case edition
        case countries
        case ip
    }

    public typealias Endpoint = ShowBookEndpoint

    public enum MyTVEndpoint: String, CaseIterable, Sendable {
        case channels
        case streams
        case logos
        case categories
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

    // MARK: - Project-scoped Fixture Access

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

    // MARK: - ShowBook Typed Fixtures

    public static func showbook(endpoint: ShowBookEndpoint, scenario: Scenario) throws -> Data {
        try data(for: .showBook, endpoint: endpoint.rawValue, scenario: scenario)
    }

    public static func showbookString(endpoint: ShowBookEndpoint, scenario: Scenario) throws -> String {
        try string(for: .showBook, endpoint: endpoint.rawValue, scenario: scenario)
    }

    // MARK: - MyTV Typed Fixtures

    public static func mytv(endpoint: MyTVEndpoint, scenario: Scenario) throws -> Data {
        try data(for: .myTV, endpoint: endpoint.rawValue, scenario: scenario)
    }

    public static func mytvString(endpoint: MyTVEndpoint, scenario: Scenario) throws -> String {
        try string(for: .myTV, endpoint: endpoint.rawValue, scenario: scenario)
    }

    public static func mytvErrorResponse() throws -> Data {
        try data("mytv-error-response")
    }

    public static func mytvOfflineError() throws -> Data {
        try data("mytv-offline-error")
    }
}
