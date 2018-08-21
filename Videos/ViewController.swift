//
//  ViewController.swift
//  Videos
//
//  Created by Red Pill on 20.08.2018.
//  Copyright © 2018 Red Pill. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos

class ViewController: UIViewController{
    
    @IBOutlet private weak var firstPlayer: PlayerView!
    @IBOutlet private weak var secondPlayer: PlayerView!
    @IBOutlet private weak var saveButton: UIButton!
    
    var imgView: UIImageView?

    //MARK: - Life cyrcle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstPlayer.parentController = self
        secondPlayer.parentController = self
    }
    
    //MARK: - IBAction
    @IBAction func saveButtonTap(_ sender: Any) {
        guard let firstAsset = firstPlayer.avurlAsset, let secondAsset = secondPlayer.avurlAsset else { return }
//        overlay(video: firstAsset, withSecondVideo: secondAsset, andAlpha: 1.0)
        overlapVideos(firstAsset: firstAsset, withSecondVideo: secondAsset)
            }
    
    
    func overlapVideos(firstAsset: AVURLAsset, withSecondVideo secondAsset: AVURLAsset) {
        
        let mixComposition = AVMutableComposition()
        let firstTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let secondTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        guard let firstMediaTrack = firstAsset.tracks(withMediaType: AVMediaType.video).first else { return }
        guard let secondMediaTrack = secondAsset.tracks(withMediaType: AVMediaType.video).first else { return }
        
        do {
            try firstTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration), of: firstMediaTrack, at: kCMTimeZero)
            try secondTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration), of: secondMediaTrack, at: kCMTimeZero)
        } catch (let error) {
            print(error)
        }
        
        let duration = firstAsset.duration
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration)
        
        let firstLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack!)
        let scale1 = CGAffineTransform(scaleX: 1.0, y: 0.5)
        
        firstLayerInstruction.setTransform(scale1, at: kCMTimeZero)
        firstLayerInstruction.setOpacity(1.0, at: kCMTimeZero)
        
        
        let width = max(firstMediaTrack.naturalSize.width, secondMediaTrack.naturalSize.width)
        let height = max(firstMediaTrack.naturalSize.height, secondMediaTrack.naturalSize.height)
        
        let secondlayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondTrack!)
        let scale2 = CGAffineTransform(scaleX: 1.0, y: 0.5)
        let move = CGAffineTransform(translationX: 0, y: height * 0.5)
        secondlayerInstruction.setTransform(scale2.concatenating(move), at: kCMTimeZero)
        secondlayerInstruction.setOpacity(1.0, at: kCMTimeZero)
        
        mainInstruction.layerInstructions = [firstLayerInstruction, secondlayerInstruction]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [mainInstruction]
        videoComposition.renderSize = CGSize(width: width, height: height)
        videoComposition.frameDuration = CMTimeMake(1, 30)
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality),
            exporter.supportedFileTypes.contains(AVFileType.mp4) else { return }
        
        var tempFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("temp_video_data.mp4", isDirectory: false)
        tempFileUrl = URL(fileURLWithPath: tempFileUrl.path)
        
        if FileManager.default.fileExists(atPath: tempFileUrl.path) {
            try! FileManager.default.removeItem(atPath: tempFileUrl.path)
        }
        
        exporter.outputURL = tempFileUrl
        exporter.outputFileType = AVFileType.mp4
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = videoComposition
        
        exporter.exportAsynchronously { [weak self] in
            if exporter.error == nil && exporter.status == .completed{
                print("SAVED!")
                
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: tempFileUrl)
                }) { saved, error in
                    if saved {
                        print( "Your video was successfully saved")
                        
                        if FileManager.default.fileExists(atPath: tempFileUrl.path) {
                            try! FileManager.default.removeItem(atPath: tempFileUrl.path)
                        }
                    }
                }
            } else {
                print("Error:", exporter.error!)
            }
        }

    }
    


}


