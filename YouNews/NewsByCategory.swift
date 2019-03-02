/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
-----------------------------------*/

import UIKit
import Parse
import AudioToolbox


class NewsByCategory: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
{

    /* Views */
    @IBOutlet weak var newsCollView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let refreshControl = UIRefreshControl()
    
    /* Variables */
    var category = ""
    var newsArray = [PFObject]()
    var cellSize = CGSize()
    
    
   
    
override func viewDidLoad() {
    super.viewDidLoad()

    // Set title
    titleLabel.text = category.uppercased()
    
    
    // Set cellSize based on device used
    if UIDevice.current.userInterfaceIdiom == .phone {
        // iPhone
        cellSize = CGSize(width: view.frame.size.width - 20, height: 230)
    } else  {
        // iPad
        cellSize = CGSize(width: 400, height: 230)
    }
    
    
    // Init refreshControl for CollectionView
    /* bounce back when touching the scroll ends */
    newsCollView.alwaysBounceVertical = true
    
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.tintColor = MAIN_COLOR
    /* call queryNews for valueChanged event
     * default action: pull-down to refresh
     * default is spinner
     */
    refreshControl.addTarget(self, action: #selector(queryNews), for: .valueChanged)
    
    /* adds View at the end of the list */
    newsCollView.addSubview(refreshControl)
    
    // Call query
    queryNews()
}

   
    
// MARK: - QUERY NEWS
@objc func queryNews() {
    showHUD("Please wait...")
    
    let query = PFQuery(className: NEWS_CLASS_NAME)
    query.whereKey(NEWS_CATEGORY, equalTo: category)
    /* at most 1000 objects to return */
    query.limit = 1000
    /* latest news comes first */
    query.order(byDescending: "createdAt")
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
    
    
    
    
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
}

    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
