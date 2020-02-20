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
    private let searchLogManager = SearchLogManager()
    
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
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = true
        self.searchController.searchBar.placeholder = "Title, Author, ISBN13, etc"
        self.searchController.searchBar.delegate = self
        self.searchController.delegate = self
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.title = "Search"

        self.bookTableView.contentInsetAdjustmentBehavior = .never
        self.bookTableView.automaticallyAdjustsScrollIndicatorInsets = false
        self.bookTableView.register(UINib(nibName: "BasicTableViewCell", bundle: nil), forCellReuseIdentifier: "BasicTableViewCell")
        self.bookTableView.register(UINib(nibName: "RecentHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentHeaderTableViewCell")
    }
}

extension SearchBookViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            self.resultViewController.searchBarSearchButtonClicked(searchText: searchText)
            self.searchLogManager.searched(searchedText: searchText)
            self.bookTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resultViewController.searchBarCancelButtonClicked()
    }
    
}

extension SearchBookViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        let searchText = searchController.searchBar.text
    }
    
    
}

extension SearchBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.item - 1
        let texts = searchLogManager.getSearchedTexts()
        
        if texts.count > index {
            let searchText = texts[index]
            
            self.searchController.searchBar.text = searchText
            self.searchLogManager.searched(searchedText: searchText)
            
            self.searchController.isActive = true
            self.searchBarSearchButtonClicked(self.searchController.searchBar)
            self.bookTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SearchBookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.searchLogManager.getSearchedTexts().count
        return (count == 0) ? 0 : count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.item == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentHeaderTableViewCell", for: indexPath) as? RecentHeaderTableViewCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BasicTableViewCell", for: indexPath) as? BasicTableViewCell else {
                return UITableViewCell()
            }
            
            let index = indexPath.item - 1
            let searchedTexts = self.searchLogManager.getSearchedTexts()
            guard searchedTexts.count > index else {
                return cell
            }
            cell.configure(title: searchedTexts[index])
            return cell
        }
    }
}

extension SearchBookViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        print("*** WILL PRESENT")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        print("*** WILL DISMISS")
    }
    
}

extension SearchBookViewController: BookSelectDelegate {
    func bookSelected(book: Book) {
        let detailVC = BookDetailViewController(book: book)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension SearchBookViewController: RecentClearDelegate {
    func clearButtonClicked() {
        self.searchLogManager.removeAll()
        self.bookTableView.reloadData()
    }
}
