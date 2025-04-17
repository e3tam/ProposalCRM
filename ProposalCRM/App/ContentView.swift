// ContentView.swift
// Main container view with tab navigation

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            NavigationView {
                CustomerListView()
            }
            .tabItem {
                Label("Customers", systemImage: "person.3")
            }
            
            NavigationView {
                CustomProductListView()
            }
            .tabItem {
                Label("Products", systemImage: "cube.box")
            }
            
            NavigationView {
                ProposalListView()
            }
            .tabItem {
                Label("Proposals", systemImage: "doc.text")
            }
            
            NavigationView {
                FinancialSummaryView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "chart.bar")
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
