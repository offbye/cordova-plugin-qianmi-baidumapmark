/**
 * Created by lenny on 16/01/19.
 * 涉及要改名称 先不变
 */
var cordova = require('cordova');

var BaiduMap = function() {};

BaiduMap.prototype.location = function(success, error,addressInfo) {
    cordova.exec(success, error, 'BaiduMapPlugin', 'location',[addressInfo,'com.qianmi.app.LbsAmap3DActivity']);
};

var baiduMap = new BaiduMap();
module.exports = baiduMap;
