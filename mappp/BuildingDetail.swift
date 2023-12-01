//
//  BuildingDetail.swift
//  final2
//
//  Created by Evans on 2023-11-25.
//
import Foundation

import SwiftUI

struct BuildingDetail: View {
    let building: Building
//    let isFavorite: Bool
//    let toggleFavorite: () -> Void
    @EnvironmentObject var viewModel: BuildingViewModel

    @State private var showFullDescription = false
    @Environment(\.presentationMode) var presentationMode
    
    

    var body: some View {
            ZStack(alignment: .topLeading) {
                ScrollView{
                    VStack(alignment:.leading){
                        
                        
                        Image(building.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaledToFill()
                            .frame(width: 370, height: 350)
                            .overlay(
                                VStack(alignment: .leading) {
                                    HStack(alignment: .center) {
                                        Button(action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }) {
                                            Image(systemName: "chevron.backward")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 6)
                                                .background(Color.white
                                                    .opacity(/*@START_MENU_TOKEN@*/0.3/*@END_MENU_TOKEN@*/))
                                                .cornerRadius(60)
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
                                    .padding(24)
                                    
                                    Spacer()
                                    VStack(alignment:.leading) {
                                        Text(building.name)
                                            .font(.title2)
                                            .fontWeight(.heavy)
                                            .foregroundStyle(Color.white)
                                        HStack {
                                            iconForCategory(building.categoryId)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .scaledToFill()
                                                .overlay(Rectangle().fill(Color.white))
                                                .mask(iconForCategory(building.categoryId).resizable())
                                                .frame(width: 15, height: 10)
                                            
                                            Text(building.category)
                                                .foregroundColor(.white)
                                                .font(.footnote)
                                        }
                                        
                                    }
                                    .padding(24)
                                    
                                }
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black]),
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                        .opacity(0.5)
                                    )
                                
                                
                            )
                            .cornerRadius(24)
                            .padding(.horizontal, 12)
 
                        VStack(alignment:.leading) {
       
                            VStack(alignment:.leading) {
                                Text("Description")
                                    .font(.headline)
                                    .padding(.bottom, 6)
                                if showFullDescription {
                                    Text(building.description)
                                        .font(.footnote)
                                } else {
                                    Text(moreDesc(building.description))
                                        .font(.footnote)
                                }
                                
                                Button(action: {
                                    showFullDescription.toggle()
                                }) {
                                    Text(showFullDescription ? "Less" : "More")
                                        .font(.footnote)
                                }
                            }
                            
                            VStack(alignment:.leading){
                                Text("Opening Hours")
                                    .font(.headline)
                                    .padding(.bottom, 6)

                                if building.isOpenSaturday {
                                    VStack(alignment:.leading) {
                                        Text("Saturday")
                                            .font(.footnote)
                                        Text("\(building.saturdayStart) - \(building.saturdayClose)" )
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.bottom, 6)
                                }
                                
                                if building.isOpenSunday {
                                    VStack(alignment:.leading) {
                                        Text("Sunday")
                                            .font(.footnote)
                                        Text("\(building.sundayStart) - \(building.sundayClose)" )
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.bottom, 6)
                                } else{
                                    Text("Sunday Closed")
                                        .font(.footnote)

                                }
                            }
                            .padding(.top, 10)
                            
                            VStack(alignment:.leading){
                                Text("Website")
                                    .font(.headline)
                                    .padding(.bottom, 6
                                    )
                                
                                
                                if (building.website == ""){
                                    Text("No website")
                                        .font(.footnote)
                                }else{
                                    Text(building.website)
                                        .font(.footnote)
                                }


                            }
                            .padding(.top, 10)

                            VStack(alignment:.leading){
                                Text("Amenities")
                                    .font(.headline)
                                    .padding(.bottom, 6
                                    )
                                ScrollView(.horizontal) {
                                    HStack{
                                        if building.isShuttle{
                                            HStack {
                                                Image("shuttle")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .scaledToFill()
                                                    .overlay(Rectangle().fill(Color.blue))
                                                    .mask(Image("shuttle").resizable())
                                                    .frame(width: 20, height: 6)
                                                
                                                
                                                
                                                Text("Shuttle")
                                                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                            }
                                            .padding(12)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
                                        }
                                        if building.isPublicWashrooms{
                                            HStack {
                                                Image("washroom")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .scaledToFill()
                                                    .overlay(Rectangle().fill(Color.blue))
                                                    .mask(Image("washroom").resizable())
                                                    .frame(width: 20, height: 6)
                                                
                                                
                                                
                                                Text("Washroom")
                                                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                            }
                                            .padding(12)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
                                        }
                                        if building.isFreeParking{
                                            HStack {
                                                Image("accessibility")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .scaledToFill()
                                                    .overlay(Rectangle().fill(Color.blue))
                                                    .mask(Image("accessibility").resizable())
                                                    .frame(width: 15, height: 6)
                                                
                                                
                                                
                                                Text("Accessible")
                                                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                            }
                                            .padding(12)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
                                        }
                                        if building.isBikeParking{
                                            HStack {
                                                Image("bikeracks")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .scaledToFill()
                                                    .overlay(Rectangle().fill(Color.blue))
                                                    .mask(Image("bikeracks").resizable())
                                                    .frame(width: 25, height: 6)
                                                
                                                
                                                
                                                Text("Bike Racks")
                                                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                            }
                                            .padding(12)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
                                        }
                                        if building.isPaidParking{
                                            HStack {
                                                Image("paidParking")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .scaledToFill()
                                                    .overlay(Rectangle().fill(Color.blue))
                                                    .mask(Image("paidParking").resizable())
                                                    .frame(width: 25, height: 6)
                                                
                                                
                                                
                                                Text("Paid Parking")
                                                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                            }
                                            .padding(12)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
                                        }
                                        if building.isGuidedTour{
                                            HStack {
                                                Image("guidedTour")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .scaledToFill()
                                                    .overlay(Rectangle().fill(Color.blue))
                                                    .mask(Image("guidedTour").resizable())
                                                    .frame(width: 20, height: 6)
                                                
                                                
                                                
                                                Text("Guided Tour")
                                                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                            }
                                            .padding(12)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
                                        }
                                        if building.isFamilyFriendly{
                                            HStack {
                                                Image("familyFriendly")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .scaledToFill()
                                                    .overlay(Rectangle().fill(Color.blue))
                                                    .mask(Image("familyFriendly").resizable())
                                                    .frame(width: 15, height: 6)
                                                
                                                
                                                
                                                Text("Family Friendly")
                                                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                            }
                                            .padding(12)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
                                        }
                                        if building.isOCTranspoNearby{
                                            HStack {
                                                Image("ocTranspo")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .scaledToFill()
                                                    .overlay(Rectangle().fill(Color.blue))
                                                    .mask(Image("ocTranspo").resizable())
                                                    .frame(width: 25, height: 6)
                                                
                                                
                                                
                                                Text("OC Transpo Nearby")
                                                    .font(/*@START_MENU_TOKEN@*/.footnote/*@END_MENU_TOKEN@*/)
                                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                            }
                                            .padding(12)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .stroke(.blue, lineWidth: 1)
                                            )
                                        }

                                    }
                                    .padding(3)
                                }

                            }
                            .padding(.top, 10)
          
                        }
                        .padding()
                    }
                    
                }
            
        }
    }
    
    private func moreDesc(_ description: String) -> String {
        let maxLength = 150
        if description.count > maxLength {
            return String(description.prefix(maxLength)) + "..."
        } else {
            return description
        }
    }
    
    private func iconForCategory(_ categoryId: Int) -> Image {
        switch categoryId {
        case 0:
            return Image("newReligionHandsFilter")
        case 1:
            return Image("embassyFilter")
        case 2:
            return Image("governmentBuildingsFilter")
        case 3:
            return Image("functionalFilter")
        case 4:
            return Image("galleriresFilter")
        case 5:
            return Image("academicsFilter")
        case 6:
            return Image("sportsFilter")
        case 7:
            return Image("communityFilter")
        case 8:
            return Image("businessFilter")
        case 9:
            return Image("museumsFilter")
        case 10:
            return Image("otherFilter")
        default:
            return Image("questionmark")
        }
    }
}

//struct BuildingDetail_Previews: PreviewProvider {
//    // Remove @State since it's not needed in a PreviewProvider
//    private var favoriteBuilding: [Building] = []
//
//    static var previews: some View {
//        let sampleBuilding = Building(
//            buildingId: 1,
//            name: "Sample Building",
//            isNew: true,
//            address: "123 Main St.",
//            description: "The AIDS Committee of Ottawa (ACO) has served the HIV/AIDS community for 30 years, providing education and support services around HIV/AIDS. Built in 1961 and overlooking the Rideau Canal, the home of the ACO features a drop-in centre known as the Living Room - a place of comfort and care that pays tribute to the origins of the HIV/AIDS movement in Canada in the early 80s.",
//            website: "http://example.com",
//            categoryId: 1,
//            category: "Community and/or Care centres",
//            saturdayStart: "2023-01-01 09:00",
//            saturdayClose: "2023-01-01 17:00",
//            sundayStart: "2023-01-02 09:00",
//            sundayClose: "2023-01-02 17:00",
//            isShuttle: true,
//            isPublicWashrooms: true,
//            isAccessible: true,
//            isFreeParking: true,
//            isBikeParking: true,
//            isPaidParking: true,
//            isGuidedTour: true,
//            isFamilyFriendly: true,
//            image: "aids_ottawa",
//            isOCTranspoNearby: true,
//            imageDescription: "Sample image description",
//            latitude: 0.0,
//            longitude: 0.0,
//            isOpenSaturday: true,
//            isOpenSunday: false
//        )
//        
//
//        // Use the sample building for preview
//        return BuildingDetail(building: sampleBuilding, isFavorite: isFavorite(building: sampleBuilding), toggleFavorite: { toggleFavorite(building: sampleBuilding) })
//    }
//}
