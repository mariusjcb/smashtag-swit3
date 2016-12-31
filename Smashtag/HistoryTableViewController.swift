//
//  HistoryTableViewController.swift
//  Smashtag
//
//  Created by Marius Ilie on 31/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

import UIKit
import CoreData

class SearchTerms<T: AnyObject> {
    weak var value: T?
    init(value: T) {
        self.value = value
    }
}

class HistoryTableViewController: TweetTableViewController {
    var searchTerms = [SearchTerm]() {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        searchTermWasChanged(in: self)
    }
    
    func searchTermWasChanged(in tablevc: UITableViewController?) {
        if let context = self.managedObjectContext {
            context.perform { [weak weakSelf = self] in
                let request = NSFetchRequest<SearchTerm>(entityName: "SearchTerm")
                weakSelf?.searchTerms = try! context.fetch(request)
            }
        }
    }
    
    @IBAction func deleteList(_ sender: UIBarButtonItem) {
        for term in searchTerms {
            for object in (term.tweets?.allObjects)! {
                if let tweet = object as? Tweet {
                    self.managedObjectContext?.delete(tweet)
                    if let tweeter = tweet.tweeter {
                        self.managedObjectContext?.delete(tweeter)
                    }
                }
            }
            
            self.managedObjectContext?.delete(term)
        }
        
        try? self.managedObjectContext?.save()
        searchTerms.removeAll()
    }
    
    // MARK: - UITableViewDataSource
    
    private struct Storyboard {
        static let HistoryTweetCellIdentifier = "History.Tweet"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return searchTerms.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchTerms[section].text ?? "Nil"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTerms[section].tweets?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.HistoryTweetCellIdentifier, for: indexPath)
        
        if let tweets = searchTerms[indexPath.section].tweets?.allObjects {
            if let tweet = tweets[indexPath.row] as? Tweet {
                cell.textLabel?.text = tweet.tweeter?.screenName
                cell.detailTextLabel?.text = tweet.text
            }
        }
        
        return cell
    }
}
