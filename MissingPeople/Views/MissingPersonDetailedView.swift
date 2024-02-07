//
//  MissingPersonDetailedView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-17.
//

import SwiftUI
import WrappingHStack

struct MissingPersonDetailedView: View {
    let missingPerson: MissingPerson

    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    AsyncImage(url: URL(string: missingPerson.imageURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else if phase.error != nil {
                            Color.red // Indicates an error.
                        } else {
                            ProgressView()
                                .frame(width: 90, height: 90)
                        }
                    }

                    HStack {
                        Text(missingPerson.name).font(.title).bold().opacity(0.8)
                        Text("\(missingPerson.age)").font(.title).bold().opacity(0.2)
                    }

                    DataBlockStyleView(highlightColor: .orange, fullWidth: true) {
                        HStack(spacing: 0) {
                            DataBlockView(
                                highlightColor: .orange,
                                icon: Image(systemName: "person.fill"),
                                supportingTitle: "Kön",
                                mainTitle: missingPerson.gender.firstLetterCapitalized()
                            )
                            Spacer()
                            DataBlockView(
                                highlightColor: .orange,
                                icon: Image(systemName: "ruler"),
                                supportingTitle: "Längd",
                                mainTitle: "\(missingPerson.height) cm"
                            )
                            Spacer()
                            DataBlockView(
                                highlightColor: .orange,
                                icon: Image(systemName: "scalemass.fill"),
                                supportingTitle: "Vikt",
                                mainTitle: "\(missingPerson.weight) kg"
                            )
                        }
                    }

                    HStack {
                        Rectangle()
                            .frame(height: 2)
                            .opacity(0.02)
                        Text("FÖRSVINNANDET")
                            .font(.system(size: 10, weight: .semibold))
                            .opacity(0.2)
                        Rectangle()
                            .frame(height: 2)
                            .opacity(0.02)
                    }

                    WrappingHStack(alignment: .leading) {
                        DataBlockStyleView(highlightColor: .blue, fullWidth: false) {
                            HStack(spacing: 0) {
                                DataBlockView(
                                    highlightColor: .blue,
                                    icon: Image(systemName: "clock.badge"),
                                    supportingTitle: "Försvunnen sedan",
                                    mainTitle: missingPerson.missingSince
                                )
                            }
                        }

                        Button(action: { 
                            if !missingPerson.lastSeenAt.isEmpty {
                                openMapsForCity(cityName: missingPerson.lastSeenAt.firstLetterCapitalized())
                            }
                        }) {
                            DataBlockStyleView(highlightColor: .blue, fullWidth: false) {
                                HStack(spacing: 0) {
                                    DataBlockView(
                                        highlightColor: .blue,
                                        icon: Image(systemName: "building.2.crop.circle"),
                                        supportingTitle: "Sågs senast i",
                                        mainTitle: missingPerson.lastSeenAt.firstLetterCapitalized()
                                    )
                                }
                            }
                        }
                    }

                    HStack {
                        Text("Om du stöter på denna person som är försvunnen, ber vi dig att omedelbart informera dina lokala myndigheter.")
                            .font(.system(size: 12, weight: .semibold))
                            .lineSpacing(5)
                            .opacity(0.7)
                            .padding(20)
                    }
                    .frame(maxWidth: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("SemiBackground"))
                    }

                    if !missingPerson.transportName.isEmpty {
                        HStack {
                            Rectangle()
                                .frame(height: 2)
                                .opacity(0.02)
                            Text("TRANSPORT")
                                .font(.system(size: 10, weight: .semibold))
                                .opacity(0.2)
                            Rectangle()
                                .frame(height: 2)
                                .opacity(0.02)
                        }

                        WrappingHStack(alignment: .leading) {
                            if !missingPerson.transportName.isEmpty {
                                DataBlockStyleView(highlightColor: .none, fullWidth: false) {
                                    HStack(spacing: 0) {
                                        DataBlockView(
                                            highlightColor: .orange,
                                            icon: Image(systemName: "train.side.front.car"),
                                            supportingTitle: "Transport",
                                            mainTitle: missingPerson.transportName
                                        )
                                    }
                                }
                            }

                            if !missingPerson.transportColor.isEmpty {
                                DataBlockStyleView(highlightColor: .none, fullWidth: false) {
                                    HStack(spacing: 0) {
                                        DataBlockView(
                                            highlightColor: .orange,
                                            icon: Image(systemName: "paintpalette.fill"),
                                            supportingTitle: "Färg",
                                            mainTitle: missingPerson.transportColor
                                        )
                                    }
                                }
                            }

                            if !missingPerson.transportRegistrationNumber.isEmpty {
                                DataBlockStyleView(highlightColor: .none, fullWidth: false) {
                                    HStack(spacing: 0) {
                                        DataBlockView(
                                            highlightColor: .orange,
                                            icon: Image(systemName: "123.rectangle.fill"),
                                            supportingTitle: "Reg. Nummer",
                                            mainTitle: missingPerson.transportRegistrationNumber
                                        )
                                    }
                                }
                            }
                        }
                    }

                    if !missingPerson.hairAppearance.isEmpty {
                        HStack {
                            Rectangle()
                                .frame(height: 2)
                                .opacity(0.02)
                            Text("UTSEENDET")
                                .font(.system(size: 10, weight: .semibold))
                                .opacity(0.2)
                            Rectangle()
                                .frame(height: 2)
                                .opacity(0.02)
                        }

                        WrappingHStack(alignment: .leading) {
                            if !missingPerson.hairAppearance.isEmpty {
                                DataBlockStyleView(highlightColor: .none, fullWidth: false) {
                                    HStack(spacing: 0) {
                                        DataBlockView(
                                            highlightColor: .orange,
                                            icon: Image(systemName: "comb.fill"),
                                            supportingTitle: "Håret",
                                            mainTitle: missingPerson.hairAppearance.firstLetterCapitalized()
                                        )
                                    }
                                }
                            }

                            if !missingPerson.hasBeard.isEmpty {
                                DataBlockStyleView(highlightColor: .none, fullWidth: false) {
                                    HStack(spacing: 0) {
                                        DataBlockView(
                                            highlightColor: .orange,
                                            icon: Image(systemName: "scissors"),
                                            supportingTitle: "Skägg",
                                            mainTitle: missingPerson.hasBeard
                                        )
                                    }
                                }
                            }

                            if !missingPerson.clothingAppearance.isEmpty {
                                DataBlockStyleView(highlightColor: .none, fullWidth: false) {
                                    HStack(spacing: 0) {
                                        DataBlockView(
                                            highlightColor: .orange,
                                            icon: Image(systemName: "tshirt.fill"),
                                            supportingTitle: "Klädsel",
                                            mainTitle: missingPerson.clothingAppearance.firstLetterCapitalized()
                                        )
                                    }
                                }
                            }
                        }
                    }

                }
                .padding(20)
            }
            .scrollIndicators(.never)
            .navigationBarTitle(Text(""), displayMode: .inline)
        }
    }
}

private func openMapsForCity(cityName: String) {
    if let encodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
       let mapsURL = URL(string: "http://maps.apple.com/?q=\(encodedCityName)") {
        UIApplication.shared.open(mapsURL, options: [:], completionHandler: nil)
    }
}

#Preview {
    ContentView()
}
