//
//  AddMedicationTableViewController.swift
//  iOSTest
//
//  Created by Apple on 2017-10-30.
//  Copyright © 2017 Brandon Chester. All rights reserved.
//

import UIKit

class AddMedicationTableViewController: UITableViewController {

    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var sundayButton: UIButton!
    
    
    @IBOutlet weak var endRepeatCell: UITableViewCell!
    @IBOutlet weak var repeatCell: UITableViewCell!
    @IBOutlet weak var startDateCell: UITableViewCell!
    
    @IBOutlet weak var medicationReminderCell: UITableViewCell!
    
    @IBOutlet weak var meetingReminderCell: UITableViewCell!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    @IBOutlet weak var eventReminderCell: UITableViewCell!
    
    @IBOutlet weak var earlyReminderCell: UITableViewCell!
    
    var startDateCellHeight:CGFloat = 0
    var endRepeatCellHeight:CGFloat = 0
    
    @IBOutlet weak var startDatePickerCell: UITableViewCell!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var endDate:Date? = nil {
        didSet {
            if let date = endDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                endRepeatCell.detailTextLabel?.text = formatter.string(from: date)
            } else {
                endRepeatCell.detailTextLabel?.text = "Never"
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let endRepeatVC = segue.destination as? MedicationEndRepeatTableViewController {
            endRepeatVC.previousViewController = self
            endRepeatVC.endDate = endDate
        }
    }
    
    @IBAction func didTapRepeat(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.backgroundColor = sender.isSelected ? UIColor.pillBlue : UIColor.clear
        if sundayButton.isSelected || mondayButton.isSelected || tuesdayButton.isSelected || wednesdayButton.isSelected || thursdayButton.isSelected || fridayButton.isSelected || saturdayButton.isSelected {
            endRepeatCellHeight = 44
        } else {
            endRepeatCellHeight = 0
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func didTapAdd(_ sender: UIBarButtonItem) {
        var days = [DateOptions]()
        if sundayButton.isSelected { days.append(.sunday) }
        if mondayButton.isSelected { days.append(.monday) }
        if tuesdayButton.isSelected { days.append(.tuesday) }
        if wednesdayButton.isSelected { days.append(.wednesday) }
        if thursdayButton.isSelected { days.append(.thursday) }
        if fridayButton.isSelected { days.append(.friday) }
        if saturdayButton.isSelected { days.append(.saturday) }
        if days.isEmpty {
            endDate = startDatePicker.date
            let dayOfWeekComponent = Calendar.current.component(.weekday, from: endDate!) - 1
            let currentDayOfWeek = DateOptions(rawValue: 1 << dayOfWeekComponent)
            days.append(currentDayOfWeek)
        }
        var reminderType:ReminderType!
        if eventReminderCell.accessoryType == .checkmark {
            reminderType = .event
        } else if medicationReminderCell.accessoryType == .checkmark {
            reminderType = .medication
        } else if meetingReminderCell.accessoryType == .checkmark {
            reminderType = .meeting
        }
        let medication = Medication(name: titleField.text!,
                                    type: reminderType,
                                    time: startDatePicker.date,
                                    endDate: endDate,
                                    days: days)
        
        ScheduleData.shared.add(medication: medication)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didEditTitle(_ sender: UITextField) {
        if sender.hasText {
            addButton.isEnabled = true
        } else {
            addButton.isEnabled = false
        }
    }
    
    @IBAction func didSelectDate(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        startDateCell.detailTextLabel?.text = formatter.string(from: sender.date)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell === startDateCell {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            startDateCell.detailTextLabel?.text = formatter.string(from: startDatePicker.date)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        titleField.resignFirstResponder()
        if cell === startDateCell {
            if startDateCellHeight == 0 {
                cell.detailTextLabel?.textColor = UIColor.pillBlue
                startDateCellHeight = 200
            } else {
                cell.detailTextLabel?.textColor = UIColor.black
                startDateCellHeight = 0
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        if cell === medicationReminderCell {
            cell.accessoryType = .checkmark
            meetingReminderCell.accessoryType = .none
            eventReminderCell.accessoryType = .none
        } else if cell === meetingReminderCell {
            cell.accessoryType = .checkmark
            medicationReminderCell.accessoryType = .none
            eventReminderCell.accessoryType = .none
        } else if cell === eventReminderCell {
            cell.accessoryType = .checkmark
            medicationReminderCell.accessoryType = .none
            meetingReminderCell.accessoryType = .none
        } else if cell === earlyReminderCell {
            earlyReminderCell.accessoryType = earlyReminderCell.accessoryType == .none ? .checkmark : .none
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 && indexPath.section == 1 {
            return startDateCellHeight
        }
        if indexPath.row == 3 && indexPath.section == 1 {
            return endRepeatCellHeight
        }
        return UITableViewAutomaticDimension
    }
}
