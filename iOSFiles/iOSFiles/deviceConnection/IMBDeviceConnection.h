//
//  IMBDeviceConnection.h
//  iOSFiles
//
//  Created by iMobie on 18/1/16.
//  Copyright © 2018年 iMobie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MobileDeviceAccess.h"
#import "IMBAMDeviceInfo.h"


typedef enum DeviceConnectMode {
    WifiRecordDevice = 0,
    WifiConnectDevice = 1,
    WifiTwoModeDevice = 2,
}DeviceConnectModeEnum;

#pragma mark -- IMBBaseInfo  Class

@interface IMBBaseInfo : NSObject {
@private
    NSString *_uniqueKey;
    NSString *_deviceName;
    IPodFamilyEnum _connectType;
    NSString *_devIconName;
    NSMutableArray *_accountiCloud;
    BOOL _isLoaded;
    BOOL _isSelected;
    long long _allDeviceSize;//全部空间
    long long _kyDeviceSize;//可用空间
    int _batteryCapacity;
    
    BOOL *_isConnected;
    BOOL _isiPod;
    BOOL _isicloudView;
    BOOL _isAndroid;
    //用于WiFi记录设备
    NSNumber *_backupSize;
    NSNumber *_backupTime;
    DeviceConnectModeEnum _deviceConnectMode;//设备连接模式
    BOOL _isNowDisconnect;
    BOOL _isBackuping;//正在备份
    NSMutableArray *_backupRecordAryM;
}

@property (nonatomic, assign) int batteryCapacity;
@property (nonatomic, assign) BOOL isicloudView;
@property (nonatomic, assign) BOOL *isConnected;
@property (nonatomic, assign) long long kyDeviceSize;
@property (nonatomic, assign) long long allDeviceSize;
@property (nonatomic, retain) NSString *uniqueKey;
@property (nonatomic, readwrite, retain) NSString *deviceName;
@property (nonatomic, readwrite) IPodFamilyEnum connectType;
@property (nonatomic, readwrite, retain) NSString *devIconName;
@property (nonatomic, readwrite, retain) NSMutableArray *accountiCloud;
@property (nonatomic, readwrite) BOOL isLoaded;
@property (nonatomic, readwrite) BOOL isSelected;
@property (nonatomic, readwrite) BOOL isiPod;
@property (nonatomic, readwrite) BOOL isAndroid;
@property (nonatomic, readwrite) BOOL isNowDisconnect;
@property (nonatomic, readwrite) BOOL isBackuping;

@property (nonatomic, retain) NSNumber *backupSize;
@property (nonatomic, retain) NSNumber *backupTime;
@property (nonatomic, assign) DeviceConnectModeEnum deviceConnectMode;
@property (nonatomic, retain) NSMutableArray *backupRecordAryM;


@end

#pragma mark -- IMBDeviceConnection  Class

@class IMBiPod;
@interface IMBDeviceConnection : NSObject
{
    @private
    
}
/**
 *  监听设备连接状态
 */
@property(nonatomic, copy)void(^IMBDeviceConnected)(void);
@property(nonatomic, copy)void(^IMBDeviceDisconnected)(NSString *serialNum);
@property(nonatomic, copy)void(^IMBDeviceNeededPassword)(am_device device);
@property(nonatomic, copy)void(^IMBDeviceConnectedCompletion)(IMBiPod *iPod);


+ (instancetype)singleton;

/**
 *  开始监听和注销监听
 */
- (void)startListening;
- (void)stopListening;
/**
 *  重新链接设备
 *
 *  @param dev dev
 */
- (void)resConnectDevice:(am_device)dev;


@end