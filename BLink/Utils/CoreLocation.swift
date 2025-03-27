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
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                var address = ""
                if let name = placemark.name {
                    address += name
                }
                if let street = placemark.thoroughfare {
                    address += " | \(street)"
                }
                DispatchQueue.main.async {
                    self.currentAddress = address
                }
            }
        }
    }
}
