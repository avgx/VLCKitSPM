import SwiftUI
import AVKit
import AVFoundation

public struct VLCKitPlayerView: UIViewRepresentable {
    @Binding var playerWrapper: VLCKitPlayerWrapper
    
    public init(playerWrapper: Binding<VLCKitPlayerWrapper>) {
        self._playerWrapper = playerWrapper
    }
    
    ///Method to create the UIKit view that is to be represented in SwiftUI
    public func makeUIView(context: Context) -> UIView {
        let playerView = UIView()
        return playerView
    }
    
    ///Method to update the UIKit view that is being used in SwiftUI
    public func updateUIView(_ uiView: UIView, context: Context) {
        if let player = playerWrapper.mediaPlayer {
            player.drawable = uiView
        }
    }
}

//@Observable
public class VLCKitPlayerWrapper: NSObject, ObservableObject {
    public var mediaPlayer: VLCMediaPlayer?
    
    @Published public var isPlaying: Bool = false
    @Published public var isBuffering: Bool = false
    @Published public var videoLength: Double = 0.0
    @Published public var progress: Double = 0.0
    @Published public var remaining: Double = 0.0
   // var duration:
    
    public override init() {
        super.init()
        mediaPlayer = VLCMediaPlayer(options: ["--network-caching=5000"]) // change your media player related options
        mediaPlayer?.delegate = self
    }
    
    ///Method to begin playing the specified URL
    public func play(url: URL) {
        let media = VLCMedia(url: url)
        mediaPlayer?.media = media
        mediaPlayer?.play()
    }
    
    ///Method to stop playing the currently playing video
    public func stop() {
        mediaPlayer?.stop()
        isPlaying = false
    }

    public func pause() {
        if isPlaying && (mediaPlayer?.canPause ?? false) {
           mediaPlayer?.pause()
           isPlaying = false
        } else {
           mediaPlayer?.play()
           isPlaying = true
        }
    }
    
    public func moveTo(position: Double) {
        if mediaPlayer?.isSeekable ?? false {
            mediaPlayer?.time = VLCTime(int: Int32(position))
        }
    }
}

extension VLCKitPlayerWrapper: VLCMediaPlayerDelegate {
    ///Implementation for VLCMediaPlayerDelegate to handle media player state change
    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        if let player = mediaPlayer {
            if player.state == .stopped {
                isPlaying = false
                isBuffering = false
            } else if player.state == .playing {
                isPlaying = true
                isBuffering = false
                videoLength = Double(mediaPlayer?.media?.length.intValue ?? Int32(0.0))
            } else if player.state == .opening {
                isBuffering = true
            } else if player.state == .error {
                stop()
            } else if player.state == .buffering {
            } else if player.state == .paused {
                isPlaying = false
            }
        }
    }
    
    public func mediaPlayerTimeChanged(_ aNotification: Notification) {
        progress = Double(mediaPlayer?.time.intValue ?? Int32(0.0))
        remaining = Double(mediaPlayer?.remainingTime?.intValue ?? Int32(0.0))
        //print(progress, remaining, videoLength)
    }
}
