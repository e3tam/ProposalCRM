// CoreDataModel.swift
// This file provides programmatic definitions for the Core Data model entities

import Foundation
import CoreData
import SwiftUI // Added SwiftUI import for Color

// MARK: - CoreData entity extensions

// Customer extension

// Product extension
extension Product {
    var formattedCode: String {
        return code ?? "Unknown Code"
    }
    
    var formattedName: String {
        return name ?? "Unknown Product"
    }
    
    var formattedPrice: String {
        return String(format: "%.2f", listPrice)
    }
}

// Proposal extension
extension Proposal {
    
  

    var formattedNumber: String {
        return number ?? "New Proposal"
    }
    
    var formattedDate: String {
        guard let date = creationDate else {
            return "Unknown Date"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedStatus: String {
        return status ?? "Draft"
    }
    
    var formattedTotal: String {
        return String(format: "%.2f", totalAmount)
    }
    
    var customerName: String {
        return customer?.name ?? "No Customer"
    }
    
    var itemsArray: [ProposalItem] {
        let set = items as? Set<ProposalItem> ?? []
        return set.sorted {
            $0.product?.name ?? "" < $1.product?.name ?? ""
        }
    }
    
    var engineeringArray: [Engineering] {
        let set = engineering as? Set<Engineering> ?? []
        return set.sorted {
            $0.desc ?? "" < $1.desc ?? ""
        }
    }
    
    var expensesArray: [Expense] {
        let set = expenses as? Set<Expense> ?? []
        return set.sorted {
            $0.desc ?? "" < $1.desc ?? ""
        }
    }
    
    var taxesArray: [CustomTax] {
        let set = taxes as? Set<CustomTax> ?? []
        return set.sorted {
            $0.name ?? "" < $1.name ?? ""
        }
    }

        // Added relationship accessors for tasks and activities
    var tasksArray: [Task] {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "proposal.id == %@", self.id! as CVarArg)
            
            do {
                let context = PersistenceController.shared.container.viewContext
                let fetchedTasks = try context.fetch(fetchRequest)
                
                // Sort the tasks
                return fetchedTasks.sorted { task1, task2 in
                    if task1.status == "Completed" && task2.status != "Completed" {
                        return false
                    } else if task1.status != "Completed" && task2.status == "Completed" {
                        return true
                    } else if let date1 = task1.dueDate, let date2 = task2.dueDate {
                        return date1 < date2
                    } else if task1.dueDate != nil && task2.dueDate == nil {
                        return true
                    } else if task1.dueDate == nil && task2.dueDate != nil {
                        return false
                    } else {
                        return task1.creationDate ?? Date() > task2.creationDate ?? Date()
                    }
                }
            } catch {
                print("ERROR: Failed to fetch tasks for proposal: \(error)")
                return []
            }
        }
    
    
    var activitiesArray: [Activity] {
        let set = activities as? Set<Activity> ?? []
        return set.sorted {
            $0.timestamp ?? Date() > $1.timestamp ?? Date()
        }
    }
    
    var subtotalProducts: Double {
        let items = itemsArray
        return items.reduce(0) { $0 + $1.amount }
    }
    
    var subtotalEngineering: Double {
        let engineering = engineeringArray
        return engineering.reduce(0) { $0 + $1.amount }
    }
    
    var subtotalExpenses: Double {
        let expenses = expensesArray
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    var subtotalTaxes: Double {
        let taxes = taxesArray
        return taxes.reduce(0) { $0 + $1.amount }
    }
    
    var totalCost: Double {
        var cost = 0.0
        for item in itemsArray {
            if let product = item.product {
                cost += product.partnerPrice * item.quantity
            }
        }
        return cost + subtotalExpenses
    }
    
    var grossProfit: Double {
        return totalAmount - totalCost
    }
    
    var profitMargin: Double {
        if totalAmount == 0 {
            return 0
        }
        return (grossProfit / totalAmount) * 100
    }
    
    var pendingTasksCount: Int {
        return tasksArray.filter { $0.status != "Completed" }.count
    }
    
    var hasOverdueTasks: Bool {
        return tasksArray.contains { $0.isOverdue }
    }
    
    var lastActivity: Activity? {
        return activitiesArray.first
    }
}

// ProposalItem extension
extension ProposalItem {
    var productName: String {
        return product?.name ?? "Unknown Product"
    }
    
    var productCode: String {
        return product?.code ?? "Unknown Code"
    }
    
    var formattedAmount: String {
        return String(format: "%.2f", amount)
    }
}

// Engineering extension
extension Engineering {
    var formattedAmount: String {
        return String(format: "%.2f", amount)
    }
}

// Expense extension
extension Expense {
    var formattedAmount: String {
        return String(format: "%.2f", amount)
    }
}

// CustomTax extension
extension CustomTax {
    var formattedRate: String {
        return String(format: "%.2f%%", rate)
    }
    
    var formattedAmount: String {
        return String(format: "%.2f", amount)
    }
}

// Task extension
extension Task {
    
    @objc dynamic var proposalObj: Proposal? {
        get { return proposal }
        set { proposal = newValue }
    }

    var formattedDueDate: String {
        guard let date = dueDate else {
            return "No due date"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var priorityColor: Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .blue
        default: return .gray
        }
    }
    
    var statusColor: Color {
        switch status {
        case "New": return .blue
        case "In Progress": return .orange
        case "Completed": return .green
        case "Deferred": return .gray
        default: return .gray
        }
    }
    
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return dueDate < Date() && status != "Completed"
    }
}

// Activity extension
extension Activity {
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp ?? Date())
    }
    
    var typeIcon: String {
        switch type {
        case "Created": return "plus.circle"
        case "Updated": return "pencil.circle"
        case "StatusChanged": return "arrow.triangle.swap"
        case "CommentAdded": return "text.bubble"
        case "TaskAdded": return "checkmark.circle"
        case "TaskCompleted": return "checkmark.circle.fill"
        case "DocumentAdded": return "doc.fill"
        default: return "circle"
        }
    }
    
    var typeColor: Color {
        switch type {
        case "Created": return .green
        case "Updated": return .blue
        case "StatusChanged": return .orange
        case "CommentAdded": return .purple
        case "TaskAdded": return .blue
        case "TaskCompleted": return .green
        case "DocumentAdded": return .gray
        default: return .gray
        }
    }
}
// Customer extension
extension Customer {
    var formattedName: String {
        return name ?? "Unknown Customer"
    }
    
    var proposalsArray: [Proposal] {
        let set = proposals as? Set<Proposal> ?? []
        return set.sorted {
            $0.creationDate ?? Date() > $1.creationDate ?? Date()
        }
    }
}
