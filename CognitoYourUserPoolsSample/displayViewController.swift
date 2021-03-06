//
//  DisplayViewController.swift
//  CognitoYourUserPoolsSample
//
//  Created by 何幸宇 on 10/31/17.
//  Copyright © 2017 Dubal, Rohan. All rights reserved.
//

import UIKit
import AWSCore
import AWSCognito
import AWSDynamoDB
import AWSCognitoIdentityProvider

class DisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return pastMessages!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessengeTableViewCell") as? MessengeTableViewCell{
            let text = Array(pastMessages!.values)[indexPath.row]
            let time = Array(pastMessages!.keys)[indexPath.row]
            cell.updateCell(text: text, time: time)
            return cell
        }else{
            return MessengeTableViewCell()
        }
    }
    
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var MessengeTableView: UITableView!
    var user : AWSCognitoIdentityUser?
    var response : AWSCognitoIdentityUserGetDetailsResponse?
    var pool : AWSCognitoIdentityUserPool?
    var pastMessages : [String:String]?

    
    @IBAction func SignOutTapped(_ sender: UIButton){
            self.user?.signOut()
            self.title = nil
}
    
    @IBAction func downloadBtnTapped(_ sender: UIButton) {
        s3download(bucketName: "hamex-storage", fileKey: "horse.jpg") { (url) in
            if let url = url as? URL{
                self.Image.image = UIImage(contentsOfFile: url.path)
            }
        }
        
        DDBRead { (message) in
            print(message._text!)
            print("this is read_DDB")
        }
        
        DDBQuery { (message) in
            print(message._text!)
            print("this is query_DDB")
        }
        
    }
    
    @IBAction func uploadBtnTapped(_ sender: UIButton){
        let url = URL(fileURLWithPath: <#T##String#>)
        s3upload(url: url, bucketName: <#T##String#>, fileKey: <#T##String#>)
    }
    
    @IBAction func SendBtnTapped(_ sender: UIButton){
        let time = DateFormatter.localizedString(from: .init(), dateStyle: .short, timeStyle: .short)
        //S3
//        if let textInput = textInput.text{
//        dataset?.setString(textInput, forKey:time)
//            dataset?.synchronize().continueWith(block: { (task) -> Any? in
//                if task.error != nil{
//                }
//                    return nil
//            })
//        }else{return}
//        textInput.text = ""
//        pastMessages = dataset?.getAll()
        
        //DynamoDB
        
        
        DDBSave(date: "11/5/17, 2:59 AM", text: textInput.text!, userId: "userInfor[]!") {
            return
        }
    
        MessengeTableView.reloadData()
}
    
    
   
    
    var dataset : AWSCognitoDataset?
    override func viewDidLoad() {
        super.viewDidLoad()
        MessengeTableView.dataSource = self
        MessengeTableView.delegate = self
        let syncClient = AWSCognito.default()
         dataset = syncClient.openOrCreateDataset("myDataset")
         pastMessages = dataset?.getAll()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        self.user = self.pool?.currentUser()
        getUserInfo(user: self.user!)
    }
}
