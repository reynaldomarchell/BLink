//
//  SplashView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            OnboardingView()
        } else {
            VStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(24)
                
                Text("B-Link")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color.orange)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

