//
//  RecordVideoViewController.swift
//  StitchItVideoPlayRecord
//
//  Created by Natalie Cervantes on 4/6/17.
//  Copyright © 2017 Natalie Cervantes. All rights reserved.
//

import UIKit
import MobileCoreServices

class RecordVideoViewController: UIViewController {
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            
            return false
        }
        
        let cameraController = UIImagePickerController()
        cameraController.sourceType = .camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        
        present(cameraController, animated: true, completion: nil)
        
        return true
    }

    @IBAction func recordAndPlay(_ sender: UIButton) {
        
        _=startCameraFromViewController(viewController: self, withDelegate: self)
        
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

extension RecordVideoViewController: UIImagePickerControllerDelegate{
    
}

extension RecordVideoViewController: UINavigationControllerDelegate {
    
}
