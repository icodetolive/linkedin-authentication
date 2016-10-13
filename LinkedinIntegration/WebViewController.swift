//
//  WebViewController.swift
//  LinkedinIntegration
//
//  Created by Sugandha Naolekar on 9/4/16.
//  Copyright © 2016 icode. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        startAuthorization()
    }
    
    @IBOutlet weak var webView: UIWebView!
    
    let linkedInKey = "78jlt0emyuuvux"
    
    let linkedinSecret = "dZeatO9O6PqaierA"
    
    let authorizationEndPoint = "https://www.linkedin.com/uas/oauth2/authorization"
    
    let accessTokenEndPoint = "https://www.linkedin.com/uas/oauth2/accessToken"
    
    
    func startAuthorization() {
        // Specify the response type which should always be "code".
        let responseType = "code"
        
        // Set the redirect URL. Adding the percent escape characthers is necessary.
        let redirectURL = "https://www.pretentiousgeek.me/oauth".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        // Create a random string based on the time interval (it will be in the form linkedin12345679).
        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"
        
        // Set preferred scope.
        let basicScope = "r_basicprofile"
        
        let emailScope = "r_emailaddress"
        
        let format = "json"
        
        //Create authorization URl string
        var authorizationURL = "\(authorizationEndPoint)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(linkedInKey)&"
        authorizationURL += "redirect_uri=\(redirectURL)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(basicScope),\(emailScope)&"
        authorizationURL += "format=\(format)"
        
        print(authorizationURL)
        
        // Create a URL request and load it in the web view.
        let request = NSURLRequest(URL: NSURL(string: authorizationURL)!)
        webView.loadRequest(request)
    }
    
    //before a webview begins loading a new frame, this function returns a Bool value - if the webview should begin loading the new content
//    A response containing authorization code somehwat looks like this:
    
    //"Your_redirect_URI?code="returned_auth_code&state="state_set_constants"
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        //get access to the URL through the request parameter
        let url = request.URL!
        
        
        print("Url::\(url)")
        if url.absoluteString.rangeOfString("error") != nil {
            print("user pressed cancel")
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        //examine the host property of the url to ensure if it's the authorization callback url set as per the app settings
        if url.host == "www.pretentiousgeek.me" {
            
            //state check to prevent CSRF attack
            let urlComponents = url.absoluteString.componentsSeparatedByString("?")
//            let state = 
            //make sure, authorization code is contained
            if url.absoluteString.rangeOfString("code") != nil {
               
                //Extract authorization code
                let code = urlComponents[1].componentsSeparatedByString("=")[1]
                
                requestForAccessToken(code)
            }
        }
        
        return true
    }
    
    
    func requestForAccessToken(authorizationCode: String) {
        let grantType = "authorization_code"
        
        let redirectURL = "https://www.pretentiousgeek.me/oauth".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())!
        
        // Set the POST parameters.
        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL)&"
        postParams += "client_id=\(linkedInKey)&"
        postParams += "client_secret=\(linkedinSecret)"
        
        // Convert the POST parameters into a NSData object since POST parameters cannot be sent as String values
        let postData = postParams.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Initialize a mutable URL request object using the access token endpoint URL string.
        let request = NSMutableURLRequest(URL: NSURL(string: accessTokenEndPoint)!)
        
        
        // Indicate that we're about to make a POST request.
        request.HTTPMethod = "POST"
        
        // Set the HTTP body using the postData object created above.
        request.HTTPBody = postData

        // Add the required HTTP header field.
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        // Initialize a NSURLSession object.
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        // Make the request.
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if error != nil {
                    print(error)
            }
            
            // Get the HTTP status code of the request.
            let statusCode = (response as! NSHTTPURLResponse).statusCode
            
            print("--\(statusCode)")
            //handle the case for status Code = 401 and redirect the user to start the authorization process again.
            //Also handle the xpiry date issue. Before the seconds become 0, you should handle the authentication process all over again
            
            if statusCode == 200 {
                
                print("success")
                // Convert the received JSON data into a dictionary.
                do {
                    let dataDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                    
                    let accessToken = dataDictionary["access_token"] as! String
                    let accessTokenExpiry = dataDictionary["expires_in"] as AnyObject!
                    
                    print("Access token: \(accessToken)--\(accessTokenExpiry)")
                    
                    NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "LIAccessToken")
                    NSUserDefaults.standardUserDefaults().setObject(accessTokenExpiry, forKey: "LIAccessTokenExpiry")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
                catch {
                    print("Could not convert JSON data into a dictionary.")
                }
            }
        }
        
        task.resume()
    }


    @IBAction func dismiss(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
