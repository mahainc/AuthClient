# AuthClient

A small TCA dependency client for **Firebase Anonymous Authentication** with email-password account linking. Built on [`swift-composable-architecture`](https://github.com/pointfreeco/swift-composable-architecture) and [`firebase-ios-sdk`](https://github.com/firebase/firebase-ios-sdk).

The package ships two products:

- **`AuthClient`** — interface only. No Firebase imports, safe for tests and previews.
- **`AuthClientLive`** — wraps `FirebaseAuth.Auth` and registers the live `DependencyKey`.

## Installation

In your `Package.swift`:

```swift
.package(url: "https://github.com/mahainc/AuthClient.git", branch: "main"),
```

Add `AuthClient` to your feature target and `AuthClientLive` to your app target.

In your app entry point, configure Firebase before any reducer runs:

```swift
import FirebaseCore

@main
struct MyApp: App {
    init() { FirebaseApp.configure() }
    // ...
}
```

Make sure `GoogleService-Info.plist` is added to the app target, and that **Anonymous** is enabled in Firebase Console → Authentication → Sign-in method.

## Usage

```swift
import AuthClient
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State { var uid: String? }

    enum Action { case onAppear, signedIn(String) }

    @Dependency(\.authClient) var auth

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    if let user = auth.currentUser() {
                        await send(.signedIn(user.uid))
                    } else {
                        let user = try await auth.signInAnonymously()
                        await send(.signedIn(user.uid))
                    }
                }
            case let .signedIn(uid):
                state.uid = uid
                return .none
            }
        }
    }
}
```

## Linking an anonymous account to email/password

```swift
@Dependency(\.authClient) var auth

let upgraded = try await auth.linkEmailPassword("user@example.com", "p4ssw0rd!")
// upgraded.uid is preserved; upgraded.isAnonymous == false
```

`linkEmailPassword` throws `AuthError.notSignedIn` if there is no current user, and `AuthError.alreadyLinked` if the credential is already attached to the account.

## Testing

The interface module ships a `happyPath` mock that maintains a stable in-memory session — useful in `TestStore` setups:

```swift
let store = TestStore(initialState: AppFeature.State()) {
    AppFeature()
} withDependencies: {
    $0.authClient = .happyPath(uid: "test-uid")
}
```

`testValue` and `previewValue` use the macro-generated unimplemented defaults — override them in tests to assert on individual closures.

## License

MIT — see [LICENSE](./LICENSE).
