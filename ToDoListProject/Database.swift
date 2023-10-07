//
//  Database.swift
//  ToDoListProject
//
//  Created by Burak Gül on 7.10.2023.
//

import Foundation
import UIKit


class Database {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
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
