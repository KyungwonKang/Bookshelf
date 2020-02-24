//
//  NewBooksViewController.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class NewBooksViewController: UIViewController {

    @IBOutlet weak var bookListTableView: UITableView!
    
    private var books: [Book] = []
    private var imageTasks: [String : URLSessionDataTask] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "New books"
        
        bookListTableView.register(UINib(nibName: "BookInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BookInfoTableViewCell")
        
        loadNewBooks { [weak self] (books) in
            guard let self = self else { return }
            self.setupNewBooksAndReload(books: books)
        }
    }

    private func loadNewBooks(success: @escaping ([Book]) -> Void) {
        BookAPI.loadNewBookLists { (result) in
            switch result {
            case .success(let newBooks):
                success(newBooks.books)
            case .failure(let error):
                print("Load new book lists error: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupNewBooksAndReload(books: [Book]) {
        self.books = books
        DispatchQueue.main.async {
            self.bookListTableView.reloadData()
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
                if let cell = self.bookListTableView.cellForRow(at: indexPath) as? BookInfoTableViewCell, cell.isbn13 == id {
                    cell.update(image: image)
                }
            }
        }
    }
}

extension NewBooksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard books.count > indexPath.item else { return }
        let book = books[indexPath.item]
        let detailVC = BookDetailViewController(book: book)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension NewBooksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookInfoTableViewCell", for: indexPath) as? BookInfoTableViewCell else {
            return UITableViewCell()
        }
        guard books.count > indexPath.item else {
            return cell
        }
        
        let book = books[indexPath.item]
        if let cache = BookImageManager.shared.getCache(forURL: book.image ?? "") {
            cell.configure(book: book, image: cache)
        } else {
            requestImage(forBook: book, cellIndexPath: indexPath)
            cell.configure(book: book, image: nil)
        }
        return cell
    }
}

extension NewBooksViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if books.count <= indexPath.item {
                continue
            }
            
            let book = books[indexPath.item]
            requestImage(forBook: book, cellIndexPath: indexPath)
        }
    }
}
