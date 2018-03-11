//
//  ScadaViewController.swift
//  CoreML in ARKit
//
//  Created by YouYue on 10/3/18.
//  Copyright © 2018 CompanyName. All rights reserved.
//

import UIKit
import CRNetworkButton
import Alamofire

class ScadaViewController: UIViewController {

    @IBAction func submitClicked(_ sender: CRNetworkButton) {
        guard !sender.isSelected else {
            if sender.currState == .finished {
                sender.resetToReady()
                sender.isSelected = false
            }
            return
        }
        
        sender.isSelected = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2*NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            sender.stopAnimate()
        }
        Alamofire.request("http://192.168.3.58:3000/task4", method: .get)
            .responseJSON { response in
                debugPrint(response)
//                SVProgressHUD.dismiss()
            }
    }
    @IBAction func connectBtnTapped(_ sender: CRNetworkButton) {
        guard !sender.isSelected else {
            if sender.currState == .finished {
                sender.resetToReady()
                sender.isSelected = false
            }
            return
        }
        
        sender.isSelected = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2*NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
            sender.stopAnimate()
        }
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
