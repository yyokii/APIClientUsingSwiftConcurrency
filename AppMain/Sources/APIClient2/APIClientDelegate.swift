import Foundation
import KeychainClient

public protocol APIClientDelegate {
    func client(willSendRequest request: inout URLRequest) async throws
    func shouldClientRetry(withError error: Error) async throws -> Bool
}

actor DefaultAPIClientDelegate: APIClientDelegate {

    let keychainClient: KeychainClientProtocol
    private var refreshTask: Task<Bool, Error>?

    init(keychainClient: KeychainClientProtocol) {
        self.keychainClient = keychainClient
    }

    nonisolated func client(willSendRequest request: inout URLRequest) async throws {
        let token: String = try await validToken()
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

    }

    func shouldClientRetry(withError error: Error) async throws -> Bool {
        if case .unacceptableStatusCode(let status, _) = (error as? APIClientError), status == 401 {
            return try await refreshToken()
        }

        return false
    }

    func validToken() async throws -> String {
        if let handle = refreshTask {
            let _ = try await handle.value
            return keychainClient.accessToken
        }

        let accessToken = keychainClient.accessToken

        if accessToken.isEmpty {
            throw APIClientError.missingToken
        } else {
            return accessToken
        }
    }

    private func refreshToken() async throws -> Bool {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }

        let task = Task { () throws -> Bool in
            defer { refreshTask = nil }

            let result = try await apiClient.send(Path.auth().get)
            keychainClient.saveToken(accessToken: result.accessToken, refreshToken: result.refreshToken)

            return true
        }

        self.refreshTask = task
        return try await task.value
    }
}
