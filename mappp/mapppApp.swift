//
//  mapppApp.swift
//  mappp
//
//  Created by Evans on 2023-11-29.
//

import SwiftUI
import Firebase

@main
struct mapppApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DataManager())
                .environmentObject(LocationModel())
        }
    }
}
