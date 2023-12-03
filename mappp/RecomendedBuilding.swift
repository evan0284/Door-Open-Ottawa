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

    @State private var name = ""
    @State private var category = ""
    @State private var description = ""
    
//    init(){
//        FirebaseApp.configure()
//    }
    
    var body: some View {
        NavigationView {
            if networkMonitor.isConnected{
                Form {
                    Section {
                        TextField("Name", text: $name)
                        TextField("Category", text: $category)
                        TextEditor(text: $description)
                            .frame(height: 100)
                    }

                    Section {
                        Button("Recommend Building") {
                            dataManager.recommendBuilding(name: name, category: category, description: description)
                        }
                    }
                }
                .navigationTitle("Recommend a Building")
            } else{
                ContentUnavailableView("No Network", systemImage: "wifi.exclamationmark", description: Text("Check your data or wifi"))
            }
        }
    }
}

class DataManager: ObservableObject {
//    @Published var building: [Buildings] = []
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
