//
//  BuildingModel.swift
//  final2
//
//  Created by Evans on 2023-11-25.
//

import Foundation
struct BuildingData: Decodable {
    let language: String
    let version: Int
    let year: Int
    let buildings: [Building]
    
    private enum CodingKeys: String, CodingKey {
        case language
        case version
        case year
        case buildings
    }
}

struct Building: Identifiable, Decodable {
    let id = UUID()
    let buildingId: Int
    let name: String
    let isNew: Bool
    let address: String
    let description: String
    let website: String
    let categoryId: Int
    let category: String
    let saturdayStart: String
    let saturdayClose: String
    let sundayStart: String
    let sundayClose: String
    let isShuttle: Bool
    let isPublicWashrooms: Bool
    let isAccessible: Bool
    let isFreeParking: Bool
    let isBikeParking: Bool
    let isPaidParking: Bool
    let isGuidedTour: Bool
    let isFamilyFriendly: Bool
    let image: String
    let isOCTranspoNearby: Bool
    let imageDescription: String
    let latitude: Double
    let longitude: Double
    let isOpenSaturday: Bool
    let isOpenSunday: Bool

    private enum CodingKeys: String, CodingKey {
        case buildingId
        case name
        case isNew
        case address
        case description
        case website
        case categoryId
        case category
        case saturdayStart
        case saturdayClose
        case sundayStart
        case sundayClose
        case isShuttle
        case isPublicWashrooms
        case isAccessible
        case isFreeParking
        case isBikeParking
        case isPaidParking
        case isGuidedTour
        case isFamilyFriendly
        case image
        case isOCTranspoNearby
        case imageDescription
        case latitude
        case longitude
        case isOpenSaturday
        case isOpenSunday
    }
}
