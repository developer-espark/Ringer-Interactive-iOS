//
//  CoreDataManager.swift
//  PersistentTodoList
//
//  Created by Alok Upadhyay on 30/03/2018.
//  Copyright © 2017 Alok Upadhyay. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class CoreDataManager {
    
    //1
    static let sharedManager = CoreDataManager()
    public init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        
//        let container = NSPersistentContainer(name: "RingerInteractive")
//        
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
        guard let modelURL = Bundle.module.url(forResource:"RingerInteractive", withExtension: "momd") else { return  nil }
             guard let model = NSManagedObjectModel(contentsOf: modelURL) else { return nil }
             let container = PersistentContainer(name:"RingerInteractive",managedObjectModel:model)
             container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                 if let error = error as NSError? {
                     print("Unresolved error \(error), \(error.userInfo)")
                 }
             })
             return container
    }()
    
    //3
    func saveContext () {
        let context = CoreDataManager.sharedManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insertContact(contact: LocalContactModel) -> LocalContact {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "LocalContact",
                                                in: managedContext)!
        let mediaList = NSManagedObject(entity: entity,
                                        insertInto: managedContext)
        
        mediaList.setValue(contact.contactId, forKeyPath: "contactId")
        mediaList.setValue(contact.contactImage, forKeyPath: "contactImage")
        mediaList.setValue(contact.createdAt, forKeyPath: "createdAt")
        mediaList.setValue(contact.createdBy, forKeyPath: "createdBy")
        mediaList.setValue(contact.deletedAt, forKeyPath: "deletedAt")
        mediaList.setValue(contact.firstName, forKeyPath: "firstName")
        mediaList.setValue(contact.galleryId, forKeyPath: "galleryId")
        mediaList.setValue(contact.id, forKeyPath: "id")
        mediaList.setValue(contact.lastName, forKeyPath: "lastName")
        mediaList.setValue(contact.modifiedAt, forKeyPath: "modifiedAt")
        mediaList.setValue(contact.modifiedBy, forKeyPath: "modifiedBy")
        
        do {
            try managedContext.save()
            return mediaList as? LocalContact ?? LocalContact()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return LocalContact()
        }
    }
    
    func fetchAllContact() -> [LocalContact]? {
        
        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LocalContact")
        
        do {
            let mediaList = try managedContext.fetch(fetchRequest)
            return mediaList as? [LocalContact]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    /*Insert*/
//    func insertMedia(orignalUrl: String, key: String, timeStamp: String)-> LocalContact {
//
//
//        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "MediaData",
//                                                in: managedContext)!
//        let mediaList = NSManagedObject(entity: entity,
//                                     insertInto: managedContext)
//
//
//        mediaList.setValue(orignalUrl, forKeyPath: "orignalUrl")
//        mediaList.setValue(key, forKeyPath: "key")
//        mediaList.setValue(timeStamp, forKeyPath: "time")
//
//        do {
//            try managedContext.save()
//            return mediaList as? LocalContact ?? LocalContact()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//            return LocalContact()
//        }
//    }
    
//    func delete(media: LocalContact){
//
//        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
//
//        managedContext.delete(media)
//
////        do {
////
////             try managedContext.delete(media)
////
////        } catch {
////            print(error)
////        }
//
//        do {
//            try managedContext.save()
//        } catch {
//        }
//    }
    
//    func fetchAllMedia() -> [LocalContact]? {
//
//
//        let managedContext = CoreDataManager.sharedManager.persistentContainer.viewContext
//
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MediaData")
//
//        do {
//            let mediaList = try managedContext.fetch(fetchRequest)
//            return mediaList as? [MediaData]
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//            return nil
//        }
//    }
    
//    func isContainKey(keys: String) -> String {
//
//        let list = self.fetchAllMedia()
//
//        let status = list?.filter{ $0.key == keys }
//
//
//        if status?.count == 1 {
//            return status?[0].orignalUrl ?? ""
//        }
//        return ""
//    }
    
//    func removeOutdatedURL() {
//
//        let list = self.fetchAllMedia()
//
//        if list?.count ?? 0 >  0 {
//            for i in list! {
//
//                let cuVal = Double(i.time ?? "0.0") ?? 0.0
//                let val: Double = Double(Date().timeIntervalSince1970) - cuVal
//
////                print("val is \(val)")
//
//                if val > (60*60*24) {
//                    CoreDataManager.sharedManager.delete(media: i)
//                }
//            }
//        }
//    }
}

