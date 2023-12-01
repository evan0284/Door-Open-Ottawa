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


struct ContentView: View {
    @State private var buildings: [Building] = []
    @State private var favoriteBuilding: [Building] = []
    
    @StateObject private var viewModel = LocationModel()
    @StateObject private var buildingModel = BuildingViewModel()
    
    @State private var selectedTab: Tab = .house
    @State private var searchTerm = ""
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationView {
                    BuildingsView()
                        .environmentObject(viewModel)
                        .environmentObject(buildingModel)

                }
                .tag(Tab.house)

//                .tabItem {
//                    Image(systemName: "house")
//                    Text("Buildings")
//                }
       
                NavigationView {
                    MapView(buildings: $buildings)
                        .environmentObject(viewModel)
                }
//                .tabItem {
//                    Image(systemName: "map")
//                    Text("Map")
//                }
                .tag(Tab.map)
                
                NavigationView {
                    FavoritesView()
                        .environmentObject(viewModel)
                }
//                .tabItem {
//                    Image(systemName: "star")
//                    Text("Favorites")
//                }
                .tag(Tab.star)

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


class LocationModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var favoriteBuilding: [Building] = []
    @Published var buildings: [Building] = []
    
    private var yourLocation = CLLocationManager()
    var userLocation: CLLocation?
    

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

class BuildingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var buildings: [Building] = []
    @EnvironmentObject var viewModel: LocationModel
    
    
    enum SortOption: String, CaseIterable {
        case alphabetical = "Alphabetical"
        case distance = "Distance"
    }
    // Sorting
    @Published var selectedSortOption: SortOption = .alphabetical
    
    // Filters
    @Published var isShuttleFilter = false
    @Published var isPublicWashroomsFilter = false

    func fetchData() {
        print("Fetching data...")

        if let url = Bundle.main.url(forResource: "buildings", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let result = try decoder.decode([BuildingData].self, from: data)
                self.buildings = result.flatMap { $0.buildings }

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

    func sortBuildings() {
        print("Sorting buildings...")

        buildings = sortedBuildings()
    }

    // Use the existing fetchData method

    func sortedBuildings() -> [Building] {
        switch selectedSortOption {
        case .alphabetical:
            return buildings.sorted { $0.name < $1.name }
        case .distance:
            // Implement sorting by distance based on user's location
            // You may want to update your BuildingViewModel to handle distance calculation
            return buildings.sorted { viewModel.calculateDistance(to: $0) < viewModel.calculateDistance(to: $1) }

        }
    }
    
    func filteredBuildings() -> [Building] {
        buildings.filter { building in
            let shuttleFilter = !isShuttleFilter || building.isShuttle
            let publicWashroomsFilter = !isPublicWashroomsFilter || building.isPublicWashrooms
            // Add similar filters for other features

            return shuttleFilter &&
                publicWashroomsFilter

        }
    }
    
}

struct BuildingsView: View {
    
    @EnvironmentObject var viewModel: LocationModel
    @EnvironmentObject var buildingModel: BuildingViewModel
    
    
    @State private var searchTerm = ""
    
    @State private var showSortSheet = false

    
    var body: some View {
        NavigationStack{
            VStack {
//                Color(.gray.opacity(0.1))
//                    .edgesIgnoringSafeArea(.all)
            HStack {
                Image("ic_logo_new")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaledToFill()
                    .overlay(Rectangle().fill(Color.blue))
                    .mask(Image("ic_logo_new").resizable())
                    .frame(width: 45, height: 6)
                    .padding([.top, .leading], 4)

                Spacer()
                Button(action: {
                    showSortSheet.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .padding(8)
                }
                .background(Color.white)
                .cornerRadius(8)
                .padding(.trailing, 16)
                .sheet(isPresented: $showSortSheet) {
                    SortSheetView( onClose: {
                        // Perform sorting based on selectedSortOption
                        print("Sheet closed")
                                showSortSheet = false
                                buildingModel.sortBuildings()
                    })
                }
            }
            .padding(.horizontal, 24)
            
            TextField("Search", text: $searchTerm)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 24)
            
        
                
                ScrollView{
                    VStack(spacing: 16) {
                    
                        ForEach(buildingModel.buildings.filter { building in
                            searchTerm.isEmpty || building.name.localizedCaseInsensitiveContains(searchTerm)
                        }) { building in
                        NavigationLink(destination: BuildingDetail(building: building).navigationBarBackButtonHidden(true)) {
                            CardView(building: building)
                                .listRowSeparator(.hidden)
                        }
                    }
                
                    }
                    .padding(24)
                }

                .onAppear {
                    buildingModel.fetchData()
                    
                }
            }
            .background( Color(.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all))
        }
//        .navigationBarHidden(true)
//        .searchable(text: $searchTerm)
        
    }

    
}


struct SortSheetView: View {
//    @Binding var selectedOption: BuildingViewModel.SortOption
    var onClose: () -> Void
//    var buildingModel: BuildingViewModel  // Add this property
    @EnvironmentObject var buildingModel: BuildingViewModel

    
    var body: some View {
        VStack {
            Text("Sort By")
                .font(.headline)
                .padding()

            ForEach(BuildingViewModel.SortOption.allCases, id: \.self) { option in
                Button(action: {
                    buildingModel.selectedSortOption = option
                    onClose()
                }) {
                    Text(option.rawValue)
                        .foregroundColor(buildingModel.selectedSortOption == option ? .blue : .black)
                        .padding()
                }
            }

            Spacer()

            Button("Close") {
                onClose()
            }
            .font(.headline)
            .padding()
        }
        .padding()
    }
}


struct CardView: View {
    let building: Building
    @EnvironmentObject var viewModel:LocationModel

    var body: some View {
        
        VStack(alignment: .leading) {
            Image(building.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaledToFill()
                .frame(height: 200)

            
                .overlay(
                    VStack(alignment:.leading) {
                        HStack{
                            if building.isNew{
                                VStack {
                                    Image("newBuilding")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .scaledToFill()
                                        .overlay(Rectangle().fill(Color.white))
                                        .mask(Image("newBuilding").resizable())
                                        .frame(width: 20, height: 6)
                                    
                                }
                                .padding(12)
                                .cornerRadius(10)
                                .background(Color.white
                                    .opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.white, lineWidth: 1)
                                )

                            }
                            Spacer()
                            Button(action: {
                                viewModel.toggleFavorite(building: building)
                            }) {
                                Image(systemName: viewModel.isFavorite(building: building) ? "star.fill" : "star")
                                    .foregroundColor(viewModel.isFavorite(building: building) ? .white : .white)
                                    .padding(6)
                                    .background(Color.white
                                        .opacity(0.3))
                                    .cornerRadius(60)
                            }
   
                            if (building.website == ""){
                                ShareLink(item: URL(string: "https://google.com")!) {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(60)
                                }
                            }else{
                                ShareLink(item: URL(string: building.website)!) {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.3))
                                        .cornerRadius(60)
                                }
                            }
            
                        }
                        .padding(20)

                        Spacer()
                    }
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]),
                                           startPoint: .bottom,
                                           endPoint: .top)
                            .opacity(0.2)
                        )

                )
                .cornerRadius(16)
                .padding(10.0)

            
            
            HStack(alignment:.top) {
                VStack(alignment:.leading, spacing: 12) {
                    VStack(alignment:.leading) {
                        Text(building.name)
                            .font(.subheadline)
                            .foregroundColor(.black)

                            .fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                        Text(building.address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)

                    }

                    HStack {
                        Image(systemName: "location.circle")
                            .foregroundColor(.green)

                        Text("\(viewModel.calculateDistance(to:building)) km away")
                                .font(.footnote)
                                .foregroundColor(.green)

                    }
                }
                
                .padding( [.leading, .bottom, .trailing], 12.0)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            


        }
        .background(Color.white)
        .cornerRadius(24)
    }

   
}


struct MapView: View {
    @Binding var buildings: [Building]
    @EnvironmentObject var viewModel:LocationModel


    @State private var selectedBuilding: Building? = nil
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

//    let home = CLLocationCoordinate2D(latitude: 45.34106231961319, longitude: -75.7602727627919)
    
    var body: some View {
        NavigationView {
            Map(position: $position) {
//                Marker("Home", systemImage: "graduationcap", coordinate: home)
                ForEach(buildings) { building in
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

    //                }
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

struct FavoritesView: View {
    @EnvironmentObject var viewModel: LocationModel
    @State private var searchTerm = ""


    var body: some View {
        NavigationStack{
            VStack {
                //                Color(.gray.opacity(0.1))
                //                    .edgesIgnoringSafeArea(.all)
                HStack {
                    Image("ic_logo_new")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaledToFill()
                        .overlay(Rectangle().fill(Color.blue))
                        .mask(Image("ic_logo_new").resizable())
                        .frame(width: 45, height: 6)
                        .padding([.top, .leading], 4)
                    
                    Spacer()
//                    Button(action: {
//                        //                isFiltering.toggle()
//                    }) {
//                        Image(systemName: "slider.horizontal.3") // Add your filter icon here
//                        //                    .foregroundColor(isFiltering ? .blue : .black)
//                            .padding(8)
//                    }
//                    .background(Color.white)
//                    .cornerRadius(8)
//                    //                .padding(.trailing, 16)
                }
                .padding(.vertical, 11)

                .padding(.horizontal, 24)
                
                TextField("Search", text: $searchTerm)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 24)
                
                
                if viewModel.favoriteBuilding.isEmpty {
                    VStack {
//                        Color(.gray.opacity(0.1))
//                            .edgesIgnoringSafeArea(.all)
                        Text("You haven't added any favorite building yet")
                            .foregroundColor(.gray)
                            .padding(24)
                        
                        Spacer()
                    }
                    //                .navigationTitle("Favorites")
                } else {
                    ZStack {
                        Color(.gray.opacity(0.1))
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            ForEach(viewModel.favoriteBuilding.filter { building in
                                searchTerm.isEmpty || building.name.localizedCaseInsensitiveContains(searchTerm)
                            }) { building in
                                NavigationLink(destination: BuildingDetail(building: building).navigationBarBackButtonHidden(true)) {
                                    CardView(building: building)
                                        .listRowSeparator(.hidden)
                                }
                            }
                            Spacer()
                        }
                        .padding(24)
                        
                    }
                }
            }
            .background( Color(.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all))
//            .searchable(text: $searchTerm)
            
        }
    }
}

#Preview {
    ContentView()
}
