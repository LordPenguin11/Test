//
//  SearchResultCollectionViewCell.swift
//  Test
//
//  Created by MacS on 2023/02/12.
//

import UIKit

class SearchResultCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    static let identifier = "SearchResultCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
