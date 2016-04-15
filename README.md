
# cordova-plugin-qianmi-baidumapmark


    This plugin is meant to implement BaiduMap GeoPoint mark feature for iOS.
    This plugin defines a global `BaiduMapMark` object.

    百度地图标注插件，支持在iOS百度地图页面显示点，重新选择点，并支持反向查询地址。确定后把地址回传，包括省市区，街道地址，经纬度等。

    首先需要有百度LBS云的帐号，并创建好iOS项目，获得访问应用（AK）

## Installation

    cordova plugin add cordova-plugin-qianmi-baidumapmark

### iOS Quirks

Add BaiduMap SDK initialize code in AppDelegate.m.

```

#import "AppDelegate.h"
#import "MainViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

BMKMapManager* _mapManager;
@implementation AppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"YOUR BAIDUMAP KEY" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }

    self.viewController = [[MainViewController alloc] init];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
```

You should register a account in http://lbsyun.baidu.com/ first, add create a iOS app in Baidu lbsyun.


## Supported Methods

The plugin support following methods of the `BaiduMapMark` object:


- `BaiduMapMark.location`
- geoPoint define

```
["city": "南京市", "address": "紫荆花路66", "dist": "雨花台区", "longitude": "118.785057565569", "latitude": "31.9948367148358", "storeName": "兼容测试01", "pro": "江苏省"]
```
