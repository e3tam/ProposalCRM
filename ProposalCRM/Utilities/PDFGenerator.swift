// File: ProposalCRM/Utilities/PDFGenerator.swift
// Enhanced version with improved table layouts matching the UI - UPDATED for Euro Formatting

import Foundation
import UIKit
import CoreData
import PDFKit // Ensure PDFKit is imported

class PDFGenerator {
    // Main function to generate a PDF from a proposal
    static func generateProposalPDF(from proposal: Proposal) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "ProposalCRM App",
            kCGPDFContextAuthor: "Generated on \(Date().formatted())"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.27 * 72.0 // A4 width in points
        let pageHeight = 11.69 * 72.0 // A4 height in points
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { (context) in
            var currentPageY: CGFloat = 30 // Renamed for clarity per page

            // Start first page
            context.beginPage()

            // --- Header and Customer Info ---
            drawHeaderAndCustomerInfo(context: context.cgContext, proposal: proposal, yPosition: &currentPageY, pageRect: pageRect)

            // --- Products Table ---
            drawProductsTable(context: context, proposal: proposal, yPosition: &currentPageY, pageRect: pageRect)

            // --- Engineering Table ---
            if !proposal.engineeringArray.isEmpty {
                drawEngineeringTable(context: context, proposal: proposal, yPosition: &currentPageY, pageRect: pageRect)
            }

            // --- Expenses Table ---
            if !proposal.expensesArray.isEmpty {
                drawExpensesTable(context: context, proposal: proposal, yPosition: &currentPageY, pageRect: pageRect)
            }

            // --- Custom Taxes Table ---
            if !proposal.taxesArray.isEmpty {
                drawCustomTaxesTable(context: context, proposal: proposal, yPosition: &currentPageY, pageRect: pageRect)
            }

            // --- Financial Summary ---
            drawFinancialSummary(context: context, proposal: proposal, yPosition: &currentPageY, pageRect: pageRect)

            // --- Notes ---
            if let notes = proposal.notes, !notes.isEmpty {
                drawNotes(context: context, notes: notes, yPosition: &currentPageY, pageRect: pageRect)
            }
        }
        return data
    }

    // MARK: - Drawing Helpers

    // Helper to draw text within a rect, handling potential nil context
    private static func drawText(_ text: String, in rect: CGRect, withAttributes attributes: [NSAttributedString.Key: Any]) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        // Flip context coordinate system for UIKit drawing
        context.translateBy(x: 0, y: rect.origin.y * 2 + rect.height)
        context.scaleBy(x: 1, y: -1)
        let adjustedRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
        (text as NSString).draw(in: adjustedRect, withAttributes: attributes)
        context.restoreGState()
    }

    // Helper to draw lines (dividers)
     private static func drawLine(from start: CGPoint, to end: CGPoint, color: UIColor = .gray, lineWidth: CGFloat = 0.5) {
         guard let context = UIGraphicsGetCurrentContext() else { return }
         context.saveGState()
         context.setStrokeColor(color.cgColor)
         context.setLineWidth(lineWidth)
         context.move(to: start)
         context.addLine(to: end)
         context.strokePath()
         context.restoreGState()
     }

    // Helper for page break logic
    private static func checkPageBreak(context: UIGraphicsPDFRendererContext, yPosition: inout CGFloat, requiredHeight: CGFloat, pageRect: CGRect, topMargin: CGFloat = 30) {
        if yPosition + requiredHeight > pageRect.height - topMargin { // Check against bottom margin
            context.beginPage()
            yPosition = topMargin
        }
    }


    // MARK: - Section Drawing Functions (UPDATED formatting)

     private static func drawHeaderAndCustomerInfo(context: CGContext, proposal: Proposal, yPosition: inout CGFloat, pageRect: CGRect) {
         let margin: CGFloat = 30
         let detailFont = UIFont.systemFont(ofSize: 12)
         let detailAttributes: [NSAttributedString.Key: Any] = [.font: detailFont, .foregroundColor: UIColor.black]
         let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
         let sectionAttributes: [NSAttributedString.Key: Any] = [.font: sectionFont, .foregroundColor: UIColor.black]

         // Company Name/Logo Placeholder
         let titleFont = UIFont.systemFont(ofSize: 28, weight: .bold)
         let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont, .foregroundColor: UIColor.black]
         let companyName = "Your Company Name" // Replace with actual data or logo drawing logic
         let companyNameSize = companyName.size(withAttributes: titleAttributes)
         drawText(companyName, in: CGRect(x: margin, y: yPosition, width: companyNameSize.width, height: companyNameSize.height), withAttributes: titleAttributes)
         yPosition += companyNameSize.height + 10

         // Proposal Title
         let proposalTitle = "PROPOSAL"
         let proposalFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
         let proposalAttributes: [NSAttributedString.Key: Any] = [.font: proposalFont, .foregroundColor: UIColor.black]
         let proposalTitleSize = proposalTitle.size(withAttributes: proposalAttributes)
         drawText(proposalTitle, in: CGRect(x: margin, y: yPosition, width: proposalTitleSize.width, height: proposalTitleSize.height), withAttributes: proposalAttributes)
         yPosition += proposalTitleSize.height + 10

         // Proposal Details
         let proposalNumber = "Proposal Number: \(proposal.formattedNumber)"
         let proposalNumberSize = proposalNumber.size(withAttributes: detailAttributes)
         drawText(proposalNumber, in: CGRect(x: margin, y: yPosition, width: proposalNumberSize.width, height: proposalNumberSize.height), withAttributes: detailAttributes)
         yPosition += proposalNumberSize.height + 5

         let dateFormatter = DateFormatter()
         dateFormatter.dateStyle = .long
         let dateString = "Date: \(dateFormatter.string(from: proposal.creationDate ?? Date()))"
         let dateStringSize = dateString.size(withAttributes: detailAttributes)
         drawText(dateString, in: CGRect(x: margin, y: yPosition, width: dateStringSize.width, height: dateStringSize.height), withAttributes: detailAttributes)
         yPosition += dateStringSize.height + 5

         let statusString = "Status: \(proposal.formattedStatus)"
         let statusStringSize = statusString.size(withAttributes: detailAttributes)
         drawText(statusString, in: CGRect(x: margin, y: yPosition, width: statusStringSize.width, height: statusStringSize.height), withAttributes: detailAttributes)
         yPosition += statusStringSize.height + 20

         // Customer Information Section
         let customerTitle = "Customer Information"
         let customerTitleSize = customerTitle.size(withAttributes: sectionAttributes)
         drawText(customerTitle, in: CGRect(x: margin, y: yPosition, width: customerTitleSize.width, height: customerTitleSize.height), withAttributes: sectionAttributes)
         yPosition += customerTitleSize.height + 5
         drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: pageRect.width - margin, y: yPosition))
         yPosition += 10

         // Customer Details
         if let customer = proposal.customer {
             let customerNameString = "Company: \(customer.formattedName)"
             let customerNameSize = customerNameString.size(withAttributes: detailAttributes)
             drawText(customerNameString, in: CGRect(x: margin, y: yPosition, width: pageRect.width - 2*margin, height: customerNameSize.height), withAttributes: detailAttributes)
             yPosition += customerNameSize.height + 5

             if let contactName = customer.contactName, !contactName.isEmpty {
                 let contactString = "Contact: \(contactName)"
                 let contactSize = contactString.size(withAttributes: detailAttributes)
                 drawText(contactString, in: CGRect(x: margin, y: yPosition, width: pageRect.width - 2*margin, height: contactSize.height), withAttributes: detailAttributes)
                 yPosition += contactSize.height + 5
             }
             // ... draw email, phone, address similarly ...
             if let email = customer.email, !email.isEmpty {
                let emailString = "Email: \(email)"
                let emailSize = emailString.size(withAttributes: detailAttributes)
                drawText(emailString, in: CGRect(x: margin, y: yPosition, width: pageRect.width - 2*margin, height: emailSize.height), withAttributes: detailAttributes)
                yPosition += emailSize.height + 5
            }
             if let phone = customer.phone, !phone.isEmpty {
                let phoneString = "Phone: \(phone)"
                let phoneSize = phoneString.size(withAttributes: detailAttributes)
                drawText(phoneString, in: CGRect(x: margin, y: yPosition, width: pageRect.width - 2*margin, height: phoneSize.height), withAttributes: detailAttributes)
                yPosition += phoneSize.height + 5
            }
            if let address = customer.address, !address.isEmpty {
                 let addressString = "Address: \(address)"
                 let addressSize = addressString.boundingRect(with: CGSize(width: pageRect.width - 2*margin, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: detailAttributes, context: nil).size
                 drawText(addressString, in: CGRect(x: margin, y: yPosition, width: pageRect.width - 2*margin, height: addressSize.height), withAttributes: detailAttributes)
                 yPosition += addressSize.height + 5
             }
         } else {
             drawText("No Customer Assigned", in: CGRect(x: margin, y: yPosition, width: 200, height: 20), withAttributes: detailAttributes)
             yPosition += 25
         }

         yPosition += 20 // Space before next section
     }

    private static func drawProductsTable(context: UIGraphicsPDFRendererContext, proposal: Proposal, yPosition: inout CGFloat, pageRect: CGRect) {
        let margin: CGFloat = 30
        let tableWidth = pageRect.width - (margin * 2)
        let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let headerFont = UIFont.systemFont(ofSize: 9, weight: .bold)
        let rowFont = UIFont.systemFont(ofSize: 9)
        let rowAttributes: [NSAttributedString.Key: Any] = [.font: rowFont, .foregroundColor: UIColor.black]
        let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont, .foregroundColor: UIColor.black]

        checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 50, pageRect: pageRect) // Check space for title+header

        // Table title
        let productsTitle = "Products"
        let productsTitleSize = productsTitle.size(withAttributes: sectionFont.attributes)
        drawText(productsTitle, in: CGRect(x: margin, y: yPosition, width: productsTitleSize.width, height: productsTitleSize.height), withAttributes: sectionFont.attributes)
        yPosition += productsTitleSize.height + 10

        // Define column widths proportionally - ADJUST AS NEEDED
        let nameWidth = tableWidth * 0.30 // Increased width for name
        let qtyWidth = tableWidth * 0.05
        let unitPriceWidth = tableWidth * 0.15 // Adjusted
        let discountWidth = tableWidth * 0.10 // Adjusted
        let extPriceWidth = tableWidth * 0.15 // Adjusted
        let profitWidth = tableWidth * 0.15 // Adjusted

        // Draw header background and text
        let headerHeight: CGFloat = 20
        let headerRect = CGRect(x: margin, y: yPosition, width: tableWidth, height: headerHeight)
        context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
        context.cgContext.fill(headerRect)
        var xPosition = margin
        drawText("Product Name", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: nameWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
        xPosition += nameWidth
        drawText("Qty", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: qtyWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
        xPosition += qtyWidth
        drawText("Unit Price", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: unitPriceWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
        xPosition += unitPriceWidth
        drawText("Discount", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: discountWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
        xPosition += discountWidth
        drawText("Ext Price", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: extPriceWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
        xPosition += extPriceWidth
        drawText("Profit", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: profitWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)

        // Draw header borders
        drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: margin + tableWidth, y: yPosition)) // Top
        drawLine(from: CGPoint(x: margin, y: yPosition + headerHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + headerHeight)) // Bottom
        xPosition = margin
        drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight)) // Left
        xPosition += nameWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
        xPosition += qtyWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
        xPosition += unitPriceWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
        xPosition += discountWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
        xPosition += extPriceWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
        xPosition += profitWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight)) // Right

        yPosition += headerHeight

        // Draw product rows
        for item in proposal.itemsArray {
            let rowHeight: CGFloat = 20
            checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: rowHeight, pageRect: pageRect)

            xPosition = margin
            let nameText = item.productName + (item.productCode.isEmpty ? "" : " (\(item.productCode))")
            drawText(nameText, in: CGRect(x: xPosition + 3, y: yPosition + 4, width: nameWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes)
            xPosition += nameWidth
            drawText(String(format: "%.0f", item.quantity), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: qtyWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes)
            xPosition += qtyWidth
            drawText(Formatters.formatEuro(item.unitPrice), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: unitPriceWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED
            xPosition += unitPriceWidth
            drawText(Formatters.formatPercent(item.discount), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: discountWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED
            xPosition += discountWidth
            drawText(Formatters.formatEuro(item.amount), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: extPriceWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED
            xPosition += extPriceWidth
            let partnerPrice = item.product?.partnerPrice ?? 0
            let profit = item.amount - (partnerPrice * item.quantity)
            drawText(Formatters.formatEuro(profit), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: profitWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED

            // Draw row borders
            drawLine(from: CGPoint(x: margin, y: yPosition + rowHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + rowHeight)) // Bottom
             xPosition = margin
             drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight)) // Left
             xPosition += nameWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
             xPosition += qtyWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
             xPosition += unitPriceWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
             xPosition += discountWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
             xPosition += extPriceWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
             xPosition += profitWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight)) // Right

            yPosition += rowHeight
        }

        // Products subtotal
        checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 20, pageRect: pageRect)
        let subtotalRowHeight: CGFloat = 20
        let subtotalRect = CGRect(x: margin, y: yPosition, width: tableWidth, height: subtotalRowHeight)
        context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
        context.cgContext.fill(subtotalRect)
        let subtotalFont = UIFont.systemFont(ofSize: 9, weight: .bold)
        let subtotalAttributes: [NSAttributedString.Key: Any] = [.font: subtotalFont, .foregroundColor: UIColor.black]
        drawText("Products Subtotal:", in: CGRect(x: margin + 5, y: yPosition + 4, width: tableWidth - extPriceWidth - profitWidth - 10, height: subtotalRowHeight - 8), withAttributes: subtotalAttributes)
        drawText(Formatters.formatEuro(proposal.subtotalProducts), in: CGRect(x: margin + nameWidth + qtyWidth + unitPriceWidth + discountWidth + 3, y: yPosition + 4, width: extPriceWidth + profitWidth - 6, height: subtotalRowHeight - 8), withAttributes: subtotalAttributes) // UPDATED

        drawLine(from: CGPoint(x: margin, y: yPosition + subtotalRowHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + subtotalRowHeight)) // Bottom
        drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: margin, y: yPosition + subtotalRowHeight)) // Left
        drawLine(from: CGPoint(x: margin + tableWidth, y: yPosition), to: CGPoint(x: margin + tableWidth, y: yPosition + subtotalRowHeight)) // Right

        yPosition += subtotalRowHeight + 20 // Space after table
    }

    // Draw Engineering Table - Apply similar formatting updates
    private static func drawEngineeringTable(context: UIGraphicsPDFRendererContext, proposal: Proposal, yPosition: inout CGFloat, pageRect: CGRect) {
         let margin: CGFloat = 30
         let tableWidth = pageRect.width - (margin * 2)
         let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
         let headerFont = UIFont.systemFont(ofSize: 9, weight: .bold)
         let rowFont = UIFont.systemFont(ofSize: 9)
         let rowAttributes: [NSAttributedString.Key: Any] = [.font: rowFont, .foregroundColor: UIColor.black]
         let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont, .foregroundColor: UIColor.black]

         checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 50, pageRect: pageRect)

         let title = "Engineering"
         let titleSize = title.size(withAttributes: sectionFont.attributes)
         drawText(title, in: CGRect(x: margin, y: yPosition, width: titleSize.width, height: titleSize.height), withAttributes: sectionFont.attributes)
         yPosition += titleSize.height + 10

         let descWidth = tableWidth * 0.55
         let daysWidth = tableWidth * 0.15
         let rateWidth = tableWidth * 0.15
         let amountWidth = tableWidth * 0.15
         let headerHeight: CGFloat = 20

         // Draw header
         let headerRect = CGRect(x: margin, y: yPosition, width: tableWidth, height: headerHeight)
         context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
         context.cgContext.fill(headerRect)
         var xPosition = margin
         drawText("Description", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: descWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
         xPosition += descWidth
         drawText("Days", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: daysWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
         xPosition += daysWidth
         drawText("Rate (€)", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: rateWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes) // UPDATED Header
         xPosition += rateWidth
         drawText("Amount (€)", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: amountWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes) // UPDATED Header
         // Draw header borders... (similar logic as products table)
         drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: margin + tableWidth, y: yPosition)) // Top
         drawLine(from: CGPoint(x: margin, y: yPosition + headerHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + headerHeight)) // Bottom
         // ... draw vertical dividers ...
          xPosition = margin
          drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight)) // Left
          xPosition += descWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
          xPosition += daysWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
          xPosition += rateWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
          xPosition += amountWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight)) // Right


         yPosition += headerHeight

         // Draw rows
         for engineering in proposal.engineeringArray {
             let rowHeight: CGFloat = 20
             checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: rowHeight, pageRect: pageRect)
             xPosition = margin
             drawText(engineering.desc ?? "", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: descWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes)
             xPosition += descWidth
             drawText(String(format: "%.1f", engineering.days), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: daysWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes)
             xPosition += daysWidth
             drawText(Formatters.formatEuro(engineering.rate), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: rateWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED
             xPosition += rateWidth
             drawText(Formatters.formatEuro(engineering.amount), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: amountWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED
             // Draw row borders... (similar logic as products table)
              drawLine(from: CGPoint(x: margin, y: yPosition + rowHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + rowHeight)) // Bottom
              // ... draw vertical dividers ...
              xPosition = margin
              drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight)) // Left
              xPosition += descWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
              xPosition += daysWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
              xPosition += rateWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
              xPosition += amountWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight)) // Right


             yPosition += rowHeight
         }

         // Subtotal
         checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 20, pageRect: pageRect)
         let subtotalRowHeight: CGFloat = 20
         let subtotalRect = CGRect(x: margin, y: yPosition, width: tableWidth, height: subtotalRowHeight)
         context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
         context.cgContext.fill(subtotalRect)
         let subtotalFont = UIFont.systemFont(ofSize: 9, weight: .bold)
         let subtotalAttributes: [NSAttributedString.Key: Any] = [.font: subtotalFont, .foregroundColor: UIColor.black]
         drawText("Engineering Subtotal:", in: CGRect(x: margin + 5, y: yPosition + 4, width: tableWidth - amountWidth - 10, height: subtotalRowHeight - 8), withAttributes: subtotalAttributes)
         drawText(Formatters.formatEuro(proposal.subtotalEngineering), in: CGRect(x: margin + tableWidth - amountWidth + 3, y: yPosition + 4, width: amountWidth - 6, height: subtotalRowHeight - 8), withAttributes: subtotalAttributes) // UPDATED
         // Draw subtotal borders...
         drawLine(from: CGPoint(x: margin, y: yPosition + subtotalRowHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + subtotalRowHeight)) // Bottom
         drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: margin, y: yPosition + subtotalRowHeight)) // Left
         drawLine(from: CGPoint(x: margin + tableWidth, y: yPosition), to: CGPoint(x: margin + tableWidth, y: yPosition + subtotalRowHeight)) // Right


         yPosition += subtotalRowHeight + 20
     }

     // Draw Expenses Table - Apply similar formatting updates
     private static func drawExpensesTable(context: UIGraphicsPDFRendererContext, proposal: Proposal, yPosition: inout CGFloat, pageRect: CGRect) {
         let margin: CGFloat = 30
         let tableWidth = pageRect.width - (margin * 2)
         let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
         let headerFont = UIFont.systemFont(ofSize: 9, weight: .bold)
         let rowFont = UIFont.systemFont(ofSize: 9)
         let rowAttributes: [NSAttributedString.Key: Any] = [.font: rowFont, .foregroundColor: UIColor.black]
         let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont, .foregroundColor: UIColor.black]

         checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 50, pageRect: pageRect)

         let title = "Expenses"
         let titleSize = title.size(withAttributes: sectionFont.attributes)
         drawText(title, in: CGRect(x: margin, y: yPosition, width: titleSize.width, height: titleSize.height), withAttributes: sectionFont.attributes)
         yPosition += titleSize.height + 10

         let descWidth = tableWidth * 0.70
         let amountWidth = tableWidth * 0.30
         let headerHeight: CGFloat = 20

         // Draw header
         let headerRect = CGRect(x: margin, y: yPosition, width: tableWidth, height: headerHeight)
         context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
         context.cgContext.fill(headerRect)
         var xPosition = margin
         drawText("Description", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: descWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
         xPosition += descWidth
         drawText("Amount (€)", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: amountWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes) // UPDATED Header
         // Draw header borders...
          drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: margin + tableWidth, y: yPosition)) // Top
          drawLine(from: CGPoint(x: margin, y: yPosition + headerHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + headerHeight)) // Bottom
          // ... draw vertical dividers ...
           xPosition = margin
           drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight)) // Left
           xPosition += descWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
           xPosition += amountWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight)) // Right

         yPosition += headerHeight

         // Draw rows
         for expense in proposal.expensesArray {
             let rowHeight: CGFloat = 20
             checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: rowHeight, pageRect: pageRect)
             xPosition = margin
             drawText(expense.desc ?? "", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: descWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes)
             xPosition += descWidth
             drawText(Formatters.formatEuro(expense.amount), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: amountWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED
             // Draw row borders...
             drawLine(from: CGPoint(x: margin, y: yPosition + rowHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + rowHeight)) // Bottom
             // ... draw vertical dividers ...
              xPosition = margin
              drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight)) // Left
              xPosition += descWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
              xPosition += amountWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight)) // Right


             yPosition += rowHeight
         }

         // Subtotal
         checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 20, pageRect: pageRect)
         let subtotalRowHeight: CGFloat = 20
         let subtotalRect = CGRect(x: margin, y: yPosition, width: tableWidth, height: subtotalRowHeight)
         context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
         context.cgContext.fill(subtotalRect)
         let subtotalFont = UIFont.systemFont(ofSize: 9, weight: .bold)
         let subtotalAttributes: [NSAttributedString.Key: Any] = [.font: subtotalFont, .foregroundColor: UIColor.black]
         drawText("Expenses Subtotal:", in: CGRect(x: margin + 5, y: yPosition + 4, width: tableWidth - amountWidth - 10, height: subtotalRowHeight - 8), withAttributes: subtotalAttributes)
         drawText(Formatters.formatEuro(proposal.subtotalExpenses), in: CGRect(x: margin + tableWidth - amountWidth + 3, y: yPosition + 4, width: amountWidth - 6, height: subtotalRowHeight - 8), withAttributes: subtotalAttributes) // UPDATED
         // Draw subtotal borders...
          drawLine(from: CGPoint(x: margin, y: yPosition + subtotalRowHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + subtotalRowHeight)) // Bottom
          drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: margin, y: yPosition + subtotalRowHeight)) // Left
          drawLine(from: CGPoint(x: margin + tableWidth, y: yPosition), to: CGPoint(x: margin + tableWidth, y: yPosition + subtotalRowHeight)) // Right


         yPosition += subtotalRowHeight + 20
     }

     // Draw Custom Taxes Table - Apply similar formatting updates
     private static func drawCustomTaxesTable(context: UIGraphicsPDFRendererContext, proposal: Proposal, yPosition: inout CGFloat, pageRect: CGRect) {
         let margin: CGFloat = 30
         let tableWidth = pageRect.width - (margin * 2)
         let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
         let headerFont = UIFont.systemFont(ofSize: 9, weight: .bold)
         let rowFont = UIFont.systemFont(ofSize: 9)
         let rowAttributes: [NSAttributedString.Key: Any] = [.font: rowFont, .foregroundColor: UIColor.black]
         let headerAttributes: [NSAttributedString.Key: Any] = [.font: headerFont, .foregroundColor: UIColor.black]

         checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 50, pageRect: pageRect)

         let title = "Custom Taxes"
         let titleSize = title.size(withAttributes: sectionFont.attributes)
         drawText(title, in: CGRect(x: margin, y: yPosition, width: titleSize.width, height: titleSize.height), withAttributes: sectionFont.attributes)
         yPosition += titleSize.height + 10

         let nameWidth = tableWidth * 0.50
         let rateWidth = tableWidth * 0.25
         let amountWidth = tableWidth * 0.25
         let headerHeight: CGFloat = 20

         // Draw header
         let headerRect = CGRect(x: margin, y: yPosition, width: tableWidth, height: headerHeight)
         context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
         context.cgContext.fill(headerRect)
         var xPosition = margin
         drawText("Tax Name", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: nameWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
         xPosition += nameWidth
         drawText("Rate (%)", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: rateWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes)
         xPosition += rateWidth
         drawText("Amount (€)", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: amountWidth - 6, height: headerHeight - 8), withAttributes: headerAttributes) // UPDATED Header
          // Draw header borders...
          drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: margin + tableWidth, y: yPosition)) // Top
          drawLine(from: CGPoint(x: margin, y: yPosition + headerHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + headerHeight)) // Bottom
           // ... draw vertical dividers ...
            xPosition = margin
            drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight)) // Left
            xPosition += nameWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
            xPosition += rateWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight))
            xPosition += amountWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + headerHeight)) // Right

         yPosition += headerHeight

         // Draw rows
         for tax in proposal.taxesArray {
             let rowHeight: CGFloat = 20
             checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: rowHeight, pageRect: pageRect)
             xPosition = margin
             drawText(tax.name ?? "", in: CGRect(x: xPosition + 3, y: yPosition + 4, width: nameWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes)
             xPosition += nameWidth
             drawText(Formatters.formatPercent(tax.rate), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: rateWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED
             xPosition += rateWidth
             drawText(Formatters.formatEuro(tax.amount), in: CGRect(x: xPosition + 3, y: yPosition + 4, width: amountWidth - 6, height: rowHeight - 8), withAttributes: rowAttributes) // UPDATED
             // Draw row borders...
              drawLine(from: CGPoint(x: margin, y: yPosition + rowHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + rowHeight)) // Bottom
              // ... draw vertical dividers ...
               xPosition = margin
               drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight)) // Left
               xPosition += nameWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
               xPosition += rateWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight))
               xPosition += amountWidth; drawLine(from: CGPoint(x: xPosition, y: yPosition), to: CGPoint(x: xPosition, y: yPosition + rowHeight)) // Right


             yPosition += rowHeight
         }

         // Subtotal
         checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 20, pageRect: pageRect)
         let subtotalRowHeight: CGFloat = 20
         let subtotalRect = CGRect(x: margin, y: yPosition, width: tableWidth, height: subtotalRowHeight)
         context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.2).cgColor)
         context.cgContext.fill(subtotalRect)
         let subtotalFont = UIFont.systemFont(ofSize: 9, weight: .bold)
         let subtotalAttributes: [NSAttributedString.Key: Any] = [.font: subtotalFont, .foregroundColor: UIColor.black]
         drawText("Taxes Subtotal:", in: CGRect(x: margin + 5, y: yPosition + 4, width: tableWidth - amountWidth - 10, height: subtotalRowHeight - 8), withAttributes: subtotalAttributes)
         drawText(Formatters.formatEuro(proposal.subtotalTaxes), in: CGRect(x: margin + tableWidth - amountWidth + 3, y: yPosition + 4, width: amountWidth - 6, height: subtotalRowHeight - 8), withAttributes: subtotalAttributes) // UPDATED
         // Draw subtotal borders...
         drawLine(from: CGPoint(x: margin, y: yPosition + subtotalRowHeight), to: CGPoint(x: margin + tableWidth, y: yPosition + subtotalRowHeight)) // Bottom
         drawLine(from: CGPoint(x: margin, y: yPosition), to: CGPoint(x: margin, y: yPosition + subtotalRowHeight)) // Left
         drawLine(from: CGPoint(x: margin + tableWidth, y: yPosition), to: CGPoint(x: margin + tableWidth, y: yPosition + subtotalRowHeight)) // Right

         yPosition += subtotalRowHeight + 20
     }

    // Draw Financial Summary - Apply similar formatting updates
    private static func drawFinancialSummary(context: UIGraphicsPDFRendererContext, proposal: Proposal, yPosition: inout CGFloat, pageRect: CGRect) {
        let margin: CGFloat = 30
        let tableWidth = pageRect.width - (margin * 2)
        let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let rowFont = UIFont.systemFont(ofSize: 10)
        let rowBoldFont = UIFont.systemFont(ofSize: 10, weight: .bold)
        let rowAttributes: [NSAttributedString.Key: Any] = [.font: rowFont, .foregroundColor: UIColor.black]
        let rowBoldAttributes: [NSAttributedString.Key: Any] = [.font: rowBoldFont, .foregroundColor: UIColor.black]

        checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: 150, pageRect: pageRect) // Estimate height

        let summaryTitle = "Financial Summary"
        let summaryTitleSize = summaryTitle.size(withAttributes: sectionFont.attributes)
        drawText(summaryTitle, in: CGRect(x: margin, y: yPosition, width: summaryTitleSize.width, height: summaryTitleSize.height), withAttributes: sectionFont.attributes)
        yPosition += summaryTitleSize.height + 10

        let summaryWidth = tableWidth / 2
        let labelWidth = summaryWidth * 0.6
        let valueWidth = summaryWidth * 0.4
        let startX = margin + (tableWidth - summaryWidth) / 2
        let labelX = startX + 10
        let valueX = startX + labelWidth

        let rowHeight: CGFloat = 20 // Reduced height for compactness
        let tableRect = CGRect(x: startX, y: yPosition, width: summaryWidth, height: rowHeight * 7) // 7 rows now
        context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.1).cgColor)
        context.cgContext.fill(tableRect)
        drawLine(from: CGPoint(x: startX, y: yPosition), to: CGPoint(x: startX + summaryWidth, y: yPosition)) // Top
        drawLine(from: CGPoint(x: startX, y: tableRect.maxY), to: CGPoint(x: startX + summaryWidth, y: tableRect.maxY)) // Bottom
        drawLine(from: CGPoint(x: startX, y: yPosition), to: CGPoint(x: startX, y: tableRect.maxY)) // Left
        drawLine(from: CGPoint(x: startX + summaryWidth, y: yPosition), to: CGPoint(x: startX + summaryWidth, y: tableRect.maxY)) // Right

        func drawSummaryRow(label: String, value: Double, isBold: Bool = false) {
            let attributes = isBold ? rowBoldAttributes : rowAttributes
            let labelRect = CGRect(x: labelX, y: yPosition, width: labelWidth - 10, height: rowHeight)
            let valueRect = CGRect(x: valueX, y: yPosition, width: valueWidth - 20, height: rowHeight) // Adjusted width for alignment
            drawText(label, in: labelRect.insetBy(dx: 0, dy: (rowHeight - (isBold ? rowBoldFont.lineHeight : rowFont.lineHeight))/2), withAttributes: attributes)
            drawText(Formatters.formatEuro(value), in: valueRect.insetBy(dx: 0, dy: (rowHeight - (isBold ? rowBoldFont.lineHeight : rowFont.lineHeight))/2), withAttributes: attributes) // UPDATED
            yPosition += rowHeight
            if !isBold { // Don't draw line after last regular row
                drawLine(from: CGPoint(x: startX, y: yPosition), to: CGPoint(x: startX + summaryWidth, y: yPosition), color: .lightGray)
            }
        }

        drawSummaryRow(label: "Products Subtotal:", value: proposal.subtotalProducts)
        drawSummaryRow(label: "Engineering Subtotal:", value: proposal.subtotalEngineering)
        drawSummaryRow(label: "Expenses Subtotal:", value: proposal.subtotalExpenses)
        drawSummaryRow(label: "Taxes Subtotal:", value: proposal.subtotalTaxes)
        // Draw thicker divider before TOTAL
        drawLine(from: CGPoint(x: startX, y: yPosition), to: CGPoint(x: startX + summaryWidth, y: yPosition), color: .gray, lineWidth: 1.0)
        drawSummaryRow(label: "TOTAL AMOUNT:", value: proposal.totalAmount, isBold: true)
        drawSummaryRow(label: "Partner Cost:", value: calculatePartnerCost(proposal))
        drawSummaryRow(label: "Profit:", value: proposal.totalAmount - calculatePartnerCost(proposal), isBold: true)

        yPosition += 20 // Space after summary
    }

    // Draw Notes - No currency changes expected
    private static func drawNotes(context: UIGraphicsPDFRendererContext, notes: String, yPosition: inout CGFloat, pageRect: CGRect) {
        let margin: CGFloat = 30
        let width = pageRect.width - (margin * 2)
        let sectionFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let notesFont = UIFont.systemFont(ofSize: 10)
        let notesAttributes: [NSAttributedString.Key: Any] = [.font: notesFont, .foregroundColor: UIColor.black]

        // Calculate text height needed
        let textSize = notes.boundingRect(
            with: CGSize(width: width - 20, height: .greatestFiniteMagnitude), // Subtract padding
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: notesAttributes,
            context: nil
        ).size

        let requiredHeight = textSize.height + 60 // Title + padding + text + padding + space after

        checkPageBreak(context: context, yPosition: &yPosition, requiredHeight: requiredHeight, pageRect: pageRect)

        let notesTitle = "Notes"
        let notesTitleSize = notesTitle.size(withAttributes: sectionFont.attributes)
        drawText(notesTitle, in: CGRect(x: margin, y: yPosition, width: notesTitleSize.width, height: notesTitleSize.height), withAttributes: sectionFont.attributes)
        yPosition += notesTitleSize.height + 10

        let notesRect = CGRect(x: margin, y: yPosition, width: width, height: textSize.height + 20)
        context.cgContext.setFillColor(UIColor.lightGray.withAlphaComponent(0.1).cgColor)
        context.cgContext.fill(notesRect)
        drawLine(from: notesRect.origin, to: CGPoint(x: notesRect.maxX, y: notesRect.minY))
        drawLine(from: CGPoint(x: notesRect.minX, y: notesRect.maxY), to: CGPoint(x: notesRect.maxX, y: notesRect.maxY))
        drawLine(from: notesRect.origin, to: CGPoint(x: notesRect.minX, y: notesRect.maxY))
        drawLine(from: CGPoint(x: notesRect.maxX, y: notesRect.minY), to: CGPoint(x: notesRect.maxX, y: notesRect.maxY))

        let notesTextRect = CGRect(x: margin + 10, y: yPosition + 10, width: width - 20, height: textSize.height)
        drawText(notes, in: notesTextRect, withAttributes: notesAttributes)

        yPosition += notesRect.height + 20 // Space after notes
    }

    // Calculate partner cost - No currency changes needed
    private static func calculatePartnerCost(_ proposal: Proposal) -> Double {
        var totalCost = proposal.itemsArray.reduce(0.0) { total, item in
            total + ((item.product?.partnerPrice ?? 0) * item.quantity)
        }
        totalCost += proposal.subtotalExpenses
        return totalCost
    }

    // Save PDF - No changes needed
    static func savePDF(_ pdfData: Data, fileName: String) -> URL? {
        // ... implementation remains the same ...
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
         let url = documentsDirectory.appendingPathComponent(fileName)
         do {
             try pdfData.write(to: url)
             print("PDF saved to: \(url.path)")
             return url
         } catch {
             print("Error saving PDF: \(error)")
             return nil
         }
    }

    // Preview PDF - No changes needed
    static func previewPDF(_ url: URL) -> UIViewController {
        // ... implementation remains the same ...
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

// Extension for UIFont attributes for cleaner code
extension UIFont {
    var attributes: [NSAttributedString.Key: Any] {
        return [.font: self]
    }
}
