//
//  LocalContact+CoreDataProperties.swift
//  RingerInteractive
//
//  Created by Hari Krishna on 15/02/22.
//
//

import Foundation
import CoreData


extension LocalContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalContact> {
        return NSFetchRequest<LocalContact>(entityName: "LocalContact")
    }

    @NSManaged public var contactId: String?
    @NSManaged public var createdAt: String?
    @NSManaged public var createdBy: String?
    @NSManaged public var deletedAt: String?
    @NSManaged public var firstName: String?
    @NSManaged public var galleryId: String?
    @NSManaged public var id: String?
    @NSManaged public var lastName: String?
    @NSManaged public var modifiedAt: String?
    @NSManaged public var modifiedBy: String?
    @NSManaged public var contactImage: Data?

}
