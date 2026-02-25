import Foundation
import AVFoundation

final class SoundManager {
    static let shared = SoundManager()

    private let soundEnabledKey = "isSoundOn"
    private let supportedExtensions = ["wav", "mp3", "m4a", "aac", "caf", "aif", "aiff"]

    private var isEnabled = true
    private var gameplayActive = false
    private var gameplayBlend: Double = 0

    private var clickPlayer: AVAudioPlayer?
    private var sirenPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?

    private init() {
        configureAudioSession()
        syncWithSettings()
    }

    func syncWithSettings() {
        let defaults = UserDefaults.standard
        let value: Bool
        if defaults.object(forKey: soundEnabledKey) == nil {
            value = true
        } else {
            value = defaults.bool(forKey: soundEnabledKey)
        }
        setSoundEnabled(value)
    }

    func setSoundEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            stopAllAudio()
            return
        }
        if gameplayActive {
            startGameplayAudio(blend: gameplayBlend)
        }
    }

    func playClick() {
        guard isEnabled else { return }
        if clickPlayer == nil {
            clickPlayer = makePlayer(baseName: "ui_click", loops: 0)
        }
        clickPlayer?.currentTime = 0
        clickPlayer?.volume = 1
        clickPlayer?.play()
    }

    func startGameplayAudio(blend: Double) {
        gameplayActive = true
        gameplayBlend = min(1, max(0, blend))

        guard isEnabled else {
            stopGameplayPlayers()
            return
        }

        if sirenPlayer == nil {
            sirenPlayer = makePlayer(baseName: "siren_loop", loops: -1)
        }
        if ambientPlayer == nil {
            ambientPlayer = makePlayer(baseName: "ambient_loop", loops: -1)
        }

        sirenPlayer?.play()
        ambientPlayer?.play()
        applyGameplayBlend()
    }

    func setGameplayBlend(_ blend: Double) {
        gameplayBlend = min(1, max(0, blend))
        guard isEnabled else { return }
        if gameplayActive {
            if sirenPlayer?.isPlaying != true || ambientPlayer?.isPlaying != true {
                startGameplayAudio(blend: gameplayBlend)
            } else {
                applyGameplayBlend()
            }
        }
    }

    func stopGameplayAudio() {
        gameplayActive = false
        stopGameplayPlayers()
    }

    private func applyGameplayBlend() {
        let sirenVolume = Float(1 - gameplayBlend)
        let ambientVolume = Float(gameplayBlend)
        sirenPlayer?.volume = sirenVolume
        ambientPlayer?.volume = ambientVolume
    }

    private func stopGameplayPlayers() {
        sirenPlayer?.stop()
        ambientPlayer?.stop()
        sirenPlayer?.currentTime = 0
        ambientPlayer?.currentTime = 0
    }

    private func stopAllAudio() {
        clickPlayer?.stop()
        clickPlayer?.currentTime = 0
        stopGameplayPlayers()
    }

    private func makePlayer(baseName: String, loops: Int) -> AVAudioPlayer? {
        guard let url = resolveURL(for: baseName) else { return nil }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loops
            player.prepareToPlay()
            return player
        } catch {
            return nil
        }
    }

    private func resolveURL(for baseName: String) -> URL? {
        let nsName = baseName as NSString
        let extInName = nsName.pathExtension
        if !extInName.isEmpty {
            let cleanName = nsName.deletingPathExtension
            if let url = Bundle.main.url(forResource: cleanName, withExtension: extInName) {
                return url
            }
            return searchResourceRecursively(name: cleanName, ext: extInName)
        }

        for ext in supportedExtensions {
            if let url = Bundle.main.url(forResource: baseName, withExtension: ext) {
                return url
            }
            if let url = searchResourceRecursively(name: baseName, ext: ext) {
                return url
            }
        }
        return nil
    }

    private func searchResourceRecursively(name: String, ext: String) -> URL? {
        guard let root = Bundle.main.resourceURL else { return nil }
        let targetFile = "\(name).\(ext)"

        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        for case let fileURL as URL in enumerator {
            if fileURL.lastPathComponent.caseInsensitiveCompare(targetFile) == .orderedSame {
                return fileURL
            }
        }
        return nil
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
        }
    }
}
