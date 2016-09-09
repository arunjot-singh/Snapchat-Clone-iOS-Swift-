/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet var username: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    @IBAction func signUpLogin(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(username.text!, password: "password") { (user, error) in
            
            if error != nil {
                
                let user = PFUser()
                user.username = self.username.text
                user.password = "password"
                user.signUpInBackgroundWithBlock({ (success, error) in
                
                    if let error = error {
                        
                        let errorString = error.userInfo["error"] as! String
                        self.errorLabel.text = "Error: \(errorString)"
                    } else {
                        print("signed up")
                        self.performSegueWithIdentifier("showUserTable", sender: self)
                    }
                })
                
            } else {
                
                print("logged in")
                self.performSegueWithIdentifier("showUserTable", sender: self)

            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.objectId != nil {
            self.performSegueWithIdentifier("showUserTable", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
