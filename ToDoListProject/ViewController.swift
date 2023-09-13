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
                
        


        
//
        
        
        
        
       
        
        loadDataFromDataBase()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var text = UITextField()
        let alert = UIAlertController(title: "Add item", message: "", preferredStyle: .alert)
        
        let addButton = UIAlertAction(title: "Add Button", style: .default) { action in
            let newItem = Item(context: self.context)
            newItem.title = text.text
            newItem.isDone = false
            self.items.append(newItem)
            self.saveDataToDataBase()
            
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Enter here"
            text = textField
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
        saveDataToDataBase()
        
        
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
        tableView.reloadData()
        
    }
    
    
    func loadDataFromDataBase() {
        items = []
        let fetchRequest:NSFetchRequest<Item> = NSFetchRequest.init(entityName: "Item")
        
        do {
            items = try context.fetch(fetchRequest)
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
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            
            
            do {
                items = try context.fetch(fetchRequest)
                print("filtered data is successful")
            }
            catch {
                print("filtered data is not successful \(error)")
            }
            tableView.reloadData()
        }

        
        
    }
    
}



