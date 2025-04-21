// CustomerListView.swift
// Displays a list of customers with search functionality

import SwiftUI
import CoreData

struct CustomerListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Customer.name, ascending: true)],
        animation: .default)
    private var customers: FetchedResults<Customer>
    
    @State private var searchText = ""
    @State private var showingAddCustomer = false
    
    var body: some View {
        List {
            ForEach(filteredCustomers, id: \.self) { customer in
                NavigationLink(destination: CustomerDetailView(customer: customer)) {
                    VStack(alignment: .leading) {
                        Text(customer.formattedName)
                            .font(.headline)
                        Text(customer.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteCustomers)
        }
        .searchable(text: $searchText, prompt: "Search Customers")
        .navigationTitle("Customers")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddCustomer = true }) {
                    Label("Add Customer", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCustomer) {
            AddCustomerView()
        }
    }
    
    private var filteredCustomers: [Customer] {
        if searchText.isEmpty {
            return Array(customers)
        } else {
            return customers.filter { customer in
                customer.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                customer.email?.localizedCaseInsensitiveContains(searchText) ?? false ||
                customer.phone?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    private func deleteCustomers(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredCustomers[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Error deleting customer: \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
