import SwiftUI
import ComposableArchitecture

struct SavingsView: View {
    var store: StoreOf<SavingsStore>
    
    var body: some View {        
        WithViewStore(self.store) { viewStore in
            VStack {
                if viewStore.state.goalSaved {
                    Text("Goal saved!")
                }
                else if viewStore.state.loading {
                    Text("Loading...")
                } else {
                    if let error = viewStore.state.error {
                        Text(error)
                    }
                    
                    List(viewStore.state.goals) { goal in
                        HStack {
                            Text(goal.name)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    Spacer()
                    Button("Save \(viewStore.state.roundUp?.displayString ?? "NaN") to goal") {
                        viewStore.send(.requestSaveRoundUp)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onAppear {
                viewStore.send(.getGoals)
            }
            .navigationBarTitle("Savings Goals")
        }
    }
}
