//
//  MissingPerson.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import Foundation

struct MissingPerson: Identifiable, Codable {
    let id: UUID = UUID()
    let age: String
    let clothingAppearance: String
    let gender: String
    let hairAppearance: String
    let hasBeard: String
    let height: String
    let imageURL: String
    let lastSeenAt: String
    let missingSince: String
    let name: String
    let transportColor: String
    let transportName: String
    let transportRegistrationNumber: String
    let weight: String
}
