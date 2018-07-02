//
//  LocationServiceDelegate.swift
//  prototype_2
//
//  Created by Leo Schoberwalter on 26.06.18.
//  Copyright © 2018 Leo Schoberwalter. All rights reserved.
//

import CoreLocation

protocol LocationServiceDelegate: class {
    func trackingLocation(for currentLocation: CLLocation)
    func trackingLocationDidFail(with error: Error)
}
