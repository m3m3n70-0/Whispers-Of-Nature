import Foundation
import AVFoundation
import MediaPlayer
import UIKit

class AudioViewModel: ObservableObject {
    static let shared = AudioViewModel() // Singleton instance
    @Published var isAudioPlaying = false
    
    private var wavePlayer: AVAudioPlayer?
    private var treePlayer: AVAudioPlayer?
    private var firePlayer: AVAudioPlayer?
    private var lastVolumes: [String: Float] = ["waves": 0.0, "trees": 0.0, "fire": 0.0]
    private var isNotificationScheduled = false

    init() {
        setupRemoteCommandCenter()
    }

    private func createPlayer(sound: String, volume: Float) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else {
            print("Failed to find the sound file for \(sound).")
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.numberOfLoops = -1
            return player
        } catch {
            print("Failed to initialize the audio player for \(sound): \(error).")
            return nil
        }
    }

    func playAllAudios() {
        if !isAnyAudioPlaying() {
            wavePlayer = createPlayer(sound: "waves", volume: lastVolumes["waves"] ?? 0.0)
            treePlayer = createPlayer(sound: "trees", volume: lastVolumes["trees"] ?? 0.0)
            firePlayer = createPlayer(sound: "fire", volume: lastVolumes["fire"] ?? 0.0)

            wavePlayer?.play()
            treePlayer?.play()
            firePlayer?.play()
            isAudioPlaying = true

            updateNowPlayingInfo(isPlaying: true)
            scheduleNotificationIfNeeded()
        }
    }

    func stopAllAudio() {
        [wavePlayer, treePlayer, firePlayer].forEach { $0?.stop() }
        isAudioPlaying = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        if isNotificationScheduled {
            AppDelegate.shared.cancelNotification()
            isNotificationScheduled = false
        }
    }

    func pauseAudio() {
        [wavePlayer, treePlayer, firePlayer].forEach { $0?.pause() }
        isAudioPlaying = false
        updateNowPlayingInfo(isPlaying: false)
    }

    func isAnyAudioPlaying() -> Bool {
        return wavePlayer?.isPlaying ?? false || treePlayer?.isPlaying ?? false || firePlayer?.isPlaying ?? false
    }

    func setVolume(for sound: String, volume: Float) {
        switch sound {
        case "waves":
            lastVolumes["waves"] = volume
            wavePlayer?.volume = volume
        case "trees":
            lastVolumes["trees"] = volume
            treePlayer?.volume = volume
        case "fire":
            lastVolumes["fire"] = volume
            firePlayer?.volume = volume
        default: break
        }
    }

    private func updateNowPlayingInfo(isPlaying: Bool) {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Nature Sounds"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Whispers Of Nature"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Relaxation Collection"
        if let image = UIImage(named: "albumArt") {
            let artwork = MPMediaItemArtwork(boundsSize: CGSize(width: 300, height: 300)) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    private func scheduleNotificationIfNeeded() {
        if !isNotificationScheduled {
            AppDelegate.shared.scheduleNotification()
            isNotificationScheduled = true
        }
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            self?.playAllAudios()
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            self?.pauseAudio()
            return .success
        }

        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { [weak self] event -> MPRemoteCommandHandlerStatus in
            self?.stopAllAudio()
            return .success
        }
    }
}
