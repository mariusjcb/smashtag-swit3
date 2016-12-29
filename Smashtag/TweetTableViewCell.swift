//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Marius Ilie on 29/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetScreenTextLabel: UILabel!
    @IBOutlet weak var tweetScreenDateLabel: UILabel!
    @IBOutlet weak var tweetScreenImageView: UIImageView!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        tweetScreenNameLabel?.text = nil
        tweetScreenTextLabel?.attributedText = nil
        tweetScreenDateLabel?.text = nil
        tweetScreenImageView?.image = UIImage(named: "placeholder")
        
        if let tweet = self.tweet
        {
            tweetScreenTextLabel?.text = tweet.text
            if tweetScreenTextLabel?.text != nil  {
                for _ in tweet.media {
                    tweetScreenTextLabel.text! += " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user.name)"
            
            if let profileImageURL = tweet.user.profileImageURL {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak weakSelf = self] in
                    let dataFromURL = NSData(contentsOf: profileImageURL) as? Data
                    
                    DispatchQueue.main.async {
                        if profileImageURL == weakSelf?.tweet?.user.profileImageURL {
                            if let imageData = dataFromURL {
                                weakSelf?.tweetScreenImageView?.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }
            
            let formatter = DateFormatter()
            if Date().timeIntervalSince(tweet.created) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            } else {
                formatter.timeStyle = DateFormatter.Style.short
            }
            tweetScreenDateLabel?.text = formatter.string(from: tweet.created)
        }
    }
}
