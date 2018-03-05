//
//  Settings+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 3/3/18.
//  Copyright © 2018 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var dataversion: Int16
    @NSManaged public var lastUpdateCheck: NSDate?

}
