import SwiftUI

struct LoadingView: View {
    @State private var loadingProgress: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
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

                    Capsule()
                        .fill(Color.white.opacity(0.88))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Color(hex: "#66699F"))
                                .frame(width: max(0, (proxy.size.width - 108) * loadingProgress))
                        }
                        .frame(height: 26)
                        .padding(.horizontal, 54)
                        .padding(.bottom, 82)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            .background {
                StartScreenBackground()
                    .allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    LoadingView()
}
