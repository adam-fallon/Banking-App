import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<AppContext>
    
    public init(store: StoreOf<AppContext>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            SwitchStore(self.store) {
                CaseLet(state: /AppContext.State.user,
                        action: AppContext.Action.user) { store in
                    LoginView(store: store)
                        .navigationBarTitle("Login")
                }
                CaseLet(state: /AppContext.State.account,
                        action: AppContext.Action.account) { store in
                    AccountView(store: store)
                        .navigationBarTitle("Accounts")
                }
            }
        }
    }
}
