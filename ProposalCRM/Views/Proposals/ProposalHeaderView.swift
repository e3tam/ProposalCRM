// ProposalHeaderView.swift
// Header view for the proposal detail screen

import SwiftUI

struct ProposalHeaderView: View {
    @ObservedObject var proposal: Proposal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(proposal.formattedNumber)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(proposal.formattedStatus)
                    .font(.subheadline)
                    .padding(6)
                    .background(statusColor(for: proposal.formattedStatus))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Customer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(proposal.customerName)
                        .font(.headline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(proposal.formattedDate)
                        .font(.headline)
                }
            }
            
            HStack {
                Text("Total Amount")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(proposal.formattedTotal)
                    .font(.title2)
                    .fontWeight(.bold)
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
