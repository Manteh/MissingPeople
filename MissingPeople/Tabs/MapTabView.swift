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

struct MapTabView: View {
    @Binding var missingPeople: [MissingPerson]

    @State private var locations: [Location] = []
    @State private var selectedTag: Int?
    @State private var selectedPerson: MissingPerson? = nil
    @State private var isSheetPresented = false

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
                        DispatchQueue.main.async {
                            self.selectedPerson = annotation.missingPerson
                            if let selectedPerson = self.selectedPerson {
                                self.isSheetPresented = true
                            }
                        }
                    }, onMapTap: { self.isSheetPresented = false })
                    .edgesIgnoringSafeArea(.top)
                } else {
                    ProgressView()
                }
            }
            .toolbar(.hidden)
            .sheet(isPresented: $isSheetPresented) {
                SummarySheetView(selectedPerson: $selectedPerson, isParentPresented: $isSheetPresented)
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
    @Binding var isParentPresented: Bool
    @State var showDetails = false
    @State var animations = [false, false, false]
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
                                    .opacity(0.8)
                            )

                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(selectedPerson.name.firstLetterCapitalized())")
                                .font(.title)
                                .bold()
                                .offset(x: self.animations[0] ? 0 : 20)
                                .opacity(self.animations[0] ? 0.8 : 0)

                            if let lastSeenAt = selectedPerson.lastSeenAt { 
                                Text(lastSeenAt)
                                    .font(.system(size: 14, weight: .semibold))
                                    .offset(y: self.animations[1] ? 0 : 20)
                                    .opacity(self.animations[1] ? 0.2 : 0)
                            }
                            if let missingSince = selectedPerson.missingSince { 
                                Text(missingSince)
                                    .font(.system(size: 14, weight: .semibold))
                                    .offset(y: self.animations[2] ? 0 : 20)
                                    .opacity(self.animations[2] ? 0.2 : 0)
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.spring) {
                                    self.animations[0] = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring) {
                                        self.animations[1] = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring) {
                                            self.animations[2] = true
                                        }
                                    }
                                }
                            }
                        }   
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                Button(action: {
                    if let _ = selectedPerson {
                        DispatchQueue.main.async {
                            self.showDetails = true
                        }
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
            .sheet(isPresented: $showDetails) {
                ZStack {
                    if let selectedPerson = selectedPerson {
                        Color("Background").edgesIgnoringSafeArea(.all)
                        MissingPersonDetailedView(missingPerson: selectedPerson)
                    } else {
                        ProgressView().onAppear { self.showDetails = false }
                    }
                }
                .presentationDetents([.large])
            }
        }
        .presentationDetents([.small])
        .presentationBackgroundInteraction(.enabled(upThrough: .small))
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
