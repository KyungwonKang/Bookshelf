//
//  SearchResultViewController.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/20.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

protocol BookSelectDelegate: NSObjectProtocol {
    func bookSelected(book: Book)
}

class SearchResultViewController: UIViewController {

    @IBOutlet weak var bookTableView: UITableView!
    @IBOutlet weak var noResultGuideView: UIView!
    
    private var lastPage: Int = 0
    private var books: [Book] = []
    private var loadingEnded: Bool = false
    
    private var lastSearchTask: URLSessionDataTask?
    private var lastSearchText: String?
    private var loadImageTasks: [Int : URLSessionDataTask] = [:]
    
    weak var delegat: BookSelectDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.bookTableView.register(UINib(nibName: "BookInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BookInfoTableViewCell")
        self.bookTableView.register(UINib(nibName: "LoadingTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadingTableViewCell")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func updateSearchResults() {
        self.noResultGuideView.isHidden = true
    }
        
    func searchBarSearchButtonClicked(searchText: String) {
        self.loadingEnded = false
        
        self.lastSearchText = searchText
        self.lastSearchTask?.cancel()
        self.lastSearchTask = nil
        self.loadImageTasks.values.forEach { (task) in
            task.cancel()
        }
        self.loadImageTasks.removeAll()
        
        let page = 1
        let task = BookAPIManager.searchBooks(searchText: searchText, page: page) { [weak self, page] (result) in
            guard let self = self else { return }
            self.lastSearchTask = nil
            
            switch result {
            case .success(let searchedBooks):
                if page == 1 {
                    self.books.removeAll()
                }
                self.lastPage = page
                self.books.append(contentsOf: searchedBooks.books)
                DispatchQueue.main.async {
                    self.noResultGuideView.isHidden = (self.books.count > 0)
                    self.bookTableView.reloadData()
                }
                
            case .failure(let error):
                print("Search Book error: \(error.localizedDescription)")
            }
        }
        self.lastSearchTask = task
    }
 
    func searchBarCancelButtonClicked() {
        self.lastSearchTask?.cancel()
        self.lastSearchTask = nil
        
        self.loadImageTasks.values.forEach { $0.cancel() }
        self.loadImageTasks.removeAll()
        
        self.lastPage = 0
        self.lastSearchText = nil
        
        self.books.removeAll()
        self.bookTableView.reloadData()
        self.noResultGuideView.isHidden = true
    }
    
    private func setImageToCell(imageURL: String, cellIndexPath indexPath: IndexPath) {
        guard BookCacheManager.shared.images.object(forKey: imageURL as NSString) == nil else { return }
        guard self.loadImageTasks[indexPath.item] == nil else { return }
        let task = BookCacheManager.shared.getImageFromURL(urlString: imageURL) { [weak self, indexPath] (image) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadImageTasks[indexPath.item] = nil
                if let cell = self.bookTableView.cellForRow(at: indexPath) as? BookInfoTableViewCell {
                    cell.configure(image: image)
                }
            }
        }
        self.loadImageTasks[indexPath.item] = task
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
        guard let loadingCell = cell as? LoadingTableViewCell else {
            return
        }
        
        guard self.loadingEnded == false, self.lastSearchTask == nil else {
            return
        }
        
        loadingCell.startAnimating()
        if let searchText = self.lastSearchText {
            let page = self.lastPage + 1
            let task = BookAPIManager.searchBooks(searchText: searchText, page: page) { [weak self, page] (result) in
                guard let self = self else { return }
                self.lastSearchTask = nil
                
                switch result {
                case .success(let searchedBooks):
                    if searchedBooks.books.count > 0 {
                        if page == 1 {
                            self.books.removeAll()
                        }
                        self.lastPage = page
                        self.books.append(contentsOf: searchedBooks.books)
                        DispatchQueue.main.async {
                            self.bookTableView.reloadData()
                        }
                    } else {
                        self.loadingEnded = true
                        DispatchQueue.main.async {
                            self.bookTableView.reloadData()
                        }
                    }
                    
                case .failure(let error):
                    print("Search Book error: \(error.localizedDescription)")
                }
            }
            self.lastSearchTask = task
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
        if self.loadingEnded {
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
            let bookImage = BookCacheManager.shared.images.object(forKey: (book.image ?? "") as NSString)
            if bookImage == nil, let imageURL = book.image {
                self.setImageToCell(imageURL: imageURL, cellIndexPath: indexPath)
            }
            
            cell.configure(book: book, image: bookImage)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingTableViewCell", for: indexPath) as? LoadingTableViewCell else {
                return UITableViewCell()
            }
            return cell
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
            if let imageURL = book.image {
                self.setImageToCell(imageURL: imageURL, cellIndexPath: indexPath)
            }
        }
    }
}