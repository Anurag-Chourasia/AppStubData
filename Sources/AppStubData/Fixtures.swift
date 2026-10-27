import Foundation

public enum Fixtures {
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

    public static func data(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try Data(contentsOf: url)
    }

    public static func string(_ name: String) throws -> String {
        String(decoding: try data(name), as: UTF8.self)
    }

    // MARK: - ShowBook Fixtures

    public static func showbook(endpoint: ShowBookEndpoint, scenario: Scenario) throws -> Data {
        try data("showbook-\(endpoint.rawValue)-\(scenario.rawValue)")
    }

    public static func showbookString(endpoint: ShowBookEndpoint, scenario: Scenario) throws -> String {
        try string("showbook-\(endpoint.rawValue)-\(scenario.rawValue)")
    }

    // MARK: - MyTV Fixtures

    public static func mytv(endpoint: MyTVEndpoint, scenario: Scenario) throws -> Data {
        try data("mytv-\(endpoint.rawValue)-\(scenario.rawValue)")
    }

    public static func mytvString(endpoint: MyTVEndpoint, scenario: Scenario) throws -> String {
        try string("mytv-\(endpoint.rawValue)-\(scenario.rawValue)")
    }

    public static func mytvErrorResponse() throws -> Data {
        try data("mytv-error-response")
    }

    public static func mytvOfflineError() throws -> Data {
        try data("mytv-offline-error")
    }
}
