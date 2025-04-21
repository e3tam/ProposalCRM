//
//  ActivityLogView.swift
//  ProposalCRM
//
//  Created by Ali Sami Gözükırmızı on 19.04.2025.
//


//
// ActivityLogView.swift
// Display activity history for a proposal
//

import SwiftUI
import CoreData

struct ActivityLogView: View {
    @ObservedObject var proposal: Proposal
    @State private var showingAddComment = false
    @State private var commentText = ""
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Activity History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showingAddComment = true }) {
                    Label("Add Comment", systemImage: "text.bubble")
                        .foregroundColor(.blue)
                }
            }
            
            if proposal.activitiesArray.isEmpty {
                Text("No activity recorded yet")
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(10)
            } else {
                ZStack {
                    // Solid background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.2))
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(proposal.activitiesArray, id: \.self) { activity in
                                ActivityRowView(activity: activity)
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                }
            }
        }
        .padding(.horizontal)
        .alert("Add Comment", isPresented: $showingAddComment) {
            TextField("Comment", text: $commentText)
            
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !commentText.isEmpty {
                    addComment()
                }
            }
        }
    }
    
    private func addComment() {
        ActivityLogger.logCommentAdded(
            proposal: proposal,
            context: viewContext,
            comment: commentText
        )
        
        commentText = ""
    }
}