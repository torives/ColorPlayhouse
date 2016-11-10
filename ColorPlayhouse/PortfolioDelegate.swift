//
//  PortfolioDelegate.swift
//  ColorPlayhouse
//
//  Created by Victor Yves Crispim on 11/5/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import Foundation

protocol PortfolioDelegate {
 
    func portfolioScreenDidLoad(screen: PortfolioScreen)
    func item(_ item: PortfolioItem, WasSelectedAtScreen screen: PortfolioScreen)
}
