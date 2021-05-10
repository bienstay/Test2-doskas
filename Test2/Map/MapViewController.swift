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
        
        if let r = restaurant {
            title = r.name
        }
        else {
            title = hotel.name
        }

        //mapView.delegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
        else {  // all facilities
            var annotations: [MKPointAnnotation] = []
            for ft in hotel.facilities {
                for f in hotel.facilities[ft.key]! {
                    let coordinate = CLLocationCoordinate2D(latitude: f.value.geoLatitude, longitude: f.value.geoLongitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = f.value.name
                    annotations.append(annotation)
                }
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
