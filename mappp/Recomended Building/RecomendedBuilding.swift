//
//  RecomendedBuilding.swift
//  mappp
//
//  Created by Evans on 2023-12-02.
//

//Document ID FIrebase FVifnjijpM5W5BFuZJMu

import SwiftUI
import Firebase

struct RecomendedBuilding: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var category = ""
    @State private var description = ""
    @State private var isShowingOverlay = false

    
    var body: some View {
        NavigationView {

            if networkMonitor.isConnected{
                
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
                    VStack {
                        
                        TextField("Name", text: $name)
                            .padding()
                            .background(Color.white.cornerRadius(12))
                            .padding(.bottom, 12)
                    
                        
                        TextField("Category", text: $category)
                            .padding()
                            .background(Color.white.cornerRadius(12))
                            .padding(.bottom, 12)

                        TextField("Description", text: $description)
                            .padding()
                            .background(Color.white.cornerRadius(12))
                            .padding(.bottom, 50)
                
                        

                            Button("Recommend Building") {
                                dataManager.recommendBuilding(name: name, category: category, description: description)
                                
                                name = ""
                                category = ""
                                description = ""
                            }
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(12)
                        
                    Spacer()
                }
                .padding(12)

                .background( Color(.gray.opacity(0.1))
                .edgesIgnoringSafeArea(.all))
                
            } else{
                ContentUnavailableView("No Network", systemImage: "wifi.exclamationmark", description: Text("Check your data or wifi"))
            }
        }
        
    }
}

class DataManager: ObservableObject {
    let buildingCollectionRef = Firestore.firestore().collection("Building")
    
    init() {}
    
    func recommendBuilding(name: String, category: String, description: String) {
        let buildingRecommendation = [
            "name": name,
            "category": category,
            "description": description
        ]
        buildingCollectionRef.addDocument(data: buildingRecommendation) { error in
            if let error = error {
                print("Error recommending building: \(error.localizedDescription)")
            } else {
                print("Building recommended successfully.")
            }
        }
    }
    
    
}

#Preview {
    RecomendedBuilding()
        .environmentObject(NetworkMonitor())

}
