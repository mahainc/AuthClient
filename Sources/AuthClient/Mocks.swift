import Dependencies

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

extension AuthClient: TestDependencyKey {
    public static var testValue: Self {
        Self()
    }

    public static var previewValue: Self {
        Self()
    }
}

extension AuthClient {
    public static func happyPath(uid: String = "anon-uid") -> Self {
        let stored = LockIsolated<AuthUser?>(nil)
        return .init(
            currentUser: { stored.value },
            signInAnonymously: {
                let user = AuthUser(uid: uid, isAnonymous: true, email: nil)
                stored.setValue(user)
                return user
            },
            signOut: {
                stored.setValue(nil)
            },
            linkEmailPassword: { email, _ in
                guard let current = stored.value else { throw AuthError.notSignedIn }
                let upgraded = AuthUser(uid: current.uid, isAnonymous: false, email: email)
                stored.setValue(upgraded)
                return upgraded
            }
        )
    }
}
