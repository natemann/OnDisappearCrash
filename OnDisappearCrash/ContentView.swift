import SwiftUI
import ComposableArchitecture


struct AppState: Equatable {

    var detailState: DetailState?
}


enum AppAction {
    case presentDetail
    case detailAction(DetailAction)
}


let appReducer: Reducer<AppState, AppAction, Void> = .combine(
    detailReducer.optional.pullback(
        state: \.detailState,
        action: /AppAction.detailAction,
        environment: { _ in ()}),

    Reducer { state, action, _ in
        switch action {
        case .presentDetail:
            state.detailState = DetailState()
            return .none

        case .detailAction(let detailAction):
            switch detailAction {
            case .dismiss:
                state.detailState = nil

            case .buttonPressed:
                return .init(value: .detailAction(.dismiss))
            }
            return .none
        }
    }
)
struct DetailState: Equatable {
    var randomText: String = ""
}

enum DetailAction {
    case dismiss
    case buttonPressed
}

let detailReducer = Reducer<DetailState, DetailAction, Void> { state, action, _ in
    switch action {
    case .buttonPressed:
        return .none

    case .dismiss:
        return .none
    }
}


struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: { viewStore.send(.presentDetail) },
                label: { Text("Present Modal") })
                .sheet(isPresented: .constant(viewStore.detailState != nil)) {
                    IfLetStore(
                        self.store.scope(
                            state: { $0.detailState }, action: AppAction.detailAction),
                        then: DetailView.init(store:))
            }
        }
    }
}


struct DetailView: View {
    let store: Store<DetailState, DetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: { viewStore.send(.buttonPressed) },
                label: {
                    Text("push this for crash") }
            ).onDisappear {
                viewStore.send(.dismiss)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: .init(
                initialState: .init(),
                reducer: appReducer,
                environment: ()))
    }
}
