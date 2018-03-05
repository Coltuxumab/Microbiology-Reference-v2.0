//
//  PopupNotificationViewController.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 11/11/17.
//  Copyright © 2017 Denkensohn. See LICENSE.txt
//

import UIKit

class PopupNotificationViewController: UIViewController {
    
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var popupLabel: UILabel!
    
    var notificationText = "Default"
    var selfDestruct:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Activity indicator hidden by default
        myActivityIndicator.isHidden = true
        
        popupLabel.text = notificationText
        
        if notificationText.components(separatedBy: " ").first?.lowercased() == "updating"{
            // Show and start activity indicator
            myActivityIndicator.isHidden = false
            myActivityIndicator.startAnimating()
        }
        
        self.preferredContentSize = CGSize(width: 300, height: 300)
        
        
        // Check if view should self dismiss
        if (selfDestruct > 0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(selfDestruct), execute: {
                self.dismiss(animated: true, completion: nil)
            })
        }
        
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
