/**
 * Created by zxt on 16/04/13.
 * BaiduMapMark
 */
var cordova = require('cordova');

var BaiduMapMark = function() {};

BaiduMapMark.prototype.location = function(success, error,addressInfo) {
    cordova.exec(success, error, 'BaiduMapMarkPlugin', 'location',[addressInfo,'com.qianmi.app.LbsAmap3DActivity']);
};

var baiduMapMark = new BaiduMapMark();
module.exports = baiduMapMark;
