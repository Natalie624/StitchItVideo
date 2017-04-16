//
//  MergeVideoViewController.swift
//  StitchItVideoPlayRecord
//
//  Created by Natalie Cervantes on 4/6/17.
//  Copyright © 2017 Natalie Cervantes. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
import MediaPlayer
import CoreMedia
import Photos

class MergeVideoViewController: UIViewController {
    var firstAsset: AVAsset?
    var secondAsset: AVAsset?
    var audioAsset: AVAsset?
    var loadingAssetOne = false
    
    @IBOutlet var activityMonitor: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        activityMonitor?.hidesWhenStopped = true;
        activityMonitor?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityMonitor?.center = view.center
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func savedPhotosAVailable() -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            let alert = UIAlertController(title: "Not Available", message: "No Saved Album Found", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func startMediaBrowserFromViewController(_ viewController: UIViewController!, usingDelegate delegate :(UINavigationControllerDelegate & UIImagePickerControllerDelegate)!) -> Bool{
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false {
            return false
        }
        
        let mediaUI = UIImagePickerController()
        mediaUI.sourceType = .savedPhotosAlbum
        mediaUI.mediaTypes = [kUTTypeMovie as NSString as String]
        mediaUI.allowsEditing = true
        mediaUI.delegate = delegate
        present(mediaUI, animated: true, completion: nil)
        return true
    }

    @IBAction func loadAssetOne(_ sender: AnyObject) {
        if savedPhotosAVailable() {
            loadingAssetOne = true
            startMediaBrowserFromViewController(self, usingDelegate: self)
        
        }
        
    }
    
    @IBAction func loadAssetTwo(_ sender: AnyObject) {
        if savedPhotosAVailable() {
            loadingAssetOne = false
            startMediaBrowserFromViewController(self, usingDelegate: self)
        }
    }
    
    @IBAction func loadAudio(_ sender: AnyObject) {
        
        let mediaPickerController = MPMediaPickerController(mediaTypes: .any)
        mediaPickerController.delegate = self
        mediaPickerController.prompt = "Select Audio"
        present(mediaPickerController, animated: true, completion: nil)
        
    }
    
    
    //Stitch function
    
    @IBAction func stitchIt(_ sender: AnyObject) {
        if let firstAsset = firstAsset, let secondAsset = secondAsset {
        
            activityMonitor?.startAnimating()
            
            
            //1 - create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances
            let mixComposition = AVMutableComposition()
            
            //2 - Video track with first and second asset
            let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration), of: firstAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
            } catch _ {
                print("Failed to load first track")
            }
            let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration), of: secondAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration)
            } catch _ {
                print("Failed to load second track")
            }
            //3 - Audio track
            if let loadedAudioAsset = audioAsset {
                let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: 0)
                do {
                    try audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)),
                        of: loadedAudioAsset.tracks(withMediaType: AVMediaTypeAudio)[0], at: kCMTimeZero)
                }catch _ {
                    print("Failed to load audio track")
                    
                }
            }
            //4 - Get path
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            let dNow = NSDate()
            let date = dateFormatter.string(from: dNow as Date)
            let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(date).mov")
            let url = URL(fileURLWithPath: savePath)
            
            //5 - Create Exporter
            guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
                else {
                    return
            }
            exporter.outputURL = url
            exporter.outputFileType = AVFileTypeQuickTimeMovie
            exporter.shouldOptimizeForNetworkUse = true
            
            //6 - Perform the export
            exporter.exportAsynchronously() {
                DispatchQueue.main.async() { _ in
                    self.exportDidFinish(session: exporter)
            }
            
            }
        }
    }
 
    //completion handler to export the final video to the photos album
    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let outputURL = session.outputURL
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL!)
            }) { completed, error in
               var title = ""
               var message = ""
                if error != nil {
                  title = "Error"
                message = "Failed to save video"
                } else {
                   title = "Success"
                   message = "Video saved"
                    
                }
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        activityMonitor?.stopAnimating()
        firstAsset = nil
        secondAsset = nil
        audioAsset = nil
    }
    
    
    
}//Closing bracket for class

extension MergeVideoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        dismiss(animated: true, completion: nil)
        
        if mediaType == kUTTypeMovie {
            let avAsset = AVAsset(url: info[UIImagePickerControllerMediaURL] as! URL)
            var message = ""
            if loadingAssetOne {
                message = "Video one loaded"
                firstAsset = avAsset
            }
            else {
                message = "Video two loaded"
                secondAsset = avAsset
            }
            let alert = UIAlertController(title: "Asset Loaded", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        }
    }
}

extension MergeVideoViewController: UINavigationControllerDelegate {
    
}

extension MergeVideoViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let selectedSongs = mediaItemCollection.items
        if selectedSongs.count > 0 {
            let song = selectedSongs[0]
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                audioAsset = (AVAsset(url: url) )
                dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Asset loaded", message: "Audio Loaded", preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                dismiss(animated:true, completion: nil)
                let alert = UIAlertController(title: "Asset Not Available", message: "Audio Not Loaded", preferredStyle:.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }else {
            dismiss(animated: true, completion: nil)
        }
        
        }
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }

}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


