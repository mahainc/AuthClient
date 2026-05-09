import DependenciesMacros

@DependencyClient
public struct AuthClient: Sendable {
    public var currentUser: @Sendable () -> AuthUser? = { nil }
    public var signInAnonymously: @Sendable () async throws -> AuthUser
    public var signOut: @Sendable () throws -> Void
    public var linkEmailPassword: @Sendable (_ email: String, _ password: String) async throws -> AuthUser
}
