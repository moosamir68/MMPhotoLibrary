//
//  MMCameraCaptureViewController.swift
//  Moosa Mir
//
//  Created by Moosa Mir on 10/3/17.
//  Copyright © 2017 Moosa Mir. All rights reserved.
//

import UIKit
import Photos
import TOCropViewController
import SnapKit

public protocol MMCameraCaptureDelegate {
    func createPhotosCollection(fromController:MMCameraCaptureViewController?) -> MMPhotosViewController?
    func dismissCameraController(fromController:MMCameraCaptureViewController?)
    func showCroperFromCameraController(fromController:MMCameraCaptureViewController?, image:UIImage?)
    func dismissCroper(fromController:MMCameraCaptureViewController?, cropper:TOCropViewController?)
    func resultCropImage(fromController:MMCameraCaptureViewController?, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int)
}

public class MMCameraCaptureViewController: UIViewController, MMPhotosDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    

    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var swipeButton: UIButton!
    @IBOutlet weak var takeButton: UIButton!
    @IBOutlet weak var cameraView: UIView!
    
    var imagePicker:UIImagePickerController?
    var photoController:MMPhotosViewController?
    
    var libraryImage:UIImage? = UIImage(named: "libraryButton"){
        didSet{
            
        }
    }
    var takeImage:UIImage?
    
    public var delegate:MMCameraCaptureDelegate?
    var flashMode:UIImagePickerControllerCameraFlashMode = .auto
    var cameraDevice:UIImagePickerControllerCameraDevice = .rear
    var sourceType:UIImagePickerControllerSourceType = .camera
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.setImageForLibraryButton()
        self.setImageForFlashButton(flashMode: self.flashMode)
        self.setCameraDevice(cameraDevice: self.cameraDevice)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        self.setImageForLibraryButton()
        self.setImageForFlashButton(flashMode: self.flashMode)
        self.setCameraDevice(cameraDevice: self.cameraDevice)
    }
    
    //MARK:- initUI
    func initUI(){
        
        let closeButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(MMCameraCaptureViewController.userDidTapOnClose))
        self.navigationItem.leftBarButtonItem = closeButton
        
        self.swipeButton.addTarget(self, action: #selector(MMCameraCaptureViewController.userDidTapOnSwipe), for: .touchUpInside)
        self.libraryButton.addTarget(self, action: #selector(MMCameraCaptureViewController.userDidTapOnLibrary), for: .touchUpInside)
        self.flashButton.addTarget(self, action: #selector(MMCameraCaptureViewController.userDidTapOnFlash), for: .touchUpInside)
        self.takeButton.addTarget(self, action: #selector(MMCameraCaptureViewController.userDidTapOnTake), for: .touchUpInside)
        
        self.edgesForExtendedLayout = []
        
        self.libraryButton.layer.masksToBounds = true
        self.libraryButton.layer.cornerRadius = 22.0
        self.libraryButton.alpha = 0.65
        
        self.imagePicker = UIImagePickerController()
        self.imagePicker?.sourceType = .camera
        self.imagePicker?.showsCameraControls = false
        self.imagePicker?.delegate = self
        
        self.cameraView.addSubview((self.imagePicker?.view)!)
        self.imagePicker?.view.snp.makeConstraints { (make) in
            make.leading.equalTo(self.cameraView.snp.leading)
            make.bottom.equalTo(self.cameraView.snp.bottom)
            make.trailing.equalTo(self.cameraView.snp.trailing)
            make.top.equalTo(self.cameraView.snp.top)
        }
        
        self.libraryButton.backgroundColor = .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(MMCameraCaptureViewController.userDidTapOnVolume), name: NSNotification.Name(rawValue: "_UIApplicationVolumeUpButtonDownNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MMCameraCaptureViewController.userDidTapOnVolume), name: NSNotification.Name(rawValue: "_UIApplicationVolumeDownButtonDownNotification"), object: nil)
    }
    
    func setImageForLibraryButton(){
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        
        if fetchResult.count > 0  {
            imgManager.requestImage(for: fetchResult.object(at: fetchResult.count - 1) as PHAsset, targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions) { (image, _) in
                if(image != nil){
                    self.libraryImage = image
                }else{
                    self.libraryImage = UIImage(named: "libraryButton")
                }
            }
        } else {
            self.libraryImage = UIImage(named: "libraryButton")
        }
        
        if(self.sourceType == .camera){
            self.libraryButton.setImage(self.libraryImage, for: .normal)
        }else{
            self.libraryButton.setImage(UIImage(named: "camera"), for: .normal)
        }
    }
    
    func setImageForFlashButton(flashMode:UIImagePickerControllerCameraFlashMode){
        if(flashMode == .auto){
            self.flashButton.setImage(UIImage(named: "flashAutoIcon"), for: .normal)
            self.imagePicker?.cameraFlashMode = .auto
        }else if(flashMode == .on){
            self.flashButton.setImage(UIImage(named: "flashOnIcon"), for: .normal)
            self.imagePicker?.cameraFlashMode = .on
        }else{
            self.flashButton.setImage(UIImage(named: "flashOffIcon"), for: .normal)
            self.imagePicker?.cameraFlashMode = .off
        }
    }

    func setCameraDevice(cameraDevice:UIImagePickerControllerCameraDevice){
        if(cameraDevice == .rear){
            self.imagePicker?.cameraDevice = .rear
        }else{
            self.imagePicker?.cameraDevice = .front
        }
    }
    
    func reInitUI(sourceType:UIImagePickerControllerSourceType){
        self.sourceType = sourceType
        if(sourceType == .camera){
            self.photoController?.view.removeFromSuperview()
            self.imagePicker?.cameraDevice = self.cameraDevice
            self.cameraView.addSubview((self.imagePicker?.view)!)
            
            self.imagePicker?.view.snp.makeConstraints { (make) in
                make.left.equalTo(self.cameraView.snp.left)
                make.bottom.equalTo(self.cameraView.snp.bottom)
                make.right.equalTo(self.cameraView.snp.right)
                make.top.equalTo(self.cameraView.snp.top)
            }
        }else{
            self.imagePicker?.view.removeFromSuperview()
            self.photoController = self.delegate?.createPhotosCollection(fromController: self)
            self.cameraView.addSubview((self.photoController?.view)!)
            
            self.photoController?.view.snp.makeConstraints { (make) in
                make.left.equalTo(self.cameraView.snp.left)
                make.bottom.equalTo(self.cameraView.snp.bottom)
                make.right.equalTo(self.cameraView.snp.right)
                make.top.equalTo(self.cameraView.snp.top)
            }
        }
    }
    
    @objc func userDidTapOnLibrary() {
        if(self.sourceType == .camera){
            self.sourceType = .photoLibrary
            self.reInitUI(sourceType: self.sourceType)
            self.libraryButton.setImage(UIImage(named: "camera"), for: .normal)
            self.flashButton.isHidden = true
            self.swipeButton.isHidden = true
            self.takeButton.isHidden = true
        }else{
            self.sourceType = .camera
            self.reInitUI(sourceType: self.sourceType)
            self.imagePicker?.showsCameraControls = false
            self.libraryButton.setImage(self.libraryImage, for: .normal)
            self.flashButton.isHidden = false
            self.swipeButton.isHidden = false
            self.takeButton.isHidden = false
        }
    }
    
    @objc func userDidTapOnFlash() {
        if(self.imagePicker?.cameraDevice == .rear && self.imagePicker?.sourceType == .camera){
            if(self.imagePicker?.cameraFlashMode == .auto){
                self.flashButton.setImage(UIImage(named: "flashOnIcon"), for: .normal)
                self.imagePicker?.cameraFlashMode = .on
                self.flashMode = .on
            }else if(self.imagePicker?.cameraFlashMode == .on){
                self.flashButton.setImage(UIImage(named: "flashOffIcon"), for: .normal)
                self.imagePicker?.cameraFlashMode = .off
                self.flashMode = .off
            }else{
                self.flashButton.setImage(UIImage(named: "flashAutoIcon"), for: .normal)
                self.imagePicker?.cameraFlashMode = .auto
                self.flashMode = .auto
            }
        }
    }
    
    @objc func userDidTapOnSwipe() {
        if(self.imagePicker?.cameraDevice == .front){
            self.imagePicker?.cameraDevice = .rear
            self.cameraDevice = .rear
        }else{
            self.imagePicker?.cameraDevice = .front
            self.cameraDevice = .front
        }
    }
    
    @objc func userDidTapOnTake() {
        self.imagePicker?.takePicture()
    }
    
    //MARK:- image picker delegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.takeImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        UIImageWriteToSavedPhotosAlbum(self.takeImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        self.delegate?.showCroperFromCameraController(fromController: self, image: self.takeImage)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("Not Save")
            print("error => ", error.localizedDescription)
        } else {
            self.setImageForLibraryButton()
            print("Save")
        }
    }
    
    //MARK:- as photos delegate
    public func resultSelectPhotoFromPhotos(image: UIImage?) {
        self.delegate?.showCroperFromCameraController(fromController: self, image: image)
    }
    
    //MARK:- notificaiton volume
    @objc func userDidTapOnVolume(){
        self.userDidTapOnTake()
    }
    
    //MARK:- user did tap
    @objc private func userDidTapOnClose(){
        self.delegate?.dismissCameraController(fromController: self)
    }
    
    //MARK:- croper delegate
    public func cropViewController(_ cropViewController: TOCropViewController, didCropImageToRect cropRect: CGRect, angle: Int) {
        
    }
    
    public func cropViewController(_ cropViewController: TOCropViewController, didCropToCircleImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        
    }
    
    public func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        self.delegate?.resultCropImage(fromController: self, didCropToImage: image, rect: cropRect, angle: angle)
    }
    
    public func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        self.delegate?.dismissCroper(fromController: self, cropper: cropViewController)
    }
}
