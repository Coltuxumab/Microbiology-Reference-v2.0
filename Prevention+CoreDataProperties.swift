//
//  Prevention+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 3/11/18.
//  Copyright © 2018 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Prevention {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prevention> {
        return NSFetchRequest<Prevention>(entityName: "Prevention")
    }

    @NSManaged public var name: String?
    @NSManaged public var important: Bool
    @NSManaged public var related_bug: NSSet?
    @NSManaged public var related_link: Links?

}

// MARK: Generated accessors for related_bug
extension Prevention {

    @objc(addRelated_bugObject:)
    @NSManaged public func addToRelated_bug(_ value: Bugs)

    @objc(removeRelated_bugObject:)
    @NSManaged public func removeFromRelated_bug(_ value: Bugs)

    @objc(addRelated_bug:)
    @NSManaged public func addToRelated_bug(_ values: NSSet)

    @objc(removeRelated_bug:)
    @NSManaged public func removeFromRelated_bug(_ values: NSSet)

}
