import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    let store: StoreOf<UserStore>
    
    @State var accessToken: String = ""
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                if let error = viewStore.errorReason {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .accessibilityIdentifier("error")
                }
                Form {
                    SecureField("Access Token", text: $accessToken)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .accessibilityIdentifier("accessToken")
                    Button("Log in") {
                        viewStore.send(.loadUser(accessToken))
                    }
                    .disabled(viewStore.state.loading)
                    .accessibilityIdentifier("login")
                }
            }
        }
    }
}
