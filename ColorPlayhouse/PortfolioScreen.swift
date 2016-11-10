//
//  PortfolioScreen.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

protocol PortfolioScreen {
    
    var delegate: PortfolioDelegate? {get set}

    //TODO: Data Types
    func showItems(_ items: [PortfolioItem])
    func showTimelapse(_ item: TimelapseItem)
    func showImage(_ image: ImageItem)
}
