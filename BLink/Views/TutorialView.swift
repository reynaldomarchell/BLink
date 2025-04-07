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
                .foregroundColor(.black)
            Text("BLink Bus Scanner")
                .font(.largeTitle)
                .foregroundColor(Color("BlueColor"))
                .padding(.bottom, 18)
                .fontWeight(.semibold)
            HStack(alignment: .center, spacing: 16) {
                Text("1")
                    .font(.system(size: 32, weight: .medium)) // Large step number
                    .padding(.leading, 16)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Point to bus")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text("Point your camera to the bus plate number")
                        .font(.body)
                        .foregroundColor(.black)
                }
                .padding(.trailing, 16)
                
                Spacer()
            }
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            HStack(alignment: .center, spacing: 16) {
                Text("2")
                    .font(.system(size: 32, weight: .medium)) // Large step number
                    .padding(.leading, 16)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Click the white button")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text("This will let us scan the bus plate number")
                        .font(.body)
                        .foregroundColor(.black)
                }
                .padding(.trailing, 16)
                
                Spacer()
            }
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            HStack(alignment: .center, spacing: 16) {
                Text("3")
                    .font(.system(size: 32, weight: .medium)) // Large step number
                    .padding(.leading, 16)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("See the route!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Text("You can see the schedule and the route of the bus here!")
                        .font(.body)
                        .foregroundColor(.black)
                    
                }
                .padding(.trailing, 16)
                
                Spacer()
            }
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 16)
            Spacer()
            
            Button(action: {
                //Buat loop ke home cuy :D - Danke Will
                isPresented.toggle()
            }) {
                Text("Continue")
                    .fontWeight(.medium)
                    .padding()
                    .frame(width: 120, height: 45)
                    .foregroundColor(.white)
                    .background(Color("BlueColor"))
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

