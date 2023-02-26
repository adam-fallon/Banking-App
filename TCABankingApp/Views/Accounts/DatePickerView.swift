import SwiftUI
import ComposableArchitecture

struct DatePickerView: View {
    let store: StoreOf<AccountStore>
    @State var date: Date
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                DatePicker("Period Ending",
                           selection: $date,
                           displayedComponents: [.date])
                    .onChange(of: date, perform: { date in
                        viewStore.send(.dateChange(date))
                    })
            }
        }
    }
}
