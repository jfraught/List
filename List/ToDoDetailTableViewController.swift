//
//  ToDoDetailTableViewController.swift
//  List
//
//  Created by Jordan Fraughton on 3/19/24.
//

import UIKit
import MessageUI

class ToDoDetailTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var isCompleteButton: UIButton!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var dueDateDatePicker: UIDatePicker!
    @IBOutlet var notesTextView: UITextView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var shareButton: UIButton!

    var isDatePickerHIdden = true
    let dateLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerIndex = IndexPath(row: 1, section: 1)
    let notesIndexPath = IndexPath(row: 0, section: 2)

    var toDo: ToDo?

    override func viewDidLoad() {
        super.viewDidLoad()
        let currentDueDate: Date
        if let toDo = toDo {
            navigationItem.title = "To-Do"
            titleTextField.text = toDo.title
            isCompleteButton.isSelected = toDo.isComplete
            currentDueDate = toDo.dueDate
            notesTextView.text = toDo.notes
        } else {
            currentDueDate = Date().addingTimeInterval(24*60*60)
        }
        dueDateDatePicker.date = currentDueDate
        updateDueDateLabel(date: dueDateDatePicker.date)
        updateSaveAndShareButtonState()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndex where isDatePickerHIdden == true:
            return 0
        case notesIndexPath:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndex:
            return 216
        case notesIndexPath:
            return 200
        default:
            return UITableView.automaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == dateLabelIndexPath {
            isDatePickerHIdden.toggle()
            updateDueDateLabel(date: dueDateDatePicker.date)
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard segue.identifier == "saveUnwind" else { return }

        let title = titleTextField.text!
        let isComplete = isCompleteButton.isSelected
        let dueDate = dueDateDatePicker.date
        let notes = notesTextView.text

        if toDo != nil {
            toDo?.title = title
            toDo?.isComplete = isComplete
            toDo?.dueDate = dueDate
            toDo?.notes = notes
        } else {
            toDo = ToDo(title: title, isComplete: isComplete, dueDate: dueDate, notes: notes)
        }
    }

    func updateSaveAndShareButtonState() {
        let shouldEnableSaveButton = titleTextField?.text?.isEmpty == false
        saveButton.isEnabled = shouldEnableSaveButton

    }

    func updateDueDateLabel(date: Date) {
        dueDateLabel.text = date.formatted(.dateTime.month(.defaultDigits).day().year(.twoDigits).hour().minute())
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard MFMailComposeViewController.canSendMail(), let toDo = toDo else {
            print("Can't send mail")
            return
        }

        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self

        mailComposer.setToRecipients(["example@example.com"])
        mailComposer.setSubject("Reminder \(toDo.title)")
        mailComposer.setMessageBody("""
            Hello, this is an email reminder for \(toDo.title).
            Due: \(toDo.dueDate)
            Notes: \(toDo.notes ?? "No notes")
        """, isHTML: false)

        present(mailComposer, animated: true, completion: nil)
    }
    

    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveAndShareButtonState()
    }

    @IBAction func returnPressed(_ sender: UITextField) {
        sender.resignFirstResponder()
    }

    @IBAction func isCompletButtonTapped(_ sender: UIButton) {
        isCompleteButton.isSelected.toggle()
    }

    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDueDateLabel(date: sender.date)
    }

    
}
