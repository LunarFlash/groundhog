/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import HealthKit


protocol WorkoutSessionServiceDelegate: class {
  /// This method is called when an HKWorkoutSession is correctly started
  func workoutSessionService(service: WorkoutSessionService, didStartWorkoutAtDate startDate: NSDate)

  /// This method is called when an HKWorkoutSession is correctly stopped
  func workoutSessionService(service: WorkoutSessionService, didStopWorkoutAtDate endDate: NSDate)

  /// This method is called when a workout is successfully saved
  func workoutSessionServiceDidSave(service: WorkoutSessionService)
  
  /// This method is called when an anchored query receives new heart rate data
  func workoutSessionService(service: WorkoutSessionService, didUpdateHeartrate heartRate:Double)

  /// This method is called when an anchored query receives new distance data
  func workoutSessionService(service: WorkoutSessionService, didUpdateDistance distance:Double)
  
  /// This method is called when an anchored query receives new energy data
  func workoutSessionService(service: WorkoutSessionService, didUpdateEnergyBurned energy:Double)
}


class WorkoutSessionService: NSObject {
  private let healthService = HealthDataService()
  let configuration: WorkoutConfiguration
  
  var startDate: NSDate?
  var endDate: NSDate?
  
  // ****** Units and Types
  var distanceType: HKQuantityType {
    if self.configuration.exerciseType.workoutType == .Cycling {
      return cyclingDistanceType
    } else {
      return runningDistanceType
    }
  }
  
  // ****** Stored Samples and Queries
  var energyData: [HKQuantitySample] = [HKQuantitySample]()
  var hrData: [HKQuantitySample] = [HKQuantitySample]()
  var distanceData: [HKQuantitySample] = [HKQuantitySample]()
  
  // ****** Query Management
  private var queries: [HKQuery] = [HKQuery]()
  internal var distanceAnchorValue:HKQueryAnchor?
  internal var hrAnchorValue:HKQueryAnchor?
  internal var energyAnchorValue:HKQueryAnchor?

  weak var delegate:WorkoutSessionServiceDelegate?
  
  // ****** Current Workout Values
  var energyBurned: HKQuantity
  var distance: HKQuantity
  var heartRate: HKQuantity
  
  init(configuration: WorkoutConfiguration) {
    self.configuration = configuration
    
    // Initialize Current Workout Values
    energyBurned = HKQuantity(unit: energyUnit, doubleValue: 0.0)
    distance = HKQuantity(unit: distanceUnit, doubleValue: 0.0)
    heartRate = HKQuantity(unit: hrUnit, doubleValue: 0.0)

    super.init()
  }
  
  func startSession() {
  }
  
  func stopSession() {
    // Let the delegate know
    self.delegate?.workoutSessionService(self, didStopWorkoutAtDate: NSDate())
  }
  
  func saveSession() {
  }
}
