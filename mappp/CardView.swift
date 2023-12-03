//
//  CardView.swift
//  mappp
//
//  Created by Evans on 2023-12-03.
//

import Foundation
import SwiftUI

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
