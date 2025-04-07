//
//  SavedLocationView.swift
//  BLink
//
//  Created by reynaldo on 06/04/25.
//

import SwiftUI
import SwiftData

struct SavedLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedLocations: [SavedLocation]
    
    @State private var newLocationName = ""
    @State private var newLocationAddress = ""
    @State private var isAddingLocation = false
    
    var onSelectLocation: (String) -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Saved Locations")) {
                    ForEach(savedLocations) { location in
                        Button(action: {
                            onSelectLocation(location.address)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: location.isHome ? "house.fill" : "mappin.circle.fill")
                                    .foregroundColor(location.isHome ? .blue : .orange)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(location.name)
                                        .font(.headline)
                                    
                                    Text(location.address)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .onDelete(perform: deleteLocation)
                }
                
                if isAddingLocation {
                    Section(header: Text("Add New Location")) {
                        TextField("Location Name", text: $newLocationName)
                        TextField("Address", text: $newLocationAddress)
                        
                        HStack {
                            Button("Cancel") {
                                isAddingLocation = false
                                newLocationName = ""
                                newLocationAddress = ""
                            }
                            .foregroundColor(.red)
                            
                            Spacer()
                            
                            Button("Save") {
                                addNewLocation()
                            }
                            .disabled(newLocationName.isEmpty || newLocationAddress.isEmpty)
                        }
                    }
                }
            }
            .navigationBarTitle("Saved Locations", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button(action: {
                    isAddingLocation.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
        }
    }
    
    private func addNewLocation() {
        let newLocation = SavedLocation(
            name: newLocationName,
            address: newLocationAddress,
            isHome: savedLocations.isEmpty // First location is home by default
        )
        
        modelContext.insert(newLocation)
        
        // Reset form
        newLocationName = ""
        newLocationAddress = ""
        isAddingLocation = false
    }
    
    private func deleteLocation(at offsets: IndexSet) {
        for index in offsets {
            let location = savedLocations[index]
            modelContext.delete(location)
        }
    }
}

#Preview {
    SavedLocationView(onSelectLocation: { _ in })
}
