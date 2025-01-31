import Foundation

extension PlayerWrapper {
    
    class VideoViewVLCLogging : NSObject, VLCLogging {
        weak var player: PlayerWrapper?
        var level: VLCLogLevel = .debug
        
        public func handleMessage(_ message: String, logLevel level: VLCLogLevel, context: VLCLogContext?) {
            //print("vlc \(Thread.isMainThread) \(context?.module ?? "-")/\(context?.objectType ?? "-") \(level.rawValue): \(message)")
            
            if(message.contains("discard MIME header:")) {
                print(message)
                DispatchQueue.main.async { [weak self] in
                    self?.player?.discardMIMEHeader = message
                }
            } else if (message.contains("subtitle:")) {
                DispatchQueue.main.async { [weak self] in
                    self?.player?.subtitle = message
                }
            } else if (message.starts(with: "VoutDisplayEvent 'resize'")) {
                /// vlc 3: VoutDisplayEvent 'resize' 3840x2160
                let regexp = try! NSRegularExpression(pattern: "VoutDisplayEvent 'resize' (\\d+)x(\\d+)", options: [])
                if let match = regexp.firstMatch(in: message, options: [], range: NSMakeRange(0, message.count)) {
                    let matchingRange = match.range(at: 1)
                    let matchingString = (message as NSString).substring(with: matchingRange) as String
                    let value = Int(matchingString)
                    let matchingRange2 = match.range(at: 2)
                    let matchingString2 = (message as NSString).substring(with: matchingRange2) as String
                    let value2 = Int(matchingString2)
                    
                    if let w = value, let h = value2 {
                        DispatchQueue.main.async { [weak self] in
                            self?.player?.voutSize = CGSize(width: w, height: h)
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.player?.voutSize = .zero
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.player?.voutSize = .zero
                    }
                }
            } else if message.starts(with: "VLC is unable to open the MRL") {
                DispatchQueue.main.async { [weak self] in
                    self?.player?.error = .unable_to_open
                }
            } else if message.starts(with: "Buffering") && message.hasSuffix("%") {
                let regexp = try! NSRegularExpression(pattern: "Buffering (\\d+)%", options: [])
                if let match = regexp.firstMatch(in: message, options: [], range: NSMakeRange(0, message.count)) {
                    let matchingRange = match.range(at: 1)
                    let matchingString = (message as NSString).substring(with: matchingRange) as String
                    let value = Int(matchingString)
                    DispatchQueue.main.async { [weak self] in
                        self?.player?.state = .opening(.buffering(value))
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.player?.state = .opening(.buffering(nil))
                    }
                }
            } else if message.contains("successfully opened") &&
                        (message.contains("http://") || message.contains("rtsp://") ) {
                /// vlc 3: `rtsp://root:root@192.168.1.85:554/hosts/LENOVO-PC/DeviceIpint.20/SourceEndpoint.video:0:0' successfully opened
                DispatchQueue.main.async { [weak self] in
                    self?.player?.state = .opening(.opened)
                }
            } else if message.starts(with: "Received first picture") {
                /// vlc 3: Received first picture
                DispatchQueue.main.async { [weak self] in
                    self?.player?.state = .opening(.received_first_picture)
                }
            } else if message.starts(with: "EOF reached") {
                DispatchQueue.main.async { [weak self] in
                    self?.player?.state = .stopped(.eof_reached)
                }
            } else if message.starts(with: "end of stream") {
                DispatchQueue.main.async { [weak self] in
                    self?.player?.state = .stopped(.end_of_stream)
                }
            } else if message.starts(with:"Stream buffering done") {
                /// vlc 3: Stream buffering done (2002 ms in 1737 ms)
                //self.state = .opening(.stream_buffering_done)
            } else if message.starts(with: "picture is too late to be displayed") {
                //picture is too late to be displayed (missing 2225 ms)
                let regexp = try! NSRegularExpression(pattern: "missing (\\d+) ms", options: [])
                if let match = regexp.firstMatch(in: message, options: [], range: NSMakeRange(0, message.count)) {
                    let matchingRange = match.range(at: 1)
                    let matchingString = (message as NSString).substring(with: matchingRange) as String
                    let value = Int(matchingString) ?? 0
                    if value > 5000 {
                        DispatchQueue.main.async { [weak self] in
                            self?.player?.warning = .display_delay
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.player?.warning = .display_delay
                    }
                }
            } else if message.starts(with:"picture might be displayed late") {
                //picture might be displayed late (missing 14 ms)
                let regexp = try! NSRegularExpression(pattern: "missing (\\d+) ms", options: [])
                if let match = regexp.firstMatch(in: message, options: [], range: NSMakeRange(0, message.count)) {
                    let matchingRange = match.range(at: 1)
                    let matchingString = (message as NSString).substring(with: matchingRange) as String
                    let value = Int(matchingString) ?? 0
                    if value > 5000 {
                        DispatchQueue.main.async { [weak self] in
                            self?.player?.warning = .display_delay
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.player?.warning = .display_delay
                    }
                }
            } else if message.starts(with:"More than") ||
                        message.starts(with:"buffer too late") ||
                        message.starts(with:"discontinuity received 0") ||
                        // gnutls
                        message.starts(with:"in DATA (0x00) frame of") ||
                        message.starts(with:"out WINDOW_UPDATE (0x08) frame ") {
                DispatchQueue.main.async { [weak self] in
                    self?.player?.warning = .display_delay
                }
            }
        }
        
    }
}
