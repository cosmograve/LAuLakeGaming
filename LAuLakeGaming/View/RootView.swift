import SwiftUI

enum AppRoute: Hashable {
    case rules
    case settings
    case gameplay
}

struct RootView: View {
    @State private var path: [AppRoute] = []

    var body: some View {
        ZStack {
            Color(hex: "#040026").ignoresSafeArea()

            NavigationStack(path: $path) {
                MenuView(path: $path)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .rules:
                            RulesView()
                        case .settings:
                            SettingsView()
                        case .gameplay:
                            GameplayView()
                        }
                    }
            }
        }
        .onAppear {
            SoundManager.shared.syncWithSettings()
        }
    }
}

#Preview {
    RootView()
}
