//
//  Extensions.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-27.
//

import Foundation

extension String {
    func firstLetterCapitalized() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

extension MissingPerson {
    static let mock = MissingPerson(
        age: "30",
        clothingAppearance: "-",
        gender: "Man",
        hairAppearance: "-",
        hasBeard: "Ja",
        height: "180",
        imageURL: "https://www.dkpittsburghsports.com/img/random/Najee%20Harris%20close%20up%20-%20Karl%20Roser%20Steelers-1600x900.jpg",
        lastSeenAt: "Stockholm",
        missingSince: "2024-01-28",
        name: "Namn",
        transportColor: "Röd",
        transportName: "Volvo V70",
        transportRegistrationNumber: "ABC 123",
        weight: "80"
    )
}
