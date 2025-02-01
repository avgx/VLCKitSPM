import UIKit
import SwiftUI

public struct VLCKitPlayerView: UIViewRepresentable {
    @EnvironmentObject var playerWrapper: PlayerWrapper
    
    public init() {
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    ///Method to create the UIKit view that is to be represented in SwiftUI
    public func makeUIView(context: Context) -> UIView {
        let playerView = UIView()
        
        if let player = playerWrapper.mediaPlayer {
            player.drawable = playerView
        }
        
        //playerWrapper.mediaPlayer?.videoAspectRatio = UnsafeMutablePointer<Int8>(mutating: NSString(string: "16:9").utf8String)
        //playerWrapper.mediaPlayer?.videoCropGeometry = UnsafeMutablePointer<Int8>(mutating: NSString(string: "16:9").utf8String)
        
        return playerView
    }
    
    ///Method to update the UIKit view that is being used in SwiftUI
    public func updateUIView(_ uiView: UIView, context: Context) {
    }
    
    // Handle view removal or player cleanup
    public static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.parent.playerWrapper.mediaPlayer?.stop()
        coordinator.parent.playerWrapper.mediaPlayer?.drawable = nil
    }
    
    public class Coordinator: NSObject {
        var parent: VLCKitPlayerView
        
        public init(_ parent: VLCKitPlayerView) {
            self.parent = parent
            super.init()
            //mediaPlayer.delegate = self
            //print("Coordinator")
            
            
        }
        
        
        deinit {
            //print("~Coordinator")
        }
    }
}


