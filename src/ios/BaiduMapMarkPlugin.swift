//
//  BaiduMapMarkPlugin.swift
//  cordova-BaiduMapMarkPlugin
//
//  Created by zxt on 2016/04/08.
//
//

import Foundation
import WebKit

let TAG = "BaiduMapMarkPlugin"

func log(message: String){
    NSLog("%@ - %@", TAG, message)
}

@available(iOS 8.0, *)
@objc(HWPBaiduMapMarkPlugin) class BaiduMapMarkPlugin : CDVPlugin {
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT

    func initialize(command: CDVInvokedUrlCommand) {
        log("BaiduMapPlugin initialization")
    }

    func location(command: CDVInvokedUrlCommand) {
        log("location")
        var pointUser = PointUser()
        if command.arguments != nil && command.arguments.count > 0 {
            let geoInfo = command.arguments[0] as! String
            print(geoInfo)
            let point = convertStringToDictionary(geoInfo)
            print(convertStringToDictionary(geoInfo))

            pointUser.storeName = point!["storeName"]!
            pointUser.pro = point!["pro"]!
            pointUser.city = point!["city"]!
            pointUser.dist = point!["dist"]!
            pointUser.address = point!["address"]!
            pointUser.latitude = Double(point!["latitude"]!)
            pointUser.longitude = Double(point!["longitude"]!)
            print(pointUser)
        }
        
        let mapVc = BaiduMapViewController()
        mapVc.isAnon = true
        mapVc.pointUser = pointUser
        mapVc.callBackId = command.callbackId
        mapVc.baiduMapMarkPlugin = self
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