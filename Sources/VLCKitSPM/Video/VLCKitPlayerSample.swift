
import SwiftUI

public struct VLCKitPlayerSample: View {
    @State private var playerWrapper: VLCKitPlayerWrapper = VLCKitPlayerWrapper()
    @Binding var selectedUrl: String?
    
    public init(selectedUrl: Binding<String?>) {
        _selectedUrl = selectedUrl
    }
    
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            if selectedUrl != nil {
                VLCKitPlayerView(playerWrapper: $playerWrapper)
                    .onAppear {
                        if let stringUrl = selectedUrl, let url = URL(string: stringUrl) {
                            playerWrapper.play(url: url)
                        }
                    }
            }
        }
    }
}


#Preview {
    Group {
        VLCKitPlayerSample(selectedUrl: .constant("rtsp://admin:L2A43F84@192.168.1.64:554/cam/realmonitor?channel=1&subtype=0&unicast=true&proto=Onvif"))
        //VLCKitPlayerSample(selectedUrl: .constant("rtsp://192.168.1.89:554/0/av1"))
    }
}
