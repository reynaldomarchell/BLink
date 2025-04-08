//
//  ManualPlateInputView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import SwiftData

struct ManualPlateInputView: View {
    @State private var plateNumber = ""
    @Environment(\.dismiss) private var dismiss
    @Query private var busInfos: [BusInfo]
    var onSubmit: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select The \nBus Plate Number")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Replace the text field with a picker
                Picker("Bus Plate Number", selection: $plateNumber) {
                    Text("Select a plate").tag("")
                    ForEach(busInfos, id: \.plateNumber) { busInfo in
                        Text(busInfo.plateNumber).tag(busInfo.plateNumber)
                    }
                }
                .pickerStyle(.wheel) // You can change this to .menu if preferred
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Button(action: {
                    if !plateNumber.isEmpty {
                        // Normalize the plate number before submitting
                        let normalizedPlate = normalizePlateNumber(plateNumber)
                        onSubmit(normalizedPlate)
                        dismiss()
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
    
    // Keep your existing normalizePlateNumber function
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
    // For the preview to work with SwiftData, you need to provide a model container
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: BusInfo.self, configurations: config)
        
        // Add some sample data for the preview
        let sampleBusInfo = BusInfo(plateNumber: "B 1234 XYZ", routeCode: "BC", routeName: "Sample Route")
        container.mainContext.insert(sampleBusInfo)
        
        return ManualPlateInputView(onSubmit: { _ in })
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
