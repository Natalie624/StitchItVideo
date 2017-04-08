//
//  PlayVideoViewController.swift
//  StitchItVideoPlayRecord
//
//  Created by Natalie Cervantes on 4/6/17.
//  Copyright © 2017 Natalie Cervantes. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaPlayer
import AVKit
import AVFoundation

class PlayVideoViewController: UIViewController {

    func startMediaBrowserFromViewController(viewController: UIViewController, usingDelegate delegate :UINavigationControllerDelegate & UIImagePickerControllerDelegate) -> Bool {
        //1
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        //2
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        
        //3
        present(mediaUI, animated: true, completion: nil)
        return true
    }

//Below playVideo code ensures that tapping "PlayVideo" button will open the UIImagePickerController
    
    @IBAction func playVideo(_ sender: Any) {
        _=startMediaBrowserFromViewController(viewController: self, usingDelegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}
//The below extensions set up PlayVideoViewController to adopt the UIImagePickerControllerDelegate and UINavigationControllerDelevate protocols.
//MARK: - UIImagePickerControlDelegate
extension PlayVideoViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //1
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        //2 dismisses the image picker (was dismissViewControllerAnimated)
        dismiss(animated: true) {
            
            //3
            if mediaType == kUTTypeMovie {
                let videoURL = info[UIImagePickerControllerMediaURL] as! URL!
                let player = AVPlayer(url: videoURL!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
                
                //let moviePlayer = MPMoviePlayerViewController(contentURL: info[UIImagePickerControllerMediaURL] as! NSURL)
                //self
            }
        }
    }
    
}

//MARK: - UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
    
}

