//
//  Favorites View.swift
//  mappp
//
//  Created by Evans on 2023-12-03.
//

import Foundation
import SwiftUI

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
