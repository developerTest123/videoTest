//
//  PlayerView.swift
//  Videos
//
//  Created by Red Pill on 20.08.2018.
//  Copyright © 2018 Red Pill. All rights reserved.
//

import UIKit
import AVKit

class PlayerView: UIView {
    
    private var videoURL : URL?
    private var player: AVPlayer?
    var parentController: UIViewController?
    
    var avurlAsset: AVURLAsset? {
        guard let url = videoURL else { return nil }
        return AVURLAsset(url: url)
    }
    
    func loadVideo(_ url: URL) {
        player = AVPlayer(url: url)
        videoURL = url
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = bounds
        playerLayer.player = player
        layer.addSublayer(playerLayer)
        player?.play()
    }
    
    func selectVideo(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.movie"]
        parentController?.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    //MARK: - Action

    @IBAction func btnAddVideoPressed(_ sender: Any) {
        selectVideo()
    }
}

//MARK: - UIImagePickerControllerDelegate
extension PlayerView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let url = info[UIImagePickerControllerMediaURL] as? URL {
            print("URL:", url)
            loadVideo(url)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
