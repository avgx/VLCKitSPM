import Foundation

extension PlayerWrapper {
    public enum VideoState {
        /// when play(url) not called yet
        case pending
        /// when play(url) called and the stream is about to play
        case opening(Opening)
        /// when the stream is playing - we see changing pictures
        /// when .playing the previous error is cleared
        case playing
        /// the stream is stopped. due to error or end of stream or something else
        case stopped(Stopped)    //case ended //case error
        
        /// for play/pause button indicator
        public var isPlayPressed: Bool {
            switch self {
            case .opening(_), .playing:
                return true
            default:
                return false
            }
        }
        
        public enum Opening {
            case opening
            case opened
            case elementary_stream_added
            case received_first_picture
            case buffering(Int?)
        }
        
        public enum Stopped {
            case unknown
            case error
            case end_of_stream
            case eof_reached
        }
        
        public enum Warning {
            case display_delay
        }
        
        public enum Error {
            case codec_not_supported
            case unable_to_open
            case other(String)
        }
    }
}

extension PlayerWrapper.VideoState: Identifiable {
    public var id: String {
        return description
    }
}

extension PlayerWrapper.VideoState: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

extension PlayerWrapper.VideoState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pending:                      return "pending"
        case .opening(let o):
            switch o {
            case .opening:                  return "opening/opening"
            case .opened:                   return "opening/opened"
            case .elementary_stream_added:  return "opening/elementary_stream_added"
            case .received_first_picture:   return "opening/received_first_picture"
            case .buffering(let p):         return "\(p ?? 0)%" //"buffering \(p ?? 0)%"
            }
        case .playing:                      return "playing"
        case .stopped(let s):
            switch s {
            case .unknown:                  return "stopped/unknown"
            case .error:                    return "stopped/error"
            case .end_of_stream:            return "stopped/end_of_stream"
            case .eof_reached:              return "stopped/eof_reached"
            }
        }
    }
}

extension PlayerWrapper.VideoState: Equatable {
    public static func == (a: PlayerWrapper.VideoState, b: PlayerWrapper.VideoState) -> Bool {
        return a.description == b.description
    }
}

extension PlayerWrapper.VideoState.Warning: CustomStringConvertible {
    public var description: String {
        switch self {
        case .display_delay:        return "warning/display_delay"
        }
    }
}

extension PlayerWrapper.VideoState.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .codec_not_supported:        return "error/codec_not_supported"
        case .unable_to_open:           return "error/unable_to_open"
        case .other(let detail):        return "\(detail)"
        }
    }
}

extension PlayerWrapper.VideoState.Error: Equatable {
    public static func == (a: PlayerWrapper.VideoState.Error, b: PlayerWrapper.VideoState.Error) -> Bool {
        return a.description == b.description
    }
}
