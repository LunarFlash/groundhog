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

import WatchKit
import Foundation

class WorkoutTypesInterfaceController: WKInterfaceController {

  
  // MARK: ****** UI Elements ******
  @IBOutlet weak var table: WKInterfaceTable!

  // MARK: ****** Lifecycle ******
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    setupTable()
  }
  
  override func willActivate() {
    super.willActivate()
    
    // Request HealthKit permission
    // In reality, it's not the Watch that requests HealthKit permissions; instead, the host iPhone app presents an interface. So you'll need to present and handle the results of the user's interactions with that UI in AppDelegate
    let healthService:HealthDataService = HealthDataService()
    healthService.authorizeHealthKitAccess { (success, error) -> Void in
      if success {
        print("HealthKit authorization recieved")
      } else {
        print("HealthKit authorization denied")
        if error != nil {print(error)}
      }
    }
    
    
  }
  
  // MARK: ****** Navigation ******
  override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
    let row = table.rowControllerAtIndex(rowIndex) as! ExerciseTypeRowController
    guard let exercise = row.exerciseType else {return nil}
    return WorkoutConfiguration(exerciseType: exercise)
  }
  
  // MARK: ****** Helpers ******
  func setupTable() {
    let allExercises = ExerciseType.allValues
    table.setNumberOfRows(allExercises.count, withRowType: "ExerciseTypeRowController")
    
    var i = 0
    for exercise in allExercises {
      let row = table.rowControllerAtIndex(i) as! ExerciseTypeRowController
      row.exerciseType = exercise
      i++
    }
  }
}
