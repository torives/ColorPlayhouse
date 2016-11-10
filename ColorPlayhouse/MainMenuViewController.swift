//
//  MainMenuViewController.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/8/16.
//  Copyright © 2016 Priscila Rosa. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController
{
    var router: MainMenuRouter?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        router?.passDataToNextScene(segue)
    }
}
