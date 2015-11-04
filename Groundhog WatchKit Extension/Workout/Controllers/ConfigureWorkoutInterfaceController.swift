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

class ConfigureWorkoutInterfaceController: WKInterfaceController {
  
  // MARK: - ****** Models ******
  
  var workoutConfiguration: WorkoutConfiguration?
  
  
  // MARK: - ****** UI ******
  
  @IBOutlet var activePicker: WKInterfacePicker!
  @IBOutlet var restPicker: WKInterfacePicker!
  
  
  // MARK: - ****** Lifecycle ******
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    workoutConfiguration = context as? WorkoutConfiguration
    
    // Configure the Active Time Picker
    activePicker.setItems(activeTimePickerValues.map { (interval) -> WKPickerItem in
      let item = WKPickerItem()
      item.contentImage = WKImage(image: interval.elapsedTimeImage())
      return item
    })
    
    if let index = activeTimePickerValues.indexOf((workoutConfiguration?.activeTime)!) {
      activePicker.setSelectedItemIndex(index)
    } else {
      activePicker.setSelectedItemIndex(0)
    }
    
    // Configure the Rest Time Picker
    restPicker.setItems(restTimePickerValues.map { (interval) -> WKPickerItem in
      let item = WKPickerItem()
      item.contentImage = WKImage(image: interval.elapsedTimeImage())
      return item
      })
    restPicker.setSelectedItemIndex(0)

    if let index = restTimePickerValues.indexOf((workoutConfiguration?.restTime)!) {
      restPicker.setSelectedItemIndex(index)
    } else {
      restPicker.setSelectedItemIndex(0)
    }
  }
  
  // MARK: - ****** Navigation ******
  
  override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
    return workoutConfiguration
  }
  
  // MARK: - ****** Pickers ******
  
  let activeTimePickerValues: [NSTimeInterval] = {
    var intervals = [NSTimeInterval]()
    for var time = 10; time <= 600; time+=5 {
      intervals.append(NSTimeInterval(time))
    }
    return intervals
  } ()
  
  let restTimePickerValues: [NSTimeInterval] = {
    var intervals = [NSTimeInterval]()
    for var time = 5; time <= 120; time+=5 {
      intervals.append(NSTimeInterval(time))
    }
    return intervals
  } ()
  
  @IBAction func pickActiveTime(value: Int) {
    workoutConfiguration?.activeTime = activeTimePickerValues[value]
  }
  
  @IBAction func pickRestTime(value: Int) {
    workoutConfiguration?.restTime = restTimePickerValues[value]
  }
  
}
