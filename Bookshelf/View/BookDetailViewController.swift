//
//  BookDetailViewController.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {

    @IBOutlet weak var detailTableView: UITableView!
    
    private var bookInfos: [(String, String)] = []
    
    let book: Book
    private var detail: BookDetail?
    
    init(book: Book) {
        self.book = book
        super.init(nibName: "BookDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.largeTitleDisplayMode = .never
        
        detailTableView.register(UINib(nibName: "BookDetailBasicTableViewCell", bundle: nil), forCellReuseIdentifier: "BookDetailBasicTableViewCell")
        detailTableView.register(UINib(nibName: "BookDetailInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BookDetailInfoTableViewCell")
        detailTableView.contentInsetAdjustmentBehavior = .never
        detailTableView.automaticallyAdjustsScrollIndicatorInsets = false
        detailTableView.sectionHeaderHeight = UITableView.automaticDimension

        self.loadBookDetailInfo(book: book, success: { [weak self] detail in
            self?.apply(detail: detail)
        })
    }
    
    private func loadBookDetailInfo(book: Book, success: @escaping (BookDetail) -> Void) {
        guard let isbn13 = book.isbn13 else { return }
        BookAPI.loadBookInfo(isbn13: isbn13, completion: { (result) in
            switch result {
            case .success(let detail):
                success(detail)
            case .failure(let error):
                print("Load book detail error: \(error.localizedDescription)")
            }
        })
    }
    
    private func apply(detail: BookDetail) {
        self.detail = detail
        if let isbn10 = detail.isbn10 {
            self.bookInfos.append(("isbn10", isbn10))
        }
        if let isbn13 = detail.isbn13 {
            self.bookInfos.append(("isbn13", isbn13))
        }
        if let pages = detail.pages {
            self.bookInfos.append(("Pages", pages))
        }
        if let year = detail.year {
            self.bookInfos.append(("Year", year))
        }
        DispatchQueue.main.async {
            self.detailTableView.reloadData()
        }
    }
}

extension BookDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Information"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNonzeroMagnitude : UITableView.automaticDimension
    }
}

extension BookDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return bookInfos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailInfoTableViewCell", for: indexPath) as? BookDetailInfoTableViewCell else {
                return UITableViewCell()
            }
            
            cell.setBaseInfo(book)
            if let detail = self.detail {
                cell.setDetailInfo(detail)
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailBasicTableViewCell", for: indexPath) as? BookDetailBasicTableViewCell else {
                return UITableViewCell()
            }
            
            guard bookInfos.count > indexPath.item else {
                return cell
            }
            
            let info = bookInfos[indexPath.item]
            cell.configure(title: info.0, value: info.1)
            return cell
        }
    }
}
