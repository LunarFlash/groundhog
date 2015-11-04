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

extension ExerciseType {
  var location: HKWorkoutSessionLocationType {
    switch self {
    case .Cycling:                    return HKWorkoutSessionLocationType.Outdoor
    case .StationaryBike:             return HKWorkoutSessionLocationType.Indoor
    case .Elliptical:                 return HKWorkoutSessionLocationType.Indoor
    case .FunctionalStrengthTraining: return HKWorkoutSessionLocationType.Indoor
    case .Rowing:                     return HKWorkoutSessionLocationType.Outdoor
    case .RowingMachine:              return HKWorkoutSessionLocationType.Indoor
    case .Running:                    return HKWorkoutSessionLocationType.Outdoor
    case .Treadmill:                  return HKWorkoutSessionLocationType.Indoor
    case .StairClimbing:              return HKWorkoutSessionLocationType.Indoor
    case .Swimming:                   return HKWorkoutSessionLocationType.Indoor
    case .Stretching:                 return HKWorkoutSessionLocationType.Unknown
    case .Walking:                    return HKWorkoutSessionLocationType.Outdoor
    case .Other:                      return HKWorkoutSessionLocationType.Unknown
    }
  }
  
  var locationName: String {
    switch self.location {
    case .Indoor:  return "Indoor Exercise"
    case .Outdoor: return "Outdoor Exercise"
    case .Unknown: return "General Exercise"
    }
  }
}