//
//  EditProposalItemView.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

struct EditProposalItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var manager: EditProposalItemManager
    @Binding var didSave: Bool
    var onSave: () -> Void
    
    init(item: ProposalItem, context: NSManagedObjectContext, didSave: Binding<Bool>, onSave: @escaping () -> Void) {
        _manager = StateObject(wrappedValue: EditProposalItemManager(item: item, context: context))
        _didSave = didSave
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Group {
                if manager.isLoading {
                    ProgressView("Loading...")
                } else if let error = manager.error {
                    VStack {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                        Button("Dismiss") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    Form {
                        Section(header: Text("PRODUCT DETAILS")) {
                            HStack {
                                Text("Product:")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(manager.productName)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Code:")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(manager.productCode)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Quantity:")
                                    .foregroundColor(.gray)
                                Spacer()
                                TextField("", text: $manager.quantityText)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                    .onSubmit {
                                        manager.validateQuantityText()
                                    }
                            }
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Discount (%)")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(String(format: "%.0f%%", manager.discount))
                                        .foregroundColor(.white)
                                }
                                
                                Slider(value: $manager.discount, in: 0...50, step: 1.0)
                                    .accentColor(.blue)
                                    .onChange(of: manager.discount) { _ in
                                        manager.updateUnitPrice()
                                    }
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.1))
                        
                        Section(header: Text("PRICING")) {
                            HStack {
                                Text("List Price")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.2f", manager.listPrice))
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Partner Price")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.2f", manager.partnerPrice))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Multiplier")
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 16) {
                                    TextField("", text: $manager.multiplierText)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 80)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                        .onChange(of: manager.multiplierText) { newValue in
                                            if let value = Double(newValue), value > 0 {
                                                manager.multiplier = value
                                                manager.updateUnitPrice()
                                            }
                                        }
                                    
                                    Text("×")
                                        .font(.system(size: 18))
                                        .foregroundColor(.gray)
                                }
                                
                                HStack(spacing: 8) {
                                    ForEach([0.8, 0.9, 1.0, 1.1, 1.2, 1.5], id: \.self) { value in
                                        Button(action: {
                                            manager.multiplier = value
                                            manager.multiplierText = String(format: "%.2f", value)
                                            manager.updateUnitPrice()
                                        }) {
                                            Text(String(format: "%.1f×", value))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(manager.multiplier == value ? Color.blue : Color.gray.opacity(0.3))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("Unit Price")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.2f", manager.unitPrice))
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("Amount")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.2f", manager.unitPrice * manager.quantity))
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.1))
                        
                        Section(header: Text("PROFIT & MARGIN")) {
                            HStack {
                                Text("Profit")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.2f", (manager.unitPrice - manager.partnerPrice) * manager.quantity))
                                    .foregroundColor((manager.unitPrice - manager.partnerPrice) * manager.quantity > 0 ? .green : .red)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("Margin")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(String(format: "%.1f%%", calculateMargin()))
                                    .foregroundColor(marginColor())
                                    .fontWeight(.bold)
                            }
                        }
                        .listRowBackground(Color.gray.opacity(0.1))
                    }
                }
            }
            .navigationTitle("Edit Product")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    manager.saveChanges { success in
                        if success {
                            didSave = true
                            onSave()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private func calculateMargin() -> Double {
        let amount = manager.unitPrice * manager.quantity
        let cost = manager.partnerPrice * manager.quantity
        let profit = amount - cost
        
        if amount <= 0 {
            return 0
        }
        return (profit / amount) * 100
    }
    
    private func marginColor() -> Color {
        let margin = calculateMargin()
        if margin >= 20 {
            return .green
        } else if margin >= 10 {
            return .orange
        } else {
            return .red
        }
    }
}
