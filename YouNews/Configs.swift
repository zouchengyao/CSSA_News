/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/


import Foundation
import UIKit


// IMPORTANT: Replace the red string below with the new name you'll give to this app
let APP_NAME = "CSSANews"



// IMPORTANT: Reaplce the strings below with your own App ID and Client Key of your app on http://back4app.com
let PARSE_APP_ID = "TRZAUkLhMhON5hEaukhbOBiRVqDsHASXThCqgY4o"
let PARSE_CLIENT_KEY = "yl8dlDWpA2sUrjkYEiMYEyUyvolB39lsc9WHFKr6"
//-----------------------------------------------------------------------------


// IMPORTANT: REPLACE THE RED STRING BELOW WITH YOUR OWN BANNER UNIT ID YOU'LL GET FROM  http://apps.admob.com
// Not used in our app. 
let ADMOB_BANNER_UNIT_ID = "ca-app-pub-3940256099942544/6300978111"




// IMPORTANT: REPLACE THE EMAIL ADDRESS BELOW WITH THE ONE YOU WANT TO DEDICATE TO THE USERS TO CONTACT YOU
let YOUR_CONTACT_EMAIL = "info@mydomain.com"



// IMPORTANT: REPLACE THE ID BELOW WITH THE ONE OF YOUR APP ON iTunes Connect
let YOUR_APP_ID = "1253850533"


// IMPORTANT: REPLACE THE STRING BELOW WITH THE LINK TO YOUR APP ON THE APP STORE (YOU CAN GET IT FROM iTunes Connect while preparing the app for submission)
let YOUR_APP_STORE_LINK = "https://itunes.apple.com/us/app/cubimaze-an-impossible-memory-puzzle-game/id1253850533"




// NEWS CATEGORIES ARRAY
let newsCategories = [
    "politics",
    "world",
    "fashion",
    "business",
    "technology",
    "science",
    "health",
    "entertainment",
    "sport",
    
    // YOU CAN ADD MORE CATEGORIES HERE, JUST REMEMBER TO ALSO ADD THEIR RELATIVE ICON IMAGES
    // INTO: Assets.xcassets/CATEGORIES
    
]




// YOU CAN EDIT THE RGB VALUES OF THIS COLOR AS YOU WISH
let MAIN_COLOR = UIColor(red: 188/255, green: 64/255, blue: 30/255, alpha :1.0)





// HUD View extension
let hudView = UIView(frame: CGRect(x:0, y:0, width:120, height: 120))
let label = UILabel()
let indicatorView = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:80, height:80))
extension UIViewController {
    func showHUD(_ mess:String) {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = MAIN_COLOR
        hudView.alpha = 1.0
        hudView.layer.cornerRadius = 8
        
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = .white
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
        
        label.frame = CGRect(x: 0, y: 90, width: 120, height:20)
        label.font = UIFont(name: "Titillium-Semibold", size: 16)
        label.text = mess
        label.textAlignment = .center
        label.textColor = UIColor.white
        hudView.addSubview(label)
    }
    
    func hideHUD() {
        hudView.removeFromSuperview()
        label.removeFromSuperview()
    }
    
    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME, message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}








/************ DO NOT EDIT THE CODE BELOW *************/

let USER_CLASS_NAME = "_User"
let USER_USERNAME = "username"
let USER_EMAIL = "email"
let USER_AVATAR = "avatar"
let USER_IS_REPORTED = "isReported"

let NEWS_CLASS_NAME = "News"
let NEWS_TITLE = "title"
let NEWS_CATEGORY = "category"
let NEWS_TEXT = "text"
let NEWS_IMAGE = "image"
let NEWS_VIDEO_URL = "videoURL"
let NEWS_READ = "read" // Number
let NEWS_LIKED_BY = "likedBy" // Array
let NEWS_HTMLTEXT = "htmltext"

let COMMENTS_CLASS_NAME = "Comments"
let COMMENTS_USER_POINTER = "userPointer"
let COMMENTS_NEWS_POINTER = "newsPointer"
let COMMENTS_COMMENT = "comment"
let COMMENTS_IS_REPORTED = "isReported"




// EXTENSION TO FORMAT LARGE NUMBERS INTO K OR M (like 1.1M, 2.5K)
extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}




// MARK: - EXTENSION TO RESIZE A UIIMAGE
extension UIViewController {
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}




// EXTENSION TO SHOW TIME AGO DATES
extension UIViewController {
    func timeAgoSinceDate(_ date:Date,currentDate:Date, numericDates:Bool) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 h ago"
            } else {
                return "An h ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 min ago"
            } else {
                return "A min ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds"
        } else {
            return "Just now"
        }
        
    }
}

