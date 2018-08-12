//
//  BSCMapView.swift
//  bachelorarbeit-prototyp
//
//  Created by Hans Seiffert on 29.01.16.
//  Copyright © 2016 Hans Seiffert. All rights reserved.
//

import Foundation
import MapKit

class BSCMapView: UIView {
	
	struct BSCMapViewConstants {
		static let OverlayRectOffset		= Double(5000)
	}
	
	let mapView								= MKMapView()

	// MARK: Lifecycle
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.mapView.delegate = self
		self.mapView.scrollEnabled = false
		self.mapView.showsBuildings = false
		self.mapView.showsTraffic = false
		self.mapView.showsPointsOfInterest = false
		self.mapView.rotateEnabled = false
		
		self.addSubview(self.mapView)
		self.mapView.frame = self.bounds
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.mapView.frame = self.bounds
	}
	
	// MARK: -
	
	func resetLocations() {
		self.mapView.removeOverlays(self.mapView.overlays)
	}
	
	func showLocations(locations: [CLLocation]?) {
		self.mapView.delegate = self
		self.resetLocations()
		self.addLocations(locations, colorHex: "FF0000")
	}
	
	func addLocations(locations: [CLLocation]?, colorHex: String) {
		self.mapView.delegate = self
		if let _locations = locations {
			for location in _locations {
				let circle = MKCircle(centerCoordinate: location.coordinate, radius: location.horizontalAccuracy)
				circle.title = colorHex
				self.mapView.addOverlay(circle)
			}
		}
		
		var zoomRect = MKMapRectNull
		for overlay in self.mapView.overlays {
			
			var rect = overlay.boundingMapRect
			rect.origin.x -= (BSCMapViewConstants.OverlayRectOffset / 2)
			rect.origin.y -= (BSCMapViewConstants.OverlayRectOffset / 2)
			rect.size.width += BSCMapViewConstants.OverlayRectOffset
			rect.size.height += BSCMapViewConstants.OverlayRectOffset
			if (MKMapRectIsNull(zoomRect) == true) {
				zoomRect = rect
			} else {
				zoomRect = MKMapRectUnion(zoomRect, rect)
			}
		}
		self.mapView.setVisibleMapRect(zoomRect, animated: false)
	}
}

// MARK: - MKMapViewDeleagate

extension BSCMapView : MKMapViewDelegate {
	
	func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
		let circle = MKCircleRenderer(overlay: overlay)
		if let
			_title = overlay.title,
			_hexString = _title {
				circle.strokeColor = UIColor(fromHexString: _hexString)
				circle.fillColor = UIColor(fromHexString: _hexString, alpha: 0.1)
		} else {
			circle.strokeColor = UIColor.redColor()
			circle.fillColor = UIColor.redColorWithAlpha(0.1)
		}
		circle.lineWidth = 1
		return circle
	}
}