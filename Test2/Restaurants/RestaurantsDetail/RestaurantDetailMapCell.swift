//
//  RestaurantDetailMapCell.swift
//  FoodPin
//
//  Created by maciulek on 02/04/2021.
//

import UIKit
import MapKit

class RestaurantDetailMapCell: UITableViewCell {

    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.layer.cornerRadius = 20.0
            mapView.clipsToBounds = true
        }
    }

    override func awakeFromNib() { super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }

/*
    func configure(location: String) {
        let geoCoder = CLGeocoder() // Get location
        geoCoder.geocodeAddressString(location, completionHandler:
            { placemarks, error in
                if let error = error { Log.log(error.localizedDescription); return }
                if let placemark = placemarks?[0], let location = placemark.location {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
                    self.mapView.setRegion(region, animated: false)
                    self.mapView.addAnnotation(annotation)
                }
            }
        )
    }
*/

    func configure(_ longitude: Double, _ latitude: Double) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        self.mapView.setRegion(region, animated: false)
        self.mapView.addAnnotation(annotation)

        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        mapView.showsPointsOfInterest = false
        if #available(iOS 13, *) {
            //mapView.pointOfInterestFilter?.excludes(MKPointOfInterestCategory.atm)
            //mapView.pointOfInterestFilter = MKPointOfInterestFilter(
        }
    }

}

