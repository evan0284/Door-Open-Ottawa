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
    @State private var favoriteBuilding: [Building] = []
    
    @StateObject var viewModel = LocationModel()
    @StateObject var buildingModel = BuildingViewModel()
    @StateObject var networkMonitor = NetworkMonitor()


    @State private var selectedTab: Tab = .gearshape
    @State private var searchTerm = ""
    
    @State private var showAboutMe: Bool = false

    
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
                .tag(Tab.map)
                
                NavigationView {
                    FavoritesView()
                        .environmentObject(viewModel)
                }
                .tag(Tab.star)
                
                NavigationView {
                    MoreView()
                        .environmentObject(buildingModel)
                        .environmentObject(networkMonitor)



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

    }
}

class LocationModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var favoriteBuilding: [Building] = []
    @Published var buildings: [Building] = []
    @EnvironmentObject var buildingModel: BuildingViewModel
    
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

class BuildingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var buildings: [Building] = []
    @EnvironmentObject var viewModel: LocationModel
    

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

struct BuildingsView: View {
    
    @EnvironmentObject var viewModel: LocationModel
    @EnvironmentObject var buildingModel: BuildingViewModel
    
    
    @State private var searchTerm = ""
    
    @State private var showSortSheet = false

    
    var body: some View {
        NavigationStack{
            VStack {

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
                .sheet(isPresented: $showSortSheet) {
                    SortSheetView( onClose: {
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
                    
                        ForEach(buildingModel.filteredBuildings().filter { building in
                            searchTerm.isEmpty || building.name.localizedCaseInsensitiveContains(searchTerm)
                        }) { building in
                        NavigationLink(destination: BuildingDetail(building: building)
                            .navigationBarBackButtonHidden(true)
                        )
                            {
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

        
    }

    
}


struct SortSheetView: View {
//    @Binding var selectedOption: BuildingViewModel.SortOption
    var onClose: () -> Void
//    var buildingModel: BuildingViewModel  // Add this property
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
                        Text("You haven't added any favorite building yet")
                            .foregroundColor(.gray)
                            .padding(24)
                        
                        Spacer()
                    }
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
            
        }
    }
}



struct MoreView: View {
    @EnvironmentObject var buildingViewModel: BuildingViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var isLanguageToggleOn = false

    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 0){
                HStack {
                    
                    Text("More")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.blue)
                }
                .padding([.top, .leading], 24.0)
                
                List{

                    Toggle("Current Language: \(buildingViewModel.selectedLanguage)", isOn: $isLanguageToggleOn)
                        .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                        .onChange(of: isLanguageToggleOn) {
                            buildingViewModel.toggleLanguage()
                        }

                    NavigationLink("Recommended Building",destination: RecomendedBuilding()
                        .environmentObject(NetworkMonitor())
                        .navigationBarBackButtonHidden(true)
                    )
                    .foregroundColor(.black)
                    
                    NavigationLink("About Me",destination: AboutMeView()
                        .navigationBarBackButtonHidden(true)
                    )
                    .foregroundColor(.black)
                    
                }
                .cornerRadius(12)
            }
            .padding(12)
            .background( Color(.gray.opacity(0.1))
            .edgesIgnoringSafeArea(.all))
        }

    }
}


struct AboutMeView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.black
                                .opacity(/*@START_MENU_TOKEN@*/0.3/*@END_MENU_TOKEN@*/))
                            .cornerRadius(60)
                }
                Spacer()
            }
                
            VStack(alignment: .center) {

                VStack {
                    Image("me")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(100)
                    
                    
                    Text("Evans")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Mutmedia and UI/UX Designer")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
            .padding(12)

            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                            VStack(alignment:.leading){
                                Text("Email")
                                    .font(.headline)
                                    .padding(.bottom, 6
                                    )
                                Text("evansalbertus@gmail.com")
                                    .font(.footnote)
                            }
                            .padding(.top, 10)
                    
                    VStack(alignment:.leading){
                        Text("Linkedin")
                            .font(.headline)
                            .padding(.bottom, 6
                            )
                        Text("https://www.linkedin.com/in/albertus-evans-990158130/")
                            .font(.footnote)
                    }
                    .padding(.top, 10)
                        

                        VStack(alignment:.leading){
                            Text("Website")
                                .font(.headline)
                                .padding(.bottom, 6
                                )
                            Text("https://www.behance.net/evansalbertus")
                                .font(.footnote)
                        }
                        .padding(.top, 10)

                        VStack(alignment:.leading){
                            Text("About")
                                .font(.headline)
                                .padding(.bottom, 6
                                )
                            Text("I am a multimedia designer with four years of experience crafting and animating content for social media, as well as conceiving creative concepts for brand campaigns. I am proficient in creative software like Photoshop, Illustrator, After Effect, Premiere Pro and Figma and I am well-versed in UI/UX design principles.")
                                .font(.footnote)
                        }
                    
                        .padding(.top, 10)

                }
                Spacer()
            }
            
        }
        .padding(24)
        Spacer()
    }
}

#Preview {
    ContentView()
}
