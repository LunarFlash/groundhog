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

class WorkoutConfiguration {
  
  let exerciseType: ExerciseType
  var activeTime: NSTimeInterval
  var restTime: NSTimeInterval
  
  private let exerciseTypeKey = "com.raywenderlich.config.exerciseType"
  private let activeTimeKey = "com.raywenderlich.config.activeTime"
  private let restTimeKey = "com.raywenderlich.config.restTime"
  
  init(exerciseType: ExerciseType = .Other, activeTime: NSTimeInterval = 120, restTime: NSTimeInterval = 30) {
    self.exerciseType = exerciseType
    self.activeTime = activeTime
    self.restTime = restTime
  }
  
  init(withDictionary rawDictionary:[String : AnyObject]) {
    if let type = rawDictionary[exerciseTypeKey] as? Int {
      self.exerciseType = ExerciseType(rawValue: type)!
    } else {
      self.exerciseType = ExerciseType.Other
    }
    
    if let active = rawDictionary[activeTimeKey] as? NSTimeInterval {
      self.activeTime = active
    } else {
      self.activeTime = 120
    }
    
    if let rest = rawDictionary[restTimeKey] as? NSTimeInterval {
      self.restTime = rest
    } else {
      self.restTime = 30
    }
  }
  
  func intervalDuration() -> NSTimeInterval {
    return activeTime + restTime
  }
  
  func dictionaryRepresentation() -> [String : AnyObject] {
    return [
      exerciseTypeKey : exerciseType.rawValue,
      activeTimeKey : activeTime,
      restTimeKey : restTime,
    ]
  }
}