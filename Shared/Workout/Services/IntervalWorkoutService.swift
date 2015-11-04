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

class IntervalWorkoutService {
  
  private let healthService = HealthDataService()
  
  /// This method gets a list of workouts from HealthKit and reformats them as IntervalWorkouts.
  /// It uses the metadata written by the watch to determine how long the intervals were when it was created
  func readIntervalWorkouts(completion: (success: Bool, workouts:[IntervalWorkout], error: NSError!) -> Void) {
    
    healthService.readWorkouts { (success, workouts, error) -> Void in
      
      var intervalWorkouts:[IntervalWorkout] = [IntervalWorkout]()
      
      // Loop through results
      for workout in workouts {
        // There's no Metadata, so it must not be an IntervalWorkout that we created - Just make it with one interval
        guard let metadata = workout.metadata where metadata.count > 0 else {
          let basicConfiguration = WorkoutConfiguration(exerciseType: ExerciseType.Other, activeTime: workout.duration, restTime: 0)
          let basicIntervalWorkout = IntervalWorkout(withWorkout: workout, configuration: basicConfiguration)
          intervalWorkouts.append(basicIntervalWorkout)
          continue
        }
        
        // Determine The Configuration
        let configuration = WorkoutConfiguration(withDictionary: metadata)
        
        // Create a workout
        let intervalWorkout = IntervalWorkout(withWorkout: workout, configuration: configuration)
        intervalWorkouts.append(intervalWorkout)
      }
      
      // Return the results to the caller
      completion(success: success, workouts: intervalWorkouts, error: error)
    }
    
  }
  
  func readWorkoutDetail(workout:IntervalWorkout, completion: (success: Bool, error: NSError!) -> Void) {
    
    // Start a dispatch group to get all the data
    let loadAllDataDispatchGroup = dispatch_group_create()
    
    for interval in workout.intervals {

      // Get Distance Data
      dispatch_group_enter(loadAllDataDispatchGroup)
      statisticsForInterval(interval, workout: workout, type: workout.distanceType, options: .CumulativeSum, completion: { (stats, error) -> Void in
        interval.distanceStats = stats
        dispatch_group_leave(loadAllDataDispatchGroup)
      })
      
      // Get HR Data
      dispatch_group_enter(loadAllDataDispatchGroup)
      statisticsForInterval(interval, workout: workout, type: hrType, options: .DiscreteAverage, completion: { (stats, error) -> Void in
        interval.hrStats = stats
        dispatch_group_leave(loadAllDataDispatchGroup)
      })
      
      // Energy Data
      dispatch_group_enter(loadAllDataDispatchGroup)
      statisticsForInterval(interval, workout: workout, type: energyType, options: .CumulativeSum, completion: { (stats, error) -> Void in
        interval.caloriesStats = stats
        dispatch_group_leave(loadAllDataDispatchGroup)
      })
    }
    
    // Now that all the work is done, call the completion handler
    dispatch_group_notify(loadAllDataDispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
      completion(success: true, error: nil)
    }
  }
  
  private func statisticsForInterval(interval: IntervalWorkoutInterval, workout: IntervalWorkout, type: HKQuantityType, options:HKStatisticsOptions,
    completion: (stats: HKStatistics!, error: NSError!) -> Void) {
      
      healthService.statisticsForWorkout(workout.workout,
        intervalStart: interval.activeStartTime,
        intervalEnd: interval.restStartTime,
        type: type,
        options: options) { (statistics, error) -> Void in
        
          completion(stats: statistics, error: error)
      }
  }
}
