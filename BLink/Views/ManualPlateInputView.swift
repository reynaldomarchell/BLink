//
//  ManualPlateInputView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI

struct ManualPlateInputView: View {
    @State private var plateNumber = ""
    @Environment(\.dismiss) private var dismiss
    var onSubmit: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Bus Plate Number")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextField("e.g. B 1234 XYZ", text: $plateNumber)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .autocapitalization(.allCharacters) // Auto-capitalize input
                
                Text("Examples: B 7366 JE, B7366JE, b 7366 je")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Button(action: {
                    if !plateNumber.isEmpty {
                        // Normalize the plate number before submitting
                        let normalizedPlate = normalizePlateNumber(plateNumber)
                        onSubmit(normalizedPlate)
                    }
                }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(plateNumber.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(plateNumber.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    // Function to normalize plate number format
    private func normalizePlateNumber(_ plate: String) -> String {
        // Convert to uppercase
        let uppercased = plate.uppercased()
        
        // Extract only alphanumeric characters
        let alphanumeric = uppercased.filter { $0.isLetter || $0.isNumber }
        
        // Try to format as standard Indonesian plate: B 1234 XYZ
        if alphanumeric.count >= 3 {
            // Extract the region code (first 1-2 letters)
            var index = alphanumeric.startIndex
            var regionCode = ""
            
            while index < alphanumeric.endIndex && alphanumeric[index].isLetter {
                regionCode.append(alphanumeric[index])
                index = alphanumeric.index(after: index)
                if regionCode.count >= 2 { break } // Maximum 2 letters for region code
            }
            
            // Extract the numbers
            var numbers = ""
            while index < alphanumeric.endIndex && alphanumeric[index].isNumber {
                numbers.append(alphanumeric[index])
                index = alphanumeric.index(after: index)
                if numbers.count >= 4 { break } // Maximum 4 digits for numbers
            }
            
            // Extract the identifier (remaining letters)
            var identifier = ""
            while index < alphanumeric.endIndex && alphanumeric[index].isLetter {
                identifier.append(alphanumeric[index])
                index = alphanumeric.index(after: index)
                if identifier.count >= 3 { break } // Maximum 3 letters for identifier
            }
            
            // Format with proper spacing
            if !regionCode.isEmpty && !numbers.isEmpty {
                if !identifier.isEmpty {
                    return "\(regionCode) \(numbers) \(identifier)"
                } else {
                    return "\(regionCode) \(numbers)"
                }
            }
        }
        
        // If we can't parse it properly, return the original uppercase version
        return uppercased
    }
}

#Preview {
    ManualPlateInputView(onSubmit: { _ in })
}
