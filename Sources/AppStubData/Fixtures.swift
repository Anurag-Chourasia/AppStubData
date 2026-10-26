import Foundation
public enum Fixtures {
    public static func data(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try Data(contentsOf: url)
    }
    public static func string(_ name: String) throws -> String {
        String(decoding: try data(name), as: UTF8.self)
    }
}
