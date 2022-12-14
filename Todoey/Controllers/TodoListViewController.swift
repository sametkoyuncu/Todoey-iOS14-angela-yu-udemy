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
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let localRealm = try! Realm()
    
    // auto-updating container, we don't need '.append()' method anymore
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet{
          loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 60
        
        let color1 = Functions.getUIColorFromList(for: selectedCategory?.color)
        let color2 = color1.darken(byPercentage: 0.5)
        
        loadItems()
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: [color1, color2!, color1])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let color = Functions.getUIColorFromList(for: selectedCategory?.color)
        let contrastColor = ContrastColorOf(color, returnFlat: true)
        
        title = selectedCategory?.name
        searchBar.tintColor = contrastColor
        searchBar.searchTextField.textColor = contrastColor
        searchBar.barTintColor = color
        
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.") }
        
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
        
        navBar.barTintColor = color
        navBar.backgroundColor = UIColor.init(white: 1.0, alpha: 0)
        navBar.tintColor = contrastColor
    }
    // claar custon colors
    override func viewWillDisappear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.") }
        
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "Purple")!]
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "Purple")!]
        
        navBar.barTintColor = UIColor(named: "Purple")
        navBar.backgroundColor = UIColor.white
    }
    
    // Add new items
    @IBAction func addItemButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Buy milk.."
            textField = alertTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            // what will happen once the user clicks the add item button on our uialert
            
           if let newTitle = textField.text {
                if newTitle.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    if let currentCategory = self.selectedCategory {
                        do {
                            try self.localRealm.write({
                                let newItem = Item()
                                newItem.title = newTitle
                                currentCategory.items.append(newItem)
                            })
                        } catch  {
                            print("Error saving new item, \(error)")
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manupulation Methods
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    // MARK: - Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.localRealm.write {
                    self.localRealm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
}

// MARK: - TableView methods
extension TodoListViewController {
    // TableView  DataSource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            let categoryColor = Functions.getUIColorFromList(for: selectedCategory?.color)
            
            if let color = categoryColor.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.isDone ? .checkmark : .none
            
            cell.textLabel?.alpha = item.isDone ? 0.7 : 1
            
            return cell
        }
        
        cell.textLabel?.text = "No items added yet!"
        
        return cell
    }
    
    // TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = todoItems?[indexPath.row] {
            do {
                try localRealm.write({
                    //localRealm.delete(item)
                    item.isDone = !item.isDone
                    tableView.reloadData()
                })
            } catch {
                print("Error updating item, \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

// MARK: - Search Bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "createdAt", ascending: true)
            
            tableView.reloadData()
        }
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
