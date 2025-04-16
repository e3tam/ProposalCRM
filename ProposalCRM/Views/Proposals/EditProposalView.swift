// EditProposalView.swift
// Form for editing an existing proposal

import SwiftUI

struct EditProposalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var proposal: Proposal
    
    @State private var proposalNumber: String
    @State private var status: String
    @State private var notes: String
    @State private var creationDate: Date
    
    let statusOptions = ["Draft", "Pending", "Sent", "Won", "Lost", "Expired"]
    
    init(proposal: Proposal) {
        self.proposal = proposal
        _proposalNumber = State(initialValue: proposal.number ?? "")
        _status = State(initialValue: proposal.status ?? "Draft")
        _notes = State(initialValue: proposal.notes ?? "")
        _creationDate = State(initialValue: proposal.creationDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Proposal Information")) {
                    TextField("Proposal Number", text: $proposalNumber)
                    
                    Picker("Status", selection: $status) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    
                    DatePicker("Date", selection: $creationDate, displayedComponents: .date)
                    
                    HStack {
                        Text("Customer")
                        Spacer()
                        Text(proposal.customerName)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Proposal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProposal()
                    }
                    .disabled(proposalNumber.isEmpty)
                }
            }
        }
    }
    
    private func saveProposal() {
        proposal.number = proposalNumber
        proposal.status = status
        proposal.creationDate = creationDate
        proposal.notes = notes
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Error updating proposal: \(nsError), \(nsError.userInfo)")
        }
    }
}
