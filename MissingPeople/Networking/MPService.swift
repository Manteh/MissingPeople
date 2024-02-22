//
//  MPService.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-23.
//

import Foundation
import Firebase
import CoreLocation

struct Location: Identifiable {
    let id: UUID = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

class MPService {
    static let shared = MPService()

    private let database = Database.database()

    func fetchMissingPeople(completion: @escaping ([MissingPerson]?) -> Void) {
        let missingPeopleRef = database.reference().child("missingPeople")

        missingPeopleRef.observeSingleEvent(of: .value) { (snapshot, _)  in
            guard let missingPeopleData = snapshot.value as? [String: Any] else {
                completion(nil)
                return
            }

            var missingPeople: [MissingPerson] = []

            for personData in missingPeopleData {
                guard let personDictionary = personData.value as? [String: Any] else { return }
                let jsonData = try! JSONSerialization.data(withJSONObject: personDictionary)
                let person = try! JSONDecoder().decode(MissingPerson.self, from: jsonData)
                missingPeople.append(person)
            }

            completion(missingPeople)
        }
    }

    func getLocationByName(name: String, completion: @escaping (Location?) -> Void) {
        let locationsRef = Database.database().reference().child("locations")

        // Check if the location coordinates are already in the database
        locationsRef.child(name).observeSingleEvent(of: .value) { (snapshot, _) in
            if let coordinatesDict = snapshot.value as? [String: Any],
               let latitude = coordinatesDict["latitude"] as? CLLocationDegrees,
               let longitude = coordinatesDict["longitude"] as? CLLocationDegrees {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                completion(.init(name: name, coordinate: coordinate))
            } else {
                // If not found in the database, use CLGeocoder to retrieve coordinates
                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(name) { (placemarks, error) in
                    guard let placemark = placemarks?.first,
                          let location = placemark.location else {
                        completion(nil)
                        return
                    }
                    let coordinate = location.coordinate

                    // Store the retrieved coordinates into the database
                    let coordinatesDict: [String: Any] = [
                        "latitude": coordinate.latitude,
                        "longitude": coordinate.longitude
                    ]
                    locationsRef.child(name).setValue(coordinatesDict)

                    completion(.init(name: name, coordinate: coordinate))
                }
            }
        }
    }
}
