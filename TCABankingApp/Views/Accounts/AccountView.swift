import SwiftUI
import ComposableArchitecture

struct AccountView: View {
    let store: StoreOf<AccountStore>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                viewStore.user.accounts.isEmpty ? Text("No Accounts")
                    .padding()
                    .foregroundColor(.gray)
                    .accessibilityIdentifier("emptyAccounts")
                : nil
                
                AccountsList(accounts: viewStore.user.accounts, action: { account in
                    viewStore.send(.pickAccount(account))
                })
                .sheet(isPresented: viewStore.binding(
                    get: \.isSheetPresented,
                    send: AccountStore.Action.setSheet(isPresented:)
                )) {
                    if let selectedAccount = viewStore.selectedAccount {
                        TransactionView(store: store, account: selectedAccount)
                    }
                }
            }
        }
    }
}

struct AccountsList: View {
    var accounts: [Account]
    var action: (Account) -> Void
    
    var body: some View {
        List (accounts) { account in
            Button(action: {
                action(account)
            }) {
                Text("\(account.name) - \(account.currency)")
            }
            .accessibilityIdentifier("account-\(account.accountUid)")
        }
        .accessibilityIdentifier("accountList")
    }
}
