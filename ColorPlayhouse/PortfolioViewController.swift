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
    //var savedArts: [UIImage] = []
    var savedArts = [UIImage(named: "desenho1"), UIImage(named: "desenho2"), UIImage(named: "desenho3"), UIImage(named: "desenho4"), UIImage(named: "desenho5")]
    var savedImages = [UIImage]()
    
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
                let url = asset.fileURL
                let imageData = NSData(contentsOf: url)
                self.savedImages.append(UIImage(data: imageData as! Data)!)
            }
            self.didFinishFetchingImages = true
            self.portfolioCollection.reloadData()
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
        return numberOfArtwork
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "portfolioCell", for: indexPath) as! PortfolioCell
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.4
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.shadowRadius = 20
        
        if didFinishFetchingImages {
            cell.imageView.setImage(image: self.savedImages[indexPath.row])
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
