import SwiftUI
import ComposableArchitecture

struct TransactionView: View {
    let store: StoreOf<AccountStore>
    
    var account: Account
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                if let feedItems = viewStore.transactions?.feedItems {
                    Form {
                        Section(header: Text("Round up"),
                                footer: Text("The round up feature will round up outgoing transactions for the 7 days up to the date you select. This amount will then be sent to a savings pot.")) {
                            VStack {
                                HStack {
                                    Text("Round up:")
                                        .font(.title)
                                    Text(viewStore.state.roundUpAmount?.displayString ?? "0")
                                        .font(.title)
                                        .accessibilityIdentifier("transaction-roundUpAmount")
                                }
                                DatePickerView(store: store,
                                               date: viewStore.endDate)
                                    .accessibilityIdentifier("transaction-datePicker")
                                NavigationLink(destination: SavingsView(store: Store(initialState: SavingsStore.State(user: viewStore.state.user,
                                                                                                                      selectedAccount: viewStore.state.selectedAccount,
                                                                                                                      roundUp: viewStore.state.roundUpAmount),
                                                                                     reducer: SavingsStore()))) {
                                    Text("Save round up amount")
                                        .foregroundColor(.blue)
                                        .accessibilityIdentifier("transaction-roundUpButton")
                                }.disabled(viewStore.state.roundUpAmount == nil)
                            }
                            .navigationBarTitle("Transactions")
                        }
                        
                        Section("Transactions for this period") {
                            List (feedItems) { transaction in
                                Text("\(transaction.amount.displayString)")
                                    .accessibilityIdentifier("transaction-\(transaction.feedItemUid)")
                            }
                            .accessibilityIdentifier("transaction-list")
                        }
                    }
                } else if viewStore.loading {
                    Text("Loading...")
                        .foregroundColor(.gray)
                        .padding()
                        .accessibilityIdentifier("transactions-loading")
                } else if let error = viewStore.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .accessibilityIdentifier("transactions-error")
                }
            }
            .onAppear() {
                viewStore.send(.setSheet(isPresented: true))
            }
            .navigationTitle("Round Up")
        }
    }
}
