//
//  EditCustomTaxView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


// EditCustomTaxView.swift
// Edit view for custom tax entries

import SwiftUI
import CoreData

struct EditCustomTaxView_: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var customTax: CustomTax
    @ObservedObject var proposal: Proposal
    
    @State private var name: String
    @State private var rate: Double
    
    init(customTax: CustomTax, proposal: Proposal) {
        self.customTax = customTax
        self.proposal = proposal
        _name = State(initialValue: customTax.name ?? "")
        _rate = State(initialValue: customTax.rate)
    }
    
    private var subtotal: Double {
        return proposal.subtotalProducts + proposal.subtotalEngineering + proposal.subtotalExpenses
    }
    
    private var amount: Double {
        return subtotal * (rate / 100)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Tax Details")) {
                TextField("Tax Name", text: $name)
                
                // Common tax presets
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(["VAT", "GST", "Sales Tax", "Service Tax", "Import Tax"], id: \.self) { preset in
                            Button(action: {
                                name = preset
                            }) {
                                Text(preset)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(name == preset ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                HStack {
                    Text("Rate (%)")
                    Spacer()
                    Slider(value: $rate, in: 0...30, step: 0.5)
                    Text("\(rate, specifier: "%.1f")%")
                        .frame(width: 50)
                }
                
                // Common rates
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach([5.0, 7.5, 10.0, 15.0, 20.0], id: \.self) { preset in
                            Button(action: {
                                rate = preset
                            }) {
                                Text("\(preset, specifier: "%.1f")%")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(rate == preset ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text(String(format: "%.2f", subtotal))
                }
                
                HStack {
                    Text("Tax Amount")
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
        customTax.name = name
        customTax.rate = rate
        customTax.amount = amount
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}
