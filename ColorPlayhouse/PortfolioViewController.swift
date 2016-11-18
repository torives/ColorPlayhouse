//
//  PortfolioViewController.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class PortfolioViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{
    var delegate: PortfolioDelegate?
    //var savedArts: [UIImage] = []
    var savedArts = [UIImage(named: "desenho1"), UIImage(named: "desenho2"), UIImage(named: "desenho3"), UIImage(named: "desenho4"), UIImage(named: "desenho5")]
    
    @IBOutlet weak var portfolioCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        portfolioCollection.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedArts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "portfolioCell", for: indexPath) as! PortfolioCell
        
        cell.image.image = self.savedArts[indexPath.row]
        
        return cell
    }
}

extension PortfolioViewController: PortfolioScreen
{
    func showItems(_ items: [PortfolioItem]){}
    func showTimelapse(_ item: TimelapseItem){}
    func showImage(_ image: ImageItem){}
}
