//
//  TwitterUser+CoreDataClass.swift
//  Smashtag
//
//  Created by Marius Ilie on 31/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

import Foundation
import CoreData
import Twitter

public class TwitterUser: NSManagedObject {
    class func twitterUser(withTwitterInfo twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        
        if let twitterUser = (try? context.fetch(request))?.first as? TwitterUser {
            return twitterUser
        } else if let twitterUser = NSEntityDescription.insertNewObject(forEntityName: "TwitterUser", into: context) as? TwitterUser {
            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
            twitterUser.image = twitterInfo.profileImageURL?.absoluteString
            
            return twitterUser
        }
        
        return nil
    }
}
