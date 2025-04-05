//
//  CoreLocation.swift
//  BLink
//
//  Created by Naspad Studio on 27/03/25.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
   private let manager = CLLocationManager()
   
   @Published var currentAddress: String = ""
   @Published var isLoading: Bool = false
   private var hasRequestedLocation = false
   
   override init() {
       super.init()
       manager.delegate = self
       manager.desiredAccuracy = kCLLocationAccuracyBest
       manager.requestWhenInUseAuthorization()
   }
   
   func requestLocation() {
       if hasRequestedLocation {
           return
       }
       
       hasRequestedLocation = true
       isLoading = true
       manager.requestLocation()
   }

   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       guard let location = locations.last else {
           isLoading = false
           return
       }

       CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
           DispatchQueue.main.async {
               self?.isLoading = false
               
               if let error = error {
                   print("Geocoding error: \(error.localizedDescription)")
                   return
               }
               
               if let placemark = placemarks?.first {
                   var address = ""
                   if let name = placemark.name {
                       address += name
                   }
                   if let street = placemark.thoroughfare {
                       address += " | \(street)"
                   }
                   if !address.isEmpty {
                       self?.currentAddress = address
                   }
               }
           }
       }
   }
   
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       print("Location error: \(error.localizedDescription)")
       DispatchQueue.main.async {
           self.isLoading = false
       }
   }
}

