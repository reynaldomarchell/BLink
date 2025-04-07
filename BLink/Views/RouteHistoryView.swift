//
//  RouteHistoryView.swift
//  BLink
//
//  Created by reynaldo on 06/04/25.
//

import SwiftUI
import SwiftData

struct RouteHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \BusInfo.lastSeen, order: .reverse) private var recentBuses: [BusInfo]
    
    var onSelectBus: (String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Recently Scanned Buses")) {
                    if recentBuses.isEmpty {
                        Text("No recent bus scans")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(recentBuses) { busInfo in
                            Button(action: {
                                onSelectBus(busInfo.plateNumber)
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(busInfo.plateNumber)
                                            .font(.headline)
                                        
                                        HStack {
                                            RouteCodeBadge(routeCode: busInfo.routeCode)
                                            
                                            Text(busInfo.routeName)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text(timeAgo(date: busInfo.lastSeen))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationBarTitle("Bus History", displayMode: .inline)
            .navigationBarItems(leading: Button("Close") {
                dismiss()
            })
        }
    }
    
    private func timeAgo(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct RouteCodeBadge: View {
    let routeCode: String
    
    var body: some View {
        Text(routeCode)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(routeCodeColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(routeCodeColor.opacity(0.2))
            .cornerRadius(4)
    }
    
    private var routeCodeColor: Color {
        switch routeCode {
        case "BC":
            return .purple
        case "GS":
            return .green
        case "AS":
            return Color(red: 34/255, green: 139/255, blue: 34/255)
        case "ID1":
            return Color(red: 64/255, green: 224/255, blue: 208/255)
        case "ID2":
            return Color(red: 219/255, green: 112/255, blue: 147/255)
        case "IV":
            return Color(red: 154/255, green: 205/255, blue: 50/255)
        default:
            return .blue
        }
    }
}

#Preview {
    RouteHistoryView(onSelectBus: { _ in })
}

