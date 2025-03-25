//
//  BusScheduleView.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import SwiftUI

struct BusScheduleView: View {
    let bus: Bus
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Route badge
            Text(bus.routeCode)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(15)
                .padding(.top)
            
            // Route name
            Text(bus.routeName)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Bus schedule
            Text("Bus Schedule")
                .font(.headline)
                .padding(.top)
            
            // Schedule times
            VStack {
                scheduleRow(time: "09:45", destination: "GOP")
                scheduleRow(time: "10:30", destination: "AEON")
                scheduleRow(time: "11:00", destination: "ICE 6")
            }
            .padding()
            
            // Route label
            Text("Route")
                .font(.headline)
            
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
    
    private func scheduleRow(time: String, destination: String) -> some View {
        HStack {
            Text(time)
                .font(.body)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            Text(destination)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}
