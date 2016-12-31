//
//  Tweet+CoreDataClass.swift
//  Smashtag
//
//  Created by Marius Ilie on 31/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

import Foundation
import CoreData
import Twitter


public class Tweet: NSManagedObject {
    class func tweet(withTwitterInfo twitterInfo: Twitter.Tweet, forSearchTerm searchTerm: String?, inManagedObjectContext context: NSManagedObjectContext) -> Tweet? {
        if let term = searchTerm {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tweet")
            request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
            
            if let tweet = (try? context.fetch(request))?.first as? Tweet {
                return tweet
            } else if let tweet = NSEntityDescription.insertNewObject(forEntityName: "Tweet", into: context) as? Tweet {
                tweet.unique = twitterInfo.id
                tweet.text = twitterInfo.text
                tweet.posted = twitterInfo.created as NSDate?
                
                tweet.hashtag = SearchTerm.searchTerm(withText: term, inManagedObjectContext: context)
                tweet.tweeter = TwitterUser.twitterUser(withTwitterInfo: twitterInfo.user, inManagedObjectContext: context)
                
                return tweet
            }
        }
        
        return nil
    }
}
