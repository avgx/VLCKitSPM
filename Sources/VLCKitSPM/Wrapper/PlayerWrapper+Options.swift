import Foundation

extension PlayerWrapper {
    
    /// All options that are yes or no
    /// Format: "--option" or "--no-option"
    ///
    public enum Options {
        public static let `default` = CachingOptions.medium.strings + HardwareDecoding.any.strings + [
            VideoOption.skip_frames.on,
            VideoOption.drop_late_frames.on,
            DecodingOption.codec_fast.on,
            DecodingOption.codec_corrupted.on,
            DecodingOption.codec_hurry_up.on,
            DecodingOption.codec_direct_rendering.on
        ]// + [ "--verbose=4", "--rtsp-tcp" ]
        
        public static let alwaysUseOptions: [String] = [
//            "-vvvv",
//            "--stats",
//            "--verbose=4",
            "--no-mouse-events",
            "--rtsp-tcp",
            "--http-reconnect",
            "--text-renderer=freetype",
            "--freetype-font=TimesNewRomanPSMT",
            "--freetype-fontsize=1",
            "--freetype-opacity=0",
            //"--rtsp-frame-buffer-size=2073616",
            "--no-video-title-show",
            "--no-sub-autodetect-file",
            //"--network-synchronisation",  - это приводит к тормозам в rtsp.
            //"--clock-synchro=0",
            "--avcodec-debug=4", //FFmpeg debug mask
            "--deinterlace=0"   //{0 (Off), -1 (Automatic), 1 (On)}
        ]
        
        /// Video
        /// These options allow you to modify the behavior of the video output subsystem.
        public enum VideoOption: String, CaseIterable {
            /// Skip frames
            /// Enables framedropping on MPEG2 stream. Framedropping occurs when your cpu is not powerful enough
            case skip_frames = "skip-frames"
            /// Drop late frames
            /// This drops frames that are late (arrive to the video output after their intended display date).
            case drop_late_frames = "drop-late-frames"
            
            public var on: String {
                return "--\(rawValue)"
            }
            public var off: String {
                return "--no-\(rawValue)"
            }
        }
        
        /// Decoding
        public enum DecodingOption: String, CaseIterable {
            /// Direct rendering
            /// When off - no dewarp working
            case codec_direct_rendering = "avcodec-dr"
            /// Show corrupted frames
            /// Prefer visual artifacts instead of missing frames
            case codec_corrupted = "avcodec-corrupted"
            /// Hurry up
            /// The decoder can partially decode or skip frame(s) when there is not enough time. It's useful with low CPU power but it can produce distorted pictures.
            case codec_hurry_up = "avcodec-hurry-up"
            /// Allow speed tricks
            /// Allow non specification compliant speedup tricks. Faster but error-prone.
            case codec_fast = "avcodec-fast"
            
            public var on: String {
                return "--\(rawValue)"
            }
            public var off: String {
                return "--no-\(rawValue)"
            }
            
            public static let fast: [String] = [
                codec_corrupted.on,
                codec_hurry_up.on,
                codec_fast.on
            ]
            public static let quality: [String] = [
                codec_corrupted.off,
                codec_hurry_up.off,
                codec_fast.off
            ]
        }
        
        /// Hardware decoding
        /// This allows hardware decoding when available.
        public enum HardwareDecoding {
            ///Enable hardware acceleration
            case any
            ///Use Hardware decoders only
            case none
            
            public var strings: [String] {
                switch self {
                case .any:
                    return [ "--avcodec-hw=any", "--videotoolbox", "--codec=videotoolbox,avcodec" ]
                case .none:
                    return [ "--avcodec-hw=none", "--codec=avcodec,none" ]
                }
            }
            
        }
        
        public struct CachingOptions {
            let network: Int
            let rtsp_frame_buffer_size: Int
            
            public static let small: CachingOptions  = .init(network: 100,  rtsp_frame_buffer_size: 100000)
            public static let medium: CachingOptions = .init(network: 1000, rtsp_frame_buffer_size: 200000)
            public static let large: CachingOptions  = .init(network: 3000, rtsp_frame_buffer_size: 2073616)
            
            public init(network: Int, rtsp_frame_buffer_size: Int) {
                self.network = network
                self.rtsp_frame_buffer_size = rtsp_frame_buffer_size
            }
            
            public var strings: [String] {
                return [
                    "--network-caching=\(String(network))",
                    "--rtsp-frame-buffer-size=\(String(rtsp_frame_buffer_size))"
                ]
            }
        }
        
        enum IntOptions {
            //"--avcodec-skiploopfilter=4",
            //"--avcodec-skip-idct=0",
            //"--swscale-mode=0", //0 (Fast bilinear), 1 (Bilinear), 2 (Bicubic (good quality)),
            //"--avcodec-skip-frame=0", // Skip frame (default=0) Force skipping of frames to speed up decoding (-1=None, 0=Default,            1=B-frames, 2=P-frames, 3=B+P frames, 4=all frames).
        }
    }
}

//https://code.videolan.org/videolan/VLCKit/-/issues/473
//Passing "--video-filter=magnify" was enough, I did not need "--video-filter=transform".
//In the buildMobileVLCKit blacklist magnify is listed twice, be careful to remove both entries before compiling 😁.
//NSWindow.isMovableByWindowBackground doesn't play very well with this feature, so you might need to consider disabling it if you want to enable zoom.


                                                                                                                        
