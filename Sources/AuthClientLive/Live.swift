import AuthClient
import Dependencies
import FirebaseAuth

extension AuthClient: DependencyKey {
    public static var liveValue: Self {
        return AuthClient(
            currentUser: {
                Auth.auth().currentUser.map {
                    AuthUser(uid: $0.uid, isAnonymous: $0.isAnonymous, email: $0.email)
                }
            },
            signInAnonymously: {
                do {
                    let result = try await Auth.auth().signInAnonymously()
                    return AuthUser(
                        uid: result.user.uid,
                        isAnonymous: result.user.isAnonymous,
                        email: result.user.email
                    )
                } catch {
                    throw AuthError.providerError(message: error.localizedDescription)
                }
            },
            signOut: {
                do {
                    try Auth.auth().signOut()
                } catch {
                    throw AuthError.providerError(message: error.localizedDescription)
                }
            },
            linkEmailPassword: { email, password in
                guard let user = Auth.auth().currentUser else {
                    throw AuthError.notSignedIn
                }
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                do {
                    let linked = try await user.link(with: credential)
                    return AuthUser(
                        uid: linked.user.uid,
                        isAnonymous: linked.user.isAnonymous,
                        email: linked.user.email
                    )
                } catch let nsError as NSError
                    where nsError.code == AuthErrorCode.providerAlreadyLinked.rawValue
                {
                    throw AuthError.alreadyLinked
                } catch {
                    throw AuthError.providerError(message: error.localizedDescription)
                }
            }
        )
    }
}
