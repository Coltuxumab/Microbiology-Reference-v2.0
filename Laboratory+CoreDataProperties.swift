//
//  Laboratory+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 3/4/18.
//  Copyright © 2018 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Laboratory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Laboratory> {
        return NSFetchRequest<Laboratory>(entityName: "Laboratory")
    }

    @NSManaged public var name: String?
    @NSManaged public var related_bug: NSSet?
    @NSManaged public var related_link: Links?

}

// MARK: Generated accessors for related_bug
extension Laboratory {

    @objc(addRelated_bugObject:)
    @NSManaged public func addToRelated_bug(_ value: Bugs)

    @objc(removeRelated_bugObject:)
    @NSManaged public func removeFromRelated_bug(_ value: Bugs)

    @objc(addRelated_bug:)
    @NSManaged public func addToRelated_bug(_ values: NSSet)

    @objc(removeRelated_bug:)
    @NSManaged public func removeFromRelated_bug(_ values: NSSet)

}
