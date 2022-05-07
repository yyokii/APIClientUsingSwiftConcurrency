public protocol KeychainClientProtocol {
    var accessToken: String { get }
    var refreshToken: String { get }

    func saveToken(accessToken: String, refreshToken: String)
}

#if DEBUG

public final class StubKeychainClient: KeychainClientProtocol {
    static let shared = StubKeychainClient()

    public var accessToken: String = "stub accessToken"
    public var refreshToken: String = "stub refreshToken"

    public func saveToken(accessToken: String, refreshToken: String) {
        // save
    }

    public init() {}

}

#endif
