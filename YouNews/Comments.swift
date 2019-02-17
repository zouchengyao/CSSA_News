/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse



// MARK: - COMMENT CUSTOM CELL
class CommentCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var cAvatarImage: UIImageView!
    @IBOutlet weak var cUsernameLabel: UILabel!
    @IBOutlet weak var cCommentTx: UITextView!
    @IBOutlet weak var cDateLabel: UILabel!
}






// MARK: - COMMENTS CONTROLLER
class Comments: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
UITextViewDelegate,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet weak var commentsTableView: UITableView!
    let commentTxt = UITextView()
    @IBOutlet weak var fakeTxt: UITextField!
    @IBOutlet weak var adTitleLabel: UILabel!
    
    
    
    /* Variables */
    var newsObj = PFObject(className: NEWS_CLASS_NAME)
    var commentsArray = [PFObject]()
    var cellHeight = CGFloat()
    
    
    
  

override func viewDidAppear(_ animated: Bool) {
    Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(queryComments), userInfo: nil, repeats: false)
}

override func viewDidLoad() {
    super.viewDidLoad()
    
    // Call query
    queryComments()
    
    
    // Get News title
    adTitleLabel.text = "\(newsObj[NEWS_TITLE]!)"
    
    
    
    // INIT A TOOLBAR TO TYPE AND SEND COMMENTS
    let toolbar = UIView(frame: CGRect(x: 0,
                                       y: view.frame.size.height+44,
                                       width: view.frame.size.width,
                                       height: 48))
    toolbar.backgroundColor = UIColor.white
    
    // Add a top line
    let line = UIView(frame: CGRect(x: 0, y: 0,
                                       width: view.frame.size.width,
                                       height: 1))
    line.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1.0)
    toolbar.addSubview(line)
    
    // Add a Send button
    let sendButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 100,
                                          y: 0,
                                          width: 44, height: 44))
    sendButt.setTitle("Send", for: .normal)
    sendButt.setTitleColor(UIColor.darkGray, for: .normal)
    sendButt.titleLabel?.font = UIFont(name: "Titillium-Semibold", size: 14)
    sendButt.addTarget(self, action: #selector(sendCommentButt), for: .touchUpInside)
    toolbar.addSubview(sendButt)
    
    // Add a Dismiss keyboard button
    let dismissButt = UIButton(frame: CGRect(x: toolbar.frame.size.width - 50, y: 0, width: 44, height: 44))
    dismissButt.setBackgroundImage(UIImage(named: "hide_keyboard_butt"), for: .normal)
    dismissButt.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
    toolbar.addSubview(dismissButt)
    
    // Add the Comment TextView
    commentTxt.frame = CGRect(x: 8, y: 4, width: toolbar.frame.size.width - 120, height: 44)
    commentTxt.backgroundColor = UIColor.white
    commentTxt.textColor = UIColor.darkGray
    commentTxt.font = UIFont(name: "Titillium-Light", size: 13)
    commentTxt.clipsToBounds = true
    commentTxt.layer.cornerRadius = 0
    commentTxt.autocapitalizationType = .none
    commentTxt.autocorrectionType = .default
    commentTxt.delegate = self
    toolbar.addSubview(commentTxt)
        
    fakeTxt.inputAccessoryView = toolbar
}
    
    
    
    
// MARK: - QUERY COMMENTS
@objc func queryComments() {
    showHUD("Please wait...")
        
    let query = PFQuery(className: COMMENTS_CLASS_NAME)
    query.whereKey(COMMENTS_NEWS_POINTER, equalTo: newsObj)
    query.whereKey(COMMENTS_IS_REPORTED, equalTo: false)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.commentsArray = objects!
            self.commentsTableView.reloadData()
            self.hideHUD()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
// MARK: - COMMENTS TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return commentsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
    var commObj = PFObject(className: COMMENTS_CLASS_NAME)
    commObj = commentsArray[indexPath.row]
        
        // Get userPointer
        let userPointer = commObj[COMMENTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground { (user, error) in
            
            // Get Full Name
            cell.cUsernameLabel.text = "\(userPointer[USER_USERNAME]!)"
            
            // Get image
            cell.cAvatarImage.layer.cornerRadius = cell.cAvatarImage.bounds.size.width/2
            cell.cAvatarImage.image = UIImage(named: "logo")
            let imageFile = userPointer[USER_AVATAR] as? PFFile
            imageFile?.getDataInBackground(block: { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.cAvatarImage.image = UIImage(data:imageData)
            }}})
            
            
            // Get comment
            cell.cCommentTx.text = "\(commObj[COMMENTS_COMMENT]!)"
            cell.cCommentTx.sizeToFit()
            cell.cCommentTx.frame.size.width = cell.frame.size.width - 72
            self.cellHeight = cell.cCommentTx.frame.origin.y + cell.cCommentTx.frame.size.height + 15
            
            
            // Get Date
            let date = Date()
            cell.cDateLabel.text = self.timeAgoSinceDate(commObj.createdAt!, currentDate: date, numericDates: true)
        }
        
        
    return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cellHeight
}
    
    
    
    
    
// MARK: -  CELL HAS BEEN TAPPED -> ASK TO REPORT OR DELETE YOUR OWN COMMENT
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var commObj = PFObject(className: COMMENTS_CLASS_NAME)
    commObj = commentsArray[indexPath.row]
        
    let alert = UIAlertController(title: APP_NAME,
        message: "Select Option",
        preferredStyle: .alert)
    
    
    // REPORT INAPPROPRIATE COMMENT
    let report = UIAlertAction(title: "Report as Inappropriate/Offensive", style: .default, handler: { (action) -> Void in

        self.dismissKeyboard()
        self.showHUD("Please wait...")
        
        commObj[COMMENTS_IS_REPORTED] = true
        commObj.saveInBackground(block: { (succ, error) in
            self.hideHUD()
            self.simpleAlert("Thanks for reporting this comment. We'll check it out within 24h!")
            
            // Refresh commentsTableView
            self.commentsArray.remove(at: indexPath.row)
            self.commentsTableView.deleteRows(at: [indexPath], with: .fade)
        })
    })
    
    
    
    // DELETE YOUR OWN COMMENT
    let delete = UIAlertAction(title: "Delete comment", style: .default, handler: { (action) -> Void in
        
        self.dismissKeyboard()
        
        // Get User Pointer
        let currUser = PFUser.current()!
        let userPointer = commObj[COMMENTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                if userPointer.objectId != currUser.objectId {
                    self.simpleAlert("You can delete only your own comments!")
                
                } else {
                   commObj.deleteInBackground(block: { (succ, error) in
                    if error == nil {
                        self.simpleAlert("Your comment has been removed!")
                        
                        // Refresh commentsTableView
                        self.commentsArray.remove(at: indexPath.row)
                        self.commentsTableView.deleteRows(at: [indexPath], with: .fade)
                    }})
        }}})
        
    })
    
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
    alert.addAction(report)
    alert.addAction(delete)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
    
    
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    commentTxt.becomeFirstResponder()
return true
}
    
func textFieldDidBeginEditing(_ textField: UITextField) {
    commentTxt.becomeFirstResponder()
}
    

    
    
    
    
    
    
// MARK: - SEND COMMENT BUTTON
@objc func sendCommentButt() {
    if commentTxt.text == "" {
        simpleAlert("You must type something!")
        
    } else {
        dismissKeyboard()
        showHUD("Please wait..")
        
        let commObj = PFObject(className: COMMENTS_CLASS_NAME)
        let currUser = PFUser.current()
            
        commObj[COMMENTS_USER_POINTER] = currUser
        commObj[COMMENTS_NEWS_POINTER] = newsObj
        commObj[COMMENTS_COMMENT] = commentTxt.text
        commObj[COMMENTS_IS_REPORTED] = false
        
        // Saving block
        commObj.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.hideHUD()
                    
                // Refresh commentsTableView
                self.commentsArray.insert(commObj, at: 0)
                self.commentsTableView.reloadData()
            
            // error on saving
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
            
    } // end IF
        
}
    
    
    
    
   
    
// MARK: - DISMISS KEYBAORD
@objc func dismissKeyboard() {
    fakeTxt.resignFirstResponder()
    fakeTxt.text = ""
    commentTxt.resignFirstResponder()
}
    
    
    
    
    
// MARK: - REFRESH BUTTON
@IBAction func refreshButt(_ sender: Any) {
    dismissKeyboard()
    // Call query
    queryComments()
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








