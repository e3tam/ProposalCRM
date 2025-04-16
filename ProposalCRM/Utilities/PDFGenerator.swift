// PDFGenerator.swift
// Generate PDF proposals for sharing and printing

import Foundation
import UIKit
import CoreData
import PDFKit

class PDFGenerator {
    // Main function to generate a PDF from a proposal
    static func generateProposalPDF(from proposal: Proposal) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ProposalCRM App",
            kCGPDFContextAuthor: "Generated on \(Date().formatted())"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // Use A4 page size
        let pageWidth = 8.27 * 72.0
        let pageHeight = 11.69 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            // First page with header and customer information
            context.beginPage()
            
            // Draw company logo or name
            let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            let companyName = "Your Company Name"
            let companyNameSize = companyName.size(withAttributes: titleAttributes)
            let companyRect = CGRect(x: 30, y: 30, width: companyNameSize.width, height: companyNameSize.height)
            companyName.draw(in: companyRect, withAttributes: titleAttributes)
            
            // Draw proposal title
            let proposalFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
            let proposalAttributes: [NSAttributedString.Key: Any] = [
                .font: proposalFont,
                .foregroundColor: UIColor.black
            ]
            let proposalTitle = "PROPOSAL"
            let proposalTitleSize = proposalTitle.size(withAttributes: proposalAttributes)
            let proposalRect = CGRect(x: 30, y: 70, width: proposalTitleSize.width, height: proposalTitleSize.height)
            proposalTitle.draw(in: proposalRect, withAttributes: proposalAttributes)
            
            // Draw proposal number and date
            let detailFont = UIFont.systemFont(ofSize: 12)
            let detailAttributes: [NSAttributedString.Key: Any] = [
                .font: detailFont,
                .foregroundColor: UIColor.black
            ]
            
            let proposalNumber = "Proposal Number: \(proposal.formattedNumber)"
            let proposalNumberSize = proposalNumber.size(withAttributes: detailAttributes)
            let proposalNumberRect = CGRect(x: 30, y: 110, width: proposalNumberSize.width, height: proposalNumberSize.height)
            proposalNumber.draw(in: proposalNumberRect, withAttributes: detailAttributes)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = "Date: \(dateFormatter.string(from: proposal.creationDate ?? Date()))"
            let dateStringSize = dateString.size(withAttributes: detailAttributes)
            let dateRect = CGRect(x: 30, y: 130, width: dateStringSize.width, height: dateStringSize.height)
            dateString.draw(in: dateRect, withAttributes: detailAttributes)
            
            // Draw customer information
            let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: sectionFont,
                .foregroundColor: UIColor.black
            ]
            
            let customerTitle = "Customer Information"
            let customerTitleSize = customerTitle.size(withAttributes: sectionAttributes)
            let customerTitleRect = CGRect(x: 30, y: 190, width: customerTitleSize.width, height: customerTitleSize.height)
            customerTitle.draw(in: customerTitleRect, withAttributes: sectionAttributes)
            
            // Basic PDF content implementation - would be expanded in real app
            // ...
        }
        
        return data
    }
    
    // Save PDF to Files app
    static func savePDF(_ pdfData: Data, fileName: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: url)
            return url
        } catch {
            print("Error saving PDF: \(error)")
            return nil
        }
    }
    
    // Preview PDF
    static func previewPDF(_ url: URL) -> UIViewController {
        let pdfView = PDFView()
        pdfView.autoScales = true
        
        if let document = PDFDocument(url: url) {
            pdfView.document = document
        }
        
        let viewController = UIViewController()
        viewController.view = pdfView
        viewController.title = "Proposal Preview"
        
        return viewController
    }
}
