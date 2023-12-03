//
//  SortSheetView.swift
//  mappp
//
//  Created by Evans on 2023-12-03.
//

import Foundation
import SwiftUI

struct SortSheetView: View {
    var onClose: () -> Void
    @EnvironmentObject var buildingModel: BuildingViewModel

    
    var body: some View {
        ScrollView {
            VStack {
                HStack() {
                    Text("Category")
                        .font(.headline)

                    Spacer()
                    Picker("Category", selection: $buildingModel.selectedCategoryFilter) {
                        Text("All Categories").tag(nil as Int?)
                        ForEach([0,1,2,3,4,5,6,7,8,9,10], id: \.self) { categoryId in
                            Text(buildingModel.categoryName(for: categoryId)).tag(categoryId as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()

                Divider()

                
                HStack {
                    Text("Sort By")
                        .font(.headline)
                    Spacer()

                    Picker("Sort By", selection: $buildingModel.selectedSortOption) {
                        ForEach(BuildingViewModel.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                
                Divider()



                VStack {
                    HStack() {
                        Text("Building Features")
                            .font(.headline)
                        Spacer()

                    }
                    Toggle("Shuttle", isOn: $buildingModel.isShuttleFilter)
                    Toggle("Public Washrooms", isOn: $buildingModel.isPublicWashroomsFilter)

                    Toggle("Accessible", isOn: $buildingModel.isAccessibleFilter)

                    Toggle("Free Parking", isOn: $buildingModel.isFreeParkingFilter)

                    Toggle("Bike Parking", isOn: $buildingModel.isBikeParkingFilter)

                    Toggle("Paid Parking", isOn: $buildingModel.isPaidParkingFilter)
           
                    Toggle("Guided Tour", isOn: $buildingModel.isGuidedTourFilter)

                    Toggle("Family Friendly", isOn: $buildingModel.isFamilyFriendlyFilter)

                    Toggle("New", isOn: $buildingModel.isNewFilter)
                }
                .padding()




                HStack {
                    Button("Reset") {
                        buildingModel.resetFilters()
                    }
                    .font(.headline)

                    Spacer()

                    Button("Confirm") {
                        buildingModel.sortBuildings()
                        onClose()
                    }
                    .foregroundColor(.white)
                    .padding(12)
                    .font(.headline)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding()
                                
            }
            .padding()
        }
    }
    
}
