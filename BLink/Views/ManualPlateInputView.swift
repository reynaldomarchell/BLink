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
                
                TextField("e.g., S11 BSD", text: $plateNumber)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    if !plateNumber.isEmpty {
                        onSubmit(plateNumber)
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
            .navigationBarTitle("Manual Input", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}

#Preview {
    ManualPlateInputView(onSubmit: { _ in })
}

