//
//  CustomMapView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-02-18.
//

import SwiftUI
import MapKit

class AnnotationManager: ObservableObject {
    let id: UUID!
    @Published var region: MKCoordinateRegion
    @Published var image: UIImage?
    @Published var annotation: PersonMapPin? {
        didSet {
            if let annotation = annotation, let data = annotation.missingPerson.imageData {
                image = UIImage(data: data)
            }
        }
    }
    @Published var circleView: UIView? = nil

    init(region: MKCoordinateRegion, annnotation: PersonMapPin? = nil) {
        self.id = UUID()
        self.region = region
        self.annotation = annnotation
    }

    func isCoordinateVisible() -> Bool {
        if let coordinate = annotation?.coordinate {
            return region.contains(coordinate)
        } else {
            return false
        }
    }
}

class PersonAnnotationView: MKAnnotationView {

    // MARK: - Properties

    @ObservedObject var manager: AnnotationManager = .init(region: MKCoordinateRegion())
    var onAnnotationTap: ((PersonMapPin) -> Void)? = nil
    var circleView: UIImageView!



    // MARK: - Initialization

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        frame.size = CGSize(width: 40, height: 40)

        self.circleView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = self.frame.width / 2  // half of the width/height to make it a circle
            view.backgroundColor = UIColor.blue  // Set your desired color
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor.white.cgColor
            return view
        }()

        self.manager.circleView = circleView
        addSubview(circleView)

        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            circleView.widthAnchor.constraint(equalTo: self.widthAnchor),
            circleView.heightAnchor.constraint(equalTo: self.heightAnchor),
        ])

        // Add a tap gesture directly to the MKAnnotationView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAnnotationTap))
        addGestureRecognizer(tapGesture)
    }

    @objc func handleAnnotationTap(_ gesture: UITapGestureRecognizer) {
        guard let annotation = manager.annotation else { return }
        guard let onAnnotationTap = onAnnotationTap else { return }

        UIView.animate {
            self.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                UIView.animate {
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        }

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
        feedbackGenerator.impactOccurred()

        onAnnotationTap(annotation)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Override hitTest to ensure the tap gesture is recognized regardless of zoom level
        if let hitView = super.hitTest(point, with: event) {
            return hitView
        }

        for subview in subviews {
            let convertedPoint = subview.convert(point, from: self)
            if let hitSubview = subview.hitTest(convertedPoint, with: event) {
                return hitSubview
            }
        }

        return nil
    }
}

struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var annotations: [PersonMapPin]
    var onMapCameraChange: ((MKCoordinateRegion) -> Void)?
    var onAnnotationTap: ((PersonMapPin) -> Void)?

    init(
        region: Binding<MKCoordinateRegion>,
        annotations: Binding<[PersonMapPin]>,
        onMapCameraChange: ( (MKCoordinateRegion) -> Void)? = nil,
        onAnnotationTap: ((PersonMapPin) -> Void)? = nil
    ) {
        self._region = region
        self._annotations = annotations
        self.onMapCameraChange = onMapCameraChange
        self.onAnnotationTap = onAnnotationTap
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        mapView.pointOfInterestFilter = .excludingAll
        mapView.register(PersonAnnotationView.self, forAnnotationViewWithReuseIdentifier: "PersonAnnotationView")
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        DispatchQueue.main.async {
            mapView.addAnnotations(annotations)
            for annotation in annotations {
                if let annotationView = mapView.view(for: annotation) as? PersonAnnotationView {
                    annotationView.manager.region = self.region
                    if let image = annotationView.manager.image {
                        annotationView.circleView.image = image
                    }
                    UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut) {
                        annotationView.isUserInteractionEnabled = annotationView.manager.isCoordinateVisible()
                        annotationView.alpha = annotationView.manager.isCoordinateVisible() ? 1 : 0.2
                        annotationView.transform = CGAffineTransform(
                            scaleX: annotationView.manager.isCoordinateVisible() ? 1 : 0.5,
                            y: annotationView.manager.isCoordinateVisible() ? 1 : 0.5
                        )
                    }
                }
            }
        }
    }
}

extension CustomMapView {
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: CustomMapView

        init(parent: CustomMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? PersonMapPin else { return nil }
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PersonAnnotationView")

            if annotationView == nil {
                annotationView = PersonAnnotationView(annotation: annotation, reuseIdentifier: "PersonAnnotationView")
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }

            if let personAnnotationView = annotationView as? PersonAnnotationView {
                personAnnotationView.manager.region = self.parent.region
                personAnnotationView.manager.annotation = annotation
                personAnnotationView.onAnnotationTap = self.parent.onAnnotationTap
                personAnnotationView.isEnabled = false
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) { }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            DispatchQueue.main.async {
                self.parent.region = mapView.region
                self.parent.onMapCameraChange?(mapView.region)
            }
        }
    }
}

struct TestView: View {
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State var annotations: [PersonMapPin] = [.init(
        missingPerson: .mock,
        coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    )]

    var body: some View {
        ZStack {
            CustomMapView(region: $region, annotations: $annotations).edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    TestView()
}
