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

class IntervalWorkout {
  
  // MARK: - Properties
  let workout: HKWorkout
  let configuration: WorkoutConfiguration
  let intervals: [IntervalWorkoutInterval]
  
  init(withWorkout workout:HKWorkout, configuration:WorkoutConfiguration) {
    self.workout = workout
    self.configuration = configuration
    self.intervals = {
      var ints: [IntervalWorkoutInterval] = [IntervalWorkoutInterval]()
      
      let activeLength = configuration.activeTime
      let restLength = configuration.restTime
      
      var intervalStart = workout.startDate
      
      while intervalStart.compare(workout.endDate) == .OrderedAscending {
        let restStart = NSDate(timeInterval: activeLength, sinceDate: intervalStart)
        let interval = IntervalWorkoutInterval(activeStartTime: intervalStart,
          restStartTime: restStart,
          duration: activeLength,
          endTime: NSDate(timeInterval: restLength, sinceDate: restStart)
        )
        ints.append(interval)
        intervalStart = NSDate(timeInterval: activeLength + restLength, sinceDate: intervalStart)
      }
      return ints
    } ()
  }
  
  // MARK: - Read-Only Properties
  
  var distanceType: HKQuantityType {
    if workout.workoutActivityType == .Cycling {
      return cyclingDistanceType
    } else {
      return runningDistanceType
    }
  }
  
  var startDate: NSDate {
    return workout.startDate
  }
  
  var endDate: NSDate {
    return workout.endDate
  }
  
  var duration: NSTimeInterval {
    return workout.duration
  }
  
  var calories: Double {
    guard let energy = workout.totalEnergyBurned else {return 0.0}
    
    return energy.doubleValueForUnit(energyUnit)
  }
  
  var distance: Double {
    guard let dist = workout.totalDistance else {return 0.0}
    
    return dist.doubleValueForUnit(distanceUnit)
  }
}

class IntervalWorkoutInterval {
  let activeStartTime: NSDate
  let duration: NSTimeInterval
  let restStartTime: NSDate
  let endTime: NSDate
  
  init (activeStartTime: NSDate, restStartTime: NSDate, duration: NSTimeInterval, endTime: NSDate) {
    self.activeStartTime = activeStartTime
    self.restStartTime = restStartTime
    self.duration = duration
    self.endTime = endTime
  }
  
  var distanceStats: HKStatistics?
  var hrStats: HKStatistics?
  var caloriesStats: HKStatistics?
  
  var distance: Double? {
    guard let distanceStats = distanceStats else { return nil }
    return distanceStats.sumQuantity()?.doubleValueForUnit(distanceUnit)
  }
  
  var averageHeartRate: Double? {
    guard let hrStats = hrStats else { return nil }
    return hrStats.averageQuantity()?.doubleValueForUnit(hrUnit)
  }
  
  var calories: Double? {
    guard let caloriesStats = caloriesStats else { return nil }
    return caloriesStats.sumQuantity()?.doubleValueForUnit(energyUnit)
  }
}

