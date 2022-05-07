import Foundation

enum APIClientError: Error {
    case encodeError
    case connectionError(Data)
    case unacceptableStatusCode(statusCode: Int, body: Data)
    case missingToken
    case other(String)
}


struct APIErrorResponce: Codable {
    var error: Error

    init(error: Error) {
        self.error = error
    }
}

extension APIErrorResponce {
    struct Error: Codable {
        var message: String
    }
}
