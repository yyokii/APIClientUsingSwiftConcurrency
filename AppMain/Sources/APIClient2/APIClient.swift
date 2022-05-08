import Foundation
import KeychainClient

let apiClient = APIClient2.shared

actor APIClient2 {
    private let session: URLSession
    private let host: String
    private let serializer = Serializer()
    private let delegate: APIClientDelegate

    static let shared = APIClient2(host: "com.aaaaa", configuration: .default, delegate: DefaultAPIClientDelegate(keychainClient: StubKeychainClient()))

    init(host: String, configuration: URLSessionConfiguration = .default, delegate: APIClientDelegate? = nil) {
        self.host = host
        self.session = URLSession(configuration: configuration)
        self.delegate = delegate ?? DefaultAPIClientDelegate(keychainClient: StubKeychainClient())
    }

    public func send<T: Decodable>(_ request: Request<T>) async throws -> T {
        try await send(request, serializer.decode)
    }

    public func send<T>(_ request: Request<T>, _ decode: @escaping (Data) async throws -> T ) async throws -> T {
        let request = try await makeRequest(for: request)
        let (data, response) = try await send(request)
        try await validate(response: response, data: data)
        return try await decode(data)
    }

    // 戻り値の方固定していいかもね
    public func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await actuallySend(request)
        } catch {
            guard try await delegate.shouldClientRetry(withError: error) else { throw error }
            return try await actuallySend(request)
        }
    }

    public func actuallySend(_ request: URLRequest) async throws -> (Data, URLResponse) {
        var request = request

        try await delegate.client(willSendRequest: &request)

        return try await session.data(for: request)
    }

    private func makeRequest<T>(for request: Request<T>) async throws -> URLRequest {
        let url = try makeURL(path: request.path, query: request.query)
        return try await makeRequest(url: url, method: request.method, body: request.body)
    }

    private func makeURL(path: String, query: [String: String]?) throws -> URL {
        guard let url = URL(string: path),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                  throw URLError(.badURL)
              }
        if path.starts(with: "/") {
            components.scheme = "https"
            components.host = host
        }
        if let query = query {
            components.queryItems = query.map(URLQueryItem.init)
        }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }

    func makeRequest(url: URL, method: String, body: AnyEncodable?) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = body {
            request.httpBody = try await serializer.encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    // WIP
    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.other("not an http response")
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            switch httpResponse.statusCode {
            case 400:
                break
            default:
                break
            }

            // TODO:
            throw APIClientError.unacceptableStatusCode(statusCode: httpResponse.statusCode, body: data)
        }
    }
}

@available(iOS, deprecated: 15.0, message: "iOS15 or later should use the standard API.")
extension URLSession {
    func data(for url: URLRequest) async throws -> (Data, URLResponse) {
         try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                 guard let data = data, let response = response else {
                     let error = error ?? URLError(.badServerResponse)
                     return continuation.resume(throwing: error)
                 }
                 continuation.resume(returning: (data, response))
             }
             task.resume()
        }
    }
}
