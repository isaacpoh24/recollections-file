//
//  ViewController.swift
//  project
//
//  Created by Student27 on 28/10/18.
//  Copyright © 2018 Student27. All rights reserved.
//

import UIKit
import Photos


private let reuseIdentifier = "Cell"
private let imageWidth: Double = 60

class PicViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
//    var pics = ["😄", "😎", "🤯", "💩", "🤔", "🤩"]
    var imgs: [UIImage] = [#imageLiteral(resourceName: "family"), #imageLiteral(resourceName: "family2"), #imageLiteral(resourceName: "family3"), #imageLiteral(resourceName: "family4")]
    
    @IBAction func clear(_ sender: Any) {
        for view in self.displayView.subviews {
            view.removeFromSuperview()}
    }

    @IBAction func chooseImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else {
                print("Camera Not Available")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { (action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func deleteImage(_ sender: Any) {
        
//        let deleteIndexPath =
//            collectionView.indexPath(for: <#T##UICollectionViewCell#>)
        
            imgs.removeLast()
            collectionView.reloadData()
//          collectionView.deleteItemsAtIndexPaths([deleteIndexPath])
        
        
        
    }
    
    @objc(imagePickerController:didFinishPickingMediaWithInfo:) internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imgs.insert(image, at: 0)
        print(imgs)
        collectionView.reloadData()
        let loadedScores = UserDefaults.standard.array(forKey: "imgs")
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    var animator: UIDynamicAnimator!
    var collisions: UICollisionBehavior!
    var gravity: UIGravityBehavior!
    var dynamics: UIDynamicItemBehavior!
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized: print("Access is granted by user")
        case .notDetermined: PHPhotoLibrary.requestAuthorization({(newStatus) in print("status is \(newStatus)")
            if newStatus == PHAuthorizationStatus.authorized { /* do stuff here */ print("success") }})
        case .restricted: print("User do not have access to photo album.")
        case .denied: print("User has denied the permission.")
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: displayView)
        collisions = UICollisionBehavior(items: [])
        collisions.translatesReferenceBoundsIntoBoundary = true
        animator.addBehavior(collisions)
        
        gravity = UIGravityBehavior(items: [])
        animator.addBehavior(gravity)
        
        dynamics = UIDynamicItemBehavior(items: [])
        dynamics.elasticity = 0.5
        dynamics.resistance = 0.5
        animator.addBehavior(dynamics)
        
        checkPermission()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as!
            PicCollectionViewCell
        
        //cell.label.text = pics[indexPath.item]
        cell.image.image = imgs[indexPath.item]
        
        return cell  
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        //let selectedPic = pics[indexPath.item]
        let selectedImage = imgs[indexPath.item]
        
        let randX = drand48() * (Double(displayView.frame.width) - imageWidth)
        let randY = drand48() * (Double(displayView.frame.height) - imageWidth)
        let imageView = UIImageView(frame: CGRect(x: randX, y: randY, width: imageWidth, height: imageWidth))
        imageView.image = selectedImage
        imageView.clipsToBounds = true
        
//        image.text = selectedPic
//        image.font = image.font.withSize(60)
//        image.adjustsFontSizeToFitWidth = true
//        image.textAlignment = .center
        displayView.addSubview(imageView)
        
        collisions.addItem(imageView)
        dynamics.addItem(imageView)
        //gravity.addItem(label)
        
        let push = UIPushBehavior(items: [imageView], mode: .instantaneous)
        push.angle = CGFloat(drand48() * .pi * 2)
        push.magnitude = CGFloat(1.0 + drand48() * 2)
        animator.addBehavior(push)
    }

}

