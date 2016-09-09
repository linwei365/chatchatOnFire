//
//  NewMessageTableViewController.swift
//  ChatChatOnFire
//
//  Created by Lin Wei on 8/26/16.
//  Copyright © 2016 Lin Wei. All rights reserved.
//

import UIKit
import Firebase

class NewMessageTableViewController: UITableViewController {
    
   var users = [User]()
    let cellID = "Cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.registerClass(FriendListTableViewCell.self, forCellReuseIdentifier: cellID)
        
        self.navigationItem.title = "Contacts"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancelButtonAction))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Friend", style: .Plain, target: self, action: #selector(handleAddContactButtonAction))
        
        fetchUsers()
        
        
    }
    
    

    func fetchUsers( )  {
        FIRDatabase.database().reference().child("users").observeEventType(FIRDataEventType.ChildAdded , withBlock: { (snapshot:FIRDataSnapshot) in
            
            if let dicitonary = snapshot.value as? [String: AnyObject] {

                
                
               
                let user:User = User()
                user.id = snapshot.key
                
                
                let currentUserId = FIRAuth.auth()?.currentUser?.uid
                if currentUserId != user.id {
                    
                    //this will crash if the firebase key doesn't match to the string key set up in the model
                    user.setValuesForKeysWithDictionary(dicitonary)
                    //safer way
                    //                user.name = dicitonary["name"] as! String
                    //                user.email = dicitonary["email"] as! String
                    
                    
                    self.users.append(user)
                }
                
                

                
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
 
            }
            
 
            }, withCancelBlock: nil)
        
    }
    
    func handleAddContactButtonAction( ) {
        let newMessageVC:AddContactsTableViewController = AddContactsTableViewController()
        //like a delegate?
        
        
        newMessageVC.addContactController = self
        
        let navigationController = UINavigationController(rootViewController: newMessageVC)
        presentViewController(navigationController, animated: true , completion: nil)
        
    }
    
    func handleCancelButtonAction()  {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID , forIndexPath: indexPath) as! FriendListTableViewCell

//        let  cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellID)
        
        
        let user = users[indexPath.row]
        

            
 
            
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.email
            
            if let profileImageUrl = user.profileImageUrl {
                
                
                cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                
            } else{
                
                //fix image changing if url string is nil
                cell.profileImageView.image = UIImage(named: "profile_teaser")
            }
     
            
            
   
        

 

        

        return cell
    }
    
    var messageController:ViewController?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        dismissViewControllerAnimated(true) {
            
            
            
            
            let user = self.users[indexPath.row]
            
            
             //pass user
            self.messageController?.showChatControllerForUser(user)
            
        }

    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

}


