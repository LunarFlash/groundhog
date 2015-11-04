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

class ActiveWorkoutInterfaceController: WKInterfaceController {
  
  // MARK: - ****** State Management ******
  var startTime: NSDate?
  var timer: NSTimer?
  
  func elapsedTime() -> NSTimeInterval {
    guard let startTime = startTime else {
      return NSTimeInterval(0)
    }
    return NSDate().timeIntervalSinceDate(startTime)
  }
  
  // ****** Models ******
  var workoutConfiguration: WorkoutConfiguration?

  var workoutSession: WorkoutSessionService?

  // ****** UI Elements ******
  @IBOutlet var elapsedTimeLabel: WKInterfaceLabel!
  @IBOutlet var intervalTimeRemainingLabel: WKInterfaceLabel!
  @IBOutlet var intervalPhaseBadge: WKInterfaceLabel!
  @IBOutlet var intervalPhaseContainer: WKInterfaceGroup!
  @IBOutlet var countdownGroup: WKInterfaceGroup!
  @IBOutlet var countdownTimerLabel: WKInterfaceTimer!
  @IBOutlet var detailGroup: WKInterfaceGroup!
  @IBOutlet var dataGroup: WKInterfaceGroup!
  @IBOutlet var dataLabel: WKInterfaceLabel!

  
  // MARK: - ****** Lifecycle ******
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    
    workoutConfiguration = context as? WorkoutConfiguration
    self.setTitle(workoutConfiguration?.exerciseType.title)

    // Start Countdown Timer
    let coundownDuration: NSTimeInterval = 3
    countdownGroup.setHidden(false)
    detailGroup.setHidden(true)
    countdownGroup.setBackgroundImageNamed("progress_ring")
    countdownGroup.startAnimatingWithImagesInRange(NSRange(location: 0, length: 91), duration: -coundownDuration, repeatCount: 1)
    countdownTimerLabel.setDate(NSDate(timeIntervalSinceNow: coundownDuration+1))
    countdownTimerLabel.start()
    NSTimer.scheduledTimerWithTimeInterval(coundownDuration+0.2, target: self, selector: "start:", userInfo: nil, repeats: false)
  }
  

  // MARK: - ****** Save Data ******
  func presentSaveDataAlertController() {
    // Save Action
    let saveAction = WKAlertAction(title: "Save", style: .Default, handler: {
    self.detailGroup.setHidden(true)

      // Save Data Here
      self.workoutSession?.saveSession()
    })
    
    // Cancel Action
    let cancelAction = WKAlertAction(title: "Cancel", style: .Destructive, handler: {
      self.dismissController()
    })
    
    presentAlertControllerWithTitle("Good Job!", message: "Would you like to save your workout?", preferredStyle: WKAlertControllerStyle.ActionSheet, actions: [saveAction, cancelAction])

  }
  
  
  // MARK: - ****** Timer Management ******

  let tickDuration = 0.5
  var currentPhaseState: (phase: ExerciseIntervalPhase, endTime: NSTimeInterval, running: Bool) = (.Active, 0.0, false)
  
  // Start the timer and the workout session after a short countdown
  @IBAction func start(sender: AnyObject?) {
    guard let workoutConfiguration = workoutConfiguration else {
      return
    }
    
    timer = NSTimer(timeInterval: tickDuration, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
    NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
    
    // Start the timer
    startTime = NSDate()
    elapsedTimeLabel.setText(elapsedTime().longElapsedTimeString())
    
    currentPhaseState = (.Active, workoutConfiguration.activeTime, true)
    updateIntervalPhaseLabels()
    
    countdownGroup.setHidden(true)
    detailGroup.setHidden(false)

    workoutSession = WorkoutSessionService(configuration: workoutConfiguration)
    workoutSession!.delegate = self
    workoutSession!.startSession()
  }
  
  @IBAction func stop(sender: AnyObject?) {
    timer?.invalidate()
    
    currentPhaseState = (.Active, 0.0, false)
    updateIntervalPhaseLabels()
    
    workoutSession!.stopSession()
  }
  
  func timerTick(timer: NSTimer) {
    intervalTimeRemainingLabel.setText((currentPhaseState.endTime - elapsedTime()).elapsedTimeString())
    elapsedTimeLabel.setText(elapsedTime().longElapsedTimeString())
    
    if (elapsedTime() >= currentPhaseState.endTime) {
      transitionToNextPhase()
    }
  }
  
  func transitionToNextPhase() {
    let previousPhase = currentPhaseState
    switch previousPhase.phase {
    case .Active:
      currentPhaseState = (.Rest, previousPhase.endTime + workoutConfiguration!.restTime, previousPhase.running)
      WKInterfaceDevice.currentDevice().playHaptic(workoutConfiguration!.restTime > 0 ? .Stop : .Start)
      
    case .Rest:
      currentPhaseState = (.Active, previousPhase.endTime + workoutConfiguration!.activeTime, previousPhase.running)
      WKInterfaceDevice.currentDevice().playHaptic(.Start)
    }
    updateIntervalPhaseLabels()
  }
  
  let activeColor = UIColor(red: 1.0, green: 149/255, blue: 0, alpha: 1.0)
  let restColor = UIColor(red: 254/255, green: 204/255, blue: 136/255, alpha: 1.0)
  
  func updateIntervalPhaseLabels() {
    intervalPhaseBadge.setText(currentPhaseState.phase.rawValue)
    switch currentPhaseState.phase {
    case .Active:
      intervalPhaseContainer.setBackgroundColor(activeColor)
    case .Rest:
      intervalPhaseContainer.setBackgroundColor(restColor)
    }
  }
}

extension ActiveWorkoutInterfaceController: WorkoutSessionServiceDelegate {
  
  func workoutSessionService(service: WorkoutSessionService, didStartWorkoutAtDate startDate: NSDate) {
  }
  
  func workoutSessionService(service: WorkoutSessionService, didStopWorkoutAtDate endDate: NSDate) {
    presentSaveDataAlertController()
  }
  
  func workoutSessionServiceDidSave(service: WorkoutSessionService) {
    self.dismissController()
  }
  
  func workoutSessionService(service: WorkoutSessionService, didUpdateHeartrate heartRate:Double) {
    dataGroup.setHidden(false)
    dataLabel?.setText(numberFormatter.stringFromNumber(heartRate)! + " bpm")
  }
  
  func workoutSessionService(service: WorkoutSessionService, didUpdateDistance distance:Double) {
    print("\(distance)")
  }
  
  func workoutSessionService(service: WorkoutSessionService, didUpdateEnergyBurned energy:Double) {
  }
}
