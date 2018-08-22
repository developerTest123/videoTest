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

    @IBOutlet private weak var btnAdd: UIButton!
    @IBOutlet private weak var borderView: UIView! {
        didSet {
            borderView.layer.borderColor = UIColor.black.cgColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    var avurlAsset: AVURLAsset? {
        guard let url = videoURL else { return nil }
        return AVURLAsset(url: url)
    }
    
    func loadVideo(_ url: URL) {
        
        btnAdd.isHidden = true
        player = AVPlayer(url: url)
        videoURL = url
        
        (layer as? AVPlayerLayer)?.player = player
        (layer as? AVPlayerLayer)?.videoGravity = .resize

    }
    
    func selectVideo(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = ["public.movie"]
        parentController?.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    //MARK: - Actions

    @IBAction func btnAddVideoPressed(_ sender: Any) {
        selectVideo()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
//        let playerLayer = AVPlayerLayer(player: player)
////        playerLayer.frame = bounds
//        playerLayer.borderColor = UIColor.black.cgColor
//        playerLayer.borderWidth = 10
        
        guard let player = player, !player.isPlaying else { return }
        borderView.layer.borderWidth = 5
        player.play()
    }
    
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        print("Video Finished")
        borderView.layer.borderWidth = 0
        player?.seek(to: kCMTimeZero)
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

extension AVPlayer {
    var isPlaying: Bool {
        print("Rate:", rate)
        print("Error:", error)
        return rate != 0 && error == nil
    }
}
