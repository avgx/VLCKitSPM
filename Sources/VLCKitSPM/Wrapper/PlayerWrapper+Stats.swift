import Foundation

extension PlayerWrapper {
    public struct Stats {
        public var timeString = "--:--"
        public var codec: Int = 0
        public var codecFourCC: String {
            fromFourCC(codec)
        }
        public var width: Int = 0
        public var height: Int = 0

        public var readBytes: Int = 0
        public var inputBitrate: Double = 0.0
        public var demuxBitrate: Double = 0.0
        
        public var inputBitrate_kb_per_sec: Int {
            return Int(inputBitrate * 1000.0 * 8)
        }
        public var demuxBitrate_kb_per_sec: Int {
            return Int(demuxBitrate * 1000.0 * 8)
        }
        
        public var decodedVideo: Int = 0
        public var displayedPictures: Int = 0
        public var lostPictures: Int = 0
        
        // Create a String representation of a FourCC
        private func fromFourCC(_ fourcc: Int) -> String {
            let bytes: [CChar] = [
                CChar(fourcc & 0xff),
                CChar((fourcc >> 8) & 0xff),
                CChar((fourcc >> 16) & 0xff),
                CChar((fourcc >> 24) & 0xff),
                0
            ]
            let result = String(cString: bytes)
            let characterSet = CharacterSet.whitespaces
            return result.trimmingCharacters(in: characterSet)
        }
        
        public init(timeString: String = "--:--", codec: Int = 0, width: Int = 0, height: Int = 0, readBytes: Int = 0, inputBitrate: Double = 0, demuxBitrate: Double = 0, decodedVideo: Int = 0, displayedPictures: Int = 0, lostPictures: Int = 0) {
            self.timeString = timeString
            self.codec = codec
            self.width = width
            self.height = height
            self.readBytes = readBytes
            self.inputBitrate = inputBitrate
            self.demuxBitrate = demuxBitrate
            self.decodedVideo = decodedVideo
            self.displayedPictures = displayedPictures
            self.lostPictures = lostPictures
        }
    }
}

extension PlayerWrapper.Stats: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

extension PlayerWrapper.Stats: CustomStringConvertible {
    public var description: String {
        return [
            "\(fromFourCC(codec)) / \(width)x\(height)",
            "\(timeString)",
            "read:\(readBytes/1024)kB",   //для rtsp незаполняется
            "decoded/displayed/lost:",
            "\(decodedVideo)/\(displayedPictures)/\(lostPictures)",
            "bitrate:\(inputBitrate_kb_per_sec)kb/s",   //для rtsp незаполняется
            "demux:\(demuxBitrate_kb_per_sec)kb/s"
        ].joined(separator: "\n")
    }
}
