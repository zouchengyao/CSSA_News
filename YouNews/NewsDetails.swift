/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import AudioToolbox


class NewsDetails: UIViewController,
UIWebViewDelegate,
UIScrollViewDelegate
{
    /* Views */
    @IBOutlet weak var newsImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var videoWebView: UIWebView!
    @IBOutlet weak var playOutlet: UIButton!
    @IBOutlet weak var readLabel: UILabel!

    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var likeOutlet: UIButton!
    @IBOutlet weak var newsTextWebView: UIWebView!
    
    
    /* Variables */
    var newsObj = PFObject(className: NEWS_CLASS_NAME)
    
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Set top title
    topTitleLabel.text = APP_NAME
    
    
    // Call query
    showNewsDetails()

    
//    // Init ad banners
//    initAdMobBanner()
}

  
    
    
    
    
// MARK: - SHOW NEWS DETAILS
func showNewsDetails() {
    
    // Get image
    let imageFile = newsObj[NEWS_IMAGE] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            self.newsImg.image = UIImage(data: imageData)
    }}})

    // Get title
    titleLabel.text = "\(newsObj[NEWS_TITLE]!)"
    
    // Get category
    categoryLabel.text = "\(newsObj[NEWS_CATEGORY]!)".uppercased()
    
    // Get news text
    let htmlText = "\(newsObj[NEWS_HTMLTEXT]!)"
    newsTextWebView.loadHTMLString(htmlText, baseURL: nil)
    newsTextWebView.scalesPageToFit = true

    
    // Get and Increment news reads
    if newsObj[NEWS_READ] != nil {
        newsObj.incrementKey(NEWS_READ, byAmount: 1)
        newsObj.saveInBackground()
        
        let reads = newsObj[NEWS_READ] as! Int
        readLabel.text = reads.abbreviated
    } else {
        newsObj[NEWS_READ] = 1
        newsObj.saveInBackground()
        readLabel.text = "1"
    }
    

    
    // Get Date
    let date = newsObj.createdAt!
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "MMM dd yyyy | hh:mm a"
    dateLabel.text = dateFormat.string(from: date)
    
    // Get video URL
    if newsObj[NEWS_VIDEO_URL] != nil {
        if "\(newsObj[NEWS_VIDEO_URL]!)" != "" {
            playOutlet.isHidden = false
            
        } else { playOutlet.isHidden = true }
    } else { playOutlet.isHidden = true }
    
    
    // Get liked
    if newsObj[NEWS_LIKED_BY] != nil && PFUser.current() != nil {
        let likedBy = newsObj[NEWS_LIKED_BY] as! [String]
        if likedBy.contains(PFUser.current()!.objectId!) {
            likeOutlet.setBackgroundImage(UIImage(named: "liked_butt"), for: .normal)
        }
    }
    
}
    
    
    

// WEBVIEW DELEGATE TO OPEN URL'S IN SAFARI
func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    if navigationType == UIWebViewNavigationType.linkClicked {
        UIApplication.shared.openURL(request.url!)
        return false
    }
    return true
}
    
    
    
    
    
    
// MARK: - LIKE BUTTON
@IBAction func likeButt(_ sender: Any) {
    if PFUser.current() != nil {
        var likedBy = [String]()
        let currUser = PFUser.current()!
        
        if newsObj[NEWS_LIKED_BY] != nil {
            likedBy = newsObj[NEWS_LIKED_BY] as! [String]
        
            // UNLIKE THIS NEWS --------------------------------
            if likedBy.contains(currUser.objectId!) {
                likedBy = likedBy.filter{$0 != currUser.objectId!}
                newsObj[NEWS_LIKED_BY] = likedBy
                newsObj.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        // self.simpleAlert("You've unliked this news!")
                        self.likeOutlet.setBackgroundImage(UIImage(named: "like_butt"), for: .normal)
                }})
                
                
            // LIKE THIS NEWS --------------------------------
            } else {
                likedBy.append(currUser.objectId!)
                newsObj[NEWS_LIKED_BY] = likedBy
                newsObj.saveInBackground(block: { (succ, error) in
                    if error == nil {
                        // self.simpleAlert("You've liked this news!")
                        self.likeOutlet.setBackgroundImage(UIImage(named: "liked_butt"), for: .normal)
                }})
            }
        } else {
            likedBy.append(currUser.objectId!)
            newsObj[NEWS_LIKED_BY] = likedBy
            newsObj.saveInBackground(block: { (succ, error) in
                if error == nil {
                    // self.simpleAlert("You've liked this news!")
                    self.likeOutlet.setBackgroundImage(UIImage(named: "liked_butt"), for: .normal)
            }})
        }
        
        
    // YOU MUST LOGIN TO LIKE NEWS!
    } else { showLoginAlert("You need to be logged in to Like this news. Want to login now?") }
    
}
    
    
    
    
  
// MARK: - COMMENT BUTTON
@IBAction func commentButt(_ sender: Any) {
    if PFUser.current() != nil {
        let aVC = storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
        aVC.newsObj = newsObj
        navigationController?.pushViewController(aVC, animated: true)
        
        
    // YOU MUST LOGIN TO COMMENT!
    } else { showLoginAlert("You need to be logged in to Comment. Want to login now?") }
}

    
    
    
    
    
    
// MARK: - SHARE NEWS BUTTON
@IBAction func shareButt(_ sender: Any) {
    let messageStr  = "\(newsObj[NEWS_TITLE]!) on #" + APP_NAME
    let img = newsImg.image!
    
    let shareItems = [messageStr, img] as [Any]
    
    let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [.print, .postToWeibo, .copyToPasteboard, .addToReadingList, .postToVimeo]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: activityViewController)
        popOver.present(from: .zero, in: self.view, permittedArrowDirections: .any, animated: true)
    } else {
        // iPhone
        present(activityViewController, animated: true, completion: nil)
    }

}

    
    
    
    
// MARK: - SHOW LOGIN ALERT
func showLoginAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME,
            message: mess,
            preferredStyle: .alert)
        
        
        let ok = UIAlertAction(title: "Login", style: .default, handler: { (action) -> Void in
            let aVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            self.present(aVC, animated: true, completion: nil)
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
}
    

   
    
    
    
// MARK: - PLAY VIDEO BUTTON
@IBAction func playVideoButt(_ sender: Any) {
    playOutlet.isHidden = true
    videoWebView.isHidden = false
    let youtubeLink = "\(newsObj[NEWS_VIDEO_URL]!)"
    let videoId = youtubeLink.replacingOccurrences(of: "https://youtu.be/", with: "")
    let embedHTML = "<iframe width='\(videoWebView.frame.size.width)' height='\(videoWebView.frame.size.height)' src='https://www.youtube.com/embed/\(videoId)?rel=0&amp;controls=0&amp;showinfo=0' frameborder='0' allowfullscreen></iframe>"
    videoWebView.loadHTMLString(embedHTML, baseURL: nil)
}

    
    

    
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
}
    
    
    
    
    
    
    
    // MARK: - ADMOB BANNER METHODS
//func initAdMobBanner() {
//        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
//        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
//        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
//        adMobBannerView.rootViewController = self
//        adMobBannerView.delegate = self
//        view.addSubview(adMobBannerView)
//        let request = GADRequest()
//        adMobBannerView.load(request)
//    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        var h: CGFloat = 0
        // iPhone X
        if UIScreen.main.bounds.size.height == 812 { h = 20
        } else { h = 0 }
        
        UIView.beginAnimations("showBanner", context: nil)
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2,
                              y: view.frame.size.height - banner.frame.size.height - h,
                              width: banner.frame.size.width, height: banner.frame.size.height);
        UIView.commitAnimations()
        banner.isHidden = false
    }

    
//    // AdMob banner available
//    func adViewDidReceiveAd(_ view: GADBannerView) {
//        print("AdMob loaded!")
//        showBanner(adMobBannerView)
//    }
//
//    // NO AdMob banner available
//    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
//        hideBanner(adMobBannerView)
//    }
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
