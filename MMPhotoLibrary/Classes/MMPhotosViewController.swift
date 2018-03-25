//
//  MMPhotosViewController.swift
//  Moosa Mir
//
//  Created by Moosa Mir on 10/3/17.
//  Copyright © 2017 Moosa Mir. All rights reserved.
//

import UIKit
import Photos
import KTCenterFlowLayout

public protocol MMPhotosDelegate {
    func resultSelectPhotoFromPhotos(image:UIImage?)
}

let photoCellIdentifire = "MMLibraryPhotoCollectionViewCell"

public class MMPhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var fetchResults:PHFetchResult<PHAsset>?
    var assetThumbnailSize: CGSize!
    
    public var delegate:MMPhotosDelegate?
    
    public init() {
        super.init(nibName: "MMPhotosViewController", bundle: Bundle(for: MMPhotosViewController.classForCoder()))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewDidAppear(_ animated: Bool) {
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
        
        self.collectionView.register(UINib(nibName: photoCellIdentifire, bundle: Bundle(for: MMPhotosViewController.classForCoder())), forCellWithReuseIdentifier: photoCellIdentifire)
        
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
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifire, for: indexPath as IndexPath) as! MMLibraryPhotoCollectionViewCell
        
        //Modify the cell
        let asset: PHAsset = self.fetchResults![indexPath.item]
        
        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
            if result != nil {
                cell.fillData(image: result)
            }
        })
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset: PHAsset = self.fetchResults![indexPath.item]
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil, resultHandler: {(result, info)in
            if result != nil {
                self.delegate?.resultSelectPhotoFromPhotos(image: result)
            }
        })
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
