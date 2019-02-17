/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse
import AudioToolbox



// MARK: - NEWS CELL
class NewsCell: UICollectionViewCell  {
    /* Views */
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryOutlet: UIButton!
}






// MARK: - HOME CONTROLLER
class Home: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
{
    
    /* Views */
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsCollView: UICollectionView!
    @IBOutlet weak var demoImg: UIImageView!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var latestOutlet: UIButton!
    @IBOutlet weak var mostReadOutlet: UIButton!
    
    
    
    /* Variables */
    var newsArray = [PFObject]()
    var cellSize = CGSize()
    var isLatest = true
    
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    

    // IMPORTANT: AFTER YOU'VE PLACED YOUR APP ID AND CLIENT KEY STRINGS INTO Configs.swift, RUN THE APP ONCE AND WAIT FOR AN ALERT THAT WILL TELL YOU  THAT THE NEWS CLASS HAS BEEN CREATED.
    // AFTER THAT, STOP THE APP AND COMMENT THE LINE OF CODE BELOW:
    
    createDemoNewsClass()
    
    
    
    // LASTY, UNCOMMENT 'queryNews()' BELOW:
    // queryNews()
    
    

    
    
    // Register device for Push Notifications
    let installation = PFInstallation.current()
    installation?.saveInBackground(block: { (succ, error) in
        if error == nil {
            print("REGISTERED FOR PUSH NOTIFICATIONS")
    }})

    
    
    
    // Set cellSize based on device used
    if UIDevice.current.userInterfaceIdiom == .phone {
        // iPhone
        cellSize = CGSize(width: view.frame.size.width - 20, height: 230)
    } else  {
        // iPad
        cellSize = CGSize(width: 400, height: 230)
    }

    
    // Init refreshControl for CollectionView
    newsCollView.alwaysBounceVertical = true
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.tintColor = MAIN_COLOR
    refreshControl.addTarget(self, action: #selector(queryNews), for: .valueChanged)
    newsCollView.addSubview(refreshControl)
    
    
    
//    // Init ad banners
//    initAdMobBanner()
}

   
    
  
// MARK: - LATEST NEWS BUTTON
@IBAction func latestButt(_ sender: Any) {
    isLatest = true
    latestOutlet.setTitleColor(MAIN_COLOR, for: .normal)
    mostReadOutlet.setTitleColor(UIColor.lightGray, for: .normal)
    queryNews()
}
    
    

// MARK: - MOST READ NEWS BUTTONS
@IBAction func mostReadButt(_ sender: Any) {
    isLatest = false
    latestOutlet.setTitleColor(UIColor.lightGray, for: .normal)
    mostReadOutlet.setTitleColor(MAIN_COLOR, for: .normal)
    queryNews()
}
    
    
    
    
    
    
// MARK: - QUERY LATEST NEWS
@objc func queryNews() {
    showHUD("Please wait...")
    
    let query = PFQuery(className: NEWS_CLASS_NAME)
    
    // Query latest news
    if isLatest {
        query.limit = 20
        query.order(byDescending: "createdAt")
    
    // Query most read news
    } else {
        query.order(byDescending: NEWS_READ)
        query.limit = 10
    }
    
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.newsArray = objects!
            self.hideHUD()
            self.newsCollView.reloadData()
            
            self.refreshControl.endRefreshing()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    
    
// MARK: - COLLECTION VIEW DELEGATES
func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}
    
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return newsArray.count
}
    
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! NewsCell
    
    // Get ParseObject
    var nObj = PFObject(className: NEWS_CLASS_NAME)
    nObj = newsArray[indexPath.row]
    
    
    // Get title, text and category
    cell.titleLabel.text = "\(nObj[NEWS_TITLE]!)"
    cell.newsTextLabel.text = "\(nObj[NEWS_TEXT]!)"
    cell.categoryOutlet.setTitle("\(nObj[NEWS_CATEGORY]!)".uppercased(), for: .normal)
    
    // Get image
    let imageFile = nObj[NEWS_IMAGE] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            cell.newsImage.image = UIImage(data: imageData)
    }}})
    
    // Get Date
    let date = nObj.createdAt!
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = "MMM dd yyyy | hh:mm a"
    cell.dateLabel.text = dateFormat.string(from: date)

    
    // Assign tags
    cell.categoryOutlet.tag = indexPath.row

    
return cell
}
    
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
}
    
    
// TAP ON A CELL -> SEE NEWS DETAILS
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var nObj = PFObject(className: NEWS_CLASS_NAME)
    nObj = newsArray[indexPath.row]
    
    let aVC = storyboard?.instantiateViewController(withIdentifier: "NewsDetails") as! NewsDetails
    aVC.newsObj = nObj
    navigationController?.pushViewController(aVC, animated: true)
}
    


    
    
// MARK: - CATEGORY BUTTON
@IBAction func categoryButt(_ sender: UIButton) {
    let butt = sender
    let aVC = storyboard?.instantiateViewController(withIdentifier: "NewsByCategory") as! NewsByCategory
    aVC.category = butt.titleLabel!.text!.lowercased()
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
    

    
    
    
    
//// MARK: - ADMOB BANNER METHODS
//func initAdMobBanner() {
//        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
//        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
//        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
//        adMobBannerView.rootViewController = self
//        adMobBannerView.delegate = self
//        view.addSubview(adMobBannerView)
//        let request = GADRequest()
//        adMobBannerView.load(request)
//}
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
    
 
    
    
    
    
    
    
    
    
    
// IMPORTANT: THIS METHOD MUST BE RAN ONLY ONCE AT FIRST APP STARTUP
func createDemoNewsClass() {
    
    let nObj = PFObject(className: NEWS_CLASS_NAME)
    nObj[NEWS_VIDEO_URL] = "your youtube video URl here (optional)"
    nObj[NEWS_TEXT] = "News text here..."
    nObj[NEWS_TITLE] = "News Title here..."
    nObj[NEWS_CATEGORY] = "News Category here..."
    nObj[NEWS_READ] = 0
    let likedBy = [String]()
    nObj[NEWS_LIKED_BY] = likedBy
    nObj[NEWS_HTMLTEXT] = "Place your html text here..."

    let imageData = UIImageJPEGRepresentation(demoImg.image!, 0.5)
    let imageFile = PFFile(name:"image.jpg", data:imageData!)
    nObj[NEWS_IMAGE] = imageFile
    
    nObj.saveInBackground(block: { (succ, error) in
        if error == nil {
            self.simpleAlert("News class has been successfully created. Now stop the app, enter your Parse Dashboard or Adminca CMS panel to edit this demo news and add new ones.\nRemember to comment 'createDemoNewsClass()' too!")
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
    }})
}
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
