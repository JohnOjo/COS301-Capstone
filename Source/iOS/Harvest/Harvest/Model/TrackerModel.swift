//
//  TrackerModel.swift
//  Harvest
//
//  Created by Letanyan Arumugam on 2018/03/29.
//  Copyright © 2018 Letanyan Arumugam. All rights reserved.
//

import UIKit
import CoreLocation

struct Tracker {
  var sessionStart: Date
  var lastCollection: Date
  
  init() {
    sessionStart = Date()
    lastCollection = sessionStart
  }
  
  mutating func collect(yield: Double, at loc: CLLocation) {
    let collectionDate = Date()
    let duration = collectionDate.timeIntervalSince(lastCollection)
    lastCollection = Date()
    
    HarvestDB.collect(yield: yield,
                      from: HarvestUser.current.name,
                      inAmountOfSeconds: duration,
                      at: loc.coordinate,
                      on: collectionDate)
  }
  
}
