//
//  SearchTerm+CoreDataClass.swift
//  Smashtag
//
//  Created by Marius Ilie on 31/12/16.
//  Copyright © 2016 University of Bucharest - Marius Ilie. All rights reserved.
//

import Foundation
import CoreData
import Twitter

public class SearchTerm: NSManagedObject {
    class func searchTerm(withText searchTermText: String, inManagedObjectContext context: NSManagedObjectContext) -> SearchTerm? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchTerm")
        request.predicate = NSPredicate(format: "text = %@", searchTermText)
        
        if let searchTerm = (try? context.fetch(request))?.first as? SearchTerm {
            return searchTerm
        } else if let searchTerm = NSEntityDescription.insertNewObject(forEntityName: "SearchTerm", into: context) as? SearchTerm {
            searchTerm.text = searchTermText
            
            return searchTerm
        }
        
        return nil
    }
}
