//
//  Data_Acronyms+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 2/27/18.
//  Copyright © 2018 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Data_Acronyms {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Data_Acronyms> {
        return NSFetchRequest<Data_Acronyms>(entityName: "Data_Acronyms")
    }

    @NSManaged public var acronym: String?
    @NSManaged public var word: String?

}
