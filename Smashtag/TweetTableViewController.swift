//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Marius Ilie on 29/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class TweetTableViewController: UITableViewController, UISearchBarDelegate {
    
    // MARK: Model
    
    weak var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // array of sections // section is an array of tweets
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchText
        }
    }
    
    private var twitterRequest: Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: query + " -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = twitterRequest {
            lastTwitterRequest = twitterRequest
            
            request.fetchTweets{ [weak weakSelf = self] newTweets in
                DispatchQueue.main.async {
                    if request.parameters == (weakSelf?.lastTwitterRequest?.parameters)! {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, at: 0)
                            weakSelf?.updateDatabase(withNewTweets: newTweets)
                        }
                    }
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - SearchTextField
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar?.delegate = self
            searchBar?.text = searchText
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    private func updateDatabase(withNewTweets newTweets: [Twitter.Tweet]) {
        managedObjectContext?.perform { [weak weakSelf = self] in
            for twitterInfo in newTweets {
                _ = Tweet.tweet(withTwitterInfo: twitterInfo, forSearchTerm: weakSelf?.searchText, inManagedObjectContext: (weakSelf?.managedObjectContext)!)
            }
            
            ((weakSelf?.tabBarController?.viewControllers?.last as? UINavigationController)?.visibleViewController as? HistoryTableViewController)?.searchTermWasChanged(in: weakSelf)
            
            do {
                try weakSelf?.managedObjectContext?.save()
            } catch let error {
                print("CoreData Error: \(error)")
            }
        }
        
        printDatabaseStatistics()
        print("done printing statistics")
        
        self.refreshControl?.endRefreshing()
    }
    
    private func printDatabaseStatistics() {
        managedObjectContext?.perform { [weak weakSelf = self] in
            if let results = try? weakSelf?.managedObjectContext!.fetch(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results?.count) TwitterUser")
            }
            
            // more efficient:
            // let tweetCount = self.managedObjectContext!.count(for: NSFetchRequest(entityName: "Tweet", error: nil))
            let tweetCount = try? weakSelf?.managedObjectContext!.fetch(NSFetchRequest(entityName: "Tweet")).count
            print("\(tweetCount) Tweets")
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TweetersMentioningSearchTerm" {
            if let tweetersTVC = segue.destination as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier, for: indexPath)
        
        let tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
}
