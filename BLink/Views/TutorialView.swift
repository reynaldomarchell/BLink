//
//  TutorialView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI

struct TutorialView: View {
    @State private var showHomeView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("How to use")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 40)
            
            Text("B-Link Bus Scanner")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.orange)
                .padding(.bottom, 20)
            
            TutorialStep(number: 1, title: "Allow Camera Use", description: "We need camera permission on your device")
                .padding(.vertical, 10)
            
            TutorialStep(number: 2, title: "Point to bus", description: "Point your camera to bus plate number")
                .padding(.vertical, 10)
            
            TutorialStep(number: 3, title: "See the route!", description: "You can see the schedule and route of scanned bus")
                .padding(.vertical, 10)
            
            Spacer()
            
            Button(action: {
                showHomeView = true
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 40)
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showHomeView) {
            HomeView()
        }
    }
}

struct TutorialStep: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Text("\(number)")
                .font(.system(size: 32, weight: .bold))
                .frame(width: 40, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    TutorialView()
}

