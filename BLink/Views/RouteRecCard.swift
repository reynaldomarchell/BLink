//
//  RouteRecCard.swift
//  BLink
//
//  Created by Naspad Studio on 28/03/25.
//

import Foundation
import SwiftUI

struct RouteRecCard {
    let from: String
    let to: String
    let routeCode: String
    let description: String
    let duration: Int
    let distance: Double
    let onTap: () -> Void
}

struct RouteRecCardView: View {
    let card: RouteRecCard

    var body: some View {
        Button(action: card.onTap) {
            VStack(alignment: .leading, spacing: 10) {
                // Route title
                HStack {
                    Text(card.from)
                        .foregroundColor(.blue)

                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)

                    Text(card.to)
                        .foregroundColor(.blue)
                }
                .font(.headline)

                // Route details
                HStack {
                    ZStack {
                        Capsule()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 36, height: 24)

                        Text(card.routeCode)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }

                    Text(card.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Duration and distance
                HStack(spacing: 20) {
                    Label("\(card.duration) Minutes", systemImage: "clock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Label("\(String(format: "%.1f", card.distance)) Km", systemImage: "figure.walk")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RouteRecCardView_Previews: PreviewProvider {
    static var previews: some View {
        RouteRecCardView(card: RouteRecCard(
            from: "GOP9",
            to: "GreenCove",
            routeCode: "BS",
            description: "BSD Test",
            duration: 60,
            distance: 6.9,
            onTap: {}
        ))
    }
}
