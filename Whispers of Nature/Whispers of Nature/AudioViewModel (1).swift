
import Foundation

class AudioViewModel: ObservableObject {
    static let shared = AudioViewModel() // Singleton instance

    func stopAudio() {
        // Implement your audio stop logic here
        print("Audio stopped")
    }
}
