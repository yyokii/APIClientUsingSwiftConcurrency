import Foundation

public struct Request<Response> {
    var method: String
    var path: String
    var query: [String: String]?
    var body: AnyEncodable?

    public static func get(_ path: String, query: [String: String]? = nil) -> Request {
        Request(method: "GET",
                path: path,
                query: query)
    }

    public static func post<U: Encodable>(_ path: String, body: U) -> Request {
        Request(method: "POST",
                path: path,
                body: AnyEncodable(body))
    }
}


struct AnyEncodable: Encodable {
    private let value: Encodable

    init(_ value: Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
