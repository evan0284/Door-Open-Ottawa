//
//  ContentView.swift
//  mappp
//
//  Created by Evans on 2023-11-29.
//

import SwiftUI
import MapKit
import Combine
import CoreLocation
import Firebase



struct ContentView: View {
    @State private var buildings: [Building] = []
//    @State private var favoriteBuilding: [Building] = []
    
    @StateObject var viewModel = LocationModel()
    @StateObject var buildingModel = BuildingViewModel()
    @StateObject var networkMonitor = NetworkMonitor()


    @State private var selectedTab: Tab = .house
    @State private var searchTerm = ""
    
    @State private var showAboutMe: Bool = false

    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationView {
                    BuildingsView()

                }
                .tag(Tab.house)

       
                NavigationView {
                    MapView(buildings: $buildings)
                }
                .tag(Tab.map)
                
                NavigationView {
                    FavoritesView()
                }
                .tag(Tab.star)
                
                NavigationView {
                    MoreView()

                }
                .tag(Tab.gearshape)

            }
            VStack {
                Spacer()
                MyTabBar(selectedTab: $selectedTab)
            }
            .shadow(radius: 1)
            .padding(.horizontal, 20)
        }
        .environmentObject(viewModel)
        .environmentObject(buildingModel)

    }
}


#Preview {
    ContentView()
}
