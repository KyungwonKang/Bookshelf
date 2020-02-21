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
    
    private var lastTask: URLSessionDataTask?
    private var details: [(String, String)] = []
    
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
        
        self.detailTableView.register(UINib(nibName: "BookDetailBasicTableViewCell", bundle: nil), forCellReuseIdentifier: "BookDetailBasicTableViewCell")
        self.detailTableView.register(UINib(nibName: "BookDetailInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BookDetailInfoTableViewCell")
        self.detailTableView.contentInsetAdjustmentBehavior = .never
        self.detailTableView.automaticallyAdjustsScrollIndicatorInsets = false
        self.detailTableView.sectionHeaderHeight = UITableView.automaticDimension

        self.loadBookDetailInfo(book: book)
    }
    
    private func loadBookDetailInfo(book: Book) {
        guard let isbn13 = book.isbn13 else { return }
        let task = BookAPIManager.loadBookInfo(isbn13: isbn13, completion: { [weak self] (result) in
            guard let self = self else { return }
            self.lastTask = nil
            
            switch result {
            case .success(let detail):
                DispatchQueue.main.async {
                    self.detail = detail
                    if let isbn10 = detail.isbn10 { self.details.append(("isbn10", isbn10)) }
                    if let isbn13 = detail.isbn13 { self.details.append(("isbn13", isbn13)) }
                    if let pages = detail.pages { self.details.append(("pages", pages)) }
                    if let year = detail.year { self.details.append(("year", year)) }
                    self.detailTableView.reloadData()
                }
            case .failure(let error):
                print("Load book detail error: \(error.localizedDescription)")
            }
        })
        
        self.lastTask = task
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
            return details.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailInfoTableViewCell", for: indexPath) as? BookDetailInfoTableViewCell else {
                return UITableViewCell()
            }
            if let detail = self.detail {
                cell.configure(bookDetail: detail)
            } else {
                cell.configure(book: book)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookDetailBasicTableViewCell", for: indexPath) as? BookDetailBasicTableViewCell else {
                return UITableViewCell()
            }
            
            guard details.count > indexPath.item else {
                return cell
            }
            
            let detail = details[indexPath.item]
            cell.configure(title: detail.0, value: detail.1)
            return cell
        }
    }
}
