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
    var newsArray = [PFObject]()
    var cellSize = CGSize()
    
    
    
    
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
    showHUD("Please wait...")
    let currUser = PFUser.current()!
    
    let query = PFQuery(className: NEWS_CLASS_NAME)
    query.whereKey(NEWS_LIKED_BY, contains: currUser.objectId!)
    query.findObjectsInBackground { (objects, error) in
        if error == nil {
            self.newsArray = objects!
            self.hideHUD()
            self.newsCollView.reloadData()
            
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
    
    

    
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: Any) {
    _ = navigationController?.popViewController(animated: true)
}
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
