//
//  LocationModel.swift
//  mappp
//
//  Created by Evans on 2023-12-03.
//

import Foundation
import MapKit

class LocationModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var favoriteBuilding: [Building] = []
    @Published var buildings: [Building] = []
//    @EnvironmentObject var buildingModel: BuildingViewModel
    
    @Published var yourLocation = CLLocationManager()
    @Published var userLocation: CLLocation?
    
    

    override init() {
        super.init()
        setupLocationManager()
        UITabBar.appearance().isHidden = true

    }

    private func setupLocationManager() {
        print("ask")
        yourLocation.delegate = self
        yourLocation.requestWhenInUseAuthorization()
        yourLocation.startUpdatingLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            objectWillChange.send()
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }

    func isFavorite(building: Building) -> Bool {
        return favoriteBuilding.contains { $0.buildingId == building.buildingId }
    }
    
        func toggleFavorite(building: Building) {
            if isFavorite(building: building) {
                favoriteBuilding.removeAll { $0.buildingId == building.buildingId }
            } else {
                favoriteBuilding.append(building)
            }
        }

    func calculateDistance(to building: Building) -> String {
        print("calculate")

        guard let userLocation = userLocation?.coordinate else {
            return " "
        }

        let buildingLocation = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)

        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let buildingCLLocation = CLLocation(latitude: buildingLocation.latitude, longitude: buildingLocation.longitude)

        let distanceInMeters = userCLLocation.distance(from: buildingCLLocation)
        let distanceInKilometers = distanceInMeters / 1000.0

        let distanceString = String(format: "%.1f", distanceInKilometers)

        return distanceString
    }
}
