//
//  ResultFailureView.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import SwiftUI

struct ResultFailureView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Failure message
            HStack {
                Text("This bus doesn't go to your destination")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Image(systemName: "face.dashed")
                    .font(.title3)
                    .foregroundColor(.orange)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // Suggestion
            Text("You can wait for another bus to come")
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
