//
//  MMLibraryPhotoCollectionViewCell.swift
//  Moosa Mir
//
//  Created by Moosa Mir on 10/3/17.
//  Copyright © 2017 Moosa Mir. All rights reserved.
//

import UIKit

class MMLibraryPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageViewCameraRoll: UIImageView!
    var image:UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fillData(image:UIImage?){
        self.image = image
        self.imageViewCameraRoll.image = image
    }
}
