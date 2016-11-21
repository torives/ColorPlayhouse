//
//  DataAccessObject.swift
//  ColorPlayhouse
//
//  Created by Bruna Aleixo on 11/11/16.
//  Copyright © 2016 Aleixo Rosa & Crispim. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

struct DataAccessObject {
    private init() {}
    
    static let sharedInstance = DataAccessObject()
    
    let publicDatabase = CKContainer(identifier: "iCloud.com.bpy.ColorPlayhouse").publicCloudDatabase
    
    func createUser() {
        let userRecord = CKRecord(recordType: "Users")
        
        publicDatabase.save(userRecord) {
            record, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print("\n\nuser \(userRecord.recordID.recordName) successfully saved\n\n")
                
                let defaults = UserDefaults.standard
                defaults.set(userRecord.recordID.recordName, forKey: "userID")
            }
        }
    }
    
    func saveImageToUser(path: String) {
        let asset = CKRecord(recordType: "Asset")
        
        let defaults = UserDefaults.standard
        let userID = defaults.object(forKey: "userID") as! String
        
        asset["user"] = CKReference(recordID:CKRecordID(recordName: userID), action: CKReferenceAction.deleteSelf)
        
        let writePath = NSURL(fileURLWithPath: path)
        
        let File : CKAsset?  = CKAsset(fileURL: writePath as URL)
        asset["asset"] = File
        
        self.publicDatabase.save(asset) {
            record, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print("successfully saved asset")
            }
        }
    }
    
    func fetchUserImages(andHandleWith handler: @escaping (([CKAsset]?)->Void)) {
        let defaults = UserDefaults.standard
        let userID = defaults.object(forKey: "userID") as! String
        
        let userReference = CKReference(recordID: CKRecordID(recordName: userID), action: CKReferenceAction.deleteSelf)
        let predicate = NSPredicate(format: "user == %@", userReference)
        let assetsQuery = CKQuery(recordType: "Asset", predicate: predicate)
        
        self.publicDatabase.perform(assetsQuery, inZoneWith: nil) { (records, error) in
            if error == nil {
                var assets = [CKAsset]()
                for record in records! {
                    assets.append(record.object(forKey: "asset") as! CKAsset)
                }
                handler(assets)
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
}
