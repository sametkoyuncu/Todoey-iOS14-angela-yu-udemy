//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Samet Koyuncu on 5.09.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Shop List"
            textField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            // what will happen once the user clicks the add item button on our uialert
            
            if let newName = textField.text {
                if newName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    let newCategory = Category(context: self.context)
                    newCategory.name = newName
                    // you can trim to
                    self.categoryArray.append(newCategory)
                    
                    self.saveCategories()
                }
            }
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Data Manipulation Methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category, \(error)")
        }
        
        self.tableView.reloadData()
    }

    func loadCategories(with request: NSFetchRequest<Category>  = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
            self.tableView.reloadData()
        } catch {
            print("Error loading categories, \(error)")
        }
    }
}

// MARK: - TableView methods
extension CategoryViewController {
    // TableView  DataSource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    // TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
}
