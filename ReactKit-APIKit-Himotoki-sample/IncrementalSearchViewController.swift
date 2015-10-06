//
//  IncrementalSearchViewController.swift
//  ReactKit-APIKit-Himotoki-sample
//
//  Created by Shinichiro Oba on 2015/10/06.
//  Copyright © 2015年 Shinichiro Oba. All rights reserved.
//

import UIKit
import ReactKit
import APIKit

class IncrementalSearchViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    dynamic var searchText: String = ""
    
    var searchResultStream: Stream<[Item]>?
    var items: [Item] = []
    
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dateFormatter.locale = NSLocale.currentLocale()
        self.dateFormatter.timeZone = NSTimeZone.localTimeZone()
        self.dateFormatter.dateStyle = .ShortStyle
        self.dateFormatter.timeStyle = .ShortStyle
        
        bind()
    }
    
    func bind() {
        self.searchResultStream = KVO.stream(self, "searchText")
            |> debounce(0.5)
            |> map { ($0 as? String) ?? "" }
            |> distinctUntilChanged
            |> map { query -> Stream<[Item]> in
                let request = GetItemsRequest(query: query)
                return Stream<[Item]>.fromTask(API.taskFromRequest(request))
            }
            |> switchLatestInner
        
        self.searchResultStream! ~> { [weak self] items in
            self?.items = items
            self?.tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Item", forIndexPath: indexPath)
        
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = self.dateFormatter.stringFromDate(item.createdAt)
        
        return cell
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}
