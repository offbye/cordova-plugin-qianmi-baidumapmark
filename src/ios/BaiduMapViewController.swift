//
//  BaiduMapViewController.swift
//  云小店
//
//  Created by 张西涛 on 16/4/11.
//
//

import UIKit
struct PointUser{
    var storeName:String?
    var pro:String?
    var city:String?
    var dist:String?
    
    var longitude:Double?
    
    /**
     * 地图坐标点-纬度
     */
    var latitude:Double?
        
    var address: String?
  
    func toJson() -> String {
        let json = "{\"storeName\":\"\(storeName!)\", \"pro\":\"\(pro!)\", \"city\":\"\(city!)\", \"dist\":\"\(dist!)\", \"longitude\":\"\(longitude!)\", \"latitude\":\"\(latitude!)\", \"address\":\"\(address!)\"}"
        return json
    }
}

class BaiduMapViewController: UIViewController, BMKMapViewDelegate, BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate {
    let bundlePath = NSBundle.mainBundle().pathForResource("baidumapmark", ofType: "bundle")
    var myBundle: NSBundle?
    var remarkImage : UIImage!
    var markImage : UIImage!

    var baiduMapPlugin: BaiduMapPlugin?
    var callBackId : String?
    /// 百度地图视图
    var mapView: BMKMapView!
    /// 定位服务
    var locationService: BMKLocationService!
    /// 当前用户位置
    var userLocation: BMKUserLocation!
    var geocodeSearch: BMKGeoCodeSearch!

    var pointUsers:[PointUser]=[]
    
    //第一次是否加载完成
    var isFirstLoding : Bool!
    
    var anon: BMKPointAnnotation!
    var pointUser: PointUser!
    /**
     * 地图坐标点-经度纬度
     */
    var longitude:Double?
    var latitude:Double?
    //联想查询地址定位
    //是否需要标注
    //是否为预览没事
    var isSuggest: Bool! = false
    var isAnon: Bool! = false
    var isPerview: Bool! = false
    
    
    var zoomOut: UIButton!
    var zoomIn: UIButton!
    var locButton: UIButton!
    
    var bottomView: UIView! = nil
    var address: UITextField!
    var markBtn: UIButton!

    func locMe(sender: AnyObject) {
        locationService.startUserLocationService()
    }
    
    func zoomOut(sender: AnyObject) {
        mapView.zoomIn();
    }
    
    func zoomIn(sender: AnyObject) {
        mapView.zoomOut();
    }
    
    func shadow(let obj: UIView) -> Void{
        obj.layer.shadowOffset = CGSizeMake(0, 1.5);
        obj.layer.shadowOpacity = 0.20
    }
    
    
    //添加网点标注信息
    func addOverlay(title: String! ,description: String! ,coordinator: CLLocationCoordinate2D) -> Void {
        let pointAnnotation = BMKPointAnnotation();
        //let coordinator = CLLocationCoordinate2DMake(39.915, 116.404)
        pointAnnotation.coordinate = coordinator
        pointAnnotation.title = title
        pointAnnotation.subtitle = description
        mapView.addAnnotation(pointAnnotation)
        NSLog("\(title) \(description) \(coordinator)")
    }
    
    // 在地图将要启动定位时，会调用此函数
    func willStartLocatingUser() {
        NSLog("start Location !")
    }
    // 在地图将要停止定位时，会调用此函数
    func didStopLocatingUser() {
        NSLog("close Location !")
    }
    
    // 定位失败的话，会调用此函数
    func didFailToLocateUserWithError(error: NSError!) {
        NSLog("location failure！\(error)")
    }
    
    
    //网点标注
    func mark(sender: AnyObject) {
        
        self.pointUser.latitude = self.latitude!
        self.pointUser.longitude = self.longitude!
        //self.pointUser.address = self.address.text!

        markBtn.setBackgroundImage(markImage, forState: .Normal)
        
        let alertVC = UIAlertController(title: "", message: "当前位置是\(self.pointUser.pro! + self.pointUser.city! + self.pointUser.dist! +  self.address.text!),确定标注吗?" , preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "确定", style: .Default){
            (action: UIAlertAction!) -> Void in
            print("you choose save")
            self.pointUser.address = self.address.text!
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: self.pointUser.toJson())
            print(pluginResult.message)
            self.baiduMapPlugin!.commandDelegate!.sendPluginResult(pluginResult, callbackId: self.callBackId!)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)

        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)

        self.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     *点中底图标注后会回调此接口
     *@param mapview 地图View
     *@param mapPoi 标注点信息
     */
    func mapView(mapView: BMKMapView!, onClickedMapPoi mapPoi: BMKMapPoi!) -> Void{
        if isPerview! {
            return
        }
        mapView.removeAnnotations(mapView.annotations)
        addOverlay(mapPoi.text,description: mapPoi.text,coordinator: mapPoi.pt)
        print("您点击了地图标注\(mapPoi.text)，当前经纬度:(\(mapPoi.pt.longitude),\(mapPoi.pt.latitude))，缩放级别:\(mapView.zoomLevel)，旋转角度:\(mapView.rotation)，俯视角度:\(mapView.overlooking)")
        self.latitude = mapPoi.pt.latitude
        self.longitude = mapPoi.pt.longitude
        address.text = mapPoi.text
        reverseGeo(mapPoi.pt.latitude, mapPoi.pt.longitude)
    }
    
    // 用户位置更新后，会调用此函数
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        mapView.updateLocationData(userLocation)
        mapView.centerCoordinate = userLocation.location.coordinate
        self.userLocation = userLocation
        let lat = userLocation.location.coordinate.latitude
        let lon = userLocation.location.coordinate.longitude
        
        print("目前位置：\(lat), \(lon)")
        reverseGeo(lat,lon)
        locationService.stopUserLocationService()
    }
    
    func reverseGeo(latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        print("reverseGeo \(latitude), \(longitude)")
        let reverseGeocodeSearchOption = BMKReverseGeoCodeOption()
        reverseGeocodeSearchOption.reverseGeoPoint = CLLocationCoordinate2DMake(latitude,longitude)
        let flag = geocodeSearch.reverseGeoCode(reverseGeocodeSearchOption)
        if flag {
            print("反geo 检索发送成功")
        } else {
            print("反geo 检索发送失败")
        }
    }
    
    //返回反地理编码搜索结果
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetReverseGeoCodeResult error: \(error)")
        
        if error == BMK_SEARCH_NO_ERROR {
            print(result.address)
            self.pointUser.address = result.addressDetail.streetName + result.addressDetail.streetNumber
            self.address.text = self.pointUser.address
            print(self.pointUser.address)
            self.pointUser.pro = result.addressDetail.province
            self.pointUser.city = result.addressDetail.city
            self.pointUser.dist = result.addressDetail.district
        }
    }    
    
    // 界面加载
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO 建议在在AppDelegate.m中初始化百度BMKMapManager
//        let baiduAk = "your key"
//        let mapManager = BMKMapManager()
//        // 如果要关注网络及授权验证事件，请设定generalDelegate参数
//        let ret = mapManager.start(baiduAk, generalDelegate: nil)
//        print("viewDidLoad \(ret)")
        myBundle = NSBundle(path: bundlePath!)

        remarkImage = UIImage(named: "images/dtbz_btn_remark.png", inBundle: myBundle, compatibleWithTraitCollection: nil)
        markImage = UIImage(named: "images/dtbz_btn_mark.png", inBundle: myBundle, compatibleWithTraitCollection: nil)
        
        initViews()
        locationService = BMKLocationService()
        geocodeSearch = BMKGeoCodeSearch()

        // 设置定位精确度，默认：kCLLocationAccuracyBest
        locationService.desiredAccuracy = kCLLocationAccuracyBest
//        //指定最小距离更新(米)，默认：kCLDistanceFilterNone
        locationService.distanceFilter = 10.0
//                locationService.startUserLocationService()
        
        if self.pointUser != nil && self.pointUser.latitude != nil {
            self.latitude = self.pointUser.latitude
        }
        if self.pointUser != nil && self.pointUser.longitude != nil {
            self.longitude = self.pointUser.longitude
            self.address.text = self.pointUser.address
        }
        
        if nil != self.longitude && self.longitude > 0 {
            self.markBtn.setBackgroundImage(markImage, forState: .Normal)
        }
        
        
        let pt: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointUser.latitude!,pointUser.longitude!)
        if isAnon! {
            addOverlay(pointUser.storeName, description: pointUser.address, coordinator: pt)
            mapView.setCenterCoordinate(pt, animated: true)
        }

        // NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(locMe(_:)), userInfo: nil, repeats: false)
        shadow(locButton)
        shadow(zoomOut)
        shadow(zoomIn)
        shadow(bottomView)
        
        isFirstLoding = false
        print("viewDidLoad")
    }
    
    
    // MARK: - 协议代理设置
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        mapView.viewWillAppear()
        mapView.delegate = self  // 此处记得不用的时候需要置nil，否则影响内存的释放
        locationService.delegate = self
        geocodeSearch.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        mapView.viewWillDisappear()
        mapView.delegate = nil  // 不用时，置nil
        locationService.delegate = nil
        geocodeSearch.delegate = nil
    }
    
    // MARK: - 内存管理
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print("didReceiveMemoryWarning")
    }
    
    func initViews(){
        mapView = BMKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        
        self.view?.addSubview(mapView!)
        
        let closeButton = UIButton(frame: CGRectMake(10, 22 , 20, 20))
        closeButton.setBackgroundImage(UIImage(named: "images/nav_back.png", inBundle: myBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        closeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        closeButton.addTarget(self, action:#selector(self.back(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        self.view?.addSubview(closeButton)
        
        
        let iconSize = CGFloat(40)
        locButton = UIButton(frame: CGRectMake(10, self.view.frame.height - 110 , iconSize, iconSize))
        //locButton.setTitle("定位", forState: .Normal)
        locButton.setBackgroundImage(remarkImage, forState: UIControlState.Normal)
        locButton.layer.cornerRadius = 8
        locButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        locButton.addTarget(self, action:#selector(self.locMe(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        self.view?.addSubview(locButton)
        
        zoomOut = UIButton(frame: CGRectMake(self.view.frame.width - 50, self.view.frame.height - 150, iconSize, iconSize))
        //zoomOut.setTitle("放大", forState: .Normal)
        zoomOut.setBackgroundImage(UIImage(named: "images/dtbz_btn_zoom_out.png", inBundle: myBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        zoomOut.layer.cornerRadius = 8
        zoomOut.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        zoomOut.addTarget(self, action:#selector(self.zoomOut(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        self.view?.addSubview(zoomOut)
        
        zoomIn = UIButton(frame: CGRectMake(self.view.frame.width - 50, self.view.frame.height - 110, iconSize, iconSize))
        //zoomIn.setTitle("缩小", forState: .Normal)
        zoomIn.setBackgroundImage(UIImage(named: "images/dtbz_btn_zoom_in.png", inBundle: myBundle, compatibleWithTraitCollection: nil), forState: UIControlState.Normal)
        zoomIn.layer.cornerRadius = 8
        zoomIn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        zoomIn.addTarget(self, action:#selector(self.zoomIn(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        self.view?.addSubview(zoomIn)
        
        let markImage = UIImageView(image: UIImage(named: "images/dtbz_icon_location.png", inBundle: myBundle, compatibleWithTraitCollection: nil))
        markImage.frame = CGRectMake(5, 15, 21, 21)

        bottomView = UIView(frame: CGRectMake(20, self.view.frame.height - 60, self.view.frame.width - 40, 50))
        bottomView.backgroundColor = UIColor.whiteColor()
        bottomView.alpha = 0.8
        
        address = UITextField(frame: CGRectMake(40, 10, self.view.frame.width - 200, 32))
    
        markBtn = UIButton(frame: CGRectMake(self.view.frame.width - 140, 10, 80, 32))
        //markBtn.setTitle("确定标注", forState: .Normal)
        //markBtn.backgroundColor = UIColor.blueColor()
        
        markBtn.layer.cornerRadius = 5
        markBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        markBtn.addTarget(self, action:#selector(self.mark(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        bottomView.addSubview(markImage)
        bottomView.addSubview(address)
        bottomView.addSubview(markBtn)
        self.view?.addSubview(bottomView)
    }
}
