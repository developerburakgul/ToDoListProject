//
//  Database.swift
//  ToDoListProject
//
//  Created by Burak Gül on 7.10.2023.
//

import Foundation
import UIKit
import CoreData


class Database {
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func loadData(request : NSFetchRequest<Item> = Item.fetchRequest(),sortDescriptors : [NSSortDescriptor]? = nil,predicates : [NSPredicate]? = nil) -> [Item] {
        let doneDescriptor = NSSortDescriptor(key: "isDone", ascending: true)
        request.sortDescriptors = [doneDescriptor]
        if let additionalSortDescriptors = sortDescriptors {
            request.sortDescriptors?.append(contentsOf: additionalSortDescriptors)
        }
        if let additionalPredicates = predicates {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: additionalPredicates)
        }
            do {
                let array = try context.fetch(request)
                print("load data is successful")
                return array
            }
            catch {
                fatalError("load data is not successful \(error)")
            }
            
        }
    func saveData() {
        do {
            try context.save()
            print("Save data is successful")
        } catch  {
            print("Error saving to database \(error)")
        }

        
    }
    
    func getUncheckedItems() -> [Item] {
        do {
            let request = Item.fetchRequest()
            let predicate = NSPredicate(format: "isDone = false")
            request.predicate = predicate
            let uncheckedItems = try context.fetch(request)
            return uncheckedItems
        } catch  {
            print("hata")
            fatalError("There was error while fetch unchecked items")
        }
    }
    
    func getCheckedItems() -> [Item] {
        do {
            let request = Item.fetchRequest()
            let predicate = NSPredicate(format: "isDone = true")
            request.predicate = predicate
            let uncheckedItems = try context.fetch(request)
            return uncheckedItems
        } catch  {
            print("hata")
            fatalError("There was error while fetch Checked items")
        }
    }

}
