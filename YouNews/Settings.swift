/*-----------------------------------
 
 - YouNews -
 
 created by cubycode ©2017
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse
import MessageUI

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
    UITableViewDataSource,
    MFMailComposeViewControllerDelegate
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
        // 需要加cell的 这里需要修改
        
        
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
            cell.upperLabel.text = "TEST 1 留空"
            cell.lowerLabel.text = APP_NAME
            
        case 2:
            cell.sImage.image = UIImage(named: "info_icon")
            cell.upperLabel.text = "TEST 2 留空"
            cell.lowerLabel.text = "Version 1.0"
            
        case 3:
            cell.sImage.image = UIImage(named: "mail_icon")
            cell.upperLabel.text = "联系CSSA"
            cell.lowerLabel.text = YOUR_CONTACT_EMAIL
            
        case 4:
            cell.sImage.image = UIImage(named: "rate_icon")
            cell.upperLabel.text = "跳转到CSSA网页"
            cell.lowerLabel.text = "看看有什么新内容！"
            
        case 5:
            cell.sImage.image = UIImage(named: "share_icon")
            cell.upperLabel.text = "Share \(APP_NAME)"
            cell.lowerLabel.text = "分享CSSA给大家吧！"
            
            
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
            
            
        //
        case 1:
            print("reached here")
            if !MFMailComposeViewController.canSendMail() {
                print("Mail services are not available")
                return
            }
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            
            // Configure the fields of the interface.
            composeVC.setToRecipients(["address@example.com"])
            composeVC.setSubject("Hello!")
            composeVC.setMessageBody("Hello from California!", isHTML: false)
            
            // Present the view controller modally.
            self.present(composeVC, animated: true, completion: nil)
            
            print("asfasdfasf")
            
            
            
            
            
            
        // Copy your contact email address to clipboard
        case 3:
            UIPasteboard.general.string = YOUR_CONTACT_EMAIL
            simpleAlert("CSSA官方邮箱地址已复制到粘贴板。\n与CSSA分享你的意见和建议吧！😊")
            
            
            // Old: Go to the App Store Ratings page of this app
        // New: GOTO CSSA webpage: http://uiuccssa.org/2018/
        case 4:
            let aURL = URL(string: "http://uiuccssa.org/2018/")
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



func mailComposeController(controller: MFMailComposeViewController,
                           didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    // Check the result or perform other tasks.
    
    
    
    
    // Dismiss the mail compose view controller.
    controller.dismiss(animated: true, completion: nil)
}

