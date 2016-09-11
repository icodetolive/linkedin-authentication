//
//  ViewController.swift
//  LinkedinIntegration
//
//  Created by Sugandha Naolekar on 9/3/16.
//  Copyright © 2016 icode. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btnSignIn: UIButton!
    
    @IBOutlet weak var btnGetProfileInfo: UIButton!
    
    @IBOutlet weak var btnOpenProfile: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnSignIn.enabled = true
        btnGetProfileInfo.enabled = false
        btnOpenProfile.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkForExistingAccessToken() {
        if NSUserDefaults.standardUserDefaults().objectForKey("LIAccessToken") != nil {
            btnSignIn.enabled = false
            btnGetProfileInfo.enabled = true
        }
    }
    
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if(segue.identifier == "idSegueShowWebVC") {
//            let controller = segue.destinationViewController as! WebViewController
//        }
//    }
    
    // MARK: IBAction Functions
    
    @IBAction func getProfileInfo(sender: AnyObject) {
        
    }
    
    
    @IBAction func openProfileInSafari(sender: AnyObject) {
        
    }
    
}

