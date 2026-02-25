import SwiftUI
import Combine

struct GameplayView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var remainingSeconds = 0
    @State private var wheelRotation: Double = 0
    @State private var lastDragAngle: Double?
    @State private var clockwiseBufferedDegrees: Double = 0
    @State private var counterclockwiseBufferedDegrees: Double = 0
    @State private var hasActivatedAudio = false
    @State private var gameplayAudioRunning = false
    private let maxSeconds = 24 * 60 * 60
    private let tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var tubesAssetName: String {
        "Tubs off"
    }

    private var firstMinuteProgress: Double {
        min(1, max(0, Double(remainingSeconds) / 60))
    }

    private var tubeMinOpacity: Double {
        let p = firstMinuteProgress
        if p < 0.5 { return 2 * p }
        return 2 * (1 - p)
    }

    private var tubeMaxOpacity: Double {
        let p = firstMinuteProgress
        if p < 0.5 { return 0 }
        return (2 * p) - 1
    }

    private var wheelOnOpacity: Double {
        min(1, max(0, Double(remainingSeconds) / 25))
    }

    private var showContinue: Bool {
        remainingSeconds == 0
    }

    private var backgroundBlend: Double {
        min(1, max(0, Double(remainingSeconds) / 120))
    }

    private var backgroundTopColor: Color {
        blendedColor(
            from: (0.16, 0.16, 0.18),
            to: (0.19, 0.20, 0.48),
            progress: backgroundBlend
        )
    }

    private var backgroundMidColor: Color {
        blendedColor(
            from: (0.08, 0.08, 0.09),
            to: (0.05, 0.07, 0.38),
            progress: backgroundBlend
        )
    }

    private var backgroundBottomColor: Color {
        blendedColor(
            from: (0.02, 0.02, 0.03),
            to: (0.01, 0.03, 0.16),
            progress: backgroundBlend
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let wheelSize = min(proxy.size.width * 0.72, 338.0)
            let backSize = wheelSize * 1.36
            let timerWidth = min(proxy.size.width * 0.36, 164.0)
            let wheelCenterX = proxy.size.width / 2
            let wheelCenterY = proxy.size.height / 2 + min(26, proxy.size.height * 0.03)
            let timerX = wheelCenterX + min(62, proxy.size.width * 0.16)
            let timerY = wheelCenterY + min(wheelSize * 0.82, 220)

            ZStack {
                LinearGradient(
                    colors: [
                        backgroundTopColor,
                        backgroundMidColor,
                        backgroundBottomColor
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .animation(.easeInOut(duration: 0.4), value: backgroundBlend)
                .ignoresSafeArea()

                Image(tubesAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .opacity(0.9)
                    .scaleEffect(1.08)
                    .ignoresSafeArea()

                Image("Tubs on min")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .opacity(tubeMinOpacity)
                    .scaleEffect(1.08)
                    .animation(.easeInOut(duration: 0.35), value: tubeMinOpacity)
                    .ignoresSafeArea()

                Image("Tubs on max")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .opacity(tubeMaxOpacity)
                    .scaleEffect(1.08)
                    .animation(.easeInOut(duration: 0.35), value: tubeMaxOpacity)
                    .ignoresSafeArea()

                if showContinue {
                    Text("Continue the work")
                        .font(AppFont.tiny(size: 30, weight: .regular))
                        .foregroundStyle(Color(hex: "#C8CCD9"))
                        .position(x: proxy.size.width / 2, y: proxy.safeAreaInsets.top + 210)
                }

                ZStack {
                    Image("WheelBack")
                        .resizable()
                        .scaledToFit()
                        .frame(width: backSize, height: backSize)

                    ZStack {
                        Image("Wheel")
                            .resizable()
                            .scaledToFit()
                            .frame(width: wheelSize, height: wheelSize)
                            .opacity(1 - wheelOnOpacity)
                            .animation(.easeInOut(duration: 0.35), value: wheelOnOpacity)

                        Image("Wheel on")
                            .resizable()
                            .scaledToFit()
                            .frame(width: wheelSize, height: wheelSize)
                            .opacity(wheelOnOpacity)
                            .animation(.easeInOut(duration: 0.35), value: wheelOnOpacity)
                    }
                    .frame(width: wheelSize, height: wheelSize)
                    .rotationEffect(.degrees(wheelRotation), anchor: .center)
                    .contentShape(Circle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let center = CGPoint(x: wheelSize / 2, y: wheelSize / 2)
                                let angle = angleFor(point: value.location, center: center)

                                guard let last = lastDragAngle else {
                                    lastDragAngle = angle
                                    return
                                }

                                let delta = normalizedDelta(from: last, to: angle)
                                wheelRotation += delta
                                if delta > 0 {
                                    clockwiseBufferedDegrees += delta
                                } else if delta < 0 {
                                    counterclockwiseBufferedDegrees += abs(delta)
                                }

                                while clockwiseBufferedDegrees >= requiredDegreesForTurn {
                                    incrementTimerStep()
                                    clockwiseBufferedDegrees -= requiredDegreesForTurn
                                }

                                while counterclockwiseBufferedDegrees >= requiredDegreesForTurn {
                                    decrementTimerStep()
                                    counterclockwiseBufferedDegrees -= requiredDegreesForTurn
                                }

                                lastDragAngle = angle
                            }
                            .onEnded { _ in
                                lastDragAngle = nil
                            }
                    )
                }
                .position(x: wheelCenterX, y: wheelCenterY)

                MetalSurface(kind: .button) {
                    Text(timeString(from: remainingSeconds))
                        .font(AppFont.tiny(size: 22, weight: .regular))
                        .foregroundStyle(Color(hex: "#FF3434"))
                }
                .frame(width: timerWidth, height: 56)
                .position(x: timerX, y: timerY)
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: {
                SoundManager.shared.playClick()
                dismiss()
            }) {
                Circle()
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 46, height: 46)
                    .overlay {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(hex: "#E1E6F5"))
                    }
            }
            .padding(.leading, 22)
            .padding(.top, 40)
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onReceive(tick) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            }
        }
        .onAppear {
            SoundManager.shared.syncWithSettings()
            hasActivatedAudio = false
            gameplayAudioRunning = false
            SoundManager.shared.stopGameplayAudio()
        }
        .onChange(of: remainingSeconds) { _ in
            syncGameplayAudio()
        }
        .onDisappear {
            SoundManager.shared.stopGameplayAudio()
            remainingSeconds = 0
            wheelRotation = 0
            lastDragAngle = nil
            clockwiseBufferedDegrees = 0
            counterclockwiseBufferedDegrees = 0
            hasActivatedAudio = false
            gameplayAudioRunning = false
        }
    }

    private func incrementTimerStep() {
        if remainingSeconds < 60 {
            remainingSeconds = min(60, remainingSeconds + 10)
            hasActivatedAudio = true
            return
        }

        remainingSeconds = min(maxSeconds, remainingSeconds + 600)
        hasActivatedAudio = true
    }

    private func decrementTimerStep() {
        guard remainingSeconds > 0 else { return }

        if remainingSeconds <= 60 {
            remainingSeconds = max(0, remainingSeconds - 10)
            return
        }

        remainingSeconds = max(60, remainingSeconds - 600)
    }

    private func timeString(from totalSeconds: Int) -> String {
        let safeSeconds = max(0, totalSeconds)
        let hours = safeSeconds / 3600
        let minutes = (safeSeconds % 3600) / 60
        let seconds = safeSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func angleFor(point: CGPoint, center: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return atan2(dy, dx) * 180 / .pi
    }

    private func normalizedDelta(from old: Double, to new: Double) -> Double {
        var delta = new - old
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return delta
    }

    private var requiredDegreesForTurn: Double {
        remainingSeconds > 6 * 60 * 60 ? 540 : 360
    }

    private func syncGameplayAudio() {
        guard hasActivatedAudio else {
            if gameplayAudioRunning {
                SoundManager.shared.stopGameplayAudio()
                gameplayAudioRunning = false
            }
            return
        }

        let blend: Double
        if remainingSeconds > 5 {
            blend = 1
        } else {
            blend = max(0, Double(remainingSeconds) / 5)
        }

        if !gameplayAudioRunning {
            SoundManager.shared.startGameplayAudio(blend: blend)
            gameplayAudioRunning = true
        }
        SoundManager.shared.setGameplayBlend(blend)
    }

    private func blendedColor(
        from start: (Double, Double, Double),
        to end: (Double, Double, Double),
        progress: Double
    ) -> Color {
        let t = min(1, max(0, progress))
        let r = start.0 + (end.0 - start.0) * t
        let g = start.1 + (end.1 - start.1) * t
        let b = start.2 + (end.2 - start.2) * t
        return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}

#Preview {
    GameplayView()
}
