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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var lastPage: Int = 0
    private var books: [Book] = []
    private var loadImageTasks: [Int : URLSessionDataTask] = [:]
    
    private var lastSearchTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.definesPresentationContext = true
        
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Books"
        self.searchController.searchBar.delegate = self
        
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "Books"
        
        self.bookTableView.register(UINib(nibName: "BookInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BookInfoTableViewCell")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchBookViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            let page = self.lastPage + 1
            let task = BookAPIManager.searchBooks(searchText: searchText, page: page) { [weak self, page] (result) in
                guard let self = self else { return }
                self.lastSearchTask = nil
                
                switch result {
                case .success(let searchedBooks):
                    self.lastPage = page
                    self.books.append(contentsOf: searchedBooks.books)
                    DispatchQueue.main.async {
                        self.bookTableView.reloadData()
                    }
                case .failure(let error):
                    print("Search Book error: \(error.localizedDescription)")
                }
            }
            self.lastSearchTask = task
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.lastSearchTask?.cancel()
        self.lastSearchTask = nil
        
        self.lastPage = 0
        self.books.removeAll()
        self.bookTableView.reloadData()
    }
}

extension SearchBookViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
//        let searchText = searchController.searchBar.text
    }
    
    
}

extension SearchBookViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.books.count > indexPath.item else { return }
        let book = self.books[indexPath.item]
        let detailVC = BookDetailViewController(book: book)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SearchBookViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoTableViewCell", for: indexPath) as? BookInfoTableViewCell else {
            return UITableViewCell()
        }
        guard self.books.count > indexPath.item else {
            return cell
        }
        
        let book = self.books[indexPath.item]
        let bookImage = BookCacheManager.shared.images.object(forKey: (book.url ?? "") as NSString)
        cell.configure(book: book, image: bookImage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if self.books.count <= indexPath.item {
                continue
            }
            
            let book = self.books[indexPath.item]
            if let imageUrl = book.image {
                let task = BookCacheManager.shared.getImageFromURL(urlString: imageUrl) { [weak self] (image) in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.loadImageTasks[indexPath.item] = nil
                        if tableView.indexPathsForVisibleRows?.contains(indexPath) == true {
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
                self.loadImageTasks[indexPath.item] = task
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if self.loadImageTasks[indexPath.item] != nil {
                self.loadImageTasks[indexPath.item]?.cancel()
                self.loadImageTasks[indexPath.item] = nil
            }
        }
    }
}
