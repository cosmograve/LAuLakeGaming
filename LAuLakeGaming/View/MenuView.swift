import SwiftUI

struct MenuView: View {
    @Binding var path: [AppRoute]

    var body: some View {
        GeometryReader { proxy in
            let startBottomPadding = proxy.safeAreaInsets.bottom + max(42, min(92, proxy.size.height * 0.11))

            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("L’AuLake")
                        .font(.system(size: min(proxy.size.width * 0.22, 96), weight: .regular, design: .serif))
                        .foregroundStyle(Color(hex: "#CAD0DD"))
                        .minimumScaleFactor(0.7)

                    Text("Gaming")
                        .font(.system(size: min(proxy.size.width * 0.13, 56), weight: .regular, design: .serif))
                        .foregroundStyle(Color(hex: "#CAD0DD"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .offset(y: -18)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.top, proxy.safeAreaInsets.top + 50)
                .frame(maxHeight: .infinity, alignment: .top)

                VStack {
                    Spacer()

                    Button(action: {
                        SoundManager.shared.playClick()
                        path.append(.gameplay)
                    }) {
                        MetalSurface(kind: .button) {
                            Text("Start")
                                .font(AppFont.tiny(size: 40, weight: .regular))
                                .foregroundStyle(Color(hex: "#FF0000"))
                        }
                        .frame(width: 168, height: 80)
                        .shadow(color: .black.opacity(0.45), radius: 12, x: 0, y: 8)
                    }
                    .padding(.bottom, startBottomPadding)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            .background {
                StartScreenBackground()
                    .allowsHitTesting(false)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    SoundManager.shared.playClick()
                    path.append(.rules)
                }) {
                    Text("?")
                        .font(AppFont.tiny(size: 30, weight: .regular))
                        .foregroundStyle(Color(hex: "#CAD0DD"))
                }

                Button(action: {
                    SoundManager.shared.playClick()
                    path.append(.settings)
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(Color(hex: "#CAD0DD"))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

#Preview {
    MenuView(path: .constant([]))
}
