//
//  OnboardingView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var showTutorial = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("OnboardingImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 250)
            
            Text("In a hurry?")
                .font(.system(size: 36, weight: .bold))
            
            Text("B-Link will help you in navigation\nthrough BSD Link!")
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                showTutorial = true
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color(red: 0/255, green: 74/255, blue: 173/255))
                    .cornerRadius(10)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView()
        }
    }
}

#Preview {
    OnboardingView()
}


