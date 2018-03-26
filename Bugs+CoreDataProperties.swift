//
//  Bugs+CoreDataProperties.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 3/11/18.
//  Copyright © 2018 Denkensohn. All rights reserved.
//
//

import Foundation
import CoreData


extension Bugs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Bugs> {
        return NSFetchRequest<Bugs>(entityName: "Bugs")
    }

    @NSManaged public var last_accessed: NSDate?
    @NSManaged public var match_basis: String?
    @NSManaged public var name: String
    @NSManaged public var related_disease: NSOrderedSet?
    @NSManaged public var related_entity: NSOrderedSet?
    @NSManaged public var related_general: NSOrderedSet?
    @NSManaged public var related_gramstain: NSSet?
    @NSManaged public var related_transmission: NSOrderedSet?
    @NSManaged public var related_laboratory: NSOrderedSet?
    @NSManaged public var related_morphology: NSOrderedSet?
    @NSManaged public var related_prevention: NSOrderedSet?
    @NSManaged public var related_signs: NSOrderedSet?
    @NSManaged public var related_source: NSSet?
    @NSManaged public var related_treatments: NSOrderedSet?
    @NSManaged public var related_type: NSSet?

}

// MARK: Generated accessors for related_disease
extension Bugs {

    @objc(insertObject:inRelated_diseaseAtIndex:)
    @NSManaged public func insertIntoRelated_disease(_ value: Disease, at idx: Int)

    @objc(removeObjectFromRelated_diseaseAtIndex:)
    @NSManaged public func removeFromRelated_disease(at idx: Int)

    @objc(insertRelated_disease:atIndexes:)
    @NSManaged public func insertIntoRelated_disease(_ values: [Disease], at indexes: NSIndexSet)

    @objc(removeRelated_diseaseAtIndexes:)
    @NSManaged public func removeFromRelated_disease(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_diseaseAtIndex:withObject:)
    @NSManaged public func replaceRelated_disease(at idx: Int, with value: Disease)

    @objc(replaceRelated_diseaseAtIndexes:withRelated_disease:)
    @NSManaged public func replaceRelated_disease(at indexes: NSIndexSet, with values: [Disease])

    @objc(addRelated_diseaseObject:)
    @NSManaged public func addToRelated_disease(_ value: Disease)

    @objc(removeRelated_diseaseObject:)
    @NSManaged public func removeFromRelated_disease(_ value: Disease)

    @objc(addRelated_disease:)
    @NSManaged public func addToRelated_disease(_ values: NSOrderedSet)

    @objc(removeRelated_disease:)
    @NSManaged public func removeFromRelated_disease(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_entity
extension Bugs {

    @objc(insertObject:inRelated_entityAtIndex:)
    @NSManaged public func insertIntoRelated_entity(_ value: RelatedEntity, at idx: Int)

    @objc(removeObjectFromRelated_entityAtIndex:)
    @NSManaged public func removeFromRelated_entity(at idx: Int)

    @objc(insertRelated_entity:atIndexes:)
    @NSManaged public func insertIntoRelated_entity(_ values: [RelatedEntity], at indexes: NSIndexSet)

    @objc(removeRelated_entityAtIndexes:)
    @NSManaged public func removeFromRelated_entity(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_entityAtIndex:withObject:)
    @NSManaged public func replaceRelated_entity(at idx: Int, with value: RelatedEntity)

    @objc(replaceRelated_entityAtIndexes:withRelated_entity:)
    @NSManaged public func replaceRelated_entity(at indexes: NSIndexSet, with values: [RelatedEntity])

    @objc(addRelated_entityObject:)
    @NSManaged public func addToRelated_entity(_ value: RelatedEntity)

    @objc(removeRelated_entityObject:)
    @NSManaged public func removeFromRelated_entity(_ value: RelatedEntity)

    @objc(addRelated_entity:)
    @NSManaged public func addToRelated_entity(_ values: NSOrderedSet)

    @objc(removeRelated_entity:)
    @NSManaged public func removeFromRelated_entity(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_general
extension Bugs {

    @objc(insertObject:inRelated_generalAtIndex:)
    @NSManaged public func insertIntoRelated_general(_ value: General, at idx: Int)

    @objc(removeObjectFromRelated_generalAtIndex:)
    @NSManaged public func removeFromRelated_general(at idx: Int)

    @objc(insertRelated_general:atIndexes:)
    @NSManaged public func insertIntoRelated_general(_ values: [General], at indexes: NSIndexSet)

    @objc(removeRelated_generalAtIndexes:)
    @NSManaged public func removeFromRelated_general(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_generalAtIndex:withObject:)
    @NSManaged public func replaceRelated_general(at idx: Int, with value: General)

    @objc(replaceRelated_generalAtIndexes:withRelated_general:)
    @NSManaged public func replaceRelated_general(at indexes: NSIndexSet, with values: [General])

    @objc(addRelated_generalObject:)
    @NSManaged public func addToRelated_general(_ value: General)

    @objc(removeRelated_generalObject:)
    @NSManaged public func removeFromRelated_general(_ value: General)

    @objc(addRelated_general:)
    @NSManaged public func addToRelated_general(_ values: NSOrderedSet)

    @objc(removeRelated_general:)
    @NSManaged public func removeFromRelated_general(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_gramstain
extension Bugs {

    @objc(addRelated_gramstainObject:)
    @NSManaged public func addToRelated_gramstain(_ value: GramStain)

    @objc(removeRelated_gramstainObject:)
    @NSManaged public func removeFromRelated_gramstain(_ value: GramStain)

    @objc(addRelated_gramstain:)
    @NSManaged public func addToRelated_gramstain(_ values: NSSet)

    @objc(removeRelated_gramstain:)
    @NSManaged public func removeFromRelated_gramstain(_ values: NSSet)

}

// MARK: Generated accessors for related_transmission
extension Bugs {

    @objc(insertObject:inRelated_transmissionAtIndex:)
    @NSManaged public func insertIntoRelated_transmission(_ value: Transmission, at idx: Int)

    @objc(removeObjectFromRelated_transmissionAtIndex:)
    @NSManaged public func removeFromRelated_transmission(at idx: Int)

    @objc(insertRelated_transmission:atIndexes:)
    @NSManaged public func insertIntoRelated_transmission(_ values: [Transmission], at indexes: NSIndexSet)

    @objc(removeRelated_transmissionAtIndexes:)
    @NSManaged public func removeFromRelated_transmission(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_transmissionAtIndex:withObject:)
    @NSManaged public func replaceRelated_transmission(at idx: Int, with value: Transmission)

    @objc(replaceRelated_transmissionAtIndexes:withRelated_transmission:)
    @NSManaged public func replaceRelated_transmission(at indexes: NSIndexSet, with values: [Transmission])

    @objc(addRelated_transmissionObject:)
    @NSManaged public func addToRelated_transmission(_ value: Transmission)

    @objc(removeRelated_transmissionObject:)
    @NSManaged public func removeFromRelated_transmission(_ value: Transmission)

    @objc(addRelated_transmission:)
    @NSManaged public func addToRelated_transmission(_ values: NSOrderedSet)

    @objc(removeRelated_transmission:)
    @NSManaged public func removeFromRelated_transmission(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_laboratory
extension Bugs {

    @objc(insertObject:inRelated_laboratoryAtIndex:)
    @NSManaged public func insertIntoRelated_laboratory(_ value: Laboratory, at idx: Int)

    @objc(removeObjectFromRelated_laboratoryAtIndex:)
    @NSManaged public func removeFromRelated_laboratory(at idx: Int)

    @objc(insertRelated_laboratory:atIndexes:)
    @NSManaged public func insertIntoRelated_laboratory(_ values: [Laboratory], at indexes: NSIndexSet)

    @objc(removeRelated_laboratoryAtIndexes:)
    @NSManaged public func removeFromRelated_laboratory(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_laboratoryAtIndex:withObject:)
    @NSManaged public func replaceRelated_laboratory(at idx: Int, with value: Laboratory)

    @objc(replaceRelated_laboratoryAtIndexes:withRelated_laboratory:)
    @NSManaged public func replaceRelated_laboratory(at indexes: NSIndexSet, with values: [Laboratory])

    @objc(addRelated_laboratoryObject:)
    @NSManaged public func addToRelated_laboratory(_ value: Laboratory)

    @objc(removeRelated_laboratoryObject:)
    @NSManaged public func removeFromRelated_laboratory(_ value: Laboratory)

    @objc(addRelated_laboratory:)
    @NSManaged public func addToRelated_laboratory(_ values: NSOrderedSet)

    @objc(removeRelated_laboratory:)
    @NSManaged public func removeFromRelated_laboratory(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_morphology
extension Bugs {

    @objc(insertObject:inRelated_morphologyAtIndex:)
    @NSManaged public func insertIntoRelated_morphology(_ value: Morphology, at idx: Int)

    @objc(removeObjectFromRelated_morphologyAtIndex:)
    @NSManaged public func removeFromRelated_morphology(at idx: Int)

    @objc(insertRelated_morphology:atIndexes:)
    @NSManaged public func insertIntoRelated_morphology(_ values: [Morphology], at indexes: NSIndexSet)

    @objc(removeRelated_morphologyAtIndexes:)
    @NSManaged public func removeFromRelated_morphology(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_morphologyAtIndex:withObject:)
    @NSManaged public func replaceRelated_morphology(at idx: Int, with value: Morphology)

    @objc(replaceRelated_morphologyAtIndexes:withRelated_morphology:)
    @NSManaged public func replaceRelated_morphology(at indexes: NSIndexSet, with values: [Morphology])

    @objc(addRelated_morphologyObject:)
    @NSManaged public func addToRelated_morphology(_ value: Morphology)

    @objc(removeRelated_morphologyObject:)
    @NSManaged public func removeFromRelated_morphology(_ value: Morphology)

    @objc(addRelated_morphology:)
    @NSManaged public func addToRelated_morphology(_ values: NSOrderedSet)

    @objc(removeRelated_morphology:)
    @NSManaged public func removeFromRelated_morphology(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_prevention
extension Bugs {

    @objc(insertObject:inRelated_preventionAtIndex:)
    @NSManaged public func insertIntoRelated_prevention(_ value: Prevention, at idx: Int)

    @objc(removeObjectFromRelated_preventionAtIndex:)
    @NSManaged public func removeFromRelated_prevention(at idx: Int)

    @objc(insertRelated_prevention:atIndexes:)
    @NSManaged public func insertIntoRelated_prevention(_ values: [Prevention], at indexes: NSIndexSet)

    @objc(removeRelated_preventionAtIndexes:)
    @NSManaged public func removeFromRelated_prevention(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_preventionAtIndex:withObject:)
    @NSManaged public func replaceRelated_prevention(at idx: Int, with value: Prevention)

    @objc(replaceRelated_preventionAtIndexes:withRelated_prevention:)
    @NSManaged public func replaceRelated_prevention(at indexes: NSIndexSet, with values: [Prevention])

    @objc(addRelated_preventionObject:)
    @NSManaged public func addToRelated_prevention(_ value: Prevention)

    @objc(removeRelated_preventionObject:)
    @NSManaged public func removeFromRelated_prevention(_ value: Prevention)

    @objc(addRelated_prevention:)
    @NSManaged public func addToRelated_prevention(_ values: NSOrderedSet)

    @objc(removeRelated_prevention:)
    @NSManaged public func removeFromRelated_prevention(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_signs
extension Bugs {

    @objc(insertObject:inRelated_signsAtIndex:)
    @NSManaged public func insertIntoRelated_signs(_ value: Signs, at idx: Int)

    @objc(removeObjectFromRelated_signsAtIndex:)
    @NSManaged public func removeFromRelated_signs(at idx: Int)

    @objc(insertRelated_signs:atIndexes:)
    @NSManaged public func insertIntoRelated_signs(_ values: [Signs], at indexes: NSIndexSet)

    @objc(removeRelated_signsAtIndexes:)
    @NSManaged public func removeFromRelated_signs(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_signsAtIndex:withObject:)
    @NSManaged public func replaceRelated_signs(at idx: Int, with value: Signs)

    @objc(replaceRelated_signsAtIndexes:withRelated_signs:)
    @NSManaged public func replaceRelated_signs(at indexes: NSIndexSet, with values: [Signs])

    @objc(addRelated_signsObject:)
    @NSManaged public func addToRelated_signs(_ value: Signs)

    @objc(removeRelated_signsObject:)
    @NSManaged public func removeFromRelated_signs(_ value: Signs)

    @objc(addRelated_signs:)
    @NSManaged public func addToRelated_signs(_ values: NSOrderedSet)

    @objc(removeRelated_signs:)
    @NSManaged public func removeFromRelated_signs(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_source
extension Bugs {

    @objc(addRelated_sourceObject:)
    @NSManaged public func addToRelated_source(_ value: Sources)

    @objc(removeRelated_sourceObject:)
    @NSManaged public func removeFromRelated_source(_ value: Sources)

    @objc(addRelated_source:)
    @NSManaged public func addToRelated_source(_ values: NSSet)

    @objc(removeRelated_source:)
    @NSManaged public func removeFromRelated_source(_ values: NSSet)

}

// MARK: Generated accessors for related_treatments
extension Bugs {

    @objc(insertObject:inRelated_treatmentsAtIndex:)
    @NSManaged public func insertIntoRelated_treatments(_ value: Treatment, at idx: Int)

    @objc(removeObjectFromRelated_treatmentsAtIndex:)
    @NSManaged public func removeFromRelated_treatments(at idx: Int)

    @objc(insertRelated_treatments:atIndexes:)
    @NSManaged public func insertIntoRelated_treatments(_ values: [Treatment], at indexes: NSIndexSet)

    @objc(removeRelated_treatmentsAtIndexes:)
    @NSManaged public func removeFromRelated_treatments(at indexes: NSIndexSet)

    @objc(replaceObjectInRelated_treatmentsAtIndex:withObject:)
    @NSManaged public func replaceRelated_treatments(at idx: Int, with value: Treatment)

    @objc(replaceRelated_treatmentsAtIndexes:withRelated_treatments:)
    @NSManaged public func replaceRelated_treatments(at indexes: NSIndexSet, with values: [Treatment])

    @objc(addRelated_treatmentsObject:)
    @NSManaged public func addToRelated_treatments(_ value: Treatment)

    @objc(removeRelated_treatmentsObject:)
    @NSManaged public func removeFromRelated_treatments(_ value: Treatment)

    @objc(addRelated_treatments:)
    @NSManaged public func addToRelated_treatments(_ values: NSOrderedSet)

    @objc(removeRelated_treatments:)
    @NSManaged public func removeFromRelated_treatments(_ values: NSOrderedSet)

}

// MARK: Generated accessors for related_type
extension Bugs {

    @objc(addRelated_typeObject:)
    @NSManaged public func addToRelated_type(_ value: Type)

    @objc(removeRelated_typeObject:)
    @NSManaged public func removeFromRelated_type(_ value: Type)

    @objc(addRelated_type:)
    @NSManaged public func addToRelated_type(_ values: NSSet)

    @objc(removeRelated_type:)
    @NSManaged public func removeFromRelated_type(_ values: NSSet)

}
