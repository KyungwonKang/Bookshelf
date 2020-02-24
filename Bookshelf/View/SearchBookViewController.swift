//
//  SearchBookViewController.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/17.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class SearchBookViewController: UIViewController {
    @IBOutlet weak var bookTableView: UITableView!
    
    private let resultViewController: SearchResultViewController!
    private let searchController: UISearchController!
    private let searchLogManager = SearchLogger()
    
    init() {
        let resultVC = SearchResultViewController()
        self.resultViewController = resultVC
        self.searchController = UISearchController(searchResultsController: resultVC)
        super.init(nibName: nil, bundle: nil)
        
        self.resultViewController.delegat = self
    }
    
    required init?(coder: NSCoder) {
        let resultVC = SearchResultViewController()
        self.resultViewController = resultVC
        self.searchController = UISearchController(searchResultsController: resultVC)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Title, Author, ISBN13, etc"
        searchController.searchBar.delegate = self
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "Search"

        bookTableView.contentInsetAdjustmentBehavior = .never
        bookTableView.automaticallyAdjustsScrollIndicatorInsets = false
        bookTableView.register(UINib(nibName: "RecentLogTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentLogTableViewCell")
        bookTableView.register(UINib(nibName: "RecentHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentHeaderTableViewCell")
    }
}

extension SearchBookViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            resultViewController.requestSearch(searchText: searchText)
            searchLogManager.add(log: searchText)
            bookTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultViewController.clear()
    }
}

extension SearchBookViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        resultViewController.updateSearchResults()
    }
}

extension SearchBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.item - 1
        let texts = searchLogManager.getLogs()
        
        if texts.count > index {
            let searchText = texts[index]
            
            searchController.searchBar.text = searchText
            searchLogManager.add(log: searchText)
            
            searchController.isActive = true
            searchBarSearchButtonClicked(self.searchController.searchBar)
            bookTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SearchBookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let logs = searchLogManager.getLogs()
        if logs.isEmpty {
            return 0
        } else {
            return logs.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentHeaderTableViewCell", for: indexPath) as? RecentHeaderTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentLogTableViewCell", for: indexPath) as? RecentLogTableViewCell else {
                return UITableViewCell()
            }
            
            let index = indexPath.item - 1
            let logs = self.searchLogManager.getLogs()
            guard logs.count > index else {
                return cell
            }
            cell.configure(title: logs[index])
            return cell
        }
    }
}

extension SearchBookViewController: BookDidClickDelegate {
    func bookSelected(book: Book) {
        let detailVC = BookDetailViewController(book: book)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension SearchBookViewController: RecentClearDelegate {
    func clearButtonClicked() {
        searchLogManager.removeAll()
        bookTableView.reloadData()
    }
}
