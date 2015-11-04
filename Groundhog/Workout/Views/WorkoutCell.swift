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

import UIKit
import HealthKit

class WorkoutCell: UITableViewCell {
  
  var workout: IntervalWorkout? {
    willSet(newWorkout) {
      self.activityTypeLabel?.text = newWorkout?.configuration.exerciseType.title.uppercaseString
      
      if let elapsedTime = elapsedTimeFormatter.stringFromTimeInterval((newWorkout?.duration)!) {
        self.durationLabel.text = elapsedTime
      }
      
      if let startDate = newWorkout?.startDate {
        self.descriptionLabel?.text = "\(dateOnlyFormatter.stringFromDate(startDate)) at \(timeOnlyFormatter.stringFromDate(startDate))"
      }
    }
  }
  
  @IBOutlet weak var activityTypeLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.activityTypeLabel?.text = nil
    self.descriptionLabel?.text = nil
    self.durationLabel?.text = nil
  }
}
