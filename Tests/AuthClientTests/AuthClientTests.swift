import Testing
@testable import AuthClient

@Suite("AuthClient happy-path mock")
struct AuthClientHappyPathTests {
    @Test("signInAnonymously returns the configured uid and marks the user anonymous")
    func signInAnonymouslyReturnsUser() async throws {
        let client = AuthClient.happyPath(uid: "test-uid")
        let user = try await client.signInAnonymously()

        #expect(user.uid == "test-uid")
        #expect(user.isAnonymous == true)
        #expect(user.email == nil)
    }

    @Test("currentUser tracks signInAnonymously and signOut")
    func currentUserTracksSession() async throws {
        let client = AuthClient.happyPath()

        #expect(client.currentUser() == nil)

        _ = try await client.signInAnonymously()
        #expect(client.currentUser() != nil)
        #expect(client.currentUser()?.isAnonymous == true)

        try client.signOut()
        #expect(client.currentUser() == nil)
    }

    @Test("linkEmailPassword upgrades the anonymous user, preserving uid")
    func linkEmailPasswordUpgradesUser() async throws {
        let client = AuthClient.happyPath(uid: "stable-uid")

        _ = try await client.signInAnonymously()
        let linked = try await client.linkEmailPassword("user@example.com", "p4ssw0rd!")

        #expect(linked.uid == "stable-uid")
        #expect(linked.isAnonymous == false)
        #expect(linked.email == "user@example.com")
    }

    @Test("linkEmailPassword without a session throws .notSignedIn")
    func linkEmailPasswordRequiresSession() async {
        let client = AuthClient.happyPath()

        await #expect(throws: AuthError.notSignedIn) {
            _ = try await client.linkEmailPassword("user@example.com", "p4ssw0rd!")
        }
    }
}
