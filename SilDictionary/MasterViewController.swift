//
//  MasterViewController.swift
//  SilDictionary
//
//  Created by Bartek Jezierski on 11/13/18.
//  Copyright © 2018 Bartek Jezierski. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var dictionary: SLPLDictionary!
    
    var sectionedFilteredEntries = [Character: [SLPLEntry]]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (dictionary.directionIsSilesianToPolish) {
            self.title = NSLocalizedString("str_silesian-polish", comment: "")
        }
        else {
            self.title = NSLocalizedString("str_polish-silesian", comment: "")
        }
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("str_search", comment: "")
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        if let leftItem = self.toolbarItems![0] as UIBarButtonItem?, let rightItem = self.toolbarItems![2] as UIBarButtonItem? {
            leftItem.title = NSLocalizedString("str_discoverSilesia", comment: "")
            rightItem.title = NSLocalizedString("str_appInfo", comment: "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        addAlert()
    }
    
    // MARK: - Gestures
    @IBAction func onLongPress(_ sender: UILongPressGestureRecognizer) {
        sender.minimumPressDuration = 2
        if sender.state == .began {
            self.becomeFirstResponder()
            
            dictionary.directionIsSilesianToPolish = !dictionary.directionIsSilesianToPolish
        }
        self.tableView.reloadData()
        viewDidLoad()
    }
    
    // MARK: - Actions
    
    func addAlert() {
        let alertMsg = NSLocalizedString("str_prompt", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("str_addEntryAlert", comment: ""),
                                      message: alertMsg,
                                      preferredStyle: .alert)
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = NSLocalizedString("str_silesian", comment: "")
        }
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = NSLocalizedString("str_polish", comment: "")
        }
        
        let saveAction = UIAlertAction(title: NSLocalizedString("str_save", comment: ""), style: .default, handler: {_ in self.addToModel(alert)})
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("str_cancel", comment: ""), style: .cancel, handler:nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteAlert() {
        let alertMsg = NSLocalizedString("str_deleteAlertWarning", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("str_warning", comment: ""),
                                      message: alertMsg,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("str_OK", comment: ""), style: .cancel, handler:nil)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func wrongInputAlert() {
        let alertMsg = NSLocalizedString("str_wrongInputWarning", comment: "")
        let alert = UIAlertController(title: NSLocalizedString("str_warning", comment: ""),
                                      message: alertMsg,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("str_OK", comment: ""), style: .cancel, handler:nil)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func addToModel(_ alertController: UIAlertController) {
        if (alertController.textFields![0].text?.count)! <= 1 || (alertController.textFields![1].text?.count)! <= 1 {
            wrongInputAlert()
            return;
        }
        dictionary.addEntry(silesianWord: alertController.textFields![0].text!, polishWord: alertController.textFields![1].text!)
        self.tableView.reloadData()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let entry: SLPLEntry
                if isFiltering() {
                    entry = sectionedFilteredEntries[dictionary.alphabet.charAt(indexPath.section)]![indexPath.row]
                } else {
                    entry = dictionary.sectionedEntries[dictionary.alphabet.charAt(indexPath.section)]![indexPath.row]
                }
                
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.entryItem = entry
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    // MARK: - Sections In Table View
    
    let sectionHeaderHeight: CGFloat = 25
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dictionary.alphabet.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(), let filteredEntries = sectionedFilteredEntries[dictionary.alphabet.charAt(section)] {
            return filteredEntries.count
        }
        else if !isFiltering(), let entries = dictionary.sectionedEntries[dictionary.alphabet.charAt(section)] {
            return entries.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isFiltering() {
            if (sectionedFilteredEntries[dictionary.alphabet.charAt(section)] != nil && (sectionedFilteredEntries[dictionary.alphabet.charAt(section)]?.count)! > 0) {
                return sectionHeaderHeight
            }
            else {
                return 0
            }
        }
        if (dictionary.sectionedEntries[dictionary.alphabet.charAt(section)] != nil && (dictionary.sectionedEntries[dictionary.alphabet.charAt(section)]?.count)! > 0) {
            return sectionHeaderHeight
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: sectionHeaderHeight))
        view.backgroundColor = UIColor.gray
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: sectionHeaderHeight))
        label.textColor = UIColor.black
        label.text = String(dictionary.alphabet.charAt(section)).uppercased()
        view.addSubview(label)
        return view
    }
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DictionaryTableCell") as? DictionaryTableCell else {
            fatalError("Expected DictionaryTableCell")
        }
        
        let entry: SLPLEntry
        if isFiltering() {
            entry = sectionedFilteredEntries[dictionary.alphabet.charAt(indexPath.section)]![indexPath.row]
        } else {
            entry = dictionary.sectionedEntries[dictionary.alphabet.charAt(indexPath.section)]![indexPath.row]
        }
        if (entry.addedByUser) {
            cell.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)
        }
        else {
            cell.backgroundColor = UIColor.white
        }
        cell.keyLabel!.text = entry.key
        cell.translationLabel!.text = entry.translation
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (!dictionary.sectionedEntries[dictionary.alphabet.charAt(indexPath.section)]![indexPath.row].addedByUser) {
                deleteAlert()
            }
            else {
                dictionary.removeEntry(from: indexPath.section, at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // MARK: - Private instance methods
    
    /*
     * Return true if the text is empty or nil.
     */
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        for key in dictionary.sectionedEntries.keys {
            sectionedFilteredEntries[key] = dictionary.sectionedEntries[key]?.filter{ (entry : SLPLEntry?) -> Bool in
                return (entry!.key.lowercased().contains(searchText.lowercased()) ||  entry!.translation.lowercased().contains(searchText.lowercased()))}
        }
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
