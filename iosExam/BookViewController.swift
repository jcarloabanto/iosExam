//
//  ViewController.swift
//  iosExam
//
//  Created by James Abanto on 16/02/2018.
//  Copyright © 2018 carlo. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {
    
    fileprivate var rssItems: [RSSItem]?
    fileprivate var filteredItems =  [RSSItem]()
    var searchActive : Bool = false
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var parser = XMLParser()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        fetchData()
    }
    
    private func fetchData() {
        let feedParser = FeedParser()
        feedParser.parseFeed(url: "https://www.amazon.co.uk/gp/rss/bestsellers/books/270423/ref=zg_bs_270423_rsslink") { (rssItems) in
            self.rssItems = rssItems
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setUpView() {
        tableView.tableFooterView = UIView()
        searchBar.delegate = self
        searchBar.returnKeyType = .done
    }
}

//MARK: - Table View Delegate and Datasource

extension BookViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rssItems = rssItems else { return 0 }
        
        return  searchActive ? filteredItems.count : rssItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BookTableViewCell
        let item: RSSItem!
        if searchActive {
            item = filteredItems[indexPath.row]
        } else {
            item = rssItems?[indexPath.row]
        }
        cell.setupCell(item)
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            searchActive = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            searchActive = true

            filteredItems = self.rssItems!.filter { ($0.title?.contains(searchText))! && (($0.ratingURL?.contains("stars-4-5"))! || ($0.ratingURL?.contains("stars-4-0"))!)}
            print("filteredItems \(filteredItems.count)")
            tableView.reloadData()
        }
    }
}

