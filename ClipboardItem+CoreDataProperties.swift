//
//  ClipboardItem+CoreDataProperties.swift
//  PerfectClip
//
//  Created by Petar Petrov on 13.12.21.
//
//

import Foundation
import CoreData


extension ClipboardItem {
    
    @nonobjc public class func fetchRequest(q: String?) -> NSFetchRequest<ClipboardItem> {
        let request = NSFetchRequest<ClipboardItem>(entityName: "ClipboardItem")
        request.fetchBatchSize = 100
        request.fetchLimit = 200
        let createdAtSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [createdAtSortDescriptor]
        if let textQuery = q, !textQuery.isEmpty {
            request.predicate = NSPredicate(format: "text CONTAINS[c] %@", textQuery)
        }
        
        
        return request
    }
    
    @NSManaged public var text: String?
    @NSManaged public var createdAt: Date?
    
}

extension ClipboardItem : Identifiable {
    
}
