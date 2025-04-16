// ProposalListView.swift
// Displays a list of all proposals with filtering options

import SwiftUI
import CoreData

struct ProposalListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Proposal.creationDate, ascending: false)],
        animation: .default)
    private var proposals: FetchedResults<Proposal>
    
    @State private var searchText = ""
    @State private var showingCreateProposal = false
    @State private var selectedStatus: String? = nil
    
    let statusOptions = ["Draft", "Pending", "Sent", "Won", "Lost", "Expired"]
    
    var body: some View {
        VStack {
            // Status filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Button(action: { selectedStatus = nil }) {
                        Text("All")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedStatus == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedStatus == nil ? .white : .primary)
                            .cornerRadius(20)
                    }
                    
                    ForEach(statusOptions, id: \.self) { status in
                        Button(action: { selectedStatus = status }) {
                            Text(status)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedStatus == status ? statusColor(for: status) : Color.gray.opacity(0.2))
                                .foregroundColor(selectedStatus == status ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            if filteredProposals.isEmpty {
                VStack(spacing: 20) {
                    if proposals.isEmpty {
                        Text("No Proposals Yet")
                            .font(.title)
                            .foregroundColor(.secondary)
                        
                        Text("Create your first proposal to get started")
                            .foregroundColor(.secondary)
                        
                        Button(action: { showingCreateProposal = true }) {
                            Label("Create Proposal", systemImage: "plus")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Text("No matching proposals")
                            .font(.title)
                            .foregroundColor(.secondary)
                        
                        Text("Try changing your search or filter")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            } else {
                List {
                    // Fix: Use ForEach with filteredProposals directly
                    // Instead of trying to convert FetchedResults to Array
                    ForEach(filteredProposals, id: \.self) { proposal in
                        NavigationLink(destination: ProposalDetailView(proposal: proposal)) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(proposal.formattedNumber)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text(proposal.formattedStatus)
                                        .font(.caption)
                                        .padding(4)
                                        .background(statusColor(for: proposal.formattedStatus))
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                                
                                Text(proposal.customerName)
                                    .font(.subheadline)
                                
                                HStack {
                                    Text(proposal.formattedDate)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(proposal.formattedTotal)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteProposals)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search Proposals")
        .navigationTitle("Proposals")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateProposal = true }) {
                    Label("Create", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateProposal) {
            CustomerSelectionForProposalView()
        }
    }
    
    // Fix: Changed the return type to [Proposal] and made sure we don't assign back to FetchedResults
    private var filteredProposals: [Proposal] {
        // Filter the proposals based on search text and selected status
        let filtered = proposals.filter { proposal in
            // Apply status filter if selected
            if let status = selectedStatus, proposal.status != status {
                return false
            }
            
            // Apply search text filter if entered
            if !searchText.isEmpty {
                let matchesNumber = proposal.number?.localizedCaseInsensitiveContains(searchText) ?? false
                let matchesCustomer = proposal.customer?.name?.localizedCaseInsensitiveContains(searchText) ?? false
                
                if !matchesNumber && !matchesCustomer {
                    return false
                }
            }
            
            return true
        }
        
        // Return the filtered results as an array
        return Array(filtered)
    }
    
    private func deleteProposals(offsets: IndexSet) {
        withAnimation {
            // Convert IndexSet to indices in the filtered array
            offsets.map { filteredProposals[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting proposal: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Draft":
            return .gray
        case "Pending":
            return .orange
        case "Sent":
            return .blue
        case "Won":
            return .green
        case "Lost":
            return .red
        case "Expired":
            return .purple
        default:
            return .gray
        }
    }
}
