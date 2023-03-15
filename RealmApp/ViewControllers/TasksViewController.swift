//
//  TasksViewController.swift
//  RealmApp
//
//  Created by Aleksei Voronovskii on 02.07.2018.
//  Copyright © 2018 Aleksei Voronovskii. All rights reserved.
//

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var taskList: TaskList!
    
    private var currentTasks: [Task]!
    private var completedTasks: [Task]!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskList.name
        
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        currentTasks = Array(taskList.tasks.filter("isComplete = false"))
        completedTasks = Array(taskList.tasks.filter("isComplete = true"))
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        content.text = task.name
        content.secondaryText = task.note
        cell.contentConfiguration = content
        return cell
    }
    
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 {
            let task = currentTasks[indexPath.row]
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
                StorageManager.shared.delete(task)
                currentTasks.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
                showAlert(with: task) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                isDone(true)
            }
            
            let doneAction = UIContextualAction(style: .normal, title: "Done") { [unowned self] _, _, isDone in
                StorageManager.shared.done(task)
                
                let task = currentTasks.remove(at: indexPath.row)
                completedTasks.append(task)
                
                let newIndex = IndexPath(row: completedTasks.count - 1, section: 1)
                tableView.moveRow(at: indexPath, to: newIndex)
                
                isDone(true)
            }
            
            editAction.backgroundColor = .orange
            doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            
            return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
        } else {
            let task = completedTasks[indexPath.row]
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [unowned self] _, _, _ in
                StorageManager.shared.delete(task)
                completedTasks.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
                showAlert(with: task) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                isDone(true)
            }
            
            let undoneAction = UIContextualAction(style: .normal, title: "Undone") { [unowned self] _, _, isDone in
                StorageManager.shared.undone(task)
                
                let task = completedTasks.remove(at: indexPath.row)
                currentTasks.append(task)
                
                let newIndex = IndexPath(row: currentTasks.count - 1, section: 0)
                tableView.moveRow(at: indexPath, to: newIndex)
                isDone(true)
            }
            
            editAction.backgroundColor = .orange
            undoneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            
            return UISwipeActionsConfiguration(actions: [undoneAction, editAction, deleteAction])
        }
    }
}

extension TasksViewController {
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let title = task != nil ? "Edit Task" : "New Task"
        
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "What do you want to do?")
        
        alert.action(with: task) { [weak self] taskTitle, note in
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task, newTitle: taskTitle, newNote: note)
                completion()
            } else {
                self?.save(task: taskTitle, withNote: note)
                self!.currentTasks.append(task!)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(task: String, withNote note: String) {
        StorageManager.shared.save(task, withNote: note, to: taskList) { task in
            let rowIndex = IndexPath(row: currentTasks.firstIndex(of: task) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}
