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
    private var loadImageTasks: [Int : URLSessionDataTask] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "New books"
        
        self.bookListTableView.register(UINib(nibName: "BookInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BookInfoTableViewCell")
        BookAPIManager.loadNewBookLists { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let newBooks):
                DispatchQueue.main.async {
                    self.books = newBooks.books
                    self.bookListTableView.reloadData()
                }
            case .failure(let error):
                print("Load new book lists error: \(error.localizedDescription)")
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private func setImageToCell(imageURL: String, cellIndexPath indexPath: IndexPath) {
        guard BookCacheManager.shared.images.object(forKey: imageURL as NSString) == nil else { return }
        guard self.loadImageTasks[indexPath.item] == nil else { return }
        let task = BookCacheManager.shared.getImageFromURL(urlString: imageURL) { [weak self, indexPath] (image) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadImageTasks[indexPath.item] = nil
                if let cell = self.bookListTableView.cellForRow(at: indexPath) as? BookInfoTableViewCell {
                    cell.configure(image: image)
                }
            }
        }
        self.loadImageTasks[indexPath.item] = task
    }
}

extension NewBooksViewController: UITableViewDelegate {
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

extension NewBooksViewController: UITableViewDataSource {
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
        
        let bookImage = BookCacheManager.shared.images.object(forKey: (book.image ?? "") as NSString)
        if bookImage == nil, let imageURL = book.image {
            self.setImageToCell(imageURL: imageURL, cellIndexPath: indexPath)
        }
        
        cell.configure(book: book, image: bookImage)
        return cell
    }
}

extension NewBooksViewController: UITableViewDataSourcePrefetching {
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
