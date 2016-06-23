//
//  FilterChoiceViewController.swift
//  InstaClone
//
//  Created by Mike Nancett on 6/21/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class FilterChoiceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var image = UIImage(contentsOfFile: "")
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterCollection: UICollectionView!
    var currentFilter = CIFilter()
    let currentImage = UIImage()
    let context = CIContext()
    var filteredImage = UIImage()
    var showFilters = true
    var filterImageData = NSData()
    let rootRefDB = FIRDatabase.database().reference()
    let rootRefStorage = FIRStorage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            imageView.image = image
        self.navigationController?.navigationBarHidden = false

    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCell", forIndexPath: indexPath) as? FilterCollectionViewCell
        
      let coreImage = CIImage(image: self.image!)
        
        cell!.cellImage.image = image

        
            if let filter = Filter(rawValue: indexPath.row){
             cell!.filterLabel.text = filter.names()
             currentFilter = filter.filters()
                
                if indexPath.row != 0 {
                self.currentFilter.setValue(coreImage, forKey: kCIInputImageKey)
                    self.applyFilter()
                    cell?.cellImage.image = self.filteredImage
                }
            
                return cell!
            }else {
                return FilterCollectionViewCell()
        }
    }
    
    func applyFilter(){
        
            let cgimg = context.createCGImage(currentFilter.outputImage!, fromRect: currentFilter.outputImage!.extent)
           filteredImage = UIImage(CGImage: cgimg, scale:1, orientation: UIImageOrientation .Right)
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let filter = Filter(rawValue: indexPath.row){
            currentFilter = filter.filters()
            
            let coreImage = CIImage(image: self.image!)
            
            if indexPath.row != 0 {
                self.currentFilter.setValue(coreImage, forKey: kCIInputImageKey)
                self.applyFilter()
                imageView.image = filteredImage
            }else{
                imageView.image = image
            }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("tap")
     
        let imageData = UIImageJPEGRepresentation(filteredImage, 0.4)
        self.filterImageData = imageData!
        performSegueWithIdentifier("toNewPost", sender: self)
    }

    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! NewPostViewController
            vc.finalImage = filteredImage
    }
    
}


