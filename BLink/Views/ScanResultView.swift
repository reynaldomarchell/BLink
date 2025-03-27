//
//  ScanResultView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI
import SwiftData

struct ScanResultView: View {
    let plateNumber: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var busRoutes: [BusRoute]
    
    // Simulated data for the view
    private var routeInfo: (code: String, name: String, color: String) {
        // In a real app, this would come from the database based on the plate number
        return ("BC", "Greenwich Park - Halte Sektor 1.3", "purple")
    }
    
    private var stations: [Station] {
        // Simulated stations data
        return [
            Station(name: "CBD Barat", arrivalTime: createTime(hour: 9, minute: 26), isCurrentStation: false, isPreviousStation: true, isNextStation: false),
            Station(name: "CBD Timur", arrivalTime: createTime(hour: 9, minute: 30), isCurrentStation: true, isPreviousStation: false, isNextStation: false),
            Station(name: "Lobby AEON Mall", arrivalTime: createTime(hour: 9, minute: 36), isCurrentStation: false, isPreviousStation: false, isNextStation: true),
            Station(name: "Lobby AEON 1", arrivalTime: createTime(hour: 9, minute: 38), isCurrentStation: false, isPreviousStation: false, isNextStation: false),
            Station(name: "Lobby AEON 1", arrivalTime: createTime(hour: 9, minute: 38), isCurrentStation: false, isPreviousStation: false, isNextStation: false),
            Station(name: "Lobby AEON 1", arrivalTime: createTime(hour: 9, minute: 38), isCurrentStation: false, isPreviousStation: false, isNextStation: false)
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .padding()
            }
            
            // Route code badge
            ZStack {
                Circle()
                    .fill(colorFromString(routeInfo.color))
                    .frame(width: 50, height: 50)
                
                Text(routeInfo.code)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 10)
            
            // Route name
            Text(routeInfo.name)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Loop Line")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            
            // Stations list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(stations.enumerated()), id: \.offset) { index, station in
                        StationRow(station: station, isLast: index == stations.count - 1)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding()
            }
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .onAppear {
            // Save the bus info to the database
            saveBusInfo()
        }
    }
    
    private func saveBusInfo() {
        let busInfo = BusInfo(
            plateNumber: plateNumber,
            routeCode: routeInfo.code,
            routeName: routeInfo.name
        )
        modelContext.insert(busInfo)
    }
    
    private func createTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components) ?? Date()
    }
    
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        default: return .gray
        }
    }
}

struct StationRow: View {
    let station: Station
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Station indicator and line
            VStack(spacing: 0) {
                Circle()
                    .fill(stationColor)
                    .frame(width: 20, height: 20)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: 3)
                        .frame(height: 40)
                }
            }
            
            // Station info
            VStack(alignment: .leading, spacing: 2) {
                if station.isPreviousStation {
                    Text("Previous station")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if station.isCurrentStation {
                    Text("Current station")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if station.isNextStation {
                    Text("Next station")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(station.name)
                    .font(.headline)
            }
            .padding(.vertical, 5)
            
            Spacer()
            
            // Arrival time
            if let time = station.arrivalTime {
                Text(timeFormatter.string(from: time))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
    
    private var stationColor: Color {
        if station.isPreviousStation {
            return .purple.opacity(0.5)
        } else if station.isCurrentStation {
            return .purple
        } else if station.isNextStation {
            return .purple
        } else {
            return .purple
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm"
        return formatter
    }
}

#Preview {
    ScanResultView(plateNumber: "S11 BSD")
}

