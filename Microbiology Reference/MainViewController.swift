//
//  ViewController.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 11/11/17.
//  Copyright © 2017 Denkensohn. See LICENSE.txt
//

import UIKit

class RecentsCell: UITableViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
}

class MainViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchBarAnchorToTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarCenterVerticallyConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var resultsTable: UITableView!
    
    @IBOutlet weak var searchTitleLabel: UILabel!
    
    var resultsHeaders:[String] = []    // Final headers to be displayed
    var resultsElements:[[BugElement]] = [] // Final data (rows) to be displayed
    var recentsElements:[[RecentBugElement]] = []
    var showingResults: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // NEED TO SHOW TUTORIAL ON FIRST LAUNCH
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            if DataManager.firstLaunch{
                self.tutorialPopover()
            }
        })
        
        // Begin by showing recents
        self.showRecents()
        
        // Set up overall background
        self.view.backgroundColor = UIColor.white
        
        // Change navigation bar bottom border color
        navigationController?.navigationBar.setBackgroundImage(UIColor.clear.as1ptImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIColor.gray.as1ptImage()
        
        // Set up navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.view.backgroundColor = UIColor.white
        navigationItem.title = nil
        
        let attributes = [
            NSAttributedStringKey.font : UIFont(name: "PingFangTC-Light", size: 50)!
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
        
        // Setup searchBar
        searchBar.showsCancelButton = false
        searchTitleLabel.font = UIFont(name: "PingFangTC-Light", size: 50)
        searchBar.barTintColor = UIColor.white
        
        // Setup resultsTable
        resultsTable.isHidden = true
        
        // Allow table cell to get bigger to fit multi-line content
        resultsTable.estimatedRowHeight = 44
        resultsTable.estimatedRowHeight = UITableViewAutomaticDimension
        resultsTable.rowHeight = UITableViewAutomaticDimension
        
        // Add poopover button to top right
        DataManager.lastDataCheck(){ (lastCheck) -> () in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            dateFormatter.locale = Locale(identifier: "en_US")

            let calendar = NSCalendar.current
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfTimeStamp = calendar.startOfDay(for: lastCheck as Date)
            let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            let day = Int(components.day!)
            print("Last data update \(day) days ago on \(dateFormatter.string(from: lastCheck as Date))")
            
            if day > 30{
                // No update checks in 30 days, so check now
                self.popupNotification(notificationText: "Checking for new data.", selfDestruct: 2)
                if self.currentReachabilityStatus != .notReachable {
                    
                    DataManager.checkDataVersion(fromWeb: true){ (webVersion) -> () in
                        
                        DataManager.checkDataVersion(fromWeb: false){ (localVersion) -> () in
                            
                            if webVersion != localVersion{
                                
                                // Dismiss linger popups and show new
                                AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil)
                                self.popupNotification(notificationText: "Updating Data\n(Version \(webVersion))")
                                
                                // Orchestrate external data update and set new version
                                DataManager.orchestrateUpdates(table: "all", dataSource: "external"){ () -> () in
                                    // Re-filter data (1 second pause required )
                                    self.filterContent(searchText: self.searchBar.text!)
                                    
                                    self.popupNotification(notificationText: "Update Successful", selfDestruct: 1)
                                }
                                DataManager.setDataVersion(dataVersion: webVersion)
                                
                            } else{
                                AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil) // Dismiss any lingering popups
                                self.popupNotification(notificationText: "No New Updates", selfDestruct: 2)
                            }
                        }
                    }
                    
                } else{
                    AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil)
                    self.popupNotification(notificationText: "No Internet Connection", selfDestruct: 2)
                }
            }
        }
        let popoverButton = UIBarButtonItem(image: UIImage(named: "barButtonItem_3lines"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(initiatePopover))
        popoverButton.tintColor = UIColor.black
        navigationItem.rightBarButtonItems = [popoverButton]
        
        // Add image behind searchbar
//        print("Frame height: \(self.view.layer.frame.height)")
//        print("Searchbar Position: \(self.searchBar.layer.position.y)")
        // self.searchBar.layer.position.y-170
        let backgroundImagePosition = ((self.view.layer.frame.height-self.searchBar.layer.position.y)/2)-30
        let searchBackground = UIImageView(frame: CGRect(x: 0, y: backgroundImagePosition, width: view.bounds.width, height: 500))
        searchBackground.image = UIImage(named: "searchbar_background")
        self.view.addSubview(searchBackground)
        self.view.sendSubview(toBack: searchBackground)
        searchBackground.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /*let attributes = [
            NSAttributedStringKey.font : UIFont(name: "PingFangTC-Light", size: 50)!
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes*/
        
        if DataManager.updatesInProgress{
            popupNotification(notificationText: "Updating Data")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func popupNotification(notificationText:String, selfDestruct:Int = 0){
        let popover = storyboard?.instantiateViewController(withIdentifier: "popupNotification") as! PopupNotificationViewController
        
        popover.modalPresentationStyle = UIModalPresentationStyle.popover
        popover.notificationText = notificationText
        popover.selfDestruct = selfDestruct
        popover.popoverPresentationController?.delegate = self
        popover.popoverPresentationController?.sourceView = self.view
        popover.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        popover.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        self.present(popover, animated: true)
    }
   
    // Handle initiation of popover
    @objc func initiatePopover(_ sender: AnyObject) {
        
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverController") as? PopoverTableViewController
        
        
        // set the presentation style
        popController?.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // Set popover data (format as array: userfriendly,action)
        PopoverTableViewController.popoverOptions = ["Browse All,browse", "Update Data,update", "Tutorial,tutorial", "About,about", "Feedback,feedback", "Suggest New,suggest-new"]
        
        // set up the popover presentation controller
        popController?.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController?.popoverPresentationController?.delegate = self
        popController?.delegate = self
        popController?.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        
        // present the popover
        self.present(popController!, animated: false, completion: nil)
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func tutorialPopover(){
        // Open Tutorial View
        let popover = storyboard?.instantiateViewController(withIdentifier: "tutorialView") as! TutorialViewController
        
        popover.modalPresentationStyle = UIModalPresentationStyle.popover
        popover.popoverPresentationController?.delegate = self
        popover.popoverPresentationController?.sourceView = self.view
        popover.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        popover.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        self.present(popover, animated: true)
        
        self.view.endEditing(true)
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }


}

extension MainViewController: PopoverTableViewDelegate{
    
    // Receive data from popover to determine which option was selected
    func sentPopoverData(option: String) {
        
        // Select correct action for chosen popover
        if option == "browse" {
            
            // Segue to browse
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "browseView") as! BrowseViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        } else if option == "update" {
            self.popupNotification(notificationText: "Checking for new data.", selfDestruct: 2)
            if currentReachabilityStatus != .notReachable {
                
                DataManager.checkDataVersion(fromWeb: true){ (webVersion) -> () in

                    DataManager.checkDataVersion(fromWeb: false){ (localVersion) -> () in

                        if webVersion != localVersion{
                            
                            // Dismiss linger popups and show new
                            AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil)
                            self.popupNotification(notificationText: "Updating Data\n(Version \(webVersion))")
                            
                            // Orchestrate external data update and set new version
                            DataManager.orchestrateUpdates(table: "all", dataSource: "external"){ () -> () in
                                // Re-filter data (1 second pause required )
                                self.filterContent(searchText: self.searchBar.text!)
                                
                                self.popupNotification(notificationText: "Update Successful", selfDestruct: 1)
                            }
                            DataManager.setDataVersion(dataVersion: webVersion)
                            
                        } else{
                            AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil) // Dismiss any lingering popups
                            self.popupNotification(notificationText: "No New Updates", selfDestruct: 2)
                        }
                    }
                }
                
            } else{
                AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil)
                self.popupNotification(notificationText: "No Internet Connection", selfDestruct: 2)
            }
            
        } else if option == "tutorial" {
            
            // Open Tutorial View
            self.tutorialPopover()
            
        } else if option == "about" {
            
            // Segue to about
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "aboutView")
            self.navigationController?.pushViewController(nextViewController, animated: true)
            
        } else if option == "feedback" {
            
            // Open Web View
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "webView") as! WebViewController
            nextViewController.passedTitle = "Feedback"
            nextViewController.passedURL = "https://docs.google.com/forms/d/e/1FAIpQLSfn-haY0J9iBSk292fq7iijLxzdLOvZrYpR_wcNPK3v-sBe_g/viewform?usp=sf_link"
            self.navigationController?.showDetailViewController(nextViewController, sender: self)
            
        } else if option == "suggest-new" {
            
            // Open Web View
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "webView") as! WebViewController
            nextViewController.passedTitle = "Suggest New"
            nextViewController.passedURL = "https://docs.google.com/forms/d/e/1FAIpQLSd8mOqlrgtBFqUJPEfX7whxhFRezRN1sl37gO9ouUEO2foEig/viewform?usp=sf_link"
            self.navigationController?.showDetailViewController(nextViewController, sender: self)
            
        }
        
    }
}

extension MainViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // Hide Search label
        searchTitleLabel.isHidden = true
        
        // Send searchbar to top of view
        self.searchBarCenterVerticallyConstraint.priority = UILayoutPriority(rawValue: 1)
        self.searchBarAnchorToTopConstraint.priority = UILayoutPriority(rawValue: 999)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        navigationItem.title = "Search"
        searchBar.showsCancelButton = true
        resultsTable.isHidden = false
        
        // Allow large title to line break
        for navItem in (self.navigationController?.navigationBar.subviews)! {
            for itemSubView in navItem.subviews {
                if let largeLabel = itemSubView as? UILabel {
                    largeLabel.text = self.title
                    largeLabel.numberOfLines = 0
                    largeLabel.lineBreakMode = .byWordWrapping
                }
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        searchBar.text = ""
        view.endEditing(true)
        showingResults = false
        
        // Show recents (rather than show nothing)
        self.showRecents()
        resultsTable.reloadData()
        
        // Send searchbar to bottom of view
        self.searchBarCenterVerticallyConstraint.priority = UILayoutPriority(rawValue: 999)
        self.searchBarAnchorToTopConstraint.priority = UILayoutPriority(rawValue: 1)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        searchBar.showsCancelButton = false
        resultsTable.isHidden = true
        searchTitleLabel.isHidden = false
        navigationItem.title = nil
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        filterContent(searchText: searchBar.text!)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContent(searchText: searchBar.text!)
    }
    
    func filterContent(searchText:String) {
        
        if searchText.count == 0 {
            showRecents()
        } else{
            
//            DispatchQueue.global(qos: .background).async {
//
//                DataManager.searchAllTables(searchText: searchText){  (returnResults) -> () in
//
//                    DispatchQueue.main.async {
//                        // Check how many results were found
//                        if(returnResults.count == 0){
//                            // No results found
//                            self.showingResults = true
//
//                            // Remove current header(s) and results
//                            self.resultsHeaders.removeAll()
//                            self.resultsElements.removeAll()
//
//                            // Set proper header
//                            self.resultsHeaders.append("No results found")
//                            self.resultsElements = [[BugElement(rank: 0, name: "none", match: ["none"])]]
//                        } else {
//                            // 1 or more results found
//                            self.showingResults = true
//
//                            // Remove current header(s) and results
//                            self.resultsHeaders.removeAll()
//                            self.resultsElements.removeAll()
//
//                            // Add result to resultsItems
//                            self.resultsHeaders.append("\(returnResults.count) results found")
//                            self.resultsElements.append(returnResults)
//                        }
//                        self.resultsTable.reloadData()
//
//                    }
//                }
//
//
//            }
            
            DataManager.searchAllTables(searchText: searchText){  (returnResults) -> () in
                self.showingResults = true
                
                // Remove current header(s) and results
                self.resultsHeaders.removeAll()
                self.resultsElements.removeAll()
                
                // Check how many results were found
                if(returnResults.count == 0){
                    // No results found
                    self.resultsHeaders.append("No results found")
                    self.resultsElements = [[BugElement(rank: 0, name: "none", match: ["none"])]]
                } else {
                    // 1 or more results found
                    self.resultsHeaders.append("\(returnResults.count) results found")
                    self.resultsElements.append(returnResults)
                }
                self.resultsTable.reloadData()
            }
            
            
            
        }
        //resultsTable.reloadData()
        
    }
    
    func showRecents(){
        
        //DispatchQueue.global(qos: .background).async {
            
            self.showingResults = false
            
            self.recentsElements.removeAll()
            DataManager.storedBugElements.removeAll()
            
            DataManager.getRecent(numberToGet: 5){ (_ returnResults) -> () in

                //DispatchQueue.main.async {
                    if returnResults.count == 0{
                        // Remove current header(s) and results
                        self.resultsHeaders.removeAll()
                        self.resultsHeaders.append("Type to find your first bug!")
                        
                        self.recentsElements = [[RecentBugElement(time: "", name: "none", match: ["none"])]]
                        
                    } else{
                        // Remove current header(s) and results
                        self.resultsHeaders.removeAll()
                        self.resultsHeaders.append("Recent bugs")
                        
                        // Add result to resultsItems
                        
                        self.recentsElements.append(returnResults)
                    }
                    
                    self.resultsTable.reloadData()
                //}
                
            }
        //}
        
        
        
        //showingResults = false
    }
    
}

extension MainViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showingResults{
            return resultsElements[section].count
        } else{
            return recentsElements[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultsHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if showingResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell")!
            
            // Allow multi line + word wrap
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping
            
            // Set title and subtitle
            if resultsElements[indexPath.section][indexPath.row].name != "none"{
                cell.textLabel?.text = resultsElements[indexPath.section][indexPath.row].name
                cell.detailTextLabel?.text = "Match basis: \(resultsElements[indexPath.section][indexPath.row].match.joined(separator: ", "))"
                cell.isUserInteractionEnabled = true
            } else{
                cell.textLabel?.text = "Tips:\n--If using key words (i.e. \"gram\"), keep typing!\n--Try using fewer words\n--Check spelling (autocorrect!)"
                cell.isUserInteractionEnabled = false
            }
            
            // Get table image by name
            let imageName:String = DataManager.getTableImage(name: resultsElements[indexPath.section][indexPath.row].name)
            
            // Add image
            let image : UIImage = UIImage(named: imageName)!
            cell.imageView?.image = image
            
            return cell
            
        } else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentsCell") as! RecentsCell
            
            if recentsElements[indexPath.section][indexPath.row].name != "none"{
                cell.nameLabel.text = recentsElements[indexPath.section][indexPath.row].name
                cell.matchLabel.text = "Match basis: \(recentsElements[indexPath.section][indexPath.row].match.joined(separator: ", "))"
                cell.dateLabel.text = recentsElements[indexPath.section][indexPath.row].time
                
                cell.isUserInteractionEnabled = true
            } else{
                cell.nameLabel.text = ""
                cell.matchLabel.text = ""
                cell.dateLabel.text = ""
                cell.isUserInteractionEnabled = false
            }
            
            return cell
            
        }
        
    }
    
}

extension MainViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Make sure that tapping cell doesn't make it turn grey
        resultsTable.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
        
        // Push to DetailsViewController
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        
        var detailsName:String = "name"
        var matchBasis:Set<String> = ["none"]
        var searchTerms:String = "term"
        
        if showingResults {
            detailsName = resultsElements[indexPath.section][indexPath.row].name
            matchBasis = resultsElements[indexPath.section][indexPath.row].match
            searchTerms = self.searchBar.text!
        } else{
            detailsName = recentsElements[indexPath.section][indexPath.row].name
            matchBasis = recentsElements[indexPath.section][indexPath.row].match
        }
        
        nextViewController.detailsName = detailsName
        nextViewController.matchBasis = matchBasis
        if searchTerms != "term" {nextViewController.searchTerms = searchTerms}
        
        DataManager.setLastAccessed(bugName: detailsName, matchBasis: matchBasis.joined(separator: ", ")) // Set as recent
        
        self.navigationController?.pushViewController(nextViewController, animated: true)

    }
    
}

extension UIColor {
    // Used to remove navigation bar bottom grey border
    /// Converts this `UIColor` instance to a 1x1 `UIImage` instance and returns it.
    ///
    /// - Returns: `self` as a 1x1 `UIImage`.
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}

