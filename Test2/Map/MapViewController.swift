//
//  MapViewController.swift
//  Test2
//
//  Created by maciulek on 04/05/2021.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    var restaurant: Restaurant?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        initMapview()

        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = false
        mapView.showsPointsOfInterest = false
        
        mapView.mapType = .satellite

        if let r = restaurant {
            title = r.name
        }
        else {
            title = hotel.name
        }

        //mapView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    func initMapview() {
        if let r = restaurant {     // show single restaurant
            let centerCoordinate = CLLocationCoordinate2D(latitude: r.geoLatitude, longitude: r.geoLongitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = centerCoordinate
            annotation.title = self.restaurant!.name
            mapView.showAnnotations([annotation], animated: true)
            for c in r.cuisines { annotation.subtitle?.append(c) }
            let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 250, longitudinalMeters: 250)
            mapView.setRegion(region, animated: false)
        }
        else {  // all facilities, TODO now restaurants only
            var annotations: [MKPointAnnotation] = []
            for f in hotel.restaurants {
                let coordinate = CLLocationCoordinate2D(latitude: f.geoLatitude, longitude: f.geoLongitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = f.name
                annotations.append(annotation)
            }
            mapView.showAnnotations(annotations, animated: true)
        }
        //self.mapView.selectAnnotation(annotation, animated: true)
    }

}


/*
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyMarker"
        if annotation.isKind(of: MKUserLocation.self) { return nil }
        // Reuse the annotation if possible
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.glyphText = "😋"
//        annotationView?.glyphImage = UIImage(systemName: "arrowtriangle.down.circle")
        annotationView?.markerTintColor = UIColor.green
        return annotationView
    }
}
*/
