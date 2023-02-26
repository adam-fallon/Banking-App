import Foundation
import ComposableArchitecture

struct AppContext: ReducerProtocol {
    @Dependency (\.httpClient) var httpClient
    @Dependency (\.jsonCoders) var jsonCoders
    @Dependency (\.uuidService) var uuidService
    @Dependency (\.apiConfiguration) var apiConfiguration
    
    // Scopes
    enum State: Equatable {
        case user(UserStore.State)
        case account(AccountStore.State)
        
        init() {
            self = .user(UserStore.State())
        }
    }
        
    enum Action: Equatable {
        case user(UserStore.Action)
        case account(AccountStore.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: /AppContext.State.user, action: /Action.user) {
          UserStore()
        }
        Scope(state: /AppContext.State.account, action: /Action.account) {
            AccountStore()
        }
        Reduce { state, action in
            switch action {
            case .user(.requestResponse(.success(let user))):
                state = .account(AccountStore.State(user: user, endDate: Date()))
                return .none
            default:
                return .none
            }
        }        
    }
}

extension AppContext {
    public static let live = Self()
}

extension AppContext {
    public static let test = Self()
}

extension AppContext: DependencyKey {
    static let liveValue = AppContext.live
}

extension AppContext: TestDependencyKey {
    static let testValue = AppContext.test
}

extension DependencyValues {
    var appContext: AppContext {
        get { self[AppContext.self] }
        set { self[AppContext.self] = newValue }
    }
}

struct WrappedAppContext: ReducerProtocol {
    var isLive: Bool
    
    var body: some ReducerProtocol<AppContext.State, AppContext.Action> {
        Reduce { state, action in
            // print(state, action)
            return .none
        }
        
        AppContext()
            .dependency(\.apiConfiguration, isLive ? .live : .unimplemented)
            .dependency(\.userClient, isLive ? .live : .test)
            .dependency(\.httpClient, isLive ? .live : .test)
            .dependency(\.appContext, isLive ? .live : .test)
            .dependency(\.accountClient, isLive ? .live : .test)
  }
}
