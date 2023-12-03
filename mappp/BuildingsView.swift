//
//  BuildingsView.swift
//  mappp
//
//  Created by Evans on 2023-12-03.
//

import Foundation

import SwiftUI


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
