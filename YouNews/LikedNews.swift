/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
-----------------------------------*/

import UIKit
import Parse


class LikedNews: UIViewController,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
{

    /* Views */
    @IBOutlet weak var newsCollView: UICollectionView!
    
    
    
    /* Variables */
    /* array of dictionary */
    var newsArray = [PFObject]()
    /* structure that contains float height and width */
    var cellSize = CGSize()
    
    
    
/* Run when view is added to the window's view hierarchy */
override func viewDidAppear(_ animated: Bool) {
    
    // Call query
    queryLikedNews()
}
    

override func viewDidLoad() {
        super.viewDidLoad()
    
    // Set cellSize based on device used
    if UIDevice.current.userInterfaceIdiom == .phone {
        // iPhone
        cellSize = CGSize(width: view.frame.size.width - 20, height: 230)
    } else  {
        // iPad
        cellSize = CGSize(width: 400, height: 230)
    }

}

    
 
// MARK: - QUERY LIKED NEWS
func queryLikedNews() {
    /* show loading animation */
    showHUD("Please wait...")
    /* get current user logged into this account (self), could be nil */
    let currUser = PFUser.current()!
    /* initialize query object with class name News */
    let query = PFQuery(className: NEWS_CLASS_NAME)
    /* Key: likedBy, substring: user object ID */
    query.whereKey(NEWS_LIKED_BY, contains: currUser.objectId!)
    /* find objects in array asynchronously
     * return the task being done */
    query.findObjectsInBackground { (objects, error) in
        /* self.anything for attaining a strong connection
         * with the function this closure is passed to
         */
        if error == nil {
            self.newsArray = objects!
            /* stop the loading animation */
            self.hideHUD()
            self.newsCollView.reloadData()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
        }
    }
}
    
    
    
    
    
// MARK: - COLLECTION VIEW DELEGATES

/* in is for caller to assign value for function
 * collectionView is used inside the function
*/
func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}

/* _ means don't care function label for caller to call
 * return number of items in collection
*/
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return newsArray.count
}
/* return a Cell (item) corresponding to an index
 */
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    /* get a reusable cell (class: UICollectionView) by its index
     * cast the return type to NewsCell (subclass of UICollectionViewCell)
     * -- UICollectionViewCell is subclass of UICollectionView --
     * as : guaranteed conversion of type (checked by compiler)
     * as!: forced conversion (can cause runtime trap)
     */
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCell", for: indexPath) as! NewsCell
        
    // Get ParseObject
    var nObj = PFObject(className: NEWS_CLASS_NAME)
    /* the value of the row element */
    nObj = newsArray[indexPath.row]
    
    /*
     NewsCell struct {
         @IBOutlet weak var newsImage: UIImageView!
         @IBOutlet weak var titleLabel: UILabel!
         @IBOutlet weak var newsTextLabel: UILabel!
         @IBOutlet weak var dateLabel: UILabel!
         @IBOutlet weak var categoryOutlet: UIButton!
     }
     */
    
    // Get title, text and category
    cell.titleLabel.text = "\(nObj[NEWS_TITLE]!)"
    cell.newsTextLabel.text = "\(nObj[NEWS_TEXT]!)"
    /* button state normal */
    cell.categoryOutlet.setTitle("\(nObj[NEWS_CATEGORY]!)".uppercased(), for: .normal)
        
    // Get image
    /* as? might be nil, will not cause runtime error
     */
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
    
/* get size of cell*/
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
}

    
    
// TAP ON A CELL -> SEE NEWS DETAILS
/* select a cell */
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var nObj = PFObject(className: NEWS_CLASS_NAME)
    nObj = newsArray[indexPath.row]
    
    /* enter the news detail screen */
    let aVC = storyboard?.instantiateViewController(withIdentifier: "NewsDetails") as! NewsDetails
    aVC.newsObj = nObj
    navigationController?.pushViewController(aVC, animated: true)
}
    
// MARK: - CATEGORY BUTTON
/* button clicked navigate to news by category view */
@IBAction func categoryButt(_ sender: UIButton) {
    let butt = sender
    let aVC = storyboard?.instantiateViewController(withIdentifier: "NewsByCategory") as! NewsByCategory
    aVC.category = butt.titleLabel!.text!.lowercased()
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
// MARK: - BACK BUTTON
/* return to last page */
@IBAction func backButt(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
}

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
