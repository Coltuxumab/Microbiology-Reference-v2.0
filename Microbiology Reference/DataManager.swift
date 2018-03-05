//
//  DataManager.swift
//  Microbiology Reference
//
//  Created by Cole Denkensohn on 11/11/17.
//  Copyright © 2017 Denkensohn. See LICENSE.txt
//

import UIKit
import Foundation
import CoreData

struct BugElement {
    var rank: Int
    var name: String
    var match: Set<String> // Unique and unordered
}
struct RecentBugElement {
    var time: String
    var name: String
    var match: Set<String>
}
struct SavedRecents{
    var name: String
    var matchBasis: String
    var date: NSDate
}
struct BugFilter {
    var phrases: [String]
    var category_restricted: [String:String]
    var acronyms: [String:String]
}
struct Related{
    var name: String
    var match: String
}

class DataManager {
    // MARK: - Core Data stack
    
    private init(){}
    
    // BEGIN: Custom functions
    
    static var editsMade:Bool = false
    
    static var updatesInProgress:Bool = false
    
    static var diseases:[[String]] = []
    
    static var debug:Bool = false // true = print messages
    
    static let url_bugs:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQJ6xoXXWy4xpMf8HbGJXu3xrBjZIhTGBNhRGVal7kFiY5ogl5aJBupYX0nstP0vdcbosO3m1cnom9Q/pub?gid=0&single=true&output=csv"
    static let url_links:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQJ6xoXXWy4xpMf8HbGJXu3xrBjZIhTGBNhRGVal7kFiY5ogl5aJBupYX0nstP0vdcbosO3m1cnom9Q/pub?gid=42956557&single=true&output=csv"
    static let url_settings:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQJ6xoXXWy4xpMf8HbGJXu3xrBjZIhTGBNhRGVal7kFiY5ogl5aJBupYX0nstP0vdcbosO3m1cnom9Q/pub?gid=1504880105&single=true&output=csv"
    static let url_definitions:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQJ6xoXXWy4xpMf8HbGJXu3xrBjZIhTGBNhRGVal7kFiY5ogl5aJBupYX0nstP0vdcbosO3m1cnom9Q/pub?gid=2129819201&single=true&output=csv"
    static let url_phrases:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQJ6xoXXWy4xpMf8HbGJXu3xrBjZIhTGBNhRGVal7kFiY5ogl5aJBupYX0nstP0vdcbosO3m1cnom9Q/pub?gid=358444454&single=true&output=csv"
    static let url_categoryRestricted:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQJ6xoXXWy4xpMf8HbGJXu3xrBjZIhTGBNhRGVal7kFiY5ogl5aJBupYX0nstP0vdcbosO3m1cnom9Q/pub?gid=192050004&single=true&output=csv"
    static let url_acronyms:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQJ6xoXXWy4xpMf8HbGJXu3xrBjZIhTGBNhRGVal7kFiY5ogl5aJBupYX0nstP0vdcbosO3m1cnom9Q/pub?gid=957923301&single=true&output=csv"
    
    static let themeMainColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    static let themeBackgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    static let themeBlueColor = UIColor(red: 47/255, green: 129/255, blue: 183/255, alpha: 1)
    static let themeRedColor = UIColor(red: 190/255, green: 58/255, blue: 49/255, alpha: 1)
    static let themeGreyColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1)
    static let themePurpleColor = UIColor(red: 141/255, green: 72/255, blue: 171/255, alpha: 1)
    
    static var firstLaunch:Bool = false
    
    static var storedSearchRank:[[(Int, String)]] = []
    
    static var storedBugElements:[[BugElement]] = []
    
    static var bugFilter = BugFilter(
        phrases:
        DataManager.getAllPhrases(), // Must be 2 words. Only type unique prefix of second word
        category_restricted:
        DataManager.getAllCategoryRestricted(),
        acronyms:
        DataManager.getAllAcronyms() // For now, need to write in both directions (can update code to auto-reverse)
    )
    
    static var storedRecents:[SavedRecents] = []
    
    static func searchAllTables(searchText:String, completion: @escaping ((_ returnResults:[BugElement])->())) {
        
        var bugElements:[BugElement] = []
        var bugElementShell:[BugElement] = []
        
        var categoryRestriction:String = "all" // Search all categories by default
        var numSearchTerms:Int = searchText.components(separatedBy: " ").count
        let searchTerm:String = self.getSearchPhrases(searchTerms: searchText.components(separatedBy: " ")).1.lowercased()
        let acronymSearchTerm = self.convertAcronyms(searchTerm: searchTerm)
        numSearchTerms = self.getSearchPhrases(searchTerms: searchText.components(separatedBy: " ")).0
        
        // Set category restriciton if needed
        if self.bugFilter.category_restricted[searchTerm] != nil{
            categoryRestriction = self.bugFilter.category_restricted[searchTerm]!
        }
        
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        // BEGIN NAME
        if categoryRestriction == "all" || categoryRestriction == "name"{
            fetchRequest.predicate = NSPredicate(format:"name BEGINSWITH[cd] %@ OR name BEGINSWITH[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 10, name: bug.name, match: Set(["Name"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 10
                            bugElementShell[index].match.insert("Name")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END NAME
        // BEGIN DISEASE
        if categoryRestriction == "all" || categoryRestriction == "disease"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_disease.name CONTAINS[cd] %@ OR ANY related_disease.name CONTAINS[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 8, name: bug.name, match: Set(["Disease"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 8
                            bugElementShell[index].match.insert("Disease")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END DISEASE
        // BEGIN GENERAL
        if categoryRestriction == "all" || categoryRestriction == "general"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_general.name CONTAINS[cd] %@ OR ANY related_general.name CONTAINS[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 5, name: bug.name, match: Set(["General"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 5
                            bugElementShell[index].match.insert("General")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END GENERAL
        // BEGIN GRAMSTAIN
        if categoryRestriction == "all" || categoryRestriction == "gramstain"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_gramstain.name BEGINSWITH[cd] %@ OR ANY related_gramstain.name BEGINSWITH[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 5, name: bug.name, match: Set(["Gram Stain"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 5
                            bugElementShell[index].match.insert("Gram Stain")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END GRAMSTAIN
        // BEGIN KEYPOINTS
        if categoryRestriction == "all" || categoryRestriction == "keypoints"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_keypoints.name CONTAINS[cd] %@ OR ANY related_keypoints.name CONTAINS[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 5, name: bug.name, match: Set(["Key Points"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 5
                            bugElementShell[index].match.insert("Key Points")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END KEYPOINTS
        // BEGIN LABORATORY
        if categoryRestriction == "all" || categoryRestriction == "laboratory"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_laboratory.name BEGINSWITH[cd] %@ OR ANY related_laboratory.name BEGINSWITH[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 2, name: bug.name, match: Set(["Laboratory"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 2
                            bugElementShell[index].match.insert("Laboratory")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END LABORATORY
        // BEGIN MORPHOLOGY
        if categoryRestriction == "all" || categoryRestriction == "morphology"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_morphology.name BEGINSWITH[cd] %@ OR ANY related_morphology.name BEGINSWITH[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 5, name: bug.name, match: Set(["Morphology"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 5
                            bugElementShell[index].match.insert("Morphology")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END MORPHOLOGY
        // BEGIN PREVENTION
        if categoryRestriction == "all" || categoryRestriction == "prevention"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_prevention.name CONTAINS[cd] %@ OR ANY related_prevention.name CONTAINS[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 10, name: bug.name, match: Set(["Prevention"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 10
                            bugElementShell[index].match.insert("Prevention")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END PREVENTION
        // BEGIN SIGNS
        if categoryRestriction == "all" || categoryRestriction == "signs"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_signs.name CONTAINS[cd] %@ OR ANY related_signs.name CONTAINS[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 1, name: bug.name, match: Set(["Signs"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 1
                            bugElementShell[index].match.insert("Signs")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END SIGNS
        // BEGIN TREATMENT
        if categoryRestriction == "all" || categoryRestriction == "treatment"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_treatments.name CONTAINS[cd] %@ OR ANY related_treatments.name CONTAINS[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 5, name: bug.name, match: Set(["Treatment"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 5
                            bugElementShell[index].match.insert("Treatment")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END TREATMENT
        // BEGIN TYPE
        if categoryRestriction == "all" || categoryRestriction == "type"{
            fetchRequest.predicate = NSPredicate(format:"ANY related_type.name BEGINSWITH[cd] %@ OR ANY related_type.name BEGINSWITH[cd] %@", searchTerm, acronymSearchTerm)
            do {
                let diseases = try DataManager.context.fetch(fetchRequest)
                for bug in diseases{
                    if !bugElementShell.contains(where: {$0.name == bug.name} ){
                        // Create Element
                        let bugElement = BugElement(rank: 5, name: bug.name, match: Set(["Type"])) // Initialize struct
                        bugElementShell.append(bugElement)
                    } else{
                        if let index = bugElementShell.index(where: { $0.name == bug.name }) {
                            bugElementShell[index].rank += 5
                            bugElementShell[index].match.insert("Type")
                        }
                    }
                }
            } catch { if DataManager.debug{ print("Could not get Bugs!") } }
        }
        // END TYPE

        let storedBugElementsCount = self.storedBugElements.count
        
        // Handle stored search
        if numSearchTerms == 0{
            // No stored search
            //print("None")
            self.storedBugElements.append(bugElementShell)
        } else if numSearchTerms > storedBugElementsCount{
            // New search term
            //print("New")
            self.storedBugElements.append(bugElementShell)
        } else if numSearchTerms < storedBugElementsCount{
            // Deleted search term
            //print("Delete")
            self.storedBugElements.removeLast()
        } else if numSearchTerms == storedBugElementsCount{
            // Still typing search term
            //print("Still...")
            self.storedBugElements.removeLast()
            self.storedBugElements.append(bugElementShell)
        }
        
        // Handle stored search
        if self.storedBugElements.count > 0 {
            let namedElements = self.storedBugElements.joined().map { ($0.name, $0) }
            // Now combine them as you describe. Add the ranks, and merge the items
            let uniqueElements =
                Dictionary<String, BugElement>(namedElements,
                                               uniquingKeysWith: { (lhs, rhs) -> BugElement in
                                                let sum = lhs.rank + rhs.rank
                                                return BugElement(rank: sum,
                                                                  name: lhs.name,
                                                                  match: lhs.match.union(rhs.match))
                })
            
            // The result is the values of the dictionary
            let result = uniqueElements.values
            bugElements = result.sorted { $0.rank > $1.rank }
            
        } else{
            bugElements = bugElementShell.sorted { $0.rank > $1.rank }
        }
        
        
        
        completion(bugElements)
        
    }
    
    static func convertAcronyms(searchTerm:String) -> (String){
        var convertedSearchTerm:String = searchTerm
        
        
        if self.bugFilter.acronyms.contains(where: {$0.key == searchTerm.lowercased()}){
            convertedSearchTerm = self.bugFilter.acronyms[searchTerm.lowercased()]!
        }
        return convertedSearchTerm
    }
    
    static func getSearchPhrases(searchTerms:[String]) -> (Int, String){
        var searchTerm:String
        var numTerms:Int = searchTerms.count
        
        if numTerms > 1{
            let lastTwo = searchTerms.suffix(2)
            if self.bugFilter.phrases.contains(where: {  lastTwo.joined(separator: " ").lowercased().hasPrefix($0) }) {
                //if self.bugFilter.phrases.contains(lastTwo.joined(separator: " ").lowercased()) {
                //print("Match!")
                searchTerm = lastTwo.joined(separator: " ")
                //numTerms = numTerms - 1
            } else if self.bugFilter.phrases.contains(where: { $0.components(separatedBy: " ").first == lastTwo.last?.lowercased() }){
                //print("Sorta...")
                numTerms = numTerms - 1
                searchTerm = searchTerms.dropLast().last!
            } else{
                //print("No match")
                searchTerm = searchTerms.last!
            }
        } else{
            if self.bugFilter.phrases.contains(where: { $0.components(separatedBy: " ").first == searchTerms[0].lowercased() }){
                searchTerm = "none"
            } else{
                searchTerm = searchTerms[0]
            }
        }
        
        return (numTerms, searchTerm)
    }
    
    // Checks bug characteristcs to determine the correct table image to display
    static func getTableImage(name:String) -> String{
        var imageName:String = "TableImage-BacteriaUnknown"
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        // Match disease
        let predicate = NSPredicate(format:"name = %@", name)
        fetchRequest.predicate = predicate
        
        // Limit number of results
        fetchRequest.fetchLimit = 1
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            for bug in bugs{
                
                // Get: Type --> Morphology --> Gram Stain
                let types = bug.related_type?.allObjects as! [Type]
                if !types.isEmpty {
                    if types.contains(where: {$0.name?.lowercased() == "bacteria"} ){
                        
                        // Get Morphology
                        let morphology = bug.related_morphology?.allObjects as! [Morphology]
                        if !morphology.isEmpty {
                            if morphology.contains(where: {($0.name?.lowercased().contains("cocci"))! && ($0.name?.lowercased().contains("clusters"))!} ){
                                
                                // Get GramStain
                                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                                if !gramstain.isEmpty {
                                    if gramstain.contains(where: {($0.name?.lowercased().contains("positive"))!} ){
                                        imageName = "TableImage-BacteriaCocciClustersGP"
                                    } else if gramstain.contains(where: {($0.name?.lowercased().contains("negative"))!} ){
                                        imageName = "TableImage-BacteriaCocciClustersGN"
                                    }
                                }
                                
                            } else if morphology.contains(where: {($0.name?.lowercased().contains("cocci"))! && (($0.name?.lowercased().contains("pairs"))! || ($0.name?.lowercased().contains("diplo"))! || ($0.name?.lowercased().contains("chain"))!)} ){
                                
                                // Get GramStain
                                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                                if !gramstain.isEmpty {
                                    if gramstain.contains(where: {($0.name?.lowercased().contains("positive"))!} ){
                                        imageName = "TableImage-BacteriaCocciPairsGP"
                                    } else if gramstain.contains(where: {($0.name?.lowercased().contains("negative"))!} ){
                                        imageName = "TableImage-BacteriaCocciPairsGN"
                                    }
                                }
                                
                            } else if morphology.contains(where: {($0.name?.lowercased().contains("cocci"))!} ){
                                
                                // Get GramStain
                                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                                if !gramstain.isEmpty {
                                    if gramstain.contains(where: {($0.name?.lowercased().contains("positive"))!} ){
                                        imageName = "TableImage-BacteriaCocciGP"
                                    } else if gramstain.contains(where: {($0.name?.lowercased().contains("negative"))!} ){
                                        imageName = "TableImage-BacteriaCocciGN"
                                    }
                                }
                                
                            } else if morphology.contains(where: {($0.name?.lowercased().contains("rod"))! || ($0.name?.lowercased().contains("bacillus"))! || ($0.name?.lowercased().contains("bacilli"))!} ){
                                
                                // Get GramStain
                                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                                if !gramstain.isEmpty {
                                    if gramstain.contains(where: {($0.name?.lowercased().contains("positive"))!} ){
                                        imageName = "TableImage-BacteriaRodGP"
                                    } else if gramstain.contains(where: {($0.name?.lowercased().contains("negative"))!} ){
                                        imageName = "TableImage-BacteriaRodGN"
                                    }
                                }
                                
                            }
                        }
                        
                    } else if types.contains(where: {$0.name?.lowercased() == "fungi" || $0.name?.lowercased() == "fungus"} ){
                        imageName = "TableImage-Fungi"
                    } else if types.contains(where: {$0.name?.lowercased() == "parasite"} ){
                        imageName = "TableImage-Parasite"
                    } else if types.contains(where: {$0.name?.lowercased() == "virus"} ){
                        imageName = "TableImage-Virus"
                    }
                }
                
            }
        } catch {
            if DataManager.debug{ print("Could not get data for bug: \(name)") }
        }
        
        return imageName
    }
    
    /*static func getData() { //NOTE MAYBE DELETE THIS FUNCTION
     var diseaseDataShell:[String] = []
     
     let fetchRequest: NSFetchRequest<Diseases> = Diseases.fetchRequest()
     
     do {
     let diseases = try DataManager.context.fetch(fetchRequest)
     for disease in diseases{
     diseaseDataShell.append(disease.name)
     }
     } catch {
     if DataManager.debug{ print("Could not get Diagnoses!") }
     }
     
     DataManager.diseases.append(diseaseDataShell)
     diseaseDataShell.removeAll()
     
     DataManager.updatesInProgress = false
     AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil)
     
     }*/
    
    /*static func countItems() {
     var num_items:Int = 0
     
     let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
     
     do {
     let bugs = try DataManager.context.fetch(fetchRequest)
     for bug in bugs{
     num_items = num_items + 1
     }
     } catch {
     if DataManager.debug{ print("Could not get count!") }
     }
     
     print("Number of bugs: \(num_items)")
     
     }*/
    
    // Determine accessories
    static func getAccessories(name:String, table:String, fact:String) -> (relatedAccessory:[Related], webViewAccessory:String) {
        
        // Format fact
        var fullItem = fact
        var mainItem = fact
        if fact.contains(" →"){
            fullItem = fact.replacingOccurrences(of: "→", with: "->")
            mainItem = fact.components(separatedBy: " →").first!
        } else if fact.contains(" ->"){
            mainItem = fullItem.components(separatedBy: " ->").first!
        } else if fact.contains(": "){
            mainItem = fullItem.components(separatedBy: ": ").last!
        }
        
        var relatedAccessoryContainer = [Related]()
        var webViewAccessory:String = ""
        
        // WEB VIEW ACCESSORIES
        
        // Check Disease
        let fetchRequest: NSFetchRequest<Links> = Links.fetchRequest()
        //fetchRequest.fetchLimit = 1
        do {
            let results = try DataManager.context.fetch(fetchRequest)
            for result in results{
                // FUTURE: May need to implement case of multiple links (turn webViewAcessory into array)
                let diseases = result.related_disease?.allObjects as! [Disease]
                if !diseases.isEmpty{
                    for related in diseases{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let generals = result.related_general?.allObjects as! [General]
                if !generals.isEmpty{
                    for related in generals{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let gramstains = result.related_gramstain?.allObjects as! [GramStain]
                if !gramstains.isEmpty{
                    for related in gramstains{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let keypoints = result.related_keypoints?.allObjects as! [KeyPoints]
                if !keypoints.isEmpty{
                    for related in keypoints{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let labs = result.related_laboratory?.allObjects as! [Laboratory]
                if !labs.isEmpty{
                    for related in labs{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let morphologies = result.related_morphology?.allObjects as! [Morphology]
                if !morphologies.isEmpty{
                    for related in morphologies{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let preventions = result.related_prevention?.allObjects as! [Prevention]
                if !preventions.isEmpty{
                    for related in preventions{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let signs = result.related_signs?.allObjects as! [Signs]
                if !signs.isEmpty{
                    for related in signs{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let sources = result.related_sources?.allObjects as! [Sources]
                if !sources.isEmpty{
                    for related in sources{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let treatments = result.related_treatment?.allObjects as! [Treatment]
                if !treatments.isEmpty{
                    for related in treatments{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
                let types = result.related_type?.allObjects as! [Type]
                if !types.isEmpty{
                    for related in types{
                        if related.name?.components(separatedBy: " ->").first == mainItem{ webViewAccessory = result.link! }
                    }
                }
            }
        } catch { if DataManager.debug{ print("Could not get links for bug: \(name)") } }

        
        // RELATED ACCESSORIES
        if table == "Disease"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_disease.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Disease")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "General"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_general.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "General")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Gram Stain"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_gramstain.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Gram Stain")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Key Points"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_keypoints.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Key Points")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Laboratory"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_laboratory.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Laboratory")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Morphology"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_morphology.name BEGINSWITH[cd] %@ OR related_morphology.name contains %@", mainItem, self.convertAcronyms(searchTerm: mainItem))
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Morphology")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Prevention"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_prevention.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Prevention")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Signs"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_signs.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Signs")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Treatment"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_treatments.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Treatment")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Type"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"ANY related_type.name BEGINSWITH[cd] %@", mainItem)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Type")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        }
        if !webViewAccessory.isEmpty{
            //print("TEST 1: (\(webViewAccessory))")
        }
        return (relatedAccessoryContainer, webViewAccessory)
    }
    
    // Return all
    static func getAllBugs(completion: @escaping ((_ data:[[String]], _ headers:[String])->())) {
        
        var flatBugs:[String] = []
        var allBugs:[[String]] = []
        var headers:[String] = []
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            for bug in bugs{
                
                flatBugs.append(bug.name)
                
                let first = String(bug.name.prefix(1))
                
                if !headers.contains(first){
                    headers.append(first)
                }
                
            }
            
            flatBugs = flatBugs.sorted { $0 < $1 } // A --> Z
            headers = headers.sorted { $0 < $1 } // A --> Z
            
            var prevInitial: Character? = nil
            for bug in flatBugs {
                let initial = bug.first
                if initial != prevInitial {  // We're starting a new letter
                    allBugs.append([])
                    prevInitial = initial
                }
                allBugs[allBugs.endIndex - 1].append(bug)
            }
            
        } catch {
            if DataManager.debug{ print("Could not get all data.") }
        }
        
        completion(allBugs, headers)
        
    }
    
    // Return all definitions
    static func getAllDefinitions(completion: @escaping ((_ definitions:[String:String])->())) {
        var definitions:[String:String] = [:]
        let fetchRequest: NSFetchRequest<Data_Definitions> = Data_Definitions.fetchRequest()
        do {
            let request = try DataManager.context.fetch(fetchRequest)
            for data_definitions in request{
                definitions[data_definitions.item!] = data_definitions.definition
            }
        } catch { if DataManager.debug{ print("Could not get all definitions.") } }
        completion(definitions)
    }
    // Return all phrases
    static func getAllPhrases() -> [String] {
        var phrases:[String] = []
        let fetchRequest: NSFetchRequest<Data_Phrases> = Data_Phrases.fetchRequest()
        do {
            let request = try DataManager.context.fetch(fetchRequest)
            for data_phrases in request{
                phrases.append(data_phrases.phrase!)
            }
        } catch { if DataManager.debug{ print("Could not get all phrases.") } }
        return phrases
    }
    // Return all Category Restricted
    static func getAllCategoryRestricted() -> [String:String] {
        var categoryRestricted:[String:String] = [:]
        let fetchRequest: NSFetchRequest<Data_CateogryRestricted> = Data_CateogryRestricted.fetchRequest()
        do {
            let request = try DataManager.context.fetch(fetchRequest)
            for data_categoryRestricted in request{
                categoryRestricted[data_categoryRestricted.term!] = data_categoryRestricted.category
            }
        } catch { if DataManager.debug{ print("Could not get all Category Restricted.") } }
        return categoryRestricted
    }
    // Return all Acronyms
    static func getAllAcronyms() -> [String:String] {
        var acronyms:[String:String] = [:]
        let fetchRequest: NSFetchRequest<Data_Acronyms> = Data_Acronyms.fetchRequest()
        do {
            let request = try DataManager.context.fetch(fetchRequest)
            for data_acronyms in request{
                acronyms[data_acronyms.acronym!] = data_acronyms.word
                acronyms[data_acronyms.word!] = data_acronyms.acronym
            }
        } catch { if DataManager.debug{ print("Could not get all Acronyms.") } }
        return acronyms
    }
    
    static func getSingleBug(bugName:String, completion: @escaping ((_ headers:[String], _ data:[[String]])->())) {
        
        var headersShell:[String] = []
        var bugDataShell:[[String]] = []
        var entityShell:[String] = []
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        // Match disease
        let predicate = NSPredicate(format:"name = %@", bugName)
        fetchRequest.predicate = predicate
        
        // Limit number of results
        fetchRequest.fetchLimit = 1
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            for bug in bugs{
                
                // Get Type
                let types = bug.related_type?.allObjects as! [Type]
                if !types.isEmpty {
                    headersShell.append("Type")
                    innerLoop: for type in types{
                        entityShell.append(type.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get KeyPoints
                let keypoints = bug.related_keypoints?.allObjects as! [KeyPoints]
                if !keypoints.isEmpty {
                    headersShell.append("Key Points")
                    innerLoop: for kp in keypoints{
                        entityShell.append(kp.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get General
                let general = bug.related_general?.allObjects as! [General]
                if !general.isEmpty {
                    headersShell.append("General")
                    innerLoop: for gen in general{
                        entityShell.append(gen.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get GramStain
                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                if !gramstain.isEmpty {
                    headersShell.append("Gram Stain")
                    innerLoop: for gs in gramstain{
                        entityShell.append(gs.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Morphology
                let morphology = bug.related_morphology?.allObjects as! [Morphology]
                if !morphology.isEmpty {
                    headersShell.append("Morphology")
                    innerLoop: for morph in morphology{
                        entityShell.append(morph.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Laboratory
                let laboratory = bug.related_laboratory?.allObjects as! [Laboratory]
                if !laboratory.isEmpty {
                    headersShell.append("Laboratory")
                    innerLoop: for lab in laboratory{
                        entityShell.append(lab.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Treatment
                let treatment = bug.related_treatments?.allObjects as! [Treatment]
                if !treatment.isEmpty {
                    headersShell.append("Treatment")
                    innerLoop: for tx in treatment{
                        entityShell.append(tx.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Prevention
                let prevention = bug.related_prevention?.allObjects as! [Prevention]
                if !prevention.isEmpty {
                    headersShell.append("Prevention")
                    innerLoop: for prevent in prevention{
                        entityShell.append(prevent.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Disease
                let disease = bug.related_disease?.allObjects as! [Disease]
                if !disease.isEmpty {
                    headersShell.append("Disease")
                    innerLoop: for dz in disease{
                        entityShell.append(dz.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Signs
                let signs = bug.related_signs?.allObjects as! [Signs]
                if !signs.isEmpty {
                    headersShell.append("Signs")
                    innerLoop: for sign in signs{
                        entityShell.append(sign.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Related
                let related = bug.related_entity?.allObjects as! [RelatedEntity]
                if !related.isEmpty {
                    headersShell.append("Related")
                    innerLoop: for relate in related{
                        entityShell.append(relate.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Sources
                let sources = bug.related_source?.allObjects as! [Sources]
                if !sources.isEmpty {
                    headersShell.append("Sources")
                    innerLoop: for source in sources{
                        entityShell.append(source.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
            }
        } catch {
            if DataManager.debug{ print("Could not get data for bug: \(bugName)") }
        }
        
        completion(headersShell,bugDataShell)
        
    }
    
    static func getRecent(numberToGet:Int = 5, completion: @escaping ((_ returnResults:[RecentBugElement])->())){
        
        var bugElements:[RecentBugElement] = []
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        // Find all matching diagnostics with given name (expect just one)
        let predicate = NSPredicate(format:"last_accessed != %@", 0)
        fetchRequest.predicate = predicate
        
        // Sort
        let timeSortDescriptor = NSSortDescriptor(key: "last_accessed", ascending: false)
        fetchRequest.sortDescriptors = [timeSortDescriptor]
        
        // Limit number of results
        fetchRequest.fetchLimit = numberToGet
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            if bugs.count == 0{
                
            } else{
                for bug in bugs{
                    
                    // Format date basis
                    guard let lastAccessed = bug.last_accessed as Date? else {
                        // date is nil, ignore this entry:
                        continue
                    }
                    
                    let previousDate = lastAccessed
                    let now = Date()
                    
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .abbreviated
                    formatter.allowedUnits = [.month, .day, .hour]
                    formatter.maximumUnitCount = 1   // Show just one unit (i.e. 1d vs. 1d 6hrs)
                    
                    let stringDate = formatter.string(from: previousDate, to: now)
                    guard var date = stringDate as String? else {
                        // date is nil, ignore this entry:
                        continue
                    }
                    
                    
                    if date == "0h" {
                        // Search was recently made
                        date = "Now"
                    }
                    var matchBasisSet = Set<String>()
                    for matchTerm in bug.match_basis!.components(separatedBy: ", ") {
                        matchBasisSet.insert(matchTerm)
                    }
                    
                    bugElements.append(RecentBugElement(time: date, name: bug.name, match: matchBasisSet))
                    
                }
            }
            
        } catch {
            if DataManager.debug{ print("Could not get get \(numberToGet) recents.") }
        }
        
        //bugElements = bugElements.sorted { $0.time > $1.time}
        
        completion(bugElements)
    }
    
    static func addData(table:String, data:[[String:String]], completion: @escaping ()->()) {
        if table == "bugs"{
            if DataManager.debug{ print("Adding Bugs data to CoreData") }
            
            for bug in data{
                var bugName:String = "DefaultBug"
                var bugDisease:String = "DefaultDisease"
                var bugGeneral:String = "DefaultGeneral"
                var bugGramStain:String = "DefaultGramStain"
                var bugKeyPoints:String = "DefaultKeyPoints"
                var bugLaboratory:String = "DefaultLaboratory"
                var bugMorphology:String = "DefaultMorphology"
                var bugPrevention:String = "DefaultPrevention"
                var bugSigns:String = "DefaultSigns"
                var bugSources:String = "DefaultSources"
                var bugTreatment:String = "DefaultTreatment"
                var bugType:String = "DefaultType"
                var bugRelated:String = "DefaultRelated"
                for (attributes,value) in bug{
                    if attributes == "Name"{
                        bugName = value
                    } else if attributes == "Disease"{
                        bugDisease = value
                    } else if attributes == "General"{
                        bugGeneral = value
                    } else if attributes == "Gram Stain"{
                        bugGramStain = value
                    } else if attributes == "Key Points"{
                        bugKeyPoints = value
                    } else if attributes == "Laboratory"{
                        bugLaboratory = value
                    } else if attributes == "Morphology"{
                        bugMorphology = value
                    } else if attributes == "Prevention"{
                        bugPrevention = value
                    } else if attributes == "Signs"{
                        bugSigns = value
                    } else if attributes == "Sources"{
                        bugSources = value
                    } else if attributes == "Treatment"{
                        bugTreatment = value
                    } else if attributes == "Type"{
                        bugType = value
                    } else if attributes == "Related"{
                        bugRelated = value
                    } else{
                        if DataManager.debug{ print("Found unexpected table header.") }
                    }
                    
                }
                
                let bugs = Bugs(context: DataManager.context)
                bugs.name = bugName
                if bugDisease != "DefaultDisease"{
                    let valueArray:[String] = bugDisease.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let disease = Disease(context: DataManager.context)
                        disease.name = singleValue
                        let related_bug = disease.mutableSetValue(forKey: "related_bug")
                        related_bug.add(bugs)
                    }
                }
                if bugGeneral != "DefaultGeneral"{
                    let valueArray:[String] = bugGeneral.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let general = General(context: DataManager.context)
                        general.name = singleValue
                        let related_bug = general.mutableSetValue(forKey: "related_bug")
                        related_bug.add(bugs)
                    }
                }
                if bugGramStain != "DefaultGramStain"{
                    let valueArray:[String] = bugGramStain.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let gramstain = GramStain(context: DataManager.context)
                        gramstain.name = singleValue
                        let related_gramstain = gramstain.mutableSetValue(forKey: "related_bug")
                        related_gramstain.add(bugs)
                    }
                }
                if bugKeyPoints != "DefaultKeyPoints"{
                    let valueArray:[String] = bugKeyPoints.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let keypoints = KeyPoints(context: DataManager.context)
                        keypoints.name = singleValue
                        let related_keypoints = keypoints.mutableSetValue(forKey: "related_bug")
                        related_keypoints.add(bugs)
                    }
                }
                if bugLaboratory != "DefaultLaboratory"{
                    let valueArray:[String] = bugLaboratory.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let laboratory = Laboratory(context: DataManager.context)
                        laboratory.name = singleValue
                        let related_laboratory = laboratory.mutableSetValue(forKey: "related_bug")
                        related_laboratory.add(bugs)
                    }
                }
                if bugMorphology != "DefaultMorphology"{
                    let valueArray:[String] = bugMorphology.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let morphology = Morphology(context: DataManager.context)
                        morphology.name = singleValue
                        let related_morphology = morphology.mutableSetValue(forKey: "related_bug")
                        related_morphology.add(bugs)
                    }
                }
                if bugPrevention != "DefaultPrevention"{
                    let valueArray:[String] = bugPrevention.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let prevention = Prevention(context: DataManager.context)
                        prevention.name = singleValue
                        let related_prevention = prevention.mutableSetValue(forKey: "related_bug")
                        related_prevention.add(bugs)
                    }
                }
                if bugSigns != "DefaultSigns"{
                    let valueArray:[String] = bugSigns.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let signs = Signs(context: DataManager.context)
                        signs.name = singleValue
                        let related_signs = signs.mutableSetValue(forKey: "related_bug")
                        related_signs.add(bugs)
                    }
                }
                if bugSources != "DefaultSources"{
                    let valueArray:[String] = bugSources.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let sources = Sources(context: DataManager.context)
                        sources.name = singleValue
                        let related_sources = sources.mutableSetValue(forKey: "related_bug")
                        related_sources.add(bugs)
                    }
                }
                if bugTreatment != "DefaultTreatment"{
                    let valueArray:[String] = bugTreatment.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let treatment = Treatment(context: DataManager.context)
                        treatment.name = singleValue
                        let related_treatment = treatment.mutableSetValue(forKey: "related_bug")
                        related_treatment.add(bugs)
                    }
                }
                if bugType != "DefaultType"{
                    let valueArray:[String] = bugType.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let type = Type(context: DataManager.context)
                        type.name = singleValue
                        let related_type = type.mutableSetValue(forKey: "related_bug")
                        related_type.add(bugs)
                    }
                }
                if bugRelated != "DefaultRelated"{
                    let valueArray:[String] = bugRelated.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let related = RelatedEntity(context: DataManager.context)
                        related.name = singleValue
                        let related_entity = related.mutableSetValue(forKey: "related_bug")
                        related_entity.add(bugs)
                    }
                }
                
            }
            
            completion()
            //DataManager.saveContext()
            
        } else if table == "links"{
            if DataManager.debug{ print("Adding Links data to CoreData") }
            
            for link in data{
                var itemName:String = "DefaultItem"
                var itemLink:String = "DefaultLink"
                for (attributes,value) in link{
                    if attributes == "Item"{
                        itemName = value
                    } else if attributes == "Link"{
                        itemLink = value
                    }
                }
                
                // Add link
                let links = Links(context: DataManager.context)
                links.link = itemLink
                
                // RELATE LINKS: Type
                let fetchRequest1: NSFetchRequest<Type> = Type.fetchRequest()
                let predicate = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest1.predicate = predicate
                do {
                    let results = try DataManager.context.fetch(fetchRequest1)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Key Points
                let fetchRequest2: NSFetchRequest<KeyPoints> = KeyPoints.fetchRequest()
                let predicate2 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest2.predicate = predicate2
                do {
                    let results = try DataManager.context.fetch(fetchRequest2)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: General
                let fetchRequest3: NSFetchRequest<General> = General.fetchRequest()
                let predicate3 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest3.predicate = predicate3
                do {
                    let results = try DataManager.context.fetch(fetchRequest3)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Gram Stain
                let fetchRequest4: NSFetchRequest<GramStain> = GramStain.fetchRequest()
                let predicate4 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest4.predicate = predicate4
                do {
                    let results = try DataManager.context.fetch(fetchRequest4)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Morphology
                let fetchRequest5: NSFetchRequest<Morphology> = Morphology.fetchRequest()
                let predicate5 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest5.predicate = predicate5
                do {
                    let results = try DataManager.context.fetch(fetchRequest5)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Laboratory
                let fetchRequest6: NSFetchRequest<Laboratory> = Laboratory.fetchRequest()
                let predicate6 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest6.predicate = predicate6
                do {
                    let results = try DataManager.context.fetch(fetchRequest6)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Treatment
                let fetchRequest7: NSFetchRequest<Treatment> = Treatment.fetchRequest()
                let predicate7 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest7.predicate = predicate7
                do {
                    let results = try DataManager.context.fetch(fetchRequest7)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Prevention
                let fetchRequest8: NSFetchRequest<Prevention> = Prevention.fetchRequest()
                let predicate8 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest8.predicate = predicate8
                do {
                    let results = try DataManager.context.fetch(fetchRequest8)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Disease
                let fetchRequest9: NSFetchRequest<Disease> = Disease.fetchRequest()
                let predicate9 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest9.predicate = predicate9
                do {
                    let results = try DataManager.context.fetch(fetchRequest9)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Signs
                let fetchRequest10: NSFetchRequest<Signs> = Signs.fetchRequest()
                let predicate10 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest10.predicate = predicate10
                do {
                    let results = try DataManager.context.fetch(fetchRequest10)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                // RELATE LINKS: Sources
                let fetchRequest11: NSFetchRequest<Sources> = Sources.fetchRequest()
                let predicate11 = NSPredicate(format:"name beginswith[cd] %@", itemName)
                fetchRequest11.predicate = predicate11
                do {
                    let results = try DataManager.context.fetch(fetchRequest11)
                    for result in results{
                        result.related_link = links
                    }
                } catch { if DataManager.debug{ print("Could not relate link.") } }
                
                
            }
            //DataManager.saveContext()
            completion()
            
            
        } else if table == "definitions"{
            
            var items:[String] = []
            var definitions:[String] = []
            for data_definitions in data{
                for (header,item) in data_definitions{
                    if header == "Item"{
                        items.append(item)
                    }
                    if header == "Definition"{
                        definitions.append(item)
                    }
                }
            }
            var i = 0
            for item in items{
                let data_definitions = Data_Definitions(context: DataManager.context)
                data_definitions.item = item
                data_definitions.definition = definitions[i]
                i += 1
            }
            completion()
            
        } else if table == "phrases"{
            
            for phrases in data{
                for (header,phrase) in phrases{
                    if header == "Phrase"{
                        let data_phrases = Data_Phrases(context: DataManager.context)
                        data_phrases.phrase = phrase
                    }
                }
            }
            completion()
            
        } else if table == "category_restricted"{
            var terms:[String] = []
            var categories:[String] = []
            for categoryRestricted in data{
                for (header,item) in categoryRestricted{
                    if header == "Term"{
                        terms.append(item)
                    }
                    if header == "Category"{
                        categories.append(item)
                    }
                }
            }
            var i = 0
            for term in terms{
                let data_categoryRestricted = Data_CateogryRestricted(context: DataManager.context)
                data_categoryRestricted.term = term
                data_categoryRestricted.category = categories[i]
                i += 1
            }
            completion()
            
        } else if table == "acronyms"{
            
            var acronyms:[String] = []
            var words:[String] = []
            for data_acronyms in data{
                for (header,item) in data_acronyms{
                    if header == "Acronym"{
                        acronyms.append(item)
                    }
                    if header == "Word"{
                        words.append(item)
                    }
                }
            }
            var i = 0
            for acronym in acronyms{
                let data_acronyms = Data_Acronyms(context: DataManager.context)
                data_acronyms.acronym = acronym
                data_acronyms.word = words[i]
                i += 1
            }
            completion()
            
        }
        
        
    }
    
    static func downloadBugs(completion: @escaping ()->()){
        DataManager.updatesInProgress = true
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_bugs, table: "bugs"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "bugs"){ (result) -> () in
                    DataManager.addData(table: "bugs", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    static func downloadLinks(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_links, table: "links"){ (success) -> () in

            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "links"){ (result) -> () in
                    DataManager.addData(table: "links", data: result){ () -> () in
                        completion()
                    }
                }

            } else{
                // HANDLE FAILED DOWNLOAD
            }

        }
    }
    
    static func downloadDefinitions(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_definitions, table: "definitions"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "definitions"){ (result) -> () in
                    DataManager.addData(table: "definitions", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func downloadPhrases(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_phrases, table: "phrases"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "phrases"){ (result) -> () in
                    DataManager.addData(table: "phrases", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func downloadCategoryRestricted(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_categoryRestricted, table: "category_restricted"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "category_restricted"){ (result) -> () in
                    DataManager.addData(table: "category_restricted", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func downloadAcronyms(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_acronyms, table: "acronyms"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "acronyms"){ (result) -> () in
                    DataManager.addData(table: "acronyms", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func saveRecentsDuringUpdate(function:String){
        
        if function == "save"{
            
            let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Limit to entities that have a last_accessed date
            let predicate = NSPredicate(format:"last_accessed != %@", 0)
            fetchRequest.predicate = predicate
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest)
                for bug in bugs{
                    self.storedRecents.append(SavedRecents(name: bug.name, matchBasis: bug.match_basis!, date: bug.last_accessed!))
                }
                
            } catch {
                if DataManager.debug{ print("Could not save recents.") }
            }
            
        } else if function == "restore"{
            
            let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest)
                for bug in bugs{
                    if self.storedRecents.contains(where: { $0.name == bug.name }){
                        let storedRecentsFiltered = storedRecents.filter{$0.name == bug.name}
                        bug.match_basis = storedRecentsFiltered.first?.matchBasis
                        bug.last_accessed = storedRecentsFiltered.first?.date
                    }
                }
                DataManager.saveContext()
            } catch {
                if DataManager.debug{ print("Could not restore recents.") }
            }
            
        }
        
    }
    
    static func orchestrateUpdates(table:String, dataSource:String = "external", completion: @escaping ()->()){
        DataManager.updatesInProgress = true
        switch (table, dataSource){
        case ("all", "external"):
            
            // Save Recents
            saveRecentsDuringUpdate(function: "save")
            
            // Delete current data
            DataManager.deleteAllObjects(table: "bugs")
            DataManager.deleteAllObjects(table: "links")
            DataManager.deleteAllObjects(table: "disease")
            DataManager.deleteAllObjects(table: "general")
            DataManager.deleteAllObjects(table: "gramstain")
            DataManager.deleteAllObjects(table: "keypoints")
            DataManager.deleteAllObjects(table: "laboratory")
            DataManager.deleteAllObjects(table: "morphology")
            DataManager.deleteAllObjects(table: "prevention")
            DataManager.deleteAllObjects(table: "signs")
            DataManager.deleteAllObjects(table: "sources")
            DataManager.deleteAllObjects(table: "treatment")
            DataManager.deleteAllObjects(table: "type")
            DataManager.deleteAllObjects(table: "definitions")
            DataManager.deleteAllObjects(table: "phrases")
            DataManager.deleteAllObjects(table: "category_restricted")
            DataManager.deleteAllObjects(table: "acronyms")
            
            downloadBugs(){ () -> () in
                orchestrateUpdates(table: "links", dataSource: "external"){ () -> () in
                    // Complete
                    DataManager.saveContext()
                    completion()
                }
            }
        case ("links", "external"):
            downloadLinks(){ () -> () in
                orchestrateUpdates(table: "definitions", dataSource: "external"){ () -> () in
                    // Complete
                    DataManager.saveContext()
                    completion()
                }
            }
//        case ("disease", "external"):
//            downloadDisease(){ () -> () in
//                orchestrateUpdates(table: "laboratory", dataSource: "external"){ () -> () in
//                    // Complete
//                    DataManager.saveContext()
//                    completion()
//                }
//            }
//        case ("laboratory", "external"):
//            downloadLaboratory(){ () -> () in
//                orchestrateUpdates(table: "signs", dataSource: "external"){ () -> () in
//                    // Complete
//                    DataManager.saveContext()
//                    completion()
//                }
//            }
//        case ("signs", "external"):
//            downloadSigns(){ () -> () in
//                orchestrateUpdates(table: "sources", dataSource: "external"){ () -> () in
//                    // Complete
//                    DataManager.saveContext()
//                    completion()
//                }
//            }
//        case ("sources", "external"):
//            downloadSources(){ () -> () in
//                orchestrateUpdates(table: "treatment", dataSource: "external"){ () -> () in
//                    // Complete
//                    DataManager.saveContext()
//                    completion()
//                }
//            }
//        case ("treatment", "external"):
//            downloadTreatment(){ () -> () in
//                orchestrateUpdates(table: "definitions", dataSource: "external"){ () -> () in
//                    // Complete
//                    DataManager.saveContext()
//                    completion()
//                }
//            }
        case ("definitions", "external"):
            downloadDefinitions(){ () -> () in
                orchestrateUpdates(table: "phrases", dataSource: "external"){ () -> () in
                    // Complete
                    DataManager.saveContext()
                    completion()
                }
            }
        case ("phrases", "external"):
            downloadPhrases(){ () -> () in
                orchestrateUpdates(table: "category_restricted", dataSource: "external"){ () -> () in
                    // Complete
                    DataManager.saveContext()
                    completion()
                }
            }
        case ("category_restricted", "external"):
            downloadCategoryRestricted(){ () -> () in
                orchestrateUpdates(table: "acronyms", dataSource: "external"){ () -> () in
                    // Complete
                    DataManager.saveContext()
                    completion()
                }
            }
        case ("acronyms", "external"):
            downloadAcronyms(){ () -> () in
                if DataManager.debug{ print("Completed external orchestration") }
                
                // Restore Recents
                saveRecentsDuringUpdate(function: "restore")
                
                AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil) // Dismiss popup notification of data update
                DataManager.updatesInProgress = false
                DataManager.saveContext()
                completion()
            }
        case ("all", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "bugs"){ (result) -> () in
                DataManager.addData(table: "bugs", data: result){ () -> () in
                    orchestrateUpdates(table: "links", dataSource: "internal"){ () -> () in
                        // Complete
                        DataManager.saveContext()
                        completion()
                    }
                }
            }
        case ("links", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "links"){ (result) -> () in
                DataManager.addData(table: "links", data: result){ () -> () in
                    orchestrateUpdates(table: "definitions", dataSource: "internal"){ () -> () in
                        // Complete
                        DataManager.saveContext()
                        completion()
                    }
                }
            }
        case ("definitions", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "definitions"){ (result) -> () in
                DataManager.addData(table: "definitions", data: result){ () -> () in
                    orchestrateUpdates(table: "phrases", dataSource: "internal"){ () -> () in
                        // Complete
                        DataManager.saveContext()
                        completion()
                    }
                }
            }
        case ("phrases", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "phrases"){ (result) -> () in
                DataManager.addData(table: "phrases", data: result){ () -> () in
                    orchestrateUpdates(table: "category_restricted", dataSource: "internal"){ () -> () in
                        // Complete
                        DataManager.saveContext()
                        completion()
                    }
                }
            }
        case ("category_restricted", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "category_restricted"){ (result) -> () in
                DataManager.addData(table: "category_restricted", data: result){ () -> () in
                    orchestrateUpdates(table: "acronyms", dataSource: "internal"){ () -> () in
                        // Complete
                        DataManager.saveContext()
                        completion()
                    }
                }
            }
        case ("acronyms", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "acronyms"){ (result) -> () in
                DataManager.addData(table: "acronyms", data: result){ () -> () in
                    if DataManager.debug{ print("Completed internal orchestration") }
                    AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil) // Dismiss popup notification of data initiation
                    DataManager.updatesInProgress = false
                    DataManager.saveContext()
                    DataManager.firstLaunch = true
                    
                    completion()
                }
            }
        case (_, _):
            if DataManager.debug{ print("Missing case in orchestrateUpdates function.") }
            completion()
        }
        
    }
    
    static func deleteAllObjects(table:String){
        switch table{
        case "bugs":
            let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "links":
            let fetchRequest: NSFetchRequest<Links> = Links.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "disease":
            let fetchRequest: NSFetchRequest<Disease> = Disease.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "general":
            let fetchRequest: NSFetchRequest<General> = General.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "gramstain":
            let fetchRequest: NSFetchRequest<GramStain> = GramStain.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "keypoints":
            let fetchRequest: NSFetchRequest<KeyPoints> = KeyPoints.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "laboratory":
            let fetchRequest: NSFetchRequest<Laboratory> = Laboratory.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "morphology":
            let fetchRequest: NSFetchRequest<Morphology> = Morphology.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "prevention":
            let fetchRequest: NSFetchRequest<Prevention> = Prevention.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "signs":
            let fetchRequest: NSFetchRequest<Signs> = Signs.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "sources":
            let fetchRequest: NSFetchRequest<Sources> = Sources.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "treatment":
            let fetchRequest: NSFetchRequest<Treatment> = Treatment.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "type":
            let fetchRequest: NSFetchRequest<Type> = Type.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "definitions":
            let fetchRequest: NSFetchRequest<Data_Definitions> = Data_Definitions.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "phrases":
            let fetchRequest: NSFetchRequest<Data_Phrases> = Data_Phrases.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "category_restricted":
            let fetchRequest: NSFetchRequest<Data_CateogryRestricted> = Data_CateogryRestricted.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "acronyms":
            let fetchRequest: NSFetchRequest<Data_Acronyms> = Data_Acronyms.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case _:
            if DataManager.debug{ print("Invalid table (\(table)) to delete.") }
        }
        
    }
    
    static func setDataVersion(dataVersion:Int16){
        let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
        
        do {
            let settings = try DataManager.context.fetch(fetchRequest)
            
            if settings.isEmpty{
                if DataManager.debug{ print("Settings empty") }
                let newSettings = Settings(context: DataManager.context)
                newSettings.dataversion = dataVersion
            } else {
                if DataManager.debug{ print("Setting new dataVersion to \(dataVersion)") }
                let newSettings = try DataManager.context.fetch(fetchRequest)
                for setting in newSettings{
                    setting.dataversion = dataVersion
                }
            }
            DataManager.saveContext()
            
        } catch {
            if DataManager.debug{ print("Could not get Settings.") }
        }
    }
    
    
    static func checkDataVersion(fromWeb:Bool = false, fakeCheck:Bool = false, completion: @escaping ((_ version:Int16)->())){
        var dataVersion:Int16 = 0
        
        if fromWeb {
            CSVImporterManager.sharedInstance.downloadNewData(webURL: url_settings, table: "settings"){ (success) -> () in
                
                if success {
                    CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "settings"){ (result) -> () in
                        if DataManager.debug{ print(Int16(result[0]["Dataversion"]!)!) }
                        if let dataVersion = Int16(result[0]["Version"]!){
                            print("Web Version: \(Int16(dataVersion))")
                            completion(Int16(dataVersion))
                        } else{
                            print("Problem with data version.")
                        }
                        
                    }
                    
                } else{
                    // HANDLE FAILED DOWNLOAD
                }
                
            }
        } else{
            // Get local version
            let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
            
            do {
                
                let newSettings = try DataManager.context.fetch(fetchRequest)
                for setting in newSettings{
                    dataVersion = setting.dataversion
                    
                    if !fakeCheck{ // Don't let the auto local-version check (runs when app hasn't launched recently) count as a real check
                        setting.lastUpdateCheck = NSDate()
                    }
                }
                DataManager.saveContext()
            } catch {
                if DataManager.debug{ print("Could not get local version.") }
            }
            completion(dataVersion)
        }
        
    }
    
    static func lastDataCheck(completion: @escaping ((_ lastCheck:NSDate)->())){
        var lastCheck:NSDate = NSDate()
        
        let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
        
        do {
            
            let settings = try DataManager.context.fetch(fetchRequest)
            for setting in settings{
                if setting.lastUpdateCheck != nil{
                    lastCheck = setting.lastUpdateCheck!
                } else{
                    print("NO DATE")
                }
            }
        } catch {
            if DataManager.debug{ print("Could not get local version.") }
        }
        completion(lastCheck)
    }
    
    static func setLastAccessed(bugName:String, matchBasis:String){
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        // Find all matching diagnostics with given name (expect just one)
        let predicate = NSPredicate(format:"name = %@", bugName)
        fetchRequest.predicate = predicate
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            for bug in bugs{
                bug.last_accessed = NSDate()
                bug.match_basis = matchBasis
            }
            DataManager.saveContext()
        } catch {
            if DataManager.debug{ print("Could not get set last accessed for \(bugName)") }
        }
    }
    
    // Begin: Core functions
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    //    static var privateContext: NSManagedObjectContext {
    //        self.privateContext.parent = context
    //        return NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    //    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Microbiology_Reference")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

