//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Elliot Hannah III on 3/4/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    //MARK: - Variables & IBOutlets
    var categories: Results<Category>?
    let realm = try! Realm()
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let backgroundColor = UIColor(hexString: "1D9BF6") {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            let navBarAppearance = UINavigationBarAppearance()
            
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: FlatWhite()]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: FlatWhite()]
            navBarAppearance.backgroundColor = backgroundColor
            
            navBar.tintColor = FlatWhite()
            navBar.standardAppearance = navBarAppearance
            navBar.scrollEdgeAppearance = navBarAppearance
            
        }
    }
    
    //MARK: - Add New Category
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let newCategoryAlert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add Category", style: .default) { (alertAction) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
            
        }
        
        newCategoryAlert.addTextField { (alertTextField) in
            textField = alertTextField
            textField.placeholder = "Create new category"
        }
        
        newCategoryAlert.addAction(action)
        present(newCategoryAlert, animated: true, completion: nil)
    }
    
    //MARK: - TableView Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let category = categories?[indexPath.row]
        
        cell.textLabel?.text = category?.name ?? "No Categories Added yet"
        guard let cellBackgroundColor = UIColor(hexString: category!.color) else {fatalError() }
        cell.backgroundColor = cellBackgroundColor
        cell.textLabel?.textColor = ContrastColorOf(cellBackgroundColor, returnFlat: true)
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.itemSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category, \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}


