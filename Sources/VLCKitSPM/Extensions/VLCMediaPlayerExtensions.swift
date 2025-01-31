import UIKit
import Foundation
import CoreImage

extension VLCMediaPlayer {
    public func snapshot() -> UIImage? {
        guard let drawable = self.drawable as? UIView else { return nil }

        guard drawable.bounds.size != .zero else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(drawable.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        drawable.drawHierarchy(in: drawable.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    public static func updateDefaultVLCParams() {
        let vlcParams: [String] = (UserDefaults.standard.object(forKey: "VLCParams") as? [String]) ?? []
        let count = vlcParams.count
        
        if count > 0 {
            print("VLCParams is set to \(vlcParams)")
            return
        }
        
        let options: [String] = [
            //"--video-filter=ci",
            //"--ci-filter=CopyFilter",
            "--stats",
            "--verbose=4",
            
            "--no-color",
            "--no-osd",
            "--no-mouse-events",
            "--no-video-title-show",
            "--no-snapshot-preview",
            "--http-reconnect",
            "--text-renderer=freetype",
            "--freetype-font=TimesNewRomanPSMT",
            "--freetype-fontsize=1",
            "--freetype-opacity=0",
            "--avi-index=3",
            "--audio-resampler=soxr"
        ]

        UserDefaults.standard.setValue(options, forKey: "VLCParams")

    }
}

extension VLCMediaPlayerState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .stopped:
            return "stopped"    ///< Player has stopped
        case .opening:
            return "opening"    ///< Stream is opening
        case .buffering:
            return "buffering"  ///< Stream is buffering
        case .ended:
            return "ended"      ///< Stream has ended
        case .error:
            return "error"      ///< Player has generated an error
        case .playing:
            return "playing"    ///< Stream is playing
        case .paused:
            return "paused"     ///< Stream is paused
        case .esAdded:
            return "esAdded"    ///< Elementary Stream added
        @unknown default:
            return "VLCMediaPlayerState.\(self.rawValue)"
        }
    }
}
    
extension VLCMediaState: @retroactive CustomStringConvertible {
    public var description: String {
        switch self {
        case .nothingSpecial:
            return "nothing special"    ///< Nothing // opening
        case .buffering:
            return "buffering"          ///< Stream is buffering
        case .playing:
            return "playing"            ///< Stream is playing
        case .error:
            return "error"              ///< Can't be played because an error occurred
        @unknown default:
            return "VLCMediaState.\(self.rawValue)"
        }
    }
}
