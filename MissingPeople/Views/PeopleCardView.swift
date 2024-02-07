//
//  PeopleCardView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI

struct PeopleCardView: View {
    let missingPerson: MissingPerson

    @State private var shouldNavToDetailedView = false

    var body: some View {
        Button(action: { self.shouldNavToDetailedView = true }) {
            HStack(alignment: .top, spacing: 20) {
                AsyncImage(url: URL(string: missingPerson.imageURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if phase.error != nil {
                        Color.red // Indicates an error.
                    } else {
                        ProgressView()
                            .frame(width: 90, height: 90)
                    }
                }
                VStack(alignment: .leading, spacing: 20) {
                    Text("\(missingPerson.name) \(missingPerson.age)")
                        .font(.title2)
                        .bold()
                    CardDetailsView(missingPerson: missingPerson)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: [Color.white.opacity(0.03), Color.white.opacity(0)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .stroke(.white.opacity(0.02), lineWidth: 2)
            )
        }
        .navigationDestination(isPresented: $shouldNavToDetailedView) {
            MissingPersonDetailedView(missingPerson: missingPerson)
        }
    }
}

struct CardDetailsView: View {
    let missingPerson: MissingPerson

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                Image(systemName: "clock.badge")
                    .opacity(0.2)
                    .padding(7)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .opacity(0.02)
                    }
                VStack(alignment: .leading) {
                    Text("Försvunnen sedan").opacity(0.2)
                    Text(missingPerson.missingSince).opacity(0.5)
                }
                .font(.footnote)
            }
            HStack(alignment: .top) {
                Image(systemName: "building.2.crop.circle")
                    .opacity(0.2)
                    .padding(7)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .opacity(0.02)
                    }
                VStack(alignment: .leading) {
                    Text("Sågs senast i").opacity(0.2)
                    Text(missingPerson.lastSeenAt).opacity(0.5)
                }
                .font(.footnote)
            }
        }
    }
}

#Preview {
    PeopleCardView(missingPerson: .mock)
}
