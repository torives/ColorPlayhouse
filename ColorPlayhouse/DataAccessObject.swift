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
                defaults.set(0, forKey: "numberOfArtwork")
            }
        }
    }
    
    func saveAssetsToUser(image: UIImage, videoURL: URL, andHandleWith handler: @escaping (Bool)->Void) {
        let asset = CKRecord(recordType: "Asset")
        
        let defaults = UserDefaults.standard
        let userID = defaults.object(forKey: "userID") as! String
        
        asset["user"] = CKReference(recordID:CKRecordID(recordName: userID), action: CKReferenceAction.deleteSelf)
        asset["type"] = "image" as CKRecordValue
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.cachesDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if paths.count > 0 {
            let writePath = NSURL(fileURLWithPath: paths[0]).appendingPathComponent("FinalImage.png")
            
            do {
                try! UIImagePNGRepresentation(image)?.write(to: writePath!, options: Data.WritingOptions.atomic)
            }
            
            let imageFile : CKAsset?  = CKAsset(fileURL: writePath!)
            asset["image"] = imageFile
            
        }
        
        let videoFile : CKAsset?  = CKAsset(fileURL: videoURL)
        asset["video"] = videoFile
        
        self.publicDatabase.save(asset) {
            record, error in
            if error != nil {
                print(error?.localizedDescription)
                handler(false)
            } else {
                print("successfully saved asset")
                handler(true)
            }
        }
    }
    
    func fetchUserImages(andHandleWith handler: @escaping (([(String, CKAsset, CKAsset)]?)->Void)) {
        let defaults = UserDefaults.standard
        let userID = defaults.object(forKey: "userID") as! String
        
        let userReference = CKReference(recordID: CKRecordID(recordName: userID), action: CKReferenceAction.deleteSelf)
        let predicate = NSPredicate(format: "user == %@", userReference)
        let assetsQuery = CKQuery(recordType: "Asset", predicate: predicate)
        
        self.publicDatabase.perform(assetsQuery, inZoneWith: nil) { (records, error) in
            if error == nil {
                var assets = [(String, CKAsset, CKAsset)]()
                for record in records! {
                    assets.append(record.recordID.recordName, record.object(forKey: "image") as! CKAsset, record.object(forKey: "video") as! CKAsset)
                }
                handler(assets)
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    func deleteRecord(WithID id: String, andHandleWith handler: @escaping ((Bool)->Void)) {
        let recordID = CKRecordID(recordName: id)
        self.publicDatabase.delete(withRecordID: recordID) { (recordID, error) in
            if error == nil {
                print("success deleting record")
                handler(true)
            } else {
                handler(false)
            }
        }
        //let assetsQuery = CKQuery(recordType: "Asset", predicate: predicate)

        
    }
}
