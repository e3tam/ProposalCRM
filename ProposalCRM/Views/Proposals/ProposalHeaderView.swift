// ProposalHeaderView.swift
// Header view for the proposal detail screen with dark theme

import SwiftUI

struct ProposalHeaderView: View {
    @ObservedObject var proposal: Proposal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(proposal.formattedNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(proposal.formattedStatus)
                    .font(.subheadline)
                    .padding(6)
                    .background(statusColor(for: proposal.formattedStatus))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            Divider().background(Color.gray.opacity(0.5))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Customer")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(proposal.customerName)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(proposal.formattedDate)
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            
            HStack {
                Text("Total Amount")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(proposal.formattedTotal)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
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
