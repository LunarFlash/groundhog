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

class WorkoutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // ****** Models
  var workoutService: IntervalWorkoutService?
  var workout: IntervalWorkout?
  
  // ****** Interface Elements
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var table: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let workout = workout else { return }
    
    refresh(nil)
    
    titleLabel?.text = workout.configuration.exerciseType.title
    title = titleLabel?.text
    durationLabel?.text = workout.configuration.exerciseType.quote
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    sizeTableHeaderToFit()
  }

  
  // MARK: - Data Access
  
  private func refresh(sender: AnyObject?) {
    workoutService?.readWorkoutDetail(workout!, completion: { (success, error) -> Void in
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.table.reloadData()
      })
    })
  }
  
  
  // MARK: - Table View sizing
  
  func sizeTableHeaderToFit() {
    
    if let header = table.tableHeaderView {
      header.setNeedsLayout()
      header.layoutIfNeeded()
      let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
      
      var frame = header.frame
      frame.size.height = height
      header.frame = frame
      
      table.tableHeaderView = header
    }
  }
  

  // MARK: - Table view data source
  
  let kHeaderSection = 0
  let kIntervalSection = 1
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case kHeaderSection:
      return TableCells.CellCount.rawValue
    case kIntervalSection:
      return (workout?.intervals.count)!
    default: return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if indexPath.section == kHeaderSection {
      let cellID = TableCells(rawValue: indexPath.row)
      let cell = tableView.dequeueReusableCellWithIdentifier(cellID!.reuseIdentifier, forIndexPath: indexPath)
      cell.imageView?.image = cellID?.image
      
      switch cellID! {
      case .CompletedCell:
        cell.detailTextLabel?.text = dateOnlyFormatter.stringFromDate(workout!.endDate)
        break;
        
      case .CaloriesCell:
        cell.detailTextLabel?.text = calorieFormatter.stringFromValue(workout!.calories, unit: energyFormatterUnit)
        break;
        
      case .DurationCell:
        if let elapsedTime = elapsedTimeFormatter.stringFromTimeInterval(workout!.duration) {
          cell.detailTextLabel?.text = elapsedTime
        }
        break;
        
      case .DistanceCell:
        cell.detailTextLabel?.text = distanceFormatter.stringFromValue(workout!.distance, unit: distanceFormatterUnit)
        break;
        
      default:
        break;
      }
      
      return cell
      
    } else {
      
      // Intervals
      let identifier = (indexPath.row % 2) == 0 ? "WorkoutIntervalCell_Even" : "WorkoutIntervalCell_Odd"
      let intervalCell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! IntervalCell
      intervalCell.interval = workout?.intervals[indexPath.row]
      
      return intervalCell
    }
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.section == kIntervalSection {
      return 30
    } else {
      return tableView.rowHeight
    }
  }

  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    // Hides the empty cell row separators
    return 0.01
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    // Hides the empty cell row separators
    return UIView()
  }
}

private enum TableCells: Int {
  case CompletedCell = 0
  case DurationCell
  case DistanceCell
  case CaloriesCell
  case IntervalHeaderCell
  
  case CellCount
  
  var reuseIdentifier: String {
    switch self {
    case .CompletedCell: return "CompletedCell"
    case .CaloriesCell: return "WorkoutCaloriesCell"
    case .DurationCell: return "WorkoutTimeCell"
    case .DistanceCell: return "WorkoutDistanceCell"
    case .IntervalHeaderCell: return "IntervalHeaderCell"
      
    case .CellCount:    return ""
    }
  }
  
  var image: UIImage? {
    switch self {
    case .CompletedCell: return UIImage(named: "icons-thumbs_up")
    case .CaloriesCell: return UIImage(named: "icons-calories")
    case .DurationCell: return UIImage(named: "icons-duration")
    case .DistanceCell: return UIImage(named: "icons-distance")
    case .IntervalHeaderCell: return nil
      
    default:
      return nil
    }
  }
}
