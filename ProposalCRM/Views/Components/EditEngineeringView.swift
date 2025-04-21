//
//  EditEngineeringView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// EditEngineeringView.swift
// Edit view for engineering entries

import SwiftUI
import CoreData

struct EditEngineeringView_: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var engineering: Engineering
    
    @State private var description: String
    @State private var days: Double
    @State private var rate: Double
    
    init(engineering: Engineering) {
        self.engineering = engineering
        _description = State(initialValue: engineering.desc ?? "")
        _days = State(initialValue: engineering.days)
        _rate = State(initialValue: engineering.rate)
    }
    
    var amount: Double {
        return days * rate
    }
    
    var body: some View {
        Form {
            Section(header: Text("Engineering Details")) {
                TextField("Description", text: $description)
                
                Stepper(value: $days, in: 0.5...100, step: 0.5) {
                    HStack {
                        Text("Days")
                        Spacer()
                        Text(String(format: "%.1f", days))
                    }
                }
                
                HStack {
                    Text("Day Rate")
                    Spacer()
                    TextField("Rate", value: $rate, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Total Amount")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "%.2f", amount))
                        .font(.headline)
                }
            }
            
            Button("Save Changes") {
                saveChanges()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private func saveChanges() {
        engineering.desc = description
        engineering.days = days
        engineering.rate = rate
        engineering.amount = amount
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
