//
//  ASPhotosViewController.swift
//  Artiscovery
//
//  Created by Moosa Mir on 10/3/17.
//  Copyright © 2017 Artiscovery. All rights reserved.
//

import UIKit
import Photos
import KTCenterFlowLayout

protocol PhotosDelegate {
    func resultSelectPhotoFromPhotos(image:UIImage?)
}

let photoCellIdentifire = "LibraryPhotoCollectionViewCell"

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchResults:PHFetchResult<PHAsset>?
    var assetThumbnailSize: CGSize!
    
    var delegate:PhotosDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getImages()
    }

    //MARK:- init UI
    func initUI(){
        self.edgesForExtendedLayout = []
        
        self.collectionView?.contentInset = UIEdgeInsets(top: 5.0,
                                                         left: 5.0,
                                                         bottom: 5.0,
                                                         right: 5.0)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: photoCellIdentifire, bundle: nil), forCellWithReuseIdentifier: photoCellIdentifire)
        
        if let layout = self.collectionView!.collectionViewLayout as? UICollectionViewFlowLayout{
            let cellSize = layout.itemSize
            
            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
        }
    }
    
    //MARK:- get images
    func getImages(){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        self.fetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    //MARK:- collection view delegate and data source
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifire, for: indexPath as IndexPath) as! LibraryPhotoCollectionViewCell
        
        //Modify the cell
        let asset: PHAsset = self.fetchResults![indexPath.item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
            if result != nil {
                cell.fillData(image: result)
            }
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset: PHAsset = self.fetchResults![indexPath.item]
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: {(result, info)in
            if result != nil {
                self.delegate?.resultSelectPhotoFromPhotos(image: result)
            }
        })
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int = 0
        
        if(self.fetchResults != nil){
            count = (self.fetchResults?.count)!
        }
        
        return count;
    }

    // MARK: - UICollectionViewDelegateFlowLayout methods
    func collectionView(collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
}
