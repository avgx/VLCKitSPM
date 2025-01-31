import Foundation
#if os(tvOS)
import TVVLCKit
#elseif os(iOS) && !targetEnvironment(macCatalyst)
import MobileVLCKit
#endif

public class PlayerWrapper: NSObject, ObservableObject {
    
    @Published public var time: String = ""
    @Published public var state: VideoState = .pending
    @Published public var error: VideoState.Error? = nil
    @Published public var warning: VideoState.Warning? = nil
    @Published public var hasFirstPicture: Bool = false
    @Published public var stats: Stats = .init()
    @Published public var discardMIMEHeader: String = ""
    @Published public var subtitle: String = ""
    
    @Published public var voutSize: CGSize = .zero
    @Published public var videoSize: CGSize = .zero
    
    public var mediaPlayer: VLCMediaPlayer?
    var dialogProvider: VLCDialogProvider?
    
    private var inputStream: InputStream? = nil
    private var outputStream: OutputStream? = nil
    private var isStreamMode = false
    private var logger: VideoViewVLCLogging? = VideoViewVLCLogging()
    
    public override init() {
        super.init()
        let mediaPlayer = VLCMediaPlayer(options: [
            "--verbose=4",
            "--rtsp-tcp=1",
            "--no-color",
            "--no-osd",
            "--no-mouse-events",
            "--no-video-title-show",
            "--no-snapshot-preview",
            "--http-reconnect",
            "--text-renderer=freetype",
            "--freetype-font=TimesNewRomanPSMT",
            "--freetype-fontsize=1",
            "--freetype-opacity=0"
        ])
        mediaPlayer.delegate = self
        
        dialogProvider = VLCDialogProvider(library: mediaPlayer.libraryInstance, customUI: true)
        dialogProvider?.customRenderer = self
        self.logger?.player = self
        
        //mediaPlayer.libraryInstance.loggers = [ self.logger!, VLCConsoleLogger() ]
        mediaPlayer.libraryInstance.loggers = [ self.logger! ]
        self.mediaPlayer = mediaPlayer
    }
    
    deinit {
        //NotificationCenter.default.removeObserver(self)
    }
    
    public var isMuted: Bool = false {
        didSet {
            mediaPlayer?.audio?.volume = isMuted ? 0 : 100
        }
    }
    
    ///Method to begin playing the specified URL
    public func play(url: URL) {
        //print("Starting player...")
        let media = VLCMedia(url: url)
        Options.default.forEach({
            media.addOption($0)
        })
        
        mediaPlayer?.media = media
        isStreamMode = false
        mediaPlayer?.play()
    }
    
    ///Method to stop playing the currently playing video
    public func stop() {
        //print("Disconnecting and stopping player...")
//        if hasFirstPicture {
//            let img = mediaPlayer?.snapshot()
//            print(img?.size)
//        }
        mediaPlayer?.stop()
        inputStream?.close()
        outputStream?.close()
        inputStream = nil
        outputStream = nil
        //isPlaying = false
        hasFirstPicture = false
        state = .pending
    }
    
    public func push(stream data: Data) {
        precondition(isStreamMode)
        // Write the data to the OutputStream
        data.withUnsafeBytes { (bufferPointer) in
            let buffer = bufferPointer.bindMemory(to: UInt8.self)
            outputStream?.write(buffer.baseAddress!, maxLength: data.count)
        }
    }
    
    public func startStream() {
        //print("Connecting ...")
        // Create streams for feeding data to VLC
        var inputStream: InputStream?
        var outputStream: OutputStream?
        Stream.getBoundStreams(withBufferSize: 4*1024 * 1024, inputStream: &inputStream, outputStream: &outputStream)
        
        self.inputStream = inputStream
        self.outputStream = outputStream
        
        inputStream?.open()
        outputStream?.open()
        
        // Set up VLCMedia with the InputStream
        if let inputStream = inputStream {
            let media = VLCMedia(stream: inputStream)
            mediaPlayer?.media = media
            
            // Set some media options that might help
//            media.addOption("--no-audio")
//            media.addOption("--network-caching=1000")
//            media.addOption("--codec=hevc")
            media.addOption("-vvvv")
            
            //print("Starting ...")
            isStreamMode = true
            mediaPlayer?.play()
        }
    }
}
