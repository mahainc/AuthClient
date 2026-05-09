import Foundation

public struct AuthUser: Equatable, Sendable {
    public let uid: String
    public let isAnonymous: Bool
    public let email: String?

    public init(uid: String, isAnonymous: Bool, email: String? = nil) {
        self.uid = uid
        self.isAnonymous = isAnonymous
        self.email = email
    }
}

public enum AuthError: Error, Equatable, Sendable {
    case notSignedIn
    case alreadyLinked
    case providerError(message: String)
}
