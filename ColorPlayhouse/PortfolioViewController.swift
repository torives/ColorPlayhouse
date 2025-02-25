//
//  PortfolioViewController.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class PortfolioViewController: UIViewController, UICollectionViewDelegate {

    var imageToPass: UIImage!
    var videoDataToPass: NSData!
    var recordIDToPass: String!
    var recordIDs = [String]()
    var savedImages = [UIImage]()
    var videoData = [NSData]()
    
    let DAO = DataAccessObject.sharedInstance
    var didFinishFetchingImages = false
    
    @IBOutlet weak var portfolioCollection: UICollectionView!
    @IBOutlet weak var noDrawings: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

		
        portfolioCollection.dataSource = self
        portfolioCollection.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		fetchData()
	}
    
    func fetchData() {
        DAO.fetchUserImages { (assets) in
            for asset in assets! {
                let recordID = asset.0
                let imageURL = asset.1.fileURL
                let videoURL = asset.2.fileURL
                let imageData = NSData(contentsOf: imageURL)
                let videoData = NSData(contentsOf: videoURL)
                
                self.recordIDs.append(recordID)
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
		
		guard	savedImages.indices.contains(indexPath.item),
				videoData.indices.contains(indexPath.item),
				recordIDs.indices.contains(indexPath.item)
		else { return }
		
		imageToPass = savedImages[indexPath.item]
        videoDataToPass = videoData[indexPath.item]
        recordIDToPass = recordIDs[indexPath.item]
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let detail = segue.destination as! PortfolioDetailViewController
            detail.selectedImage = imageToPass
            detail.videoData = videoDataToPass
            detail.recordID = recordIDToPass
        }
    }
}

//MARK: DataSource
extension PortfolioViewController: UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let defaults = UserDefaults.standard
        let numberOfArtwork = defaults.object(forKey: "numberOfArtwork") as! Int
        
        if numberOfArtwork > 0 { noDrawings.isHidden = true }
		else{ noDrawings.isHidden = false }
		
		return numberOfArtwork
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
