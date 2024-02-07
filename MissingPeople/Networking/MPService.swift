//
//  MPService.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-23.
//

import Foundation
import Firebase

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
}
