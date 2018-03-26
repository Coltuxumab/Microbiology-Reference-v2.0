//
//  DiseaseViewController.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 11/11/17.
//  Copyright © 2017 Denkensohn. See LICENSE.txt
//

import UIKit

class DetailsCell: UITableViewCell {
    
    
    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var cellLabelLeading: NSLayoutConstraint!
    
    @IBOutlet weak var cellImage1: UIImageView!
    
    @IBOutlet weak var cellImage2: UIImageView!
    
    let tapRec = UITapGestureRecognizer() // WHY IS THIS HERE?
    
    @IBOutlet weak var cellImage1Width: NSLayoutConstraint!
    @IBOutlet weak var cellImage2Width: NSLayoutConstraint!
    
    @IBOutlet weak var cellImage1WidthSmall: NSLayoutConstraint!
    @IBOutlet weak var cellImage2WidthSmall: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Set cell accessory width (999 = active, 750 = inactive)
        cellImage1Width.priority = UILayoutPriority(rawValue: 750)
        cellImage2Width.priority = UILayoutPriority(rawValue: 750)
        cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 999)
        cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
        
        cellLabelLeading.priority = UILayoutPriority(rawValue: 999)
        
    }
    
}

class DetailsViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var detailsTable: UITableView!
    
    var detailsName:String = "Default Name"
    var matchBasis:Set<String> = ["none"]
    var searchTerms:String = "term"
    
    var definitions:[String:String] = [:]
    
    var detailsHeaders:[String] = []    // Final headers to be displayed
    var detailsItems:[[Entity]] = []    // Final data (rows) to be displayed
    
    var shareText:String = ""
    
    struct RelatedAccessory{
        var term:String
        var relatedName:String
    }
    struct AccessoryRelated{
        var term:String
        var related:[Related]
        var match:Set<String>
    }
    struct AccessoryWebView{
        var title:String
        var url:String
    }
    struct CellDefinitions{
        var item:String
        var definition:String
        var section:Int
        var row:Int
        var range:NSRange
    }
    struct ColonItems{
        var prefix:String
        var item:String
        var section:Int
    }
    struct CellCache{
        var section:Int
        var row:Int
        var attributedText:NSAttributedString
        let tabWidth:Int
    }
    struct AccessoryCache{
        var section:Int
        var row:Int
        var accessory_image1:UIImageView?
        var accessory_image2:UIImageView?
        var hasImage1:Bool
        var hasImage2:Bool
        var important:Bool
    }
    
    var accessoryRelated = [RelatedAccessory]()
    var accessoryLinked = [AccessoryRelated]()
    var accessoryWebView = [AccessoryWebView]()
    var cellDefinitions = [CellDefinitions]()
    var colonItems = [ColonItems]()
    var cellCache = [CellCache]()
    var accessoryCache = [AccessoryCache]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        navigationItem.title = detailsName
        let attributes = [
            //NSAttributedStringKey.foregroundColor : UIColor.red,
            NSAttributedStringKey.font : UIFont(name: "PingFangTC-Light", size: 30)!
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
        
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
        
        // Set up overall background
        self.view.backgroundColor = DataManager.themeBackgroundColor
        detailsTable.backgroundColor = DataManager.themeBackgroundColor
        
        // Allow table cell to get bigger to fit multi-line content
        detailsTable.estimatedRowHeight = 44
        detailsTable.estimatedRowHeight = UITableViewAutomaticDimension
        detailsTable.rowHeight = UITableViewAutomaticDimension
        
        // Add poopover button to top right
        let searchButton = UIBarButtonItem(image: UIImage(named: "search"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(returnToSearch))
        searchButton.tintColor = UIColor.black
        let popoverButton = UIBarButtonItem(image: UIImage(named: "barButtonItem_3lines"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(initiatePopover))
        popoverButton.tintColor = UIColor.black
        navigationItem.rightBarButtonItems = [popoverButton,searchButton]
        
        // Get definitions
        DataManager.getAllDefinitions { (returnDefinitions) -> () in
            print("Definitions: \(returnDefinitions)")
            self.definitions = returnDefinitions
        }
        
        // Get data
        DataManager.getSingleBug(bugName: detailsName){ (headers,data) -> () in
            self.detailsHeaders = headers
            self.detailsItems = data
            self.detailsTable.reloadData()
        }
        
        // Cache attributed text
        cacheAttributedText()
        
        // Cache accessories
        cacheAccessories()
        
        // Set share text
        shareText = "\(detailsName) \n"
        var i = 0
        for item in self.detailsHeaders{
            shareText = shareText + "\n\(item):\n"
            for item in self.detailsItems[i]{
                shareText = shareText + "\(item.item)\n"
            }
            //shareText = shareText + "\(self.detailsItems[i].joined(separator: "\n"))\n"
            i += 1
        }
        
    }

    // Handle return to search
    @objc func returnToSearch(_ sender: AnyObject) {
        print("Returning to search")
        self.performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    // Handle initiation of popover
    @objc func initiatePopover(_ sender: AnyObject) {
        
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverController") as? PopoverTableViewController
         
         
        // set the presentation style
        popController?.modalPresentationStyle = UIModalPresentationStyle.popover
         
        // Set popover data (format as array: userfriendly,action)
        PopoverTableViewController.popoverOptions = ["Share/Save,share-save", "Suggest Change,suggest-change"]
         
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension DetailsViewController: PopoverTableViewDelegate{
    
    // Receive data from popover to determine which option was selected
    func sentPopoverData(option: String) {
        
        // Select correct action for chosen popover
        if option == "share-save" {
            
            // set up activity view controller
            let textToShare = [shareText]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
            
        } else if option == "suggest-change" {
            
            // Open Web View
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "webView") as! WebViewController
            nextViewController.passedTitle = "Suggest Change"
            nextViewController.passedURL = "https://docs.google.com/forms/d/e/1FAIpQLSeSb4Ccr3zqocmGpqBegu5Hp81dv7ghYEM8Za7qsP5bVmHL-A/viewform?usp=pp_url&entry.286988055=\(detailsName.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil))&entry.1744268545"
            self.navigationController?.showDetailViewController(nextViewController, sender: self)
            
        }
        
    }
}

extension DetailsViewController: UITableViewDataSource{
    
    // Table style
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = DataManager.themeMainColor
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.clear
    }
    
    // Table functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsItems[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return detailsHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Make sure accessories are only visible when needed
        
        //let cellInfo = attributedItems.filter { $0.section == indexPath.section && $0.row == indexPath.row }.first
//        let cellInfo = accessoryCache.filter { $0.section == indexPath.section && $0.row
//            == indexPath.row }.first
//
//        if let detailsCell = cell as? DetailsCell  {
//
//            if cellInfo?.hasImage1 == true && cellInfo?.hasImage2 == true {
//                // 2 images
//                detailsCell.cellImage1 = cellInfo?.accessory_image1
//                detailsCell.cellImage2 = cellInfo?.accessory_image2
//
//                detailsCell.cellImage1.isHidden = false
//                detailsCell.cellImage2.isHidden = false
//
//                detailsCell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
//                detailsCell.cellImage2Width.priority = UILayoutPriority(rawValue: 999)
//                detailsCell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
//                detailsCell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 750)
//
//            } else if cellInfo?.hasImage1 == true && cellInfo?.hasImage2 == false {
//                // 1 image
//                //print("1 Image")
//                detailsCell.cellImage1 = cellInfo?.accessory_image1
//                detailsCell.cellImage2.image = nil
//
//                detailsCell.cellImage1.isHidden = false
//                detailsCell.cellImage2.isHidden = true
//
//                detailsCell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
//                detailsCell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
//                detailsCell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
//                detailsCell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
//            } else{
//                // 0 images
//                detailsCell.cellImage1.image = nil
//                detailsCell.cellImage2.image = nil
//
//                detailsCell.cellImage1.isHidden = true
//                detailsCell.cellImage2.isHidden = true
//
//                detailsCell.cellImage1Width.priority = UILayoutPriority(rawValue: 750)
//                detailsCell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
//                detailsCell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 999)
//                detailsCell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
//            }
//
//            // Set proper background color
//            if (cellInfo?.important)! { detailsCell.backgroundColor = DataManager.themeCellHighlightColor } else{ detailsCell.backgroundColor = UIColor.white }
//
//        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "customDetailsCell") as! DetailsCell
        
        // Allow multi line + word wrap
        cell.cellLabel.numberOfLines = 0
        cell.cellLabel.lineBreakMode = .byWordWrapping
        
        // Check for important
        if detailsItems[indexPath.section][indexPath.row].important{
            cell.backgroundColor = DataManager.themeCellHighlightColor
        } else{
            cell.backgroundColor = UIColor.white
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        //let itemText = detailsItems[indexPath.section][indexPath.row].item.firstUppercased
        
        // Set attributedText
        cell.cellLabel.attributedText = self.cellCache.first(where: {$0.section == indexPath.section && $0.row == indexPath.row} )?.attributedText
        cell.cellLabel.isUserInteractionEnabled = true
        
        var numAccessories = 0 // Used to determine layout
        
        // Set accessory 1
        if (self.accessoryCache.first(where: {$0.section == indexPath.section && $0.row == indexPath.row} )?.hasImage1)!{
            cell.cellImage1.isHidden = false
            cell.cellImage1.isUserInteractionEnabled = true
            let storedImageProperties = self.accessoryCache.first(where: {$0.section == indexPath.section && $0.row == indexPath.row} )?.accessory_image1
            cell.cellImage1.image = storedImageProperties?.image
            cell.cellImage1.backgroundColor = storedImageProperties?.backgroundColor
            cell.cellImage1.tintColor = storedImageProperties?.tintColor
            cell.cellImage1.layer.cornerRadius = (storedImageProperties?.layer.cornerRadius)!
            cell.cellImage1.clipsToBounds = (storedImageProperties?.clipsToBounds)!
            cell.cellImage1.tag = (storedImageProperties?.tag)!
            
            // Set action
            if storedImageProperties?.backgroundColor == DataManager.themeBlueColor{
                // Link
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellLinkedImageAction))
                cell.cellImage1.addGestureRecognizer(tapGestureRecognizer)
            } else if storedImageProperties?.backgroundColor == DataManager.themeRedColor{
                // Web
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellWebViewImageAction))
                cell.cellImage1.addGestureRecognizer(tapGestureRecognizer)
            } else if storedImageProperties?.backgroundColor == DataManager.themePurpleColor{
                // Related
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellRelatedAction))
                cell.cellImage1.addGestureRecognizer(tapGestureRecognizer)
            }
            numAccessories += 1
        } else{
            cell.cellImage1.isHidden = true
        }
        
        // Set accessory 2
        if (self.accessoryCache.first(where: {$0.section == indexPath.section && $0.row == indexPath.row} )?.hasImage2)!{
            cell.cellImage2.isHidden = false
            cell.cellImage2.isUserInteractionEnabled = true
            let storedImageProperties = self.accessoryCache.first(where: {$0.section == indexPath.section && $0.row == indexPath.row} )?.accessory_image2
            cell.cellImage2.image = storedImageProperties?.image
            cell.cellImage2.backgroundColor = storedImageProperties?.backgroundColor
            cell.cellImage2.tintColor = storedImageProperties?.tintColor
            cell.cellImage2.layer.cornerRadius = (storedImageProperties?.layer.cornerRadius)!
            cell.cellImage2.clipsToBounds = (storedImageProperties?.clipsToBounds)!
            cell.cellImage2.tag = (storedImageProperties?.tag)!
            
            // Set action
            if storedImageProperties?.backgroundColor == DataManager.themeBlueColor{
                // Link
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellLinkedImageAction))
                cell.cellImage2.addGestureRecognizer(tapGestureRecognizer)
            } else if storedImageProperties?.backgroundColor == DataManager.themeRedColor{
                // Web
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellWebViewImageAction))
                cell.cellImage2.addGestureRecognizer(tapGestureRecognizer)
            } else if storedImageProperties?.backgroundColor == DataManager.themePurpleColor{
                // Related
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellRelatedAction))
                cell.cellImage2.addGestureRecognizer(tapGestureRecognizer)
            }
            numAccessories += 1
        } else{
            cell.cellImage2.isHidden = true
        }
        
        // Set layout
        if numAccessories == 0{
            cell.cellImage1Width.priority = UILayoutPriority(rawValue: 750)
            cell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
            cell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 999)
            cell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
        } else if numAccessories == 1{
            cell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
            cell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
            cell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
            cell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
        } else if numAccessories == 2{
            cell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
            cell.cellImage2Width.priority = UILayoutPriority(rawValue: 999)
            cell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
            cell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 750)
        }
        
        // Set label tab (if needed)
        cell.cellLabelLeading.constant = (CGFloat(14 + (self.cellCache.first(where: {$0.section == indexPath.section && $0.row == indexPath.row} )?.tabWidth)!))
        
// BEGIN: DEFINITIONS NOT FUNCTIONING
        // Detect definition tap
        //cell.cellLabel.tag = cellDefinitions.filter{ $0.section == indexPath.section && $0.row == indexPath.row }.first.index
//        if cellDefinitions.index(where: { $0.section == indexPath.section && $0.row == indexPath.row } ) != nil {
//            cell.cellLabel.tag = cellDefinitions.index(where: { $0.section == indexPath.section && $0.row == indexPath.row } )!
//        } else{
//            cell.cellLabel.tag = 999
//        }
//
//        let tapLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellDefinitionsAction))
//        cell.cellLabel.addGestureRecognizer(tapLabelGestureRecognizer)
// END: DEFINITIONS NOT FUNCTIONING
        
        return cell
        
    }
    
    // Stores cell text as attributedText on view load to avoid dynaicly creating attributed text on cell load (scroll lag)
    func cacheAttributedText(){
        
        var sectionID = 0
        for section in self.detailsItems{
            var rowID = 0
            for row in section{
                
                // Replace arrows
                let itemText = row.item.replacingOccurrences(of: "->", with: "→").firstUppercased
                
                // Highlight searched text
                let attributedText = NSMutableAttributedString.init(string: itemText)
                let splitSearchArray = searchTerms.components(separatedBy: " ")
                
                var tabWidth = 0
                
                if matchBasis.contains(detailsHeaders[sectionID]){ // Only highlight matched term within matched section
                    for searchTerm in splitSearchArray {
                        var range = NSRange()
                        if (itemText.lowercased() as NSString).contains(searchTerm.lowercased()){
                            range = (itemText.lowercased() as NSString).range(of: searchTerm.lowercased())
                        } else if (itemText.lowercased() as NSString).contains(DataManager.convertAcronyms(searchTerm: searchTerm.lowercased())){
                            range = (itemText.lowercased() as NSString).range(of: DataManager.convertAcronyms(searchTerm: searchTerm.lowercased()))
                        }
                        attributedText.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow , range: range)
                    }
                }
                
                // Format arrows and colons
                if itemText.contains(" →"){
                    let subItem = itemText.components(separatedBy: " →").last!
                    
                    // Style just subtext (after ->)
                    let range = (itemText as NSString).range(of: subItem)
                    attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: DataManager.themeGreyColor, range: range)
                    
                } else if itemText.contains(": "){
                    let subItem = itemText.components(separatedBy: ": ").first!
                    let item = itemText.components(separatedBy: ": ").last!
                    
                    var firstColonItemOfKind:Bool = true
                    let matchingColonItems = colonItems.filter { $0.prefix == subItem && $0.section == sectionID }
                    if matchingColonItems.count == 0{
                        colonItems.append(ColonItems(prefix: subItem, item: item, section: sectionID) )
                    } else if matchingColonItems.first?.item == item{
                        firstColonItemOfKind = true
                    } else{
                        firstColonItemOfKind = false
                    }
                    
                    // Style just subtext (before : )
                    let range = (itemText as NSString).range(of: subItem)
                    attributedText.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 17), range: range)
                    
                    var numberOfTabs = 0
                    let sectionItemsWithColon = detailsItems[sectionID].filter { $0.item.contains(": ") }
                    if let longestItem = sectionItemsWithColon.max(by: {$1.item.components(separatedBy: ": ").first!.size().width > $0.item.components(separatedBy: ": ").first!.size().width}) {
                        let subitemSize = (subItem as NSString).size().width
                        let longestItemSize = (longestItem.item.components(separatedBy: ": ").first! as NSString).size().width
                        let longestPrefix = longestItem.item.components(separatedBy: ": ").first! + ": "
                        
                        // Set up prefix with attributes to get proper width
                        let attributedText2 = NSMutableAttributedString.init(string: longestPrefix)
                        let range = (longestPrefix as NSString).range(of: longestPrefix)
                        attributedText2.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 17), range: range)
                        tabWidth = Int(attributedText2.size().width)
                        
                        if longestItemSize != subitemSize{ // Not longest
                            // NOTE: The following is dedicated to adding spaces after prefix for all first items that are not the longest
                            
                            // Set up attributed longest to get size
                            let testLongItem = (longestItem.item.components(separatedBy: ": ").first! + ": ")
                            let attributedLongest = NSMutableAttributedString.init(string: testLongItem)
                            let rangeLongest = (testLongItem as NSString).range(of: testLongItem)
                            attributedLongest.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 17), range: rangeLongest)
                            
                            // Set up attributedcurrent to get size
                            let testSubItem = subItem + ": "
                            let attributedSubItem = NSMutableAttributedString.init(string: testSubItem)
                            let rangeSubItem = (testSubItem as NSString).range(of: testSubItem)
                            attributedSubItem.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 17), range: rangeSubItem)
                            
                            var addedTabs = 0

                            while attributedSubItem.size().width < attributedLongest.size().width{
                                addedTabs += 1
                                let space = " "
                                let attributedSpace = NSMutableAttributedString.init(string: space)
                                let rangeSpace = (space as NSString).range(of: space)
                                attributedSpace.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: 17), range: rangeSpace)
                                attributedSubItem.append(attributedSpace)
                            }
                            
                            numberOfTabs = addedTabs
                            
                        } else{ // Longest
                            numberOfTabs = 1
                        }
                    }
                    
                    // Add additional tabs
                    if !firstColonItemOfKind{
                        attributedText.replaceCharacters(in: (itemText as NSString).range(of: subItem + ": "), with: "")
                    } else{
                        attributedText.replaceCharacters(in: (itemText as NSString).range(of: ": "), with: ":" + String(repeating: " ", count: numberOfTabs))
                        tabWidth = 0
                    }
                    
                }
                
                // Set line height
                let lineHeight = NSMutableParagraphStyle()
                lineHeight.lineSpacing = 2
                attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: lineHeight, range: NSMakeRange(0, attributedText.length))
                
// BEGIN: DEFINITIONS NOT FUNCTIONING
//                // Format definitions
//                let matchedDefinitions = definitions.filter({(key: String, value: String) -> Bool in
//                    let stringMatch = itemText.lowercased().range(of: key.lowercased())
//                    return stringMatch != nil ? true : false
//                })
//                if !matchedDefinitions.isEmpty{
//                    for matchedDefinition in matchedDefinitions{
//                        //let tapLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellDefinitionsAction))
//
//                        let range = (itemText.lowercased() as NSString).range(of: matchedDefinition.key)
//                        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: DataManager.themeBlueColor, range: range)
//                        attributedText.addAttribute(NSAttributedStringKey.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: range)
//                        attributedText.addAttribute(NSAttributedStringKey.underlineColor, value: DataManager.themeBlueColor, range: range)
//
//                        if !cellDefinitions.contains(where: { $0.section == sectionID && $0.row == rowID && $0.item == matchedDefinition.key } ){
//                            cellDefinitions.append(
//                                CellDefinitions(
//                                    item: matchedDefinition.key,
//                                    definition: matchedDefinition.value,
//                                    section: sectionID,
//                                    row: rowID,
//                                    range: range
//                                )
//                            )
//                        }
//                        //cell.cellLabel.tag = cellDefinitions.index(where: { $0.label.text?.lowercased() == cell.cellLabel.text?.lowercased() } )!
//                        //cell.cellLabel.addGestureRecognizer(tapLabelGestureRecognizer)
//                    }
//
//
//                }
// END: DEFINITIONS NOT FUNCTIONING
                
                // Finally, store attributedText
                self.cellCache.append(CellCache(section: sectionID, row: rowID, attributedText: attributedText, tabWidth: tabWidth))
                
                rowID += 1
            }
            sectionID += 1
        }
        
    }
    
    func cacheAccessories(){
        
        var sectionID = 0
        for section in self.detailsItems{
            var rowID = 0
            for row in section{
                
                let accessoryImage1:UIImageView = UIImageView()
                let accessoryImage2:UIImageView = UIImageView()
                
                // Replace arrows
                let itemText = row.item.replacingOccurrences(of: "->", with: "→")
                
                // Setup Accessory Icons
                var mainItem = itemText
                if itemText.contains(" →"){
                    mainItem = itemText.components(separatedBy: " →").first!
                }
                let accessory = DataManager.getAccessories(name: detailsName, table: detailsHeaders[sectionID], fact: itemText)
                let relatedAccessory = accessory.relatedAccessory
                let webViewAccessory = accessory.webViewAccessory
                var accessoriesUsed:Int = 0
                
                // Distinguish between Related category and others
                if detailsHeaders[sectionID] == "Related"{
                    
                    
                    var relatedName = itemText
                    if relatedName.contains(" →"){
                        relatedName = relatedName.components(separatedBy: " →").first!
                        
                    }
                    
                    if UIImage(named: "cellAccessory_related") != nil{
                        accessoryImage1.image = UIImage(named: "cellAccessory_related")
                        accessoryImage1.tintColor = DataManager.themeBackgroundColor
                        accessoryImage1.backgroundColor = DataManager.themePurpleColor
                        accessoryImage1.layer.cornerRadius = 8.0
                        accessoryImage1.clipsToBounds = true
                        
                        let tapLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellRelatedAction))
                        
                        if !accessoryRelated.contains(where: { $0.term == detailsItems[sectionID][rowID].item } ){
                            accessoryRelated.append(
                                RelatedAccessory(
                                    term: detailsItems[sectionID][rowID].item,
                                    relatedName: relatedName
                                )
                            )
                        }
                        
                        accessoryImage1.tag = accessoryRelated.index(where: { $0.term == detailsItems[sectionID][rowID].item } )!
                        accessoryImage1.addGestureRecognizer(tapLabelGestureRecognizer)
                        
                    }
                    
                } else{ // All categories other than Related
                    
                    // Add accessories
                    if !relatedAccessory.isEmpty{
                        if UIImage(named: "cellAccessory_linked") != nil{
                            accessoryImage1.image = UIImage(named: "cellAccessory_linked")
                            accessoryImage1.tintColor = DataManager.themeBackgroundColor
                            accessoryImage1.backgroundColor = DataManager.themeBlueColor
                            accessoryImage1.layer.cornerRadius = 8.0
                            accessoryImage1.clipsToBounds = true
                            
                            let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cellLinkedImageAction))
                            
                            if !accessoryLinked.contains(where: { $0.term == mainItem } ){
                                accessoryLinked.append(AccessoryRelated(term: mainItem, related: relatedAccessory, match:[detailsHeaders[sectionID]]))
                            }
                            
                            accessoryImage1.tag = accessoryLinked.index(where: { $0.term == mainItem } )!
                            accessoryImage1.addGestureRecognizer(tapGestureRecognizer1)
                            
                        }
                        accessoriesUsed += 1
                    } else{
                        // No image to show
                        accessoryImage1.image = nil
                    }
                    
                    if !webViewAccessory.isEmpty{
                        if UIImage(named: "cellAccessory_webview") != nil{
                            if accessoriesUsed == 1{
                                accessoryImage2.image = UIImage(named: "cellAccessory_webview")
                                accessoryImage2.tintColor = DataManager.themeBackgroundColor
                                accessoryImage2.backgroundColor = DataManager.themeRedColor
                                accessoryImage2.layer.cornerRadius = 8.0
                                accessoryImage2.clipsToBounds = true
                                
                                let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(cellWebViewImageAction))
                                accessoryImage2.isUserInteractionEnabled = true
                                
                                if !accessoryWebView.contains(where: { $0.title == mainItem } ){
                                    accessoryWebView.append(AccessoryWebView(title: mainItem, url: webViewAccessory))
                                }
                                
                                accessoryImage2.tag = accessoryWebView.index(where: { $0.title == mainItem } )!
                                
                                accessoryImage2.addGestureRecognizer(tapGestureRecognizer2)
                                
                            } else{
                                accessoryImage1.image = UIImage(named: "cellAccessory_webview")
                                accessoryImage1.tintColor = DataManager.themeBackgroundColor
                                accessoryImage1.backgroundColor = DataManager.themeRedColor
                                accessoryImage1.layer.cornerRadius = 8.0
                                accessoryImage1.clipsToBounds = true
                                
                                let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(cellWebViewImageAction))
                                
                                if !accessoryWebView.contains(where: { $0.title == mainItem } ){
                                    accessoryWebView.append(AccessoryWebView(title: mainItem, url: webViewAccessory))
                                }
                                
                                accessoryImage1.tag = accessoryWebView.index(where: { $0.title == mainItem } )!
                                
                                accessoryImage1.addGestureRecognizer(tapGestureRecognizer2)
                                
                            }
                        }
                    } else{
                        // No image to show
                        if accessoriesUsed == 1{
                            accessoryImage2.image = nil
                        } else{
                            accessoryImage1.image = nil
                        }
                        
                    }
                    
                }
                    
                // Save completed cell so it doesn't need to be called from scratch
                var hasImage1:Bool = false
                var hasImage2:Bool = false
                
                if accessoryImage1.image != nil{
                    hasImage1 = true
                }
                if accessoryImage2.image != nil{
                    hasImage2 = true
                }
                
                // Store accessoryCache
                accessoryCache.append(AccessoryCache(section: sectionID, row: rowID, accessory_image1: accessoryImage1, accessory_image2: accessoryImage2, hasImage1: hasImage1, hasImage2: hasImage2, important: detailsItems[sectionID][rowID].important))

                rowID += 1
            }
            
            sectionID += 1
        }
    }
    
    // Handle tapped related label
    @objc func tapRelatedLabel(_ sender:AnyObject) {
        
        // Push to DetailsViewController
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        let matchBasis:Set<String> = ["Related"]
        nextViewController.detailsName = accessoryRelated[sender.view.tag].relatedName
        nextViewController.matchBasis = matchBasis
        DataManager.setLastAccessed(bugName: detailsName, matchBasis: matchBasis.joined(separator: ", ")) // Set as recent
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    // Handle tapped accessory icons
    @objc func cellLinkedImageAction(_ sender:AnyObject){
        // Open Related View
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "relatedView") as! RelatedViewController
        nextViewController.passedName = detailsName
        nextViewController.passedTerm = accessoryLinked[sender.view.tag].term
        nextViewController.matchBasis = accessoryLinked[sender.view.tag].match
        nextViewController.relatedEntities = accessoryLinked[sender.view.tag].related
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    @objc func cellWebViewImageAction(_ sender:AnyObject){
        // Open Web View
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "webView") as! WebViewController
        nextViewController.passedTitle = accessoryWebView[sender.view.tag].title
        nextViewController.passedURL = accessoryWebView[sender.view.tag].url
        self.navigationController?.showDetailViewController(nextViewController, sender: self)
    }
    @objc func cellRelatedAction(_ sender:AnyObject){
        // Push to DetailsViewController
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        let matchBasis:Set<String> = ["Related"]
        nextViewController.detailsName = accessoryRelated[sender.view.tag].relatedName
        nextViewController.matchBasis = matchBasis
        DataManager.setLastAccessed(bugName: detailsName, matchBasis: matchBasis.joined(separator: ", ")) // Set as recent
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
//    @objc func cellDefinitionsAction(gesture: UITapGestureRecognizer){
//        var definition = ""
//        var item = ""
//        let label = UILabel() //cellDefinitions[(gesture.view?.tag)!].label
//        //print("LABEL W: \(label.layer.bounds.width), SAVED W: \(labelWidth) FOR: \(cellDefinitions[(gesture.view?.tag)!].label.text)")
//        let cachedCell = cellCache.filter{$0.section == cellDefinitions[(gesture.view?.tag)!].section && $0.row == cellDefinitions[(gesture.view?.tag)!].row}.first
//        label.attributedText = cachedCell?.attributedText
//
//        let tapRange = gesture.didTapAttributedTextInLabel(label: label)
//        print("TAPPED: \(tapRange) | \(String(describing: gesture.view?.tag))")
//
//        // Get cellDefinitions that match this label text (in case one label has multiple definitions)
////        _ = cellDefinitions.filter({(cellDefinitions) -> Bool in
////            if cellDefinitions.label.text?.lowercased() == label.text?.lowercased(){
////                if let range = label.text?.lowercased().range(of: cellDefinitions.item) {
////
////                    //if range.nsRange.lowerBound...range.nsRange.upperBound ~= tapRange && tapRange != 0{
////                    if NSLocationInRange(tapRange, range.nsRange) && tapRange != 0 && tapRange != label.text?.count{
////                        print("MATCHED \(cellDefinitions.item) Low: \(range.nsRange.lowerBound), High: \(range.nsRange.upperBound)")
////                        //print("MATCHED RANGE: \(range.nsRange)")
////                        definition = cellDefinitions.definition
////                        item = cellDefinitions.item
////                    }
////                }
////                return true
////            } else{
////                return false
////            }
////        })
//
//
//        if !item.isBlank || !definition.isBlank{
//            // Launch Popup
//
//            // Create the AlertController
//            let actionSheetController = UIAlertController(title: "Definition: \(item)", message: definition, preferredStyle: .actionSheet)
//
//            // Create and add the Cancel action
//            let cancelAction = UIAlertAction(title: "Done", style: .cancel) { action -> Void in
//                // Just dismiss the action sheet
//            }
//            actionSheetController.addAction(cancelAction)
//
//            // We need to provide a popover sourceView when using it on iPad
//            actionSheetController.popoverPresentationController?.sourceView = label
//
//            // Present the AlertController
//            self.present(actionSheetController, animated: true, completion: nil)
//        }
//    }

}

extension DetailsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Make sure that tapping cell doesn't make it turn grey
        //detailsTable.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
    }
    
}

// Capitalize first letter of sentence
extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}

//extension UITapGestureRecognizer {
//    func didTapAttributedTextInLabel(label: UILabel) -> Int {
//
//        // Make sure the recognizer hit that same label
//        guard self.view as? UILabel == label else {
//            return 999
//        }
//
//        // Make sure label contains attributed text
//        guard let attributedText = label.attributedText else {
//            return 999
//        }
//
//        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
//        let layoutManager = NSLayoutManager()
//        let textContainer = NSTextContainer(size: CGSize.zero)
//        let textStorage = NSTextStorage(attributedString: attributedText)
//
//        // Configure layoutManager and textStorage
//        layoutManager.addTextContainer(textContainer)
//        textStorage.addLayoutManager(layoutManager)
//
//        // Configure textContainer
//        textContainer.lineFragmentPadding = 0.0
//        textContainer.lineBreakMode = label.lineBreakMode
//        textContainer.maximumNumberOfLines = label.numberOfLines
//        let labelSize = label.bounds.size
//        textContainer.size = labelSize
//
//        // Find the tapped character location and compare it to the specified range
//        let locationOfTouchInLabel = self.location(in: label)
//        //print("TOUCH: \(locationOfTouchInLabel)")
//        let textBoundingBox = layoutManager.usedRect(for: textContainer)
//        //print("WR: \(labelWidth) | W1: \(labelSize.width), HR: \(labelHeight) | H1: \(labelSize.height)")
//        //print("TAP BoundingWidth: \(textBoundingBox.size.width), BoundingWidth-STORED \(boundingWidth)")
//        let textContainerOffset = CGPoint(
//            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
//            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
//        )
//        //print("OFFSET-X: \(textContainerOffset.x), Y: \(textContainerOffset.y)")
//        //print("TAP:  LW: \(label.layer.bounds.width) vs. \(labelWidth), BBW: \(textBoundingBox.size.width), BBO: \(textBoundingBox.origin.x)")
//        //print("OC: \((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x), O1: \(textContainerOffset.x)")
//        //print("TOUCH: \(locationOfTouchInLabel.x), OFFSET: \(textContainerOffset.x), = \(locationOfTouchInLabel.x - textContainerOffset.x)")
//
//        let locationOfTouchInTextContainer = CGPoint(
//            x: locationOfTouchInLabel.x - textContainerOffset.x,
//            y: locationOfTouchInLabel.y - textContainerOffset.y
//        )
//        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//        //print("INDEX: \(indexOfCharacter)") // OFFSET IS OFF!
//        return indexOfCharacter
//    }
//}
//extension UITapGestureRecognizer {
//    func didTapAttributedTextInLabel(label: UILabel) -> Int {
//
//        // Make sure the recognizer hit that same label
//        guard self.view as? UILabel == label else {
//            return 999
//        }
//
//        // Make sure label contains attributed text
//        guard let attributedText = label.attributedText else {
//            return 999
//        }
//
//        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
//        let layoutManager = NSLayoutManager()
//        let textContainer = NSTextContainer(size: CGSize.zero)
//        let textStorage = NSTextStorage(attributedString: attributedText)
//
//        // Configure layoutManager and textStorage
//        layoutManager.addTextContainer(textContainer)
//        textStorage.addLayoutManager(layoutManager)
//
//        // Configure textContainer
//        textContainer.lineFragmentPadding = 0.0
//        textContainer.lineBreakMode = label.lineBreakMode
//        textContainer.maximumNumberOfLines = label.numberOfLines
//        let labelSize = label.bounds.size
//        textContainer.size = labelSize
//
//        // Find the tapped character location and compare it to the specified range
//        let locationOfTouchInLabel = self.location(in: label)
//        //print("TOUCH: \(locationOfTouchInLabel)")
//        let textBoundingBox = layoutManager.usedRect(for: textContainer)
//        //print("WR: \(labelWidth) | W1: \(labelSize.width), HR: \(labelHeight) | H1: \(labelSize.height)")
//        //print("TAP BoundingWidth: \(textBoundingBox.size.width), BoundingWidth-STORED \(boundingWidth)")
//        let textContainerOffset = CGPoint(
//            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
//            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
//        )
//        //print("OFFSET-X: \(textContainerOffset.x), Y: \(textContainerOffset.y)")
//        //print("TAP:  LW: \(label.layer.bounds.width) vs. \(labelWidth), BBW: \(textBoundingBox.size.width), BBO: \(textBoundingBox.origin.x)")
//        //print("OC: \((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x), O1: \(textContainerOffset.x)")
//        //print("TOUCH: \(locationOfTouchInLabel.x), OFFSET: \(textContainerOffset.x), = \(locationOfTouchInLabel.x - textContainerOffset.x)")
//
//        let locationOfTouchInTextContainer = CGPoint(
//            x: locationOfTouchInLabel.x - textContainerOffset.x,
//            y: locationOfTouchInLabel.y - textContainerOffset.y
//        )
//        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
//        //print("INDEX: \(indexOfCharacter)") // OFFSET IS OFF!
//        return indexOfCharacter
//    }
//}

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}

