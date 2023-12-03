//
//  MoreView.swift
//  mappp
//
//  Created by Evans on 2023-12-03.
//

import Foundation
import SwiftUI

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

