/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse


class Profile: UIViewController,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    

    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Get user's details
    let currUser = PFUser.current()!

    let imageFile = currUser[USER_AVATAR] as? PFFile
    imageFile?.getDataInBackground(block: { (data, error) in
        if error == nil { if let imageData = data {
            self.avatarImg.image = UIImage(data: imageData)
    }}})

    usernameTxt.text = "\(currUser[USER_USERNAME]!)"
    emailTxt.text = "\(currUser[USER_EMAIL]!)"

    
    // Layout
    avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
    
}

    
    
    
// MARK: - CHANGE AVATAR BUTTON
@IBAction func changeAVatarButt(_ sender: Any) {
    
    let alert = UIAlertController(title: APP_NAME,
        message: "Select Source",
        preferredStyle: .alert)
    
    let camera = UIAlertAction(title: "Take a picture", style: .default, handler: { (action) -> Void in
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    let library = UIAlertAction(title: "Pick from Library", style: .default, handler: { (action) -> Void in
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    })
    
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })

    alert.addAction(camera)
    alert.addAction(library)
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
    
// ImagePicker delegate
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        let scaledImg = resizeImage(image: image, newWidth: 300)
        avatarImg.image = scaledImg
    }
    dismiss(animated: true, completion: nil)
}

    
    
    
    
    
// MARK: - UPDATE PROFILE BUTTON
@IBAction func updateProfileButt(_ sender: Any) {
    let currUser = PFUser.current()!
    
    // Save data
    if usernameTxt.text == "" || emailTxt.text == "" {
        simpleAlert("You must insert a username and an email address to update your Profile!")

    } else {
        usernameTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        
        showHUD("Please wait...")
        
        currUser[USER_USERNAME] = usernameTxt.text
        currUser[USER_EMAIL] = emailTxt.text
    
        // Save Avatar (if exists)
        if avatarImg.image != nil {
            let imageData = UIImageJPEGRepresentation(avatarImg.image!, 0.8)
            let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
            currUser[USER_AVATAR] = imageFile
        }
    
        // Saving block
        currUser.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.hideHUD()
                self.simpleAlert("Your Profile has been updated!")
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }})
    }
    
}
    
    
    
    

    

    
    
// MARK: - LIKED NEWS BUTTONS
@IBAction func likedNewsButt(_ sender: Any) {
    let aVC = storyboard?.instantiateViewController(withIdentifier: "LikedNews") as! LikedNews
    navigationController?.pushViewController(aVC, animated: true)
}
    
    
    
    

// MARK: - LOGOUT BUTTON
@IBAction func logoutButt(_ sender: Any) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to logout?",
        preferredStyle: .alert)
    
    let ok = UIAlertAction(title: "Logout", style: .default, handler: { (action) -> Void in
        self.showHUD("Logging Out...")
        
        PFUser.logOutInBackground(block: { (error) in
            if error == nil {
                _ = self.navigationController?.popViewController(animated: true)
            }
            self.hideHUD()
        })
    })
    
    
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
    alert.addAction(ok);
    alert.addAction(cancel)
    present(alert, animated: true, completion: nil)
}
    
    
    
    
// MARK: - TEXT FIELD DELEGATES
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
return true
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
