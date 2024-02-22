//
//  MissingPerson.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import Foundation
import CoreLocation
import UIKit

class MissingPerson: Identifiable, Codable, Equatable {
    static func == (lhs: MissingPerson, rhs: MissingPerson) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID = UUID()
    let age: String?
    let clothingAppearance: String?
    let gender: String?
    let hairAppearance: String?
    let hasBeard: String?
    let height: String?
    let imageURL: String
    var imageData: Data? = nil
    let lastSeenAt: String?
    let latitude: String?
    let longitude: String?
    let missingSince: String?
    let name: String
    let transportColor: String?
    let transportName: String?
    let transportRegistrationNumber: String?
    let weight: String?

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.age = try container.decodeIfPresent(String.self, forKey: .age)
        self.clothingAppearance = try container.decodeIfPresent(String.self, forKey: .clothingAppearance)
        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
        self.hairAppearance = try container.decodeIfPresent(String.self, forKey: .hairAppearance)
        self.hasBeard = try container.decodeIfPresent(String.self, forKey: .hasBeard)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.imageData = nil
        self.lastSeenAt = try container.decodeIfPresent(String.self, forKey: .lastSeenAt)
        self.latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        self.longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
        self.missingSince = try container.decodeIfPresent(String.self, forKey: .missingSince)
        self.name = try container.decode(String.self, forKey: .name)
        self.transportColor = try container.decodeIfPresent(String.self, forKey: .transportColor)
        self.transportName = try container.decodeIfPresent(String.self, forKey: .transportName)
        self.transportRegistrationNumber = try container.decodeIfPresent(String.self, forKey: .transportRegistrationNumber)
        self.weight = try container.decodeIfPresent(String.self, forKey: .weight)

        print("Init")
        self.setImageData()
    }

    init(age: String?, clothingAppearance: String?, gender: String?, hairAppearance: String?, hasBeard: String?, height: String?, imageURL: String, imageData: Data? = nil, lastSeenAt: String?, latitude: String?, longitude: String?, missingSince: String?, name: String, transportColor: String?, transportName: String?, transportRegistrationNumber: String?, weight: String?) {
        self.age = age
        self.clothingAppearance = clothingAppearance
        self.gender = gender
        self.hairAppearance = hairAppearance
        self.hasBeard = hasBeard
        self.height = height
        self.imageURL = imageURL
        self.imageData = nil
        self.lastSeenAt = lastSeenAt
        self.latitude = latitude
        self.longitude = longitude
        self.missingSince = missingSince
        self.name = name
        self.transportColor = transportColor
        self.transportName = transportName
        self.transportRegistrationNumber = transportRegistrationNumber
        self.weight = weight

        print("Init")
        self.setImageData()
    }

    func setImageData() {
        guard let url = URL(string: imageURL) else {
            print("URL not valid")
            return
        }
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() {
                self.imageData = data
            }
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
