//
//  PortfolioDetailViewController.swift
//  ColorPlayhouse
//
//  Created by Priscila Rosa on 11/28/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import UIKit

class PortfolioDetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var share: UIButton!
    
    @IBAction func playClick(_ sender: AnyObject) {
    }
    @IBAction func shareClick(_ sender: AnyObject) {
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
