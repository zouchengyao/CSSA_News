/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import AudioToolbox



// MARK: - CATEGORY CELL
//catrgory class的cell，每一个category有一个Image 和 label
class CategoryCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var catImage: UIImageView!
    @IBOutlet weak var catNameLabel: UILabel!
}





// MARK: - CATEGORIES CONTROLLER
class Categories: UIViewController,
//GADBannerViewDelegate,
UITableViewDelegate,
UITableViewDataSource
{

    /* Views */
    @IBOutlet weak var categoriesTableView: UITableView!
    //用TableView
//    let adMobBannerView = GADBannerView()

    
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Init ad banners
//    initAdMobBanner()

}

   
    
   
// MARK: - TABLEVIEW DELEGATES
//关于delegate https://www.appcoda.com/swift-delegate/
    
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return newsCategories.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
    
    // Get name and image
    cell.catNameLabel.text = "\(newsCategories[indexPath.row])".uppercased()
    cell.catImage.image = UIImage(named: "\(newsCategories[indexPath.row])")
    
    
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
}
    
    
    
// MARK: - CELL TAPPED -> SHOW NEWS BY CATEGORY
//选中category之后跳转到对应category的新闻页面
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "NewsByCategory") as! NewsByCategory
    aVC.category = "\(newsCategories[indexPath.row])"
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
    
   
    
    
    
//    // MARK: - ADMOB BANNER METHODS
//    func initAdMobBanner() {
//        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
//        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
//        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
//        adMobBannerView.rootViewController = self
//        adMobBannerView.delegate = self
//        view.addSubview(adMobBannerView)
//        let request = GADRequest()
//        adMobBannerView.load(request)
//    }
//
    
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
        if UIScreen.main.bounds.size.height == 812 { h = 84
        } else { h = 48 }
        
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
//
    
    
    

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
