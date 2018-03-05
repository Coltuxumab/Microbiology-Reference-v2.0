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
    
    @IBOutlet weak var cellImage1: UIImageView!
    
    @IBOutlet weak var cellImage2: UIImageView!
    
    let tapRec = UITapGestureRecognizer() // WHY IS THIS HERE?
    
    @IBOutlet weak var cellImage1Width: NSLayoutConstraint!
    @IBOutlet weak var cellImage2Width: NSLayoutConstraint!
    
    @IBOutlet weak var cellImage1WidthSmall: NSLayoutConstraint!
    @IBOutlet weak var cellImage2WidthSmall: NSLayoutConstraint!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        cellImage1Width.priority = UILayoutPriority(rawValue: 750)
        cellImage2Width.priority = UILayoutPriority(rawValue: 750)
        cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 999)
        cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
        
    }
    
}

class DetailsViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var detailsTable: UITableView!
    
    var detailsName:String = "Default Name"
    var matchBasis:Set<String> = ["none"]
    var searchTerms:String = "term"
    
    var definitions:[String:String] = [:]
    
    var detailsHeaders:[String] = []    // Final headers to be displayed
    var detailsItems:[[String]] = []    // Final data (rows) to be displayed
    
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
        var label:UILabel
        var range:NSRange
    }
    
    var accessoryRelated = [RelatedAccessory]()
    var accessoryLinked = [AccessoryRelated]()
    var accessoryWebView = [AccessoryWebView]()
    var cellDefinitions = [CellDefinitions]()
    
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
//        DataManager.getAllDefinitions { (returnDefinitions) -> () in
//            print("Definitions: \(returnDefinitions)")
//            self.definitions = returnDefinitions
//        }
        
        // Get data
        DataManager.getSingleBug(bugName: detailsName){ (headers,data) -> () in
            self.detailsHeaders = headers
            self.detailsItems = data
            self.detailsTable.reloadData()
        }
        
        // Set share text
        shareText = "\(detailsName) \n"
        var i = 0
        for item in self.detailsHeaders{
            shareText = shareText + "\n\(item):\n"
            shareText = shareText + "\(self.detailsItems[i].joined(separator: "\n"))\n"
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

        
        let accessory = DataManager.getAccessories(name: detailsName, table: detailsHeaders[indexPath.section], fact: detailsItems[indexPath.section][indexPath.row])
        let relatedAccessory = accessory.relatedAccessory
        let webViewAccessory = accessory.webViewAccessory

        if let detailsCell = cell as? DetailsCell  {

            // If category is Related, show image
            if detailsHeaders[indexPath.section] == "Related"{
                detailsCell.cellImage1.isHidden = false
                detailsCell.cellImage2.isHidden = true
                
                detailsCell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
                detailsCell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
                detailsCell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
                detailsCell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
            } else{ // Any category other than Related
                if relatedAccessory.isEmpty && webViewAccessory.isEmpty{
                    detailsCell.cellImage1.isHidden = true
                    detailsCell.cellImage2.isHidden = true
                    
                    detailsCell.cellImage1Width.priority = UILayoutPriority(rawValue: 750)
                    detailsCell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
                    detailsCell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 999)
                    detailsCell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
                    
                } else if (relatedAccessory.isEmpty && !webViewAccessory.isEmpty) || (!relatedAccessory.isEmpty && webViewAccessory.isEmpty){
                    detailsCell.cellImage1.isHidden = false
                    detailsCell.cellImage2.isHidden = true
                    
                    detailsCell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
                    detailsCell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
                    detailsCell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
                    detailsCell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
                    
                } else{
                    detailsCell.cellImage1.isHidden = false
                    detailsCell.cellImage2.isHidden = false
                    
                    detailsCell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
                    detailsCell.cellImage2Width.priority = UILayoutPriority(rawValue: 999)
                    detailsCell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
                    detailsCell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 750)
                    
                }
            }
            
            // Check definitions
//            for index in 0..<cellDefinitions.count {
//                if cellDefinitions[index].label.text == detailsCell.cellLabel.text{
//                    if cellDefinitions[index].label == detailsCell.cellLabel{
//                        print("EXACT label match")
//                    }
//                    print("Matched label based on text: \(String(describing: detailsCell.cellLabel.text))")
//                    cellDefinitions[index].label = detailsCell.cellLabel
//                }
//            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "customDetailsCell") as! DetailsCell
        
        // Allow multi line + word wrap
        cell.cellLabel.numberOfLines = 0
        cell.cellLabel.lineBreakMode = .byWordWrapping
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        var itemText = detailsItems[indexPath.section][indexPath.row].firstUppercased
        
        // Replace arrows
        itemText = itemText.replacingOccurrences(of: "->", with: "→")
        
        // Highlight searched text
        let labelAttributed = NSMutableAttributedString.init(string: itemText)
        let splitSearchArray = searchTerms.components(separatedBy: " ")
        
        if matchBasis.contains(detailsHeaders[indexPath.section]){ // Only highlight matched term within matched section
            for searchTerm in splitSearchArray {
                var range = NSRange()
                if (itemText.lowercased() as NSString).contains(searchTerm.lowercased()){
                    range = (itemText.lowercased() as NSString).range(of: searchTerm.lowercased())
                } else if (itemText.lowercased() as NSString).contains(DataManager.convertAcronyms(searchTerm: searchTerm.lowercased())){
                    range = (itemText.lowercased() as NSString).range(of: DataManager.convertAcronyms(searchTerm: searchTerm.lowercased()))
                }
                labelAttributed.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow , range: range)
            }
        }
        
        cell.cellLabel.attributedText = labelAttributed
        
        // Setup Accessory Icons
        var mainItem = itemText
        if itemText.contains(" →"){
            mainItem = itemText.components(separatedBy: " →").first!
        }
        let accessory = DataManager.getAccessories(name: detailsName, table: detailsHeaders[indexPath.section], fact: itemText)
        let relatedAccessory = accessory.relatedAccessory
        let webViewAccessory = accessory.webViewAccessory
        var accessoriesUsed:Int = 0
        
        //print("Item: \(itemText), WV: \(webViewAccessory)")
        
        // Distinguish between Related category and others
        if detailsHeaders[indexPath.section] == "Related"{
            cell.cellLabel.isUserInteractionEnabled = true
            
            var relatedName = itemText
            if relatedName.contains(" →"){
                relatedName = relatedName.components(separatedBy: " →").first!
                
                // Style just link
//                let range = (itemText as NSString).range(of: relatedName)
//                labelAttributed.addAttribute(NSAttributedStringKey.foregroundColor, value: DataManager.themeBlueColor, range: range)
//                labelAttributed.addAttribute(NSAttributedStringKey.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: range)
//                labelAttributed.addAttribute(NSAttributedStringKey.underlineColor, value: DataManager.themeBlueColor, range: range)
                
            } else{
                // Whole thing is a link, so style
//                let range = (itemText as NSString).range(of: itemText)
//                labelAttributed.addAttribute(NSAttributedStringKey.foregroundColor, value: DataManager.themeBlueColor, range: range)
//                labelAttributed.addAttribute(NSAttributedStringKey.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: range)
//                labelAttributed.addAttribute(NSAttributedStringKey.underlineColor, value: DataManager.themeBlueColor, range: range)
                
            }
//            cell.cellLabel.attributedText = labelAttributed
            
//            if !cellRelatedLabel.contains(where: { $0.term == detailsItems[indexPath.section][indexPath.row] } ){
//                cellRelatedLabel.append(
//                    CellRelatedLabel(
//                        term: detailsItems[indexPath.section][indexPath.row],
//                        relatedName: relatedName
//                    )
//                )
//            }
//
//            cell.cellLabel.tag = cellRelatedLabel.index(where: { $0.term == detailsItems[indexPath.section][indexPath.row] } )!
//            cell.cellLabel.addGestureRecognizer(tapLabelGestureRecognizer)
            
            // Add accessory
            cell.cellImage1.image = nil
            cell.cellImage2.image = nil
            
            if UIImage(named: "cellAccessory_related") != nil{
                cell.cellImage1.image = UIImage(named: "cellAccessory_related")
                cell.cellImage1.tintColor = DataManager.themeBackgroundColor
                cell.cellImage1.backgroundColor = DataManager.themePurpleColor
                cell.cellImage1.layer.cornerRadius = 8.0
                cell.cellImage1.clipsToBounds = true
                
                let tapLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellRelatedAction))
                cell.cellImage1.isUserInteractionEnabled = true
                
                if !accessoryRelated.contains(where: { $0.term == detailsItems[indexPath.section][indexPath.row] } ){
                    accessoryRelated.append(
                        RelatedAccessory(
                            term: detailsItems[indexPath.section][indexPath.row],
                            relatedName: relatedName
                        )
                    )
                }
                
                cell.cellImage1.tag = accessoryRelated.index(where: { $0.term == detailsItems[indexPath.section][indexPath.row] } )!
                cell.cellImage1.addGestureRecognizer(tapLabelGestureRecognizer)
                
                // Set constraints: 1 accessory
                cell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
                cell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
                cell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
                cell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
            }
            
        } else{ // All categories other than Related
            
//            if relatedAccessory.isEmpty && webViewAccessory.isEmpty{
//                // Set constraints: 0 accessories
//                cell.cellImage1Width.priority = UILayoutPriority(rawValue: 750)
//                cell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
//                cell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 999)
//                cell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
//            }
            
            // Add accessories
            if !relatedAccessory.isEmpty{
                if UIImage(named: "cellAccessory_linked") != nil{
                    cell.cellImage1.image = UIImage(named: "cellAccessory_linked")
                    cell.cellImage1.tintColor = DataManager.themeBackgroundColor
                    cell.cellImage1.backgroundColor = DataManager.themeBlueColor
                    cell.cellImage1.layer.cornerRadius = 8.0
                    cell.cellImage1.clipsToBounds = true
                    
                    let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cellLinkedImageAction))
                    cell.cellImage1.isUserInteractionEnabled = true
                    
                    if !accessoryLinked.contains(where: { $0.term == mainItem } ){
                        accessoryLinked.append(AccessoryRelated(term: mainItem, related: relatedAccessory, match:[detailsHeaders[indexPath.section]]))
                    }
                    
                    cell.cellImage1.tag = accessoryLinked.index(where: { $0.term == mainItem } )!
                    cell.cellImage1.addGestureRecognizer(tapGestureRecognizer1)
                    
                    // Set constraints: 1 accessory
//                    cell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
//                    cell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
//                    cell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
//                    cell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
                }
                accessoriesUsed += 1
            } else{
                // No image to show
                cell.cellImage1.image = nil
            }
            
            if !webViewAccessory.isEmpty{
                if UIImage(named: "cellAccessory_webview") != nil{
                    if accessoriesUsed == 1{
                        cell.cellImage2.image = UIImage(named: "cellAccessory_webview")
                        cell.cellImage2.tintColor = DataManager.themeBackgroundColor
                        cell.cellImage2.backgroundColor = DataManager.themeRedColor
                        cell.cellImage2.layer.cornerRadius = 8.0
                        cell.cellImage2.clipsToBounds = true
                        
                        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(cellWebViewImageAction))
                        cell.cellImage2.isUserInteractionEnabled = true
                        
                        if !accessoryWebView.contains(where: { $0.title == mainItem } ){
                            accessoryWebView.append(AccessoryWebView(title: mainItem, url: webViewAccessory))
                        }
                        
                        cell.cellImage2.tag = accessoryWebView.index(where: { $0.title == mainItem } )!
                        
                        cell.cellImage2.addGestureRecognizer(tapGestureRecognizer2)
                        
                        // Set constraints: 2 accessories
//                        cell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
//                        cell.cellImage2Width.priority = UILayoutPriority(rawValue: 999)
//                        cell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
//                        cell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 750)
                        
                    } else{
                        cell.cellImage1.image = UIImage(named: "cellAccessory_webview")
                        cell.cellImage1.tintColor = DataManager.themeBackgroundColor
                        cell.cellImage1.backgroundColor = DataManager.themeRedColor
                        cell.cellImage1.layer.cornerRadius = 8.0
                        cell.cellImage1.clipsToBounds = true
                        
                        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(cellWebViewImageAction))
                        cell.cellImage1.isUserInteractionEnabled = true
                        
                        if !accessoryWebView.contains(where: { $0.title == mainItem } ){
                            accessoryWebView.append(AccessoryWebView(title: mainItem, url: webViewAccessory))
                        }
                        
                        cell.cellImage1.tag = accessoryWebView.index(where: { $0.title == mainItem } )!
                        
                        cell.cellImage1.addGestureRecognizer(tapGestureRecognizer2)
                        
                        // Set constraints: 1 accessory
//                        cell.cellImage1Width.priority = UILayoutPriority(rawValue: 999)
//                        cell.cellImage2Width.priority = UILayoutPriority(rawValue: 750)
//                        cell.cellImage1WidthSmall.priority = UILayoutPriority(rawValue: 750)
//                        cell.cellImage2WidthSmall.priority = UILayoutPriority(rawValue: 999)
                    }
                }
            } else{
                // No image to show
                if accessoriesUsed == 1{
                    cell.cellImage2.image = nil
                } else{
                    cell.cellImage1.image = nil
                }
                
            }
            
        }
        
        // Format arrows and colons
        if itemText.contains(" →"){
            let subItem = itemText.components(separatedBy: " →").last!
            
            // Style just subtext (after ->)
            let range = (itemText as NSString).range(of: subItem)
            labelAttributed.addAttribute(NSAttributedStringKey.foregroundColor, value: DataManager.themeGreyColor, range: range)
            
        } else if itemText.contains(": "){
            let subItem = itemText.components(separatedBy: ": ").first!
            
            var numberOfTabs = 0
            let sectionItemsWithColon = detailsItems[indexPath.section].filter { $0.contains(": ") }
            if let longestItem = sectionItemsWithColon.max(by: {$1.components(separatedBy: ": ").first!.size().width > $0.components(separatedBy: ": ").first!.size().width}) {
                //let tabSize = 28
                let subitemSize = (subItem as NSString).size().width
                let longestItemSize = (longestItem.components(separatedBy: ": ").first! as NSString).size().width

                if longestItemSize != subitemSize{ // Not longest
                    
                    let testLongItemSize = (longestItem.components(separatedBy: ":").first! + ":").size().width
                    var testSubItem = subItem + ":"

                    var addedTabs = 1
                    while testSubItem.size().width < testLongItemSize{
                        addedTabs += 1
                        testSubItem = testSubItem + " "
                    }
                    

                    numberOfTabs = addedTabs
                    
                } else{ // Longest
                    numberOfTabs = 1
                }
            }
            

            // Style just subtext (before ->)
            let range = (itemText as NSString).range(of: subItem)
            labelAttributed.addAttribute(NSAttributedStringKey.foregroundColor, value: DataManager.themeGreyColor, range: range)
            
            // Add additional tabs
            var i = 0
            var extraTabs = ""
            while i < (numberOfTabs){
                extraTabs += " "
                i += 1
            }
            
            labelAttributed.replaceCharacters(in: (itemText as NSString).range(of: ":"), with: ":" + String(repeating: " ", count: numberOfTabs))
            
        }
        cell.cellLabel.attributedText = labelAttributed
        
        // Format definitions
//        let matchedDefinitions = definitions.filter({(key: String, value: String) -> Bool in
//            let stringMatch = itemText.lowercased().range(of: key.lowercased())
//            return stringMatch != nil ? true : false
//        })
//        if !matchedDefinitions.isEmpty{
//            for matchedDefinition in matchedDefinitions{
//                let tapLabelGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellDefinitionsAction))
//
//                let range = (itemText.lowercased() as NSString).range(of: matchedDefinition.key)
//                labelAttributed.addAttribute(NSAttributedStringKey.foregroundColor, value: DataManager.themeBlueColor, range: range)
//                labelAttributed.addAttribute(NSAttributedStringKey.underlineStyle , value: NSUnderlineStyle.styleSingle.rawValue, range: range)
//                labelAttributed.addAttribute(NSAttributedStringKey.underlineColor, value: DataManager.themeBlueColor, range: range)
//
//                cell.cellLabel.isUserInteractionEnabled = true
//
//                cell.cellLabel.attributedText = labelAttributed
//
//                //print("TextBoundingWidth: \(cell.layer.bounds.width), ORIGIN \(cell.layer.bounds.origin.x) FOR \(cell.cellLabel.text)")
//
//                if !cellDefinitions.contains(where: { $0.label == cell.cellLabel && $0.item == matchedDefinition.key } ){
//                    cellDefinitions.append(
//                        CellDefinitions(
//                            item: matchedDefinition.key,
//                            definition: matchedDefinition.value,
//                            label: cell.cellLabel,
//                            range: range
//                        )
//                    )
//                }
//                cell.cellLabel.tag = cellDefinitions.index(where: { $0.label.text?.lowercased() == cell.cellLabel.text?.lowercased() } )!
//                cell.cellLabel.addGestureRecognizer(tapLabelGestureRecognizer)
//            }
//
//
//        }
        
        return cell
        
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
//        let label = cellDefinitions[(gesture.view?.tag)!].label
//        //print("LABEL W: \(label.layer.bounds.width), SAVED W: \(labelWidth) FOR: \(cellDefinitions[(gesture.view?.tag)!].label.text)")
//
//        let tapRange = gesture.didTapAttributedTextInLabel(label: label)
//        print("TAPPED: \(tapRange)")
//
//        // Get cellDefinitions that match this label text (in case one label has multiple definitions)
//        _ = cellDefinitions.filter({(cellDefinitions) -> Bool in
//            if cellDefinitions.label.text?.lowercased() == label.text?.lowercased(){
//                if let range = label.text?.lowercased().range(of: cellDefinitions.item) {
//
//                    //if range.nsRange.lowerBound...range.nsRange.upperBound ~= tapRange && tapRange != 0{
//                    if NSLocationInRange(tapRange, range.nsRange) && tapRange != 0 && tapRange != label.text?.count{
//                        print("MATCHED \(cellDefinitions.item) Low: \(range.nsRange.lowerBound), High: \(range.nsRange.upperBound)")
//                        //print("MATCHED RANGE: \(range.nsRange)")
//                        definition = cellDefinitions.definition
//                        item = cellDefinitions.item
//                    }
//                }
//                return true
//            } else{
//                return false
//            }
//        })
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
        detailsTable.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
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

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}

