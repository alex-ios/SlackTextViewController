//
//  RecipientsViewController.swift
//  Twitta
//
//  Created by Ignacio Romero Z. on 9/30/14.
//  Copyright (c) 2014 Slack Technologies, Inc. All rights reserved.
//

import UIKit
import Accounts
import Social
import SwifteriOS

class RecipientsViewController: UITableViewController {
    
    var key: NSString = "RErEmzj7ijDkJr60ayE2gjSHT" //"ejzsGPK20pckEY16aM1MTf6qt"
    var secret: NSString = "SbS0CHk11oJdALARa7NDik0nty4pXvAxdt7aj0R5y1gNzWaNEx" //"bdvsnHkGKQc0xcbnjAz6TwMu16dxv1N4UgEnMovVdqv4xQ8HgN"

    var swifter: Swifter
    var discussions : [JSONValue] = []
    let useACAccount = true

    required init(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: key, consumerSecret: secret)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Recipients"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: UIBarButtonItemStyle.Done, target: self, action: Selector("login"))
    }

    func login() {
        
        let failureHandler: ((NSError) -> Void) = {
            error in
            
            self.logError("Error", message: error.localizedDescription)
        }
        
        if useACAccount {
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            
            // Prompt the user for permission to their twitter account stored in the phone's settings
            accountStore.requestAccessToAccountsWithType(accountType, options: nil) {
                granted, error in
                
                if granted {
                    let twitterAccounts = accountStore.accountsWithAccountType(accountType)
                    
                    if twitterAccounts?.count == 0
                    {
                        self.logError("Error", message: "There are no Twitter accounts configured. You can add or create a Twitter account in Settings.")
                    }
                    else {
                        let twitterAccount = twitterAccounts[0] as ACAccount
                        self.swifter = Swifter(account: twitterAccount)
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.next()
                        })
                    }
                }
                else {
                    self.logError("Error", message: error.localizedDescription)
                }
            }
        }
        else {
            swifter.authorizeWithCallbackURL(NSURL(string: "twitta://success"), success: {
                accessToken, response in
                
                self.next()
                
                },failure: failureHandler
            )
        }
    }
    
    func next() {
        let vc:MessagesViewController = MessagesViewController(tableViewStyle: UITableViewStyle.Plain)
        vc.parent = self
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        //self.fetchDiscussions()
    }
    
    func fetchDiscussions() {
        let failureHandler: ((NSError) -> Void) = {
            error in
            self.logError("Error", message: error.localizedDescription)
        }
        
        self.swifter.getSentDirectMessagesSinceID(nil, maxID: nil, count: 20, page: 0, includeEntities: true, success: {
            (messages) -> Void in
            
            self.discussions = messages!
            self.tableView.reloadData()
            
        }, failure: failureHandler)
    }
    
    // MARK: - <UITableViewDataSource>

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discussions.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        
        let discussion = discussions[indexPath.row]
        println(discussion)
        
        cell.textLabel!.text = discussion["text"].string
        
        return cell
    }

    func logError(title: String, message: String) {
        println(title,message)
    }
}
