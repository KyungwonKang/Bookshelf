//
//  SearchResultViewController.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/20.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

protocol BookDidClickDelegate: NSObjectProtocol {
    func bookSelected(book: Book)
}

class SearchResultViewController: UIViewController {

    @IBOutlet weak var bookTableView: UITableView!
    @IBOutlet weak var noResultView: UIView!
    
    private var lastPage: Int = 0
    private var searchText: String?
    private var books: [Book] = []
    private var noMoreResult: Bool = false
    
    private var searchTask: URLSessionDataTask?
    private var imageTasks: [String : URLSessionDataTask] = [:]
    
    weak var delegat: BookDidClickDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bookTableView.register(UINib(nibName: "BookInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BookInfoTableViewCell")
        self.bookTableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingTableViewCell")
    }

    func updateSearchResults() {
        self.noResultView.isHidden = true
    }
        
    func requestSearch(searchText: String) {
        self.cancelAllTasks()
        self.noMoreResult = false
        self.searchBooks(searchText: searchText, success: { [weak self] (page, searchedBooks) in
            self?.appendDataAndReloadUI(page: page, searchedBooks: searchedBooks)
        })
    }
 
    func clear() {
        self.lastPage = 0
        self.searchText = nil
        self.cancelAllTasks()
        self.books.removeAll()
        self.bookTableView.reloadData()
        self.noResultView.isHidden = true
    }
    
    private func cancelAllTasks() {
        self.searchTask?.cancel()
        self.searchTask = nil
        
        self.imageTasks.values.forEach { $0.cancel() }
        self.imageTasks.removeAll()
    }
     
    private func searchBooks(searchText: String, page: Int = 1, success: @escaping (Int, SearchedBooks) -> Void) {
        self.searchText = searchText
        self.searchTask = BookAPI.searchBooks(searchText: searchText, page: page) { [weak self, page] (result) in
            guard let self = self else { return }
            self.searchTask = nil
            
            switch result {
            case .success(let searchedBooks):
                success(page, searchedBooks)
            case .failure(let error):
                print("Search Book error: \(error.localizedDescription)")
            }
        }
    }
    
    private func appendDataAndReloadUI(page: Int, searchedBooks: SearchedBooks) {
        if searchedBooks.books.count > 0 {
            self.lastPage = page
            if page == 1 {
                self.books = searchedBooks.books
            } else {
                self.books.append(contentsOf: searchedBooks.books)
            }
        } else {
            self.noMoreResult = true
        }
        
        DispatchQueue.main.async {
            self.noResultView.isHidden = (self.books.count > 0)
            self.bookTableView.reloadData()
        }
    }
    
    private func requestImage(forBook book: Book, cellIndexPath indexPath: IndexPath) {
        guard let id = book.isbn13, let imagePath = book.image, BookImageManager.shared.getCache(forURL: imagePath) == nil else {
            return
        }
        
        guard imageTasks[id] == nil else {
            return
        }
        
        
        self.imageTasks[id] = BookImageManager.shared.loadImage(fromURL: imagePath) { [weak self, id] (image) in
            guard let self = self else { return }
            self.imageTasks[id] = nil
            DispatchQueue.main.async {
                if let cell = self.bookTableView.cellForRow(at: indexPath) as? BookInfoTableViewCell, cell.isbn13 == id {
                    cell.update(image: image)
                }
            }
        }
    }

    private func loadMoreBooks() {
        guard let searchText = self.searchText else {
            return
        }
        
        if isLoadMoreEnabled() {
            searchBooks(searchText: searchText, page: self.lastPage + 1) { [weak self] (page, searchedBooks) in
                self?.appendDataAndReloadUI(page: page, searchedBooks: searchedBooks)
            }
        }
    }
    
    private func isLoadMoreEnabled() -> Bool {
        return (self.noMoreResult == false) && (self.searchTask == nil)
    }
    
}

extension SearchResultViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.books.count > indexPath.item else { return }
        let book = self.books[indexPath.item]
        self.delegat?.bookSelected(book: book)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let loadingCell = cell as? LoadingTableViewCell {
            loadingCell.startAnimating()
            self.loadMoreBooks()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let loadingCell = cell as? LoadingTableViewCell {
            loadingCell.stopAnimating()
        }
    }
}

extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.noMoreResult {
            return self.books.count
        } else {
            return (self.books.count == 0) ? 0 : (self.books.count + 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.books.count > indexPath.item {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoTableViewCell", for: indexPath) as? BookInfoTableViewCell else {
                return UITableViewCell()
            }
            
            let book = self.books[indexPath.item]
            if let cache = BookImageManager.shared.getCache(forURL: book.image ?? "") {
                cell.configure(book: book, image: cache)
            } else {
                requestImage(forBook: book, cellIndexPath: indexPath)
                cell.configure(book: book, image: nil)
            }
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath) as? LoadingTableViewCell {
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension SearchResultViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if self.books.count <= indexPath.item {
                continue
            }
            
            let book = self.books[indexPath.item]
            requestImage(forBook: book, cellIndexPath: indexPath)
        }
    }
}
