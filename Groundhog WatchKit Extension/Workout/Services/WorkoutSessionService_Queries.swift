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

extension WorkoutSessionService {
  
  internal func distanceQuery(withStartDate start: NSDate) -> HKQuery {
    // Query all samples from the beginning of the workout session
    let predicate = HKQuery.predicateForSamplesWithStartDate(start, endDate: nil, options: .None)
    
    let query = HKAnchoredObjectQuery(type: distanceType,
      predicate: predicate,
      anchor: distanceAnchorValue,
      limit: Int(HKObjectQueryNoLimit)) {
        (query, samples, deleteObjects, anchor, error) -> Void in
        
        self.distanceAnchorValue = anchor
        self.newDistanceSamples(samples)
    }
    
    query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
      self.distanceAnchorValue = newAnchor
      self.newDistanceSamples(samples)
    }
    return query
  }
  
  internal func newDistanceSamples(samples: [HKSample]?) {
    // Abort if the data isn't right
    guard let samples = samples as? [HKQuantitySample] where samples.count > 0 else {
      return
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.distance = self.distance.addSamples(samples, unit: distanceUnit)
      self.distanceData += samples
      
      self.delegate?.workoutSessionService(self, didUpdateDistance:self.distance.doubleValueForUnit(distanceUnit))
    }
  }
  
  internal func energyQuery(withStartDate start: NSDate) -> HKQuery {
    // Query all samples from the beginning of the workout session
    let predicate = HKQuery.predicateForSamplesWithStartDate(start, endDate: nil, options: .None)
    
    let query = HKAnchoredObjectQuery(type: (energyType),
      predicate: predicate,
      anchor: energyAnchorValue,
      limit: Int(HKObjectQueryNoLimit)) {
        (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
        
        self.energyAnchorValue = newAnchor
        self.newEnergySamples(sampleObjects)
    }
    
    query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
      self.energyAnchorValue = newAnchor
      self.newEnergySamples(samples)
    }
    
    return query
  }
  
  internal func newEnergySamples(samples: [HKSample]?) {
    // Abort if the data isn't right
    guard let samples = samples as? [HKQuantitySample] where samples.count > 0 else {
      return
    }
    
    dispatch_async(dispatch_get_main_queue()) {
      self.energyBurned = self.energyBurned.addSamples(samples, unit: energyUnit)
      self.energyData += samples
      
      self.delegate?.workoutSessionService(self, didUpdateEnergyBurned: self.energyBurned.doubleValueForUnit(energyUnit))
    }
  }
}