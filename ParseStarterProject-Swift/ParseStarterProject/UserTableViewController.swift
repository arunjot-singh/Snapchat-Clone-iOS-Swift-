//
//  UserTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Arunjot Singh on 6/18/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var usernames = [String]()
    var userIds = [String]()
    var recipientUsername = ""
    var recipientUserId = ""

    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: (PFUser.currentUser()?.username)!)
        query?.findObjectsInBackgroundWithBlock({ (users, error) in
            
            if error == nil {
                
                if let users = users {
                    
                    for user in users as! [PFUser] {
                        user
                        self.usernames.append(user.username!)
                        self.userIds.append(user.objectId!)
                    }
                    self.tableView.reloadData()

                }
            } else {
                
                print(error)
            }
        })
        
        timer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(UserTableViewController.checkForMessage), userInfo: nil, repeats: true)
        
        
    }
    
    func checkForMessage() {
        
        let query = PFQuery(className: "image")
        query.whereKey("recipientUsername", equalTo: (PFUser.currentUser()?.username)!)
        query.findObjectsInBackgroundWithBlock { (images, error) in
            
            if error == nil {
                
                if let images = images {
                    
                    if images.count > 0 {
                        print(images)

                        let imageView = images[0]["photo"] as! PFFile
                        imageView.getDataInBackgroundWithBlock({ (data, error) in
                            
                            if error == nil {
                                
                                var senderUsername = "Unknown User"
                                
                                if let username = images[0]["senderUsername"] as? String {
                                    
                                    senderUsername = username
                                }
                                
                                if #available(iOS 8.0, *) {
                                    let alert = UIAlertController(title: "You have a message!", message: "Message from " + senderUsername, preferredStyle: UIAlertControllerStyle.Alert)
                             
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                                    
//                                    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.init(rawValue: 0)!)
//                                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
//                                    blurEffectView.frame = self.view.bounds
//                                    self.view.addSubview(blurEffectView)
                                    
                                    let bg = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                    bg.backgroundColor = UIColor.blackColor()
                                    bg.alpha = 0.8
                                    bg.tag = 10
                                    bg.contentMode = UIViewContentMode.ScaleAspectFit
                                    self.view.addSubview(bg)
                                    
                                    let displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                    displayedImage.image = UIImage(data: data!)
                                    displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                                    displayedImage.center = self.view.center
                                    displayedImage.tag = 10
                                    self.view.addSubview(displayedImage)
                                    
                                    images[0].deleteInBackground()
                                    
                                    _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(UserTableViewController.hideMessage), userInfo: nil, repeats: false)
                              
                                }))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                
                              }
                                
                            } else {
                                
                                print(error)
                            }
                        
                        })
                        
                }
                    
              }
                
            } else {
                
                print(error)
            }
        }
    }
    
    func hideMessage() {
        
        for subview in self.view.subviews {
            
            if subview.tag == 10 {
                subview.removeFromSuperview()
            }
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        recipientUsername = usernames[indexPath.row]
        recipientUserId = userIds[indexPath.row]
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let imageToSend = PFObject(className: "image")
        imageToSend["photo"] = PFFile(name: "photo.jpg", data: UIImageJPEGRepresentation(image, 0.5)!)
        imageToSend["senderUsername"] = PFUser.currentUser()?.username
        imageToSend["recipientUsername"] = recipientUsername
        
        let acl = PFACL()
        acl.setReadAccess(true, forUserId: recipientUserId)
        acl.setWriteAccess(true, forUserId: recipientUserId)
        imageToSend.ACL = acl
        imageToSend.saveInBackground()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logOut" {
            PFUser.logOut()
            timer.invalidate()
        }
    }
}
