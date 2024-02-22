//
//  MapTabView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine

class PersonMapPin: NSObject, Identifiable, MKAnnotation {
    let id: UUID
    let missingPerson: MissingPerson
    let coordinate: CLLocationCoordinate2D
    var isVisible: Bool = true

    init(missingPerson: MissingPerson, coordinate: CLLocationCoordinate2D, isVisible: Bool? = nil) {
        self.id = UUID()
        self.missingPerson = missingPerson
        self.coordinate = coordinate
        self.isVisible = isVisible ?? true
    }
}

struct PersonMapPinView: View {

    @Binding var mapPin: PersonMapPin
    @Binding var selectedPerson: MissingPerson?
    @Binding var currentCameraPosition: MapCameraPosition
    @Binding var lastCameraPosition: MapCameraPosition?
    @Binding var viewRegion: MKCoordinateRegion

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: mapPin.missingPerson.imageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: selectedPerson == mapPin.missingPerson ? 60 : (mapPin.isVisible ? 30 : 10),
                            height: selectedPerson == mapPin.missingPerson ? 60 : (mapPin.isVisible ? 30 : 10),
                            alignment: .center
                        )
                        .clipShape(selectedPerson == mapPin.missingPerson ? RoundedRectangle(cornerRadius: 10) : RoundedRectangle(cornerRadius: 30))
                        .overlay(RoundedRectangle(cornerRadius: selectedPerson == mapPin.missingPerson ? 10 : 30).stroke(Color.white, lineWidth: selectedPerson == mapPin.missingPerson ? 4 : 2))
                }
            }

            Text(mapPin.missingPerson.name)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(5)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                .opacity(selectedPerson == mapPin.missingPerson ? 1 : 0)
        }
        .animation(.linear, value: self.selectedPerson)
        .animation(.linear, value: mapPin.isVisible)
        .onChange(of: lastCameraPosition) {
            DispatchQueue.main.async {
                if mapPin.isVisible != isCoordinateVisible(mapPin.coordinate) {
                    self.mapPin.isVisible = isCoordinateVisible(mapPin.coordinate)
                }
            }
        }
        .onTapGesture {
            DispatchQueue.main.async {
                let newCameraPosition = MapCameraPosition.region(MKCoordinateRegion(
                    center: mapPin.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                ))
                withAnimation(.spring) {
                    self.selectedPerson = mapPin.missingPerson
                }

                withAnimation(.spring) {
                    self.currentCameraPosition = newCameraPosition
                }
            }
        }
    }

    func isCoordinateVisible(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return viewRegion.contains(coordinate)
    }
}

struct MapTabView: View {
    @Binding var missingPeople: [MissingPerson]

    @State private var locations: [Location] = []
    @State private var selectedTag: Int?
    @State private var selectedPerson: MissingPerson?
    @State private var showDetails = false

    static let initialCameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 62.0, longitude: 15.0),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    ))



    @State private var lastCameraPosition: MapCameraPosition? = initialCameraPosition
    @State private var currentCameraPosition: MapCameraPosition = initialCameraPosition
    @State private var viewRegion: MKCoordinateRegion = initialCameraPosition.region!
    @State private var mapPins: [PersonMapPin] = []

    var body: some View {
        NavigationView {
            ZStack {
                Color("Background").edgesIgnoringSafeArea(.all)
                if !mapPins.isEmpty {
                    CustomMapView(region: $viewRegion, annotations: $mapPins, onAnnotationTap: { annotation in
                        print("Annotation: \(annotation.missingPerson.name)")
                        self.selectedPerson = annotation.missingPerson
                    })
                    .edgesIgnoringSafeArea(.top)
                } else {
                    ProgressView()
                }
            }
            .toolbar(.hidden)
            .sheet(item: self.$selectedPerson, onDismiss: {
                DispatchQueue.main.async {
                    if let lastCameraPosition = lastCameraPosition {
                        withAnimation {
                            self.currentCameraPosition = lastCameraPosition
                        }
                    }
                    self.selectedPerson = nil
                }
            }) { selectedPerson in
                SummarySheetView(
                    selectedPerson: Binding(
                        get: { selectedPerson },
                        set: { self.selectedPerson = $0 }
                    )
                )
            }
            .onAppear {
                if mapPins.isEmpty {
                    missingPeople.forEach { person in
                        guard let locationName = person.lastSeenAt else { return }
                        MPService.shared.getLocationByName(name: locationName) { location in
                            guard let location = location else { return }
                            mapPins.append(.init(missingPerson: person, coordinate: location.coordinate))
                        }
                    }
                }
            }
        }
    }

    func isCoordinateVisible(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return viewRegion.contains(coordinate)
    }
}

struct SummarySheetView: View {
    @Binding var selectedPerson: MissingPerson?
    @State var showDetails = false
    var body: some View {
        ZStack {
            Color("Background").edgesIgnoringSafeArea(.all)
            VStack {
                HStack(spacing: 15) {
                    if let selectedPerson = selectedPerson,
                       let imageData = selectedPerson.imageData,
                       let uiImage = UIImage(data: imageData)
                    {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 80, maxHeight: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 2)
                            )

                        VStack(alignment: .leading) {
                            Text("\(selectedPerson.name.firstLetterCapitalized())")
                                .font(.title)
                                .bold()
                                .padding(.bottom, 5)

                            if let lastSeenAt = selectedPerson.lastSeenAt { 
                                Text(lastSeenAt)
                                    .font(.footnote)
                                    .opacity(0.2)
                            }
                            if let missingSince = selectedPerson.missingSince { 
                                Text(missingSince)
                                    .font(.footnote)
                                    .opacity(0.2)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Button(action: {
                    DispatchQueue.main.async {
                        self.showDetails = true
                    }
                }) {
                    HStack(alignment: .center, spacing: 15) {
                        Text("Visa mer")
                            .font(.system(size: 14, weight: .regular))
                            .bold()
                    }
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .opacity(0.8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("SemiBackground"))
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 25)
            .sheet(isPresented: $showDetails, onDismiss: { self.selectedPerson = nil }) {
                ZStack {
                    Color("Background").edgesIgnoringSafeArea(.all)
                    if let missingPerson = selectedPerson {
                        MissingPersonDetailedView(missingPerson: missingPerson)
                    }
                }
                .presentationDetents([.large])
            }
        }
        .presentationDetents([.small])
    }
}

extension PresentationDetent {
    static let bar = Self.custom(BarDetent.self)
    static let small = Self.height(200)
    static let extraLarge = Self.fraction(0.75)
}

extension MKCoordinateRegion {
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let regionBounds = (
            minLatitude: center.latitude - span.latitudeDelta / 3,
            maxLatitude: center.latitude + span.latitudeDelta / 3,
            minLongitude: center.longitude - span.longitudeDelta / 3,
            maxLongitude: center.longitude + span.longitudeDelta / 3
        )

        let isCoordinateInsideRegion =
            coordinate.latitude >= regionBounds.minLatitude &&
            coordinate.latitude <= regionBounds.maxLatitude &&
            coordinate.longitude >= regionBounds.minLongitude &&
            coordinate.longitude <= regionBounds.maxLongitude

        return isCoordinateInsideRegion
    }
}


private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        max(44, context.maxDetentValue * 0.1)
    }
}
