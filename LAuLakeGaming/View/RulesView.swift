import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { proxy in
            let minSide = min(proxy.size.width, proxy.size.height)
            let fontSize = max(17, min(28, minSide * 0.06))
            let lineSpacing = max(2, min(7, fontSize * 0.16))
            let horizontalPadding = max(20, min(34, proxy.size.width * 0.07))
            let topContentPadding = proxy.safeAreaInsets.top + max(44, min(80, proxy.size.height * 0.14))
            let bottomContentPadding = proxy.safeAreaInsets.bottom + max(56, min(112, proxy.size.height * 0.1))

            ZStack {
                VStack {
                    Text("""
                    When the system runs dry, the atmosphere turns cold, gray, and a persistent signal reminds you that the work has stopped. To bring back the peace, you have to engage. You physically rotate the valve—swipe by swipe, turn by turn. Each full rotation buys you ten minutes of deep, immersive ambient sound and a shift into a vibrant, living aesthetic.
                    """)
                    .font(AppFont.tiny(size: fontSize, weight: .regular))
                    .foregroundStyle(Color(hex: "#EEF1FF"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(lineSpacing)
                    .padding(.horizontal, horizontalPadding)
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, topContentPadding)
                .padding(.bottom, bottomContentPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background {
                StartScreenBackground(imageName: "RulesScreen")
                    .allowsHitTesting(false)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    SoundManager.shared.playClick()
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(Color(hex: "#E7EBF5"))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

#Preview {
    RulesView()
}
