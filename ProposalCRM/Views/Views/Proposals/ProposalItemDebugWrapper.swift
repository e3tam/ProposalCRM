//
//  ProposalItemDebugWrapper.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 21.04.2025.
//


//
//  ProposalItemDebugWrapper.swift
//  ProposalCRM
//

import SwiftUI
import CoreData

// This wrapper ensures the item is fully loaded before presenting the edit view
struct ProposalItemDebugWrapper: View {
    @Environment(\.managedObjectContext) private var viewContext
    let item: ProposalItem
    @Binding var didSave: Bool
    var onSave: () -> Void
    
    @State private var loadedItem: ProposalItem?
    @State private var isLoaded = false
    
    var body: some View {
        Group {
            if isLoaded, let loadedItem = loadedItem {
                EditProposalItemView(
                    item: loadedItem,
                    context: viewContext,
                    didSave: $didSave,
                    onSave: onSave
                )
            } else {
                ProgressView("Loading item data...")
                    .onAppear {
                        loadItem()
                    }
            }
        }
    }
    
    private func loadItem() {
        // Create a fetch request for the specific item
        let fetchRequest: NSFetchRequest<ProposalItem> = ProposalItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "self == %@", item)
        fetchRequest.relationshipKeyPathsForPrefetching = ["product", "proposal"]
        
        do {
            // Fetch the item to ensure it's fully loaded
            let fetchedItems = try viewContext.fetch(fetchRequest)
            if let fetchedItem = fetchedItems.first {
                // Ensure product is loaded
                if let product = fetchedItem.product, product.isFault {
                    viewContext.refresh(product, mergeChanges: true)
                }
                
                // Print debug info
                print("Loading item - Quantity: \(fetchedItem.quantity), Discount: \(fetchedItem.discount), UnitPrice: \(fetchedItem.unitPrice)")
                print("Product name: \(fetchedItem.product?.name ?? "No name")")
                print("Product list price: \(fetchedItem.product?.listPrice ?? 0)")
                
                loadedItem = fetchedItem
                isLoaded = true
            } else {
                // Fallback to original item
                print("Failed to fetch item, using original")
                loadedItem = item
                isLoaded = true
            }
        } catch {
            print("Error fetching item: \(error)")
            // Fallback to the original item
            loadedItem = item
            isLoaded = true
        }
    }
}