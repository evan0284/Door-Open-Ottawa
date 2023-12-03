//
//  MapView.swift
//  mappp
//
//  Created by Evans on 2023-12-03.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @Binding var buildings: [Building]
    
    @EnvironmentObject var viewModel:LocationModel
    @EnvironmentObject var buildingModel: BuildingViewModel

    @State private var selectedBuilding: Building? = nil
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    
    var body: some View {
        NavigationView {
            Map(position: $position) {
                ForEach(buildingModel.filteredBuildings()) { building in
                    let coordinate = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)

                    Annotation(building.name, coordinate: coordinate){
                        mapCategory(building.categoryId)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                selectedBuilding = building
                            }

                    }
                    
                }
            }
            .onAppear(){
                CLLocationManager().requestWhenInUseAuthorization()
            }

            .mapControls() {
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
            .overlay(
                selectedBuilding.map { building in
                        HStack(alignment: .top) {
                                            NavigationLink(
                                                destination: BuildingDetail(building: building)
                                                    .navigationBarBackButtonHidden(true)
                                                    .navigationBarHidden(true)
                                            ){
                                                HStack {
                                                    HStack {
                                                        
                                                        Text(building.name)
                                                            .font(.footnote)
                                                            .foregroundColor(.black)
                                                            .padding(8)
                                                        
                                                        Image(systemName: "info.circle.fill")
                                                            .foregroundColor(.white)
                                                            .font(.title)
                                                            .padding(8)
                                                            .background(Color.blue)
                                                            .cornerRadius(8)
                                                        
                                                    }
                                                }
                                            }
                            
                            VStack(alignment: .leading) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.black)
                                    .font(.title3)
                                    .opacity(0.2)
                                    .onTapGesture {
                                        selectedBuilding = nil
                                    }
                            }
                        }

                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(12)

                }
        )
        }

    }
    
    private func mapCategory(_ categoryId: Int) -> Image {
        switch categoryId {
        case 0:
            return Image("newReligionFilterMap")
        case 1:
            return Image("mapEmbassy")
        case 2:
            return Image("mapGovernement")
        case 3:
            return Image("mapFunctional")
        case 4:
            return Image("mapGalleries")
        case 5:
            return Image("mapAcademic")
        case 6:
            return Image("mapSports")
        case 7:
            return Image("mapCommunity")
        case 8:
            return Image("mapBusiness")
        case 9:
            return Image("mapMuseum")
        case 10:
            return Image("mapOther")
        default:
            return Image("questionmark")
        }
    }

}

