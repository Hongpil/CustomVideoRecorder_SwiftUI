//
//  VideoComposer.swift
//  CustomVideoRecorder
//
//  Created by kimhongpil on 2023/06/02.
//

import SwiftUI
import AVFoundation
import AVKit

/**
 * [Ref]
 * ChatGPT 한테 물어봤음
 * "how to combine recored video and background audio in swiftui?"
 */
class VideoComposer {
    func composeVideo(with videoURL: URL, backgroundAudioURL: URL, outputURL: URL, isVideoAudioApply: Bool, completion: @escaping (URL?, Error?) -> Void) {
        let composition = AVMutableComposition()
        
        // Create a video asset from the recorded video URL
        let videoAsset = AVURLAsset(url: videoURL)
        
        /**
         * 원본 영상에서의 영상 적용
         */
        // Create a composition track for the video
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try videoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: .zero)
        } catch {
            completion(nil, error)
            return
        }
        
        
        if isVideoAudioApply {
            /**
             * 원본 영상에서의 오디오 적용
             */
            // Create a composition track for audio of the video
            let videoAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            do {
                try videoAudioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .audio)[0], at: .zero)
            } catch {
                completion(nil, error)
                return
            }
        }
        
        
        // Create an audio asset from the background audio URL
        let audioAsset = AVURLAsset(url: backgroundAudioURL)
        /**
         * 배경 오디오 적용
         */
        // Create a composition track for the audio
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        do {
            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: videoAsset.duration), of: audioAsset.tracks(withMediaType: .audio)[0], at: .zero)
        } catch {
            completion(nil, error)
            return
        }
        
        // Export the composition to the output URL
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputFileType = .mov
        exportSession?.outputURL = outputURL
        exportSession?.exportAsynchronously {
            if exportSession?.status == .completed {
                
                print("로그::: outputURL in class : \(String(describing: outputURL))")
                
                completion(outputURL, nil)
            } else if let error = exportSession?.error {
                completion(nil, error)
            }
        }
    }
}


struct CombineVideoAndAudioView: View {
    @State var videoURL: URL?
    @State var backgroundAudioURL: URL?
    @State var requestOutputURL: URL? // Set the output URL where you want to save the combined video
    @State var combinedOutputURL: URL?
    
    @State var playVideo: Bool = false
    
    var body: some View {
        VStack {
            Button("Combine Video and Audio") {
                
                // set URL data
                videoURL = Bundle.main.url(forResource: "recorded_video", withExtension: "mov")!
                backgroundAudioURL = Bundle.main.url(forResource: "background_audio", withExtension: "mp3")!
                requestOutputURL = URL(fileURLWithPath: NSTemporaryDirectory().appendingFormat("/combinedVideo-\(Date()).mov"))
                
                let videoComposer = VideoComposer()
                if let NOvideoURL = videoURL,
                   let NObackgroundAudioURL = backgroundAudioURL,
                   let NOrequestOutputURL = requestOutputURL {
                    
                    // isVideoAudioApply :
                    videoComposer.composeVideo(with: NOvideoURL, backgroundAudioURL: NObackgroundAudioURL, outputURL: NOrequestOutputURL, isVideoAudioApply: false) { outputURL, error in
                        print("로그::: outputURL : \(String(describing: outputURL))")
                        print("로그::: error : \(String(describing: error))")
                        if let outputURL = outputURL {
                            // Combined video and audio is available at the output URL
                            // Handle the output URL as needed (e.g., play it, save it, etc.)
                            
                            combinedOutputURL = outputURL
                        } else if let error = error {
                            // Handle the error
                        }
                    }
                }
            }
            
            Divider()
                .padding(.bottom, 30)
            
            if let NOcombinedOutputURL = combinedOutputURL {
                Button("Check Combined Video") {
                    playVideo = true
                }

                if playVideo {
                    VideoPlayer(player: AVPlayer(url: NOcombinedOutputURL))
                        .aspectRatio(contentMode: .fill)
                }
            }
            
            Spacer()
            
        }
        .frame(maxHeight: .infinity)
        
    }
}
