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
import WatchKit

extension WKInterfaceLabel {
  func setTimeInterval(interval: NSTimeInterval) {
    self.setText(interval.elapsedTimeString())
  }
}

extension NSTimeInterval {
  
  func elapsedTimeString() -> String {
    let h = UInt(self / 3600)
    let m = UInt(self / 60) % 60
    let s = UInt(self % 60)
    
    var formattedTime: String
    
    if (h > 0) {
      formattedTime = String(format: "%lu:%02lu:%02lu", h, m, s)
    } else if (m > 0) {
      formattedTime = String(format: "%lu:%02lu", m, s)
    } else {
      formattedTime = String(format: ":%02lu", s)
    }
    return formattedTime;
  }
  
  func longElapsedTimeString() -> String {
    let h = UInt(self / 3600)
    let m = UInt(self / 60) % 60
    let s = UInt(self % 60)
    
    return String(format: "%lu:%02lu:%02lu", h, m, s)
  }
  
  func elapsedTimeImage() -> UIImage {
    let timeString = self.elapsedTimeString()
    
    let imageSize = CGSize(width: 110, height: 50)
    var image: UIImage
    
    UIGraphicsBeginImageContext(imageSize)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .Right
    var fontAttributes: [String:AnyObject] = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    fontAttributes[NSFontAttributeName] = UIFont(name: "Avenir", size: CGFloat(40.0))
    fontAttributes[NSParagraphStyleAttributeName] = paragraphStyle
    
    let attrString = NSAttributedString(string: timeString, attributes: fontAttributes)
    attrString.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize))
    
    image = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return image
  }
}