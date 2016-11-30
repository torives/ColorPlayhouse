//
//  PortfolioViewController.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class PortfolioViewController: UIViewController, UICollectionViewDelegate {

    var delegate: PortfolioDelegate?
    var imageToPass: UIImage!
    var videoDataToPass: NSData!
    var savedImages = [UIImage]()
    var videoData = [NSData]()
    
    let DAO = DataAccessObject.sharedInstance
    var didFinishFetchingImages = false
    
    @IBOutlet weak var portfolioCollection: UICollectionView!
    @IBOutlet weak var noDrawings: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        portfolioCollection.dataSource = self
        portfolioCollection.delegate = self
    }
    
    func fetchData() {
        DAO.fetchUserImages { (assets) in
            for asset in assets! {
                let imageURL = asset.0.fileURL
                let videoURL = asset.1.fileURL
                let imageData = NSData(contentsOf: imageURL)
                let videoData = NSData(contentsOf: videoURL)
                self.savedImages.append(UIImage(data: imageData as! Data)!)
                self.videoData.append(videoData!)
            }
            self.didFinishFetchingImages = true
            
            DispatchQueue.main.async {
                self.portfolioCollection.reloadData()
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageToPass = savedImages[indexPath.item]
        videoDataToPass = videoData[indexPath.item]
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let detail = segue.destination as! PortfolioDetailViewController
            detail.selectedImage = imageToPass
            detail.videoData = videoDataToPass
        }
    }
    
}

//MARK: DataSource
extension PortfolioViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if savedImages.count > 0 { noDrawings.isHidden = true }
        return savedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "portfolioCell", for: indexPath) as! PortfolioCell
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowRadius = 20

        
        if didFinishFetchingImages {
            cell.imageView.setImage(image: self.savedImages[indexPath.item])
        } else {
            cell.imageView.refresh()
        }
        
        return cell
    }
}

extension PortfolioViewController: PortfolioScreen
{
    func showItems(_ items: [PortfolioItem]){}
    func showTimelapse(_ item: TimelapseItem){}
    func showImage(_ image: ImageItem){}
}
