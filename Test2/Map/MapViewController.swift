//
//  MapViewController.swift
//  Test2
//
//  Created by maciulek on 04/05/2021.
//

import UIKit
import MapKit

class MyAnnotation: MKPointAnnotation {
    var poi: POI?
}

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    var restaurant: Restaurant?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        mapView.delegate = self
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
            var annotations: [MyAnnotation] = []
            var pois: [POI] = []
            pois.append(contentsOf: hotel.restaurants)
            pois.append(contentsOf: hotel.facilities)
            for p in pois {
                let coordinate = CLLocationCoordinate2D(latitude: p.geoLatitude, longitude: p.geoLongitude)
                let annotation = MyAnnotation()
                annotation.coordinate = coordinate
                annotation.title = p.name
                annotation.poi = p
                annotations.append(annotation)
            }
            mapView.showAnnotations(annotations, animated: true)
            var region = mapView.region
            region.span.latitudeDelta = 2 * region.span.latitudeDelta
            region.span.longitudeDelta = 2 * region.span.longitudeDelta
            mapView.setRegion(region, animated: true)
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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "MyMarker"
        let myAnnotation = annotation as! MyAnnotation
        var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: myAnnotation, reuseIdentifier: reuseIdentifier)
        }
        var color = UIColor.red
        switch myAnnotation.poi?.type {
        case .Restaurant: color = .red
        case .Recreation: color = .green
        case .Administration: color = .blue
        default: color = .red
        }
        annotationView?.markerTintColor = color
        return annotationView
    }
}
