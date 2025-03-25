//
//  TutorialView.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Text("How To Scan")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    Text("1.")
                        .fontWeight(.bold)
                    Text("Point your camera at the front of the bus to capture the plate number")
                }
                
                HStack(alignment: .top) {
                    Text("2.")
                        .fontWeight(.bold)
                    Text("Hold steady until the app recognizes the bus")
                }
                
                HStack(alignment: .top) {
                    Text("3.")
                        .fontWeight(.bold)
                    Text("The app will show you if this bus goes to your destination")
                }
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Text("Let's go!")
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
