//
//  SearchTerm+CoreDataProperties.swift
//  Smashtag
//
//  Created by Marius Ilie on 31/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

import Foundation
import CoreData


extension SearchTerm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchTerm> {
        return NSFetchRequest<SearchTerm>(entityName: "SearchTerm");
    }

    @NSManaged public var text: String?
    @NSManaged public var tweets: NSSet?

}

// MARK: Generated accessors for tweets
extension SearchTerm {

    @objc(addTweetsObject:)
    @NSManaged public func addToTweets(_ value: Tweet)

    @objc(removeTweetsObject:)
    @NSManaged public func removeFromTweets(_ value: Tweet)

    @objc(addTweets:)
    @NSManaged public func addToTweets(_ values: NSSet)

    @objc(removeTweets:)
    @NSManaged public func removeFromTweets(_ values: NSSet)

}
