//
//  BrowseViewController.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 11/11/17.
//  Copyright © 2017 Denkensohn. See LICENSE.txt
//

import UIKit

class BrowseViewController: UIViewController {
    
    @IBOutlet weak var browseTable: UITableView!
    
    var allData = [[String]]()
    var headers = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        navigationItem.title = "Browse All"
        let attributes = [
            //NSAttributedStringKey.foregroundColor : UIColor.red,
            NSAttributedStringKey.font : UIFont(name: "PingFangTC-Light", size: 30)!
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
        
        // Allow table cell to get bigger to fit multi-line content
        browseTable.estimatedRowHeight = 44
        browseTable.estimatedRowHeight = UITableViewAutomaticDimension
        browseTable.rowHeight = UITableViewAutomaticDimension
        
        // Get data
        DataManager.getAllBugs(){ (data, headers) -> () in
            self.allData = data
            self.headers = headers
            self.browseTable.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension BrowseViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headers[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = allData[indexPath.section][indexPath.row]
        
        // Get table image by name
        let imageName:String = DataManager.getTableImage(name: allData[indexPath.section][indexPath.row])
        
        // Add image
        let image : UIImage = UIImage(named: imageName)!
        cell.imageView?.image = image
        
        return cell
        
    }
    
}

extension BrowseViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Make sure that tapping cell doesn't make it turn grey
        browseTable.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
        
        // Push to DiseaseViewController
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        
        nextViewController.detailsName = allData[indexPath.section][indexPath.row]
        
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return headers
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        let temp = headers as NSArray
        return temp.index(of: title)
    }
    
}
