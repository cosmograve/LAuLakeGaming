import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isSoundOn") private var storedSoundOn = true
    @State private var draftSoundOn = true

    var body: some View {
        GeometryReader { proxy in
            let bottomPadding = proxy.safeAreaInsets.bottom + max(42, min(92, proxy.size.height * 0.11))

            VStack(spacing: 18) {
                SettingsRow(
                    title: "Sound",
                    value: draftSoundOn ? "ON" : "OFF",
                    valueColor: draftSoundOn ? Color(hex: "#00FF7A") : Color(hex: "#FF2D2D"),
                    action: {
                        SoundManager.shared.playClick()
                        draftSoundOn.toggle()
                    }
                )
                .padding(.top, proxy.safeAreaInsets.top + 76)
                .padding(.horizontal, 24)

                Spacer()

                Button(action: {
                    SoundManager.shared.playClick()
                    storedSoundOn = draftSoundOn
                    SoundManager.shared.setSoundEnabled(storedSoundOn)
                    dismiss()
                }) {
                    MetalSurface(kind: .button) {
                        Text("Save")
                            .font(AppFont.tiny(size: 40, weight: .regular))
                            .foregroundStyle(Color(hex: "#FF0000"))
                    }
                    .frame(width: 168, height: 80)
                    .shadow(color: .black.opacity(0.45), radius: 12, x: 0, y: 8)
                }
                .padding(.bottom, bottomPadding)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
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
        .onAppear {
            draftSoundOn = storedSoundOn
        }
    }
}

private struct SettingsRow: View {
    let title: String
    let value: String
    let valueColor: Color
    let action: () -> Void

    var body: some View {
        MetalSurface(kind: .plate) {
            HStack {
                Text(title)
                    .font(AppFont.tiny(size: 42, weight: .regular))
                    .foregroundStyle(Color(hex: "#EEF1FF"))
                    .shadow(color: Color(hex: "#C21515").opacity(0.95), radius: 9, x: 0, y: 0)

                Spacer()

                Button(action: action) {
                    MetalSurface(kind: .button) {
                        Text(value)
                            .font(AppFont.tiny(size: 34, weight: .regular))
                            .foregroundStyle(valueColor)
                    }
                    .frame(width: 116, height: 58)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: 392)
        .frame(height: 112)
        .shadow(color: .black.opacity(0.42), radius: 11, x: 0, y: 7)
    }
}

#Preview {
    SettingsView()
}
