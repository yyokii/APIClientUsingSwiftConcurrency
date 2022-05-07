public enum Path {}

extension Path {
    static func auth() -> TokenRefresh {
        TokenRefresh(path: "/auth/refresh_token")
    }

    struct TokenRefresh {
        let path: String

        var get: Request<TokenResponse> { .get(path) }
    }
}
