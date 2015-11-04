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

class WorkoutListViewController: UITableViewController {
  
  let workoutService = IntervalWorkoutService()
  var workouts: [IntervalWorkout]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
    
    // This code is pretty much the same as the code you placed in the AppDelegate, but in this case, you refresh the controller's tableView if the user grants access. Also, note that you dispatch to the main thread: HKHealthStore doesn't make any guarantees that it will call completion blocks on the queue that a method was called upon, so you'll need to dispatch UIKit methods to the main thread, as usual. Now you have access to HealthKit for reading and writing.
    
    let healthService:HealthDataService = HealthDataService()
    healthService.authorizeHealthKitAccess { accessGranted, error in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        if accessGranted {
          self.refresh(nil)
        } else {
          print("HealthKit authorization denied! \n\(error)")
        }
      })
    }
    
    
    
    
  }
  
  
  // MARK: - Actions
  
  @IBAction func refresh(sender: AnyObject?) {
      self.refreshControl?.beginRefreshing()
      self.workoutService.readIntervalWorkouts { (success, workouts, error) -> Void in
    dispatch_async(dispatch_get_main_queue(), { () -> Void in
    self.refreshControl?.endRefreshing()
    self.workouts = workouts
    self.tableView.reloadData()
    })
      }
  }
  
  
  // MARK: - Table view data source
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      guard let workouts = workouts else {return 0}
      
      return workouts.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("WorkoutCell", forIndexPath: indexPath) as! WorkoutCell
    
    cell.workout = workouts![indexPath.row]
    
    return cell
  }
  
  
  // MARK: - UITableViewDelegate
  
  override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      // Hides the empty cell row separators
      return 0.01
  }
  
  override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    // Hides the empty cell row separators
    return UIView()
  }
  
  
  // MARK: - Navigation
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      let vc = segue.destinationViewController as! WorkoutViewController
      vc.workoutService = workoutService
      vc.workout = workouts![self.tableView.indexPathForSelectedRow!.row]
  }
  
}
