//
//  BookTableViewCell.swift
//  iosExam
//
//  Created by James Abanto on 16/02/2018.
//  Copyright © 2018 carlo. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    func setupCell(_ rssItem: RSSItem) {
        
        guard let pubDate = rssItem.pubDate else { return }
        guard let imgURL = rssItem.imgURL else { return }
        guard let ratingURL = rssItem.ratingURL else { return }
        guard let title = rssItem.title else { return }
        
        //Formatting Publication Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss zzz"
        let date = dateFormatter.date(from: pubDate)
        
        //Setting up the cell
        bookImageView.imageFromUrl(urlString: imgURL)
        titleLabel.text = title
        dateLabel.text = String(describing: date!)
        ratingImageView.imageFromUrl(urlString: ratingURL)
    }
}
