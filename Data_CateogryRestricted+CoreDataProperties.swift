//
//  Data_CateogryRestricted+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 2/27/18.
//  Copyright © 2018 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Data_CateogryRestricted {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Data_CateogryRestricted> {
        return NSFetchRequest<Data_CateogryRestricted>(entityName: "Data_CateogryRestricted")
    }

    @NSManaged public var term: String?
    @NSManaged public var category: String?

}
