//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    //MARK: - Variables & IBOutlets
    var todoItems: Results<Item>?
    let realm = try! Realm()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory!.name
        tableView.tintColor = FlatWhite()
        
        if let colorHex = selectedCategory?.color {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            let navBarAppearance = UINavigationBarAppearance()
            
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: FlatWhite()]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: FlatWhite()]
            navBarAppearance.backgroundColor = UIColor(hexString: colorHex)
            
            navBar.tintColor = FlatWhite()
            navBar.standardAppearance = navBarAppearance
            navBar.scrollEdgeAppearance = navBarAppearance
            
            searchBar.barTintColor = UIColor(hexString: colorHex)
            searchBar.searchTextField.backgroundColor = FlatWhite()
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if todoItems!.count > 0 {
            guard let item = todoItems?[indexPath.row] else {fatalError()}
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isCompleted ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }

        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isCompleted.toggle()
                }
            } catch {
                print("Error saving completion status, \(error)")
            }
            
        }
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            
            if textField.text != "" {
                let newItem = Item()
                newItem.title = textField.text!
                newItem.dateCreated = Date()
                self.save(item: newItem)
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    func save(item: Item) {
        if let currentCategory = selectedCategory {
            do {
                try realm.write {
                    currentCategory.items.append(item)
                }
            } catch {
                print("Error saving context, \(error)")
            }
        }
        
        
        //UITableViewController automatically loads the table view archived in a storyboard or nib file. Access the table view using the "tableView" property.
        //this will trigger the cellForRowAt method
        tableView.reloadData()
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    
    //MARK: - Delete Item Object
    
    override func updateModel(at indexPath: IndexPath) {
        if let todoItem = todoItems?[indexPath.row]{
            do {
                try realm.write {
                    realm.delete(todoItem)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
   
}


