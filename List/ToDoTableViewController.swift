//
//  ToDoTableViewController.swift
//  List
//
//  Created by Jordan Fraughton on 3/18/24.
//

import UIKit

class ToDoTableViewController: UITableViewController, ToDoCellDelegate, UISearchBarDelegate {
    var toDos = [ToDo]()
    var filterToDos: [ToDo] = []
    
    @IBOutlet var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedToDos = ToDo.loadToDos() {
            toDos = savedToDos
        } else {
            toDos = ToDo.loadSampleToDos()
        }

        filterToDos = toDos

        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterToDos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell

        cell.delegate = self

        let toDo = filterToDos[indexPath.row]
        cell.titleLabel?.text = toDo.title
        cell.isCompleteButton.isSelected = toDo.isComplete

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let removedToDo = filterToDos.remove(at: indexPath.row)
            for (i, toDo) in toDos.enumerated() {
                if toDo.id == removedToDo.id {
                    toDos.remove(at: i)
                }
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }

    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var toDo = filterToDos[indexPath.row]
            toDo.isComplete.toggle()
            filterToDos[indexPath.row] = toDo
            updateTodos(with: toDo)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterToDos = []
        if searchText == "" {
            filterToDos = toDos
        } else {
            for toDo in toDos {
                if toDo.title.uppercased().contains(searchText.uppercased()) {
                    filterToDos.append(toDo)
                }
            }
        }
        tableView.reloadData()
    }

    func updateTodos(with updatedToDo: ToDo) {
        for (i, toDo) in toDos.enumerated() {
            if toDo.id == updatedToDo.id {
                toDos[i] = updatedToDo
            }
        }
    }

    // MARK: - IBActions

    @IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! ToDoDetailTableViewController

        if let toDo = sourceViewController.toDo {
            if let indexOfExistingToDo = filterToDos.firstIndex(of: toDo) {
                filterToDos[indexOfExistingToDo] = toDo
                updateTodos(with: toDo)
                tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
            } else {
                let newIndexPath = IndexPath(row: filterToDos.count, section: 0)
                toDos.append(toDo)
                filterToDos.append(toDo)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        ToDo.saveToDos(toDos)
    }

    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        let detailController = ToDoDetailTableViewController(coder: coder)

        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return detailController
        }

        tableView.deselectRow(at: indexPath, animated: true)

        detailController?.toDo = filterToDos[indexPath.row]

        return detailController
    }
}
