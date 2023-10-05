//
//  ViewController.swift
//  SinglePageToDoListProject
//
//  Created by Burak Gül on 12.09.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController()
    var items : [Item] = []
    var checkedItems : [Item] = []
    var uncheckedItems : [Item] = []
    var copyItems : [Item] {
        return uncheckedItems + checkedItems
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchController.searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.searchController = searchController
        searchController.searchBar.isHidden = false
        searchController.obscuresBackgroundDuringPresentation = false
        uncheckedItems = getUncheckedItems()
        checkedItems = getCheckedItems()
        compoundCheckedAndUncheckedItems()
       
        loadDataFromDataBase()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add item", message: "", preferredStyle: .alert)
        let addButton = UIAlertAction(title: "Add Button", style: .default) { action in
            if textField.text != "" { // if textField is not empty , save data
                let newItem = Item(context: self.context)
                newItem.title = textField.text
                newItem.isDone = false
                self.uncheckedItems.append(newItem)
                self.items.append(newItem)
                self.items = self.copyItems
                var indeksPath = IndexPath(row: self.uncheckedItems.count-1, section: 0)
                self.tableView.insertRows(at: [indeksPath], with: .automatic)
                self.saveDataToDataBase()
                self.loadDataFromDataBase()
            }else {
                print(alert.textFields![0].placeholder = "Text is not be empty")
                self.present(alert, animated: true)
            }
               
        }
        alert.addTextField { text in
            text.placeholder = "Enter here"
            textField = text
        }
        alert.addAction(addButton)
        present(alert, animated: true)
    }
}

//MARK: - TableViewDataSource Functions

extension ViewController : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        if item.isDone {
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        return cell
    }
}

//MARK: - TableViewDelegate Functions
extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        item.isDone = !item.isDone
        if item.isDone {
            // you must move item to checkedItems
            
            let data = uncheckedItems.remove(at: indexPath.row)
            checkedItems.append(data)
            items = copyItems
            let uncheckedItemCount = uncheckedItems.count
            let checkedItemCount = checkedItems.count
             // Animasyonlu olarak hücreleri güncellemek için aşağıdaki kodu kullanabilirsiniz:
            let indexPathToRemove = IndexPath(row: indexPath.row, section: 0)
            let indexPathToInsert = IndexPath(row: items.count-1, section: 0)

             tableView.beginUpdates()
             tableView.deleteRows(at: [indexPathToRemove], with: .left)
            tableView.insertRows(at: [indexPathToInsert], with: .right)
             tableView.endUpdates()
            

           
        }else {
            let data = checkedItems.remove(at: indexPath.row-uncheckedItems.count)
            
            uncheckedItems.append(data)
            items = copyItems
            let indexPathToRemove = IndexPath(row: indexPath.row, section: 0)
            let indexPathToInsert = IndexPath(row: uncheckedItems.count-1, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPathToRemove], with: .right)
            tableView.insertRows(at: [indexPathToInsert], with: .left)
            tableView.endUpdates()
            

        }
        
       
        saveDataToDataBase()
        
    }
}



//MARK: - DataBase Functions2



extension ViewController {
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
    
    
    func compoundCheckedAndUncheckedItems()  {
        items = uncheckedItems + checkedItems
    }
}
//MARK: - DataBase Functions

 
extension ViewController {
    func saveDataToDataBase() {
        do {
            try context.save()
            print("Save data is successful")
        } catch  {
            print("Error saving to database \(error)")
        }

        
    }

    func loadDataFromDataBase(request : NSFetchRequest<Item> = Item.fetchRequest(),sortDescriptors : [NSSortDescriptor]? = nil,predicates : [NSPredicate]? = nil) {
        items = []
        let doneDescriptor = NSSortDescriptor(key: "isDone", ascending: true)
        let nameDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [doneDescriptor]
        if let additionalSortDescriptors = sortDescriptors {
            request.sortDescriptors?.append(contentsOf: additionalSortDescriptors)
        }
        if let additionalPredicates = predicates {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: additionalPredicates)
        }
            do {
                items = try context.fetch(request)
                print("load data is successful")
            }
            catch {
                print("load data is not successful \(error)")
            }
            tableView.reloadData()
        }
    }
 //MARK: - SearchBarDelegate Functions
extension ViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadDataFromDataBase()
        }else {
                        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
            let predicate = NSPredicate(format: "title BEGINSWITH[cd] %@", searchBar.text!)
                        do {
                            items = try context.fetch(fetchRequest)
                            print("filtered data is successful")
                        }
                        catch {
                            print("filtered data is not successful \(error)")
                        }
            tableView.reloadData()
            loadDataFromDataBase(predicates: [predicate])
        }
    }
}
 
 
 
    
    
    

