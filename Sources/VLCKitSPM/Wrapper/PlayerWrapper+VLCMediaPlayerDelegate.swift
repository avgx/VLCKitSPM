import Foundation

extension PlayerWrapper {
    func retryPlayingStream() {
        // Retry playing the stream after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.mediaPlayer?.play()
        }
    }
}

extension PlayerWrapper: VLCMediaPlayerDelegate {
    public func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let vlcPlayer = aNotification.object as? VLCMediaPlayer else { return }
        if vlcPlayer.media == nil {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch vlcPlayer.state {
            case .opening:
                self.state = .opening(.opening)
                vlcPlayer.audio?.volume = self.isMuted ? 0 : 100
    //        case .buffering:
                //TODO: нужно проверить что звук есть!!
    //            vlcPlayer.audio?.volume = self.isMuted ? 0 : 100
                //self.state = .opening(.buffering(nil))
            case .paused, .stopped:
                if error == nil {
                    if case .playing = self.state {
                        self.state = .stopped(.unknown)
                    }
                }
            case .error:
                if vlcPlayer.media?.state == .error {
                    // self.error заполнен парсером логов но если нет, надо заполнить
                    if self.error == nil {
                        self.error = .other("unknown")
                    }
                    self.state = .stopped(.error)
                    self.retryPlayingStream()
                }
            case .ended:
                if case .playing = self.state {
                    self.state = .stopped(.eof_reached)
                }
            case .esAdded:
                self.state = .opening(.elementary_stream_added)
            default:
                return
            }
        }
    }
    
    
    
    public func mediaPlayerTimeChanged(_ aNotification: Notification) {
        guard let vlcPlayer = aNotification.object as? VLCMediaPlayer else { return }
        
        if vlcPlayer.media == nil {
            return
        }

        guard vlcPlayer.media?.state == .playing else { return }
        
        if vlcPlayer.videoSize != videoSize {
            videoSize = vlcPlayer.videoSize
        }
        
        if case .playing = state {
            if self.hasFirstPicture == false {
                hasFirstPicture = true
            }
            if self.time != vlcPlayer.time.stringValue || self.stats.decodedVideo != (vlcPlayer.media?.statistics.decodedVideo ?? 0) {
                    self.time = vlcPlayer.time.stringValue
                
                    let info = vlcPlayer.media?.tracksInformation as? [ [ String : Any ] ]
                    let videoTrack: [String: Any]? = info?.first(where: { ($0["type"] as? String) == "video"})
                    let codec = videoTrack?[VLCMediaTracksInformationCodec] as? Int
                    let w = videoTrack?[VLCMediaTracksInformationVideoWidth] as? Int
                    let h = videoTrack?[VLCMediaTracksInformationVideoHeight] as? Int
                    
                    let stats = Stats(
                        timeString: vlcPlayer.time.stringValue,
                        codec: codec ?? 0,
                        width: w ?? 0,
                        height: h ?? 0,
                        
                        
                        readBytes: Int(vlcPlayer.media?.statistics.readBytes ?? 0),
                        inputBitrate: Double(vlcPlayer.media?.statistics.inputBitrate ?? 0),
                        demuxBitrate: Double(vlcPlayer.media?.statistics.demuxBitrate ?? 0),
                        decodedVideo: Int(vlcPlayer.media?.statistics.decodedVideo ?? 0),
                        displayedPictures: Int(vlcPlayer.media?.statistics.displayedPictures ?? 0),
                        lostPictures: Int(vlcPlayer.media?.statistics.lostPictures ?? 0)
                    )

                    self.stats = stats
                    self.warning = nil
            }
        } else {
            self.state = .playing
            self.error = nil
        }
        

//        if vlcPlayer.time.stringValue == "00:00" {
//            self.resetScreenIdleTimer()
//        }
    }
    
    

}

