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

class PlayVideoViewController: UIViewController {

    

    @IBAction func playVideo(_ sender: Any) {
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
    
}

//MARK: - UINavigationControllerDelegate
extension PlayVideoViewController: UINavigationControllerDelegate {
    
}

