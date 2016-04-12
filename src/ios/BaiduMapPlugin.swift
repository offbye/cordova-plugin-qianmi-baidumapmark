//
//  BaiduMapPlugin.swift
//  ionic-BaiduMap
//
//  Created by zxt on 2016/04/08.
//
//

import Foundation
import AudioToolbox
import WebKit

let TAG = "BaiduMapPlugin"

func log(message: String){
    NSLog("%@ - %@", TAG, message)
}

@available(iOS 8.0, *)
@objc(HWPBaiduMapPlugin) class BaiduMapPlugin : CDVPlugin {
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT

    func initialize(command: CDVInvokedUrlCommand) {
        log("BaiduMapPlugin initialization")
    }

    func location(command: CDVInvokedUrlCommand) {
        log("location")
        let message = command.arguments[0] as! String
        print(message)
        
        let point = convertStringToDictionary(message)
        print(convertStringToDictionary(message))
        
        var pointUser = PointUser()
        pointUser.storeName = point!["storeName"]!
        pointUser.pro = point!["pro"]!
        pointUser.city = point!["city"]!
        pointUser.dist = point!["dist"]!
        pointUser.address = point!["address"]!
        pointUser.latitude = Double(point!["latitude"]!)
        pointUser.longitude = Double(point!["longitude"]!)
        print(pointUser)
        
        let mapVc = BaiduMapViewController()
        mapVc.isAnon = true
        mapVc.pointUser = pointUser
        mapVc.callBackId = command.callbackId
        mapVc.baiduMapPlugin = self
        self.viewController?.presentViewController(mapVc, animated: true,completion: nil)
    }
    
    func convertStringToDictionary(text: String) -> [String:String]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:String]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}