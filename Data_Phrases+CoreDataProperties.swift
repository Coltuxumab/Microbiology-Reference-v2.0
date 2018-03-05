//
//  Data_Phrases+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 2/27/18.
//  Copyright © 2018 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Data_Phrases {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Data_Phrases> {
        return NSFetchRequest<Data_Phrases>(entityName: "Data_Phrases")
    }

    @NSManaged public var phrase: String?

}
