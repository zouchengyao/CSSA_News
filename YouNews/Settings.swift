/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse


// MARK: - SETTINGS CELL
class SettingsCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var upperLabel: UILabel!
    @IBOutlet weak var lowerLabel: UILabel!
    @IBOutlet weak var sImage: UIImageView!
    
}




// MARK: - SETTINGS CONTROLLER
class Settings: UIViewController,
UITableViewDelegate,
UITableViewDataSource
{

    /* Views */
    @IBOutlet weak var settingsTableView: UITableView!
    
    

 
override func viewDidAppear(_ animated: Bool) {
    settingsTableView.reloadData()
}

    
override func viewDidLoad() {
        super.viewDidLoad()

}

    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 6 // This is the number of cells that will be displayed
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
    
    // Round cell image
    cell.sImage.layer.cornerRadius = cell.sImage.bounds.size.width/2
    
    
    // Init cells
    switch indexPath.row {
        
    case 0:
        cell.upperLabel.text = "Your Profile"
        if PFUser.current() != nil {
            cell.lowerLabel.text = PFUser.current()!.username
            let imageFile = PFUser.current()![USER_AVATAR] as? PFFile
            imageFile?.getDataInBackground(block: { (data, error) in
                if error == nil { if let imageData = data {
                    cell.sImage.image = UIImage(data: imageData)
            }}})
            
        } else {
            cell.sImage.image = UIImage(named: "logo")
            cell.lowerLabel.text = "Tap to Login or Sign Up"
        }
    

    case 1:
        cell.sImage.image = UIImage(named: "application_icon")
        cell.upperLabel.text = "Application Name"
        cell.lowerLabel.text = APP_NAME

    case 2:
        cell.sImage.image = UIImage(named: "info_icon")
        cell.upperLabel.text = "Build Version"
        cell.lowerLabel.text = "Version 1.0"
        
    case 3:
        cell.sImage.image = UIImage(named: "mail_icon")
        cell.upperLabel.text = "Contact Email"
        cell.lowerLabel.text = YOUR_CONTACT_EMAIL
        
    case 4:
        cell.sImage.image = UIImage(named: "rate_icon")
        cell.upperLabel.text = "Rate App"
        cell.lowerLabel.text = "Give us some feedback"
        
    case 5:
        cell.sImage.image = UIImage(named: "share_icon")
        cell.upperLabel.text = "Share \(APP_NAME)"
        cell.lowerLabel.text = "Spread the word for this awesome app!"

        
    default:break
    }
    
    
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
}
    
    
// MARK: - CELL TAPPED
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
        
    // Go to your Profile
    case 0:
            if PFUser.current() != nil {
                let aVC = storyboard?.instantiateViewController(withIdentifier: "Profile") as! Profile
                navigationController?.pushViewController(aVC, animated: true)
            } else {
                let aVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
                present(aVC, animated: true, completion: nil)
            }
        
        
    // Copy your contact email address to clipboard
    case 3:
            UIPasteboard.general.string = YOUR_CONTACT_EMAIL
            simpleAlert("Our email address has been copied to your clipboard. Open your favorite Mail app and send us a message, we'd love to hear from you!")
        
        
    // Go to the App Store Ratings page of this app
    case 4:
            let aURL = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=" + YOUR_APP_ID)
            UIApplication.shared.openURL(aURL!)

        
    // Share this app
    case 5:
        let messageStr  = "Get #" + APP_NAME + " on the App Store " + YOUR_APP_STORE_LINK
        let img = UIImage(named: "logo")!
        
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

        
    default:break
    }
 
}
    

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
