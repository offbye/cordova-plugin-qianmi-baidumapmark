/**
 * Created by lenny on 16/01/19.
 * 涉及要改名称 先不变
 */
var cordova = require('cordova');

var BaiduMapMark = function() {};

BaiduMapMark.prototype.location = function(success, error,addressInfo) {
    cordova.exec(success, error, 'BaiduMapMarkPlugin', 'location',[addressInfo,'com.qianmi.app.LbsAmap3DActivity']);
};

var baiduMapMark = new BaiduMapMark();
module.exports = baiduMapMark;
