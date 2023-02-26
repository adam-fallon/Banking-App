import SwiftUI
import ComposableArchitecture

@main
struct TCABankingApp: App {
    var uiTesting: Bool
    
    init() {
        uiTesting = ProcessInfo.processInfo.arguments.contains("isRunningUITests")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(
                    initialState:AppContext.State(),
                    reducer: WrappedAppContext(isLive: !uiTesting)
                )
            )
        }
    }
}
