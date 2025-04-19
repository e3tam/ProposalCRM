//
//  EngineeringView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// EngineeringView.swift
// View for adding new engineering entries

import SwiftUI
import CoreData

struct EngineeringView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var proposal: Proposal
    
    @State private var description = ""
    @State private var days = 1.0
    @State private var rate = 800.0
    
    var amount: Double {
        return days * rate
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Engineering Details")) {
                    TextField("Description", text: $description)
                    
                    // Fixed Days control with proper state updates
                    HStack {
                        Text("Days")
                        Spacer()
                        
                        // Improve button hit targets and add state update
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    if days > 0.5 {
                                        days -= 0.5
                                    }
                                }
                            }) {
                                Image(systemName: "minus")
                                    .frame(width: 32, height: 32)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Important for nested buttons
                            
                            Text(String(format: "%.1f", days))
                                .frame(minWidth: 40, alignment: .center)
                            
                            Button(action: {
                                withAnimation {
                                    days += 0.5
                                }
                            }) {
                                Image(systemName: "plus")
                                    .frame(width: 32, height: 32)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Important for nested buttons
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
            }
            .navigationTitle("Add Engineering")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addEngineering()
                    }
                    .disabled(days <= 0 || rate <= 0)
                }
            }
        }
    }
    
    private func addEngineering() {
        let engineering = Engineering(context: viewContext)
        engineering.id = UUID()
        engineering.desc = description
        engineering.days = days
        engineering.rate = rate
        engineering.amount = amount
        engineering.proposal = proposal
        
        do {
            try viewContext.save()
            updateProposalTotal()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error adding engineering: \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func updateProposalTotal() {
        let productsTotal = proposal.subtotalProducts
        let engineeringTotal = proposal.subtotalEngineering
        let expensesTotal = proposal.subtotalExpenses
        let taxesTotal = proposal.subtotalTaxes
        
        proposal.totalAmount = productsTotal + engineeringTotal + expensesTotal + taxesTotal
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error updating proposal total: \(nsError), \(nsError.userInfo)")
        }
    }
}
