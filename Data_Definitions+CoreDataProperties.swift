//
//  Data_Definitions+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 2/27/18.
//  Copyright © 2018 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Data_Definitions {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Data_Definitions> {
        return NSFetchRequest<Data_Definitions>(entityName: "Data_Definitions")
    }

    @NSManaged public var item: String?
    @NSManaged public var definition: String?

}
