//
//  ResultSuccessView.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import SwiftUI

struct ResultSuccessView: View {
    let bus: Bus
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Success message
            HStack {
                Text("Hooray! This is your bus!")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Image(systemName: "bus.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            }
            
            // Arrival time
            Text("Approximately, you'll arrive in 10 minutes")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Route label
            Text("Route")
                .font(.headline)
                .padding(.top)
            
            // Map placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .overlay(
                    Text("Map")
                        .foregroundColor(.gray)
                )
                .cornerRadius(10)
                .padding(.horizontal)
            
            Spacer()
            
            // Bus details (could expand this section)
            VStack(alignment: .leading) {
                Text("Bus Details:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Plate Number: \(bus.plateNumber)")
                    .font(.caption)
                
                Text("Bus Number: \(bus.busNumber)")
                    .font(.caption)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Dismiss button
            Button(action: {
                isPresented = false
            }) {
                Text("Got it!")
                    .fontWeight(.medium)
                    .padding()
                    .frame(width: 200)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding(.bottom, 40)
        }
        .padding()
    }
}
