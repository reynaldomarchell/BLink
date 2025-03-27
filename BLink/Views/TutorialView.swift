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
        TutorialContent(isPresented: $showHomeView)
            .fullScreenCover(isPresented: $showHomeView) {
                HomeView()
            }
    }
}

struct TutorialContent: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("How To Use")
                .padding(8)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(alignment: .bottom)
            Text("B-Link Bus Scanner")
                .padding(.bottom, 18)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 237/255, green: 100/255, blue: 0/255))
            
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    Text("1.")
                    Text("Point your camera at the front of the bus to capture the plate number")
                        .padding(.leading, 10)
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                .padding()
                .background(Color(.white))
                .cornerRadius(12)
                
                HStack(alignment: .top) {
                    Text("2.")
                    Text("Hold steady until the app recognizes the bus")
                        .padding(.leading, 10)
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                .padding()
                .background(Color(.white))
                .cornerRadius(12)
                
                HStack(alignment: .top) {
                    Text("3.")
                    Text("The app will show you if this bus goes to your destination")
                        .padding(.leading, 10)
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
                .padding()
                .background(Color(.white))
                .cornerRadius(12)
            }
            
            Spacer()
            
            Button(action: {
                isPresented = true
            }) {
                Text("Continue")
                    .fontWeight(.medium)
                    .padding()
                    .frame(width: 120, height: 45)
                    .foregroundColor(.white)
                    .background(Color(red: 0/255, green: 74/255, blue: 173/255))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .background(Color(red: 245/255, green: 245/255, blue: 245/255))
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    TutorialView()
}

