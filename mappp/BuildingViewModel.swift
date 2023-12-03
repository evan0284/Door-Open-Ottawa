//
//  BuildingViewModel.swift
//  mappp
//
//  Created by Evans on 2023-12-03.
//

import Foundation
import CoreLocation
import MapKit

class BuildingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var buildings: [Building] = []
//    @EnvironmentObject var viewModel: LocationModel
    

    @Published var isShuttleFilter = false
    @Published var isPublicWashroomsFilter = false
    @Published var isAccessibleFilter = false
    @Published var isFreeParkingFilter = false
    @Published var isBikeParkingFilter = false
    @Published var isPaidParkingFilter = false
    @Published var isGuidedTourFilter = false
    @Published var isFamilyFriendlyFilter = false
    @Published var isNewFilter = false
    
    @Published var selectedCategoryFilter: Int? = nil

    
    enum SortOption: String, CaseIterable {
        case alphabetical = "Alphabetical"
        case distance = "Distance"
    }


    @Published var selectedSortOption: SortOption = .alphabetical
    
    @Published var selectedLanguage: String = "en"

   
    func fetchData() {
        print("Fetching data...")

        if let url = Bundle.main.url(forResource: "buildings", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let result = try decoder.decode([BuildingData].self, from: data)

                let filteredBuildings = result.first(where: { $0.language == selectedLanguage })?.buildings ?? []

                self.buildings = filteredBuildings

                for building in buildings {
                    print("Fetched Building: \(building.name)")
                }
            } catch {
                print("Error loading JSON: \(error)")
            }
        } else {
            print("URL for buildings.json is nil")
        }
    }
    
    func toggleLanguage() {
        if selectedLanguage == "en" {
            selectedLanguage = "fr"
        } else {
            selectedLanguage = "en"
        }

        fetchData()
    }

    
    func categoryName(for categoryId: Int) -> String {
        switch categoryId {
        case 0:
            return "Religious buildings"
        case 1:
            return "Embassies"
        case 2:
            return "Government buildings"
        case 3:
            return "Functional buildings"
        case 4:
            return "Galleries and Theatres"
        case 5:
            return "Academic Institutions"
        case 6:
            return "Sports and Leisure buildings"
        case 7:
            return "Community and/or Care centres"
        case 8:
            return "Business and/or Foundations"
        case 9:
            return "Museums, Archives and Historic Sites"
        case 10:
            return "Other"
        default:
            return "Unknown Category"
        }
    }

    func sortBuildings() {
        print("Sorting buildings...")

        buildings = sortedBuildings()

    }

    func sortedBuildings() -> [Building] {
        switch selectedSortOption {
        case .alphabetical:
            return buildings.sorted { $0.name < $1.name }
        case .distance:
            return buildings.sorted { $0.name < $1.name }

//            return buildings.sorted { LocationModel().calculateDistance(to: $0) < viewModel.calculateDistance(to: $1) }
            
        }
    }
    
    func filteredBuildings() -> [Building] {
        buildings.filter { building in
            let shuttleFilter = !isShuttleFilter || building.isShuttle
            let publicWashroomsFilter = !isPublicWashroomsFilter || building.isPublicWashrooms
            let accessibleFilter = !isAccessibleFilter || building.isAccessible
            let freeParkingFilter = !isFreeParkingFilter || building.isFreeParking
            let bikeParkingFilter = !isBikeParkingFilter || building.isBikeParking
            let paidParkingFilter = !isPaidParkingFilter || building.isPaidParking
            let guidedTourFilter = !isGuidedTourFilter || building.isGuidedTour
            let familyFriendlyFilter = !isFamilyFriendlyFilter || building.isFamilyFriendly
            
            
            let newFilter = !isNewFilter || building.isNew

            let categoryFilter = selectedCategoryFilter == nil || building.categoryId == selectedCategoryFilter

            
            
            return shuttleFilter &&
                publicWashroomsFilter &&
                accessibleFilter &&
                freeParkingFilter &&
                bikeParkingFilter &&
                paidParkingFilter &&
                guidedTourFilter &&
                familyFriendlyFilter &&
                newFilter &&
                categoryFilter
        }
    }
    
    func resetFilters() {
        isShuttleFilter = false
        isPublicWashroomsFilter = false
        isAccessibleFilter = false
        isFreeParkingFilter = false
        isBikeParkingFilter = false
        isPaidParkingFilter = false
        isGuidedTourFilter = false
        isFamilyFriendlyFilter = false
        isNewFilter = false
        selectedCategoryFilter = nil

        sortBuildings()
    }
    
}
