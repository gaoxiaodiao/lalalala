//
//  IMBDeviceConnection.m
//  iOSFiles
//
//  Created by iMobie on 18/1/16.
//  Copyright © 2018年 iMobie. All rights reserved.
//

#import "IMBDeviceConnection.h"
#import "IMBiPod.h"


#pragma mark -- IMBBaseInfo  Class
@implementation IMBBaseInfo

@synthesize kyDeviceSize = _kyDeviceSize;
@synthesize allDeviceSize = _allDeviceSize ;
@synthesize uniqueKey = _uniqueKey;
@synthesize deviceName = _deviceName;
@synthesize connectType = _connectType;
@synthesize devIconName = _devIconName;
@synthesize accountiCloud = _accountiCloud;
@synthesize isLoaded = _isLoaded;
@synthesize isSelected = _isSelected;
@synthesize isConnected = _isConnected;
@synthesize isicloudView = _isicloudView;
@synthesize isiPod = _isiPod;
@synthesize isAndroid = _isAndroid;

#pragma mark -- 初始化操作
- (id)init {
    self = [super init];
    if (self) {
        _isLoaded = NO;
        _isSelected = NO;
        _isiPod = NO;
        _isAndroid = NO;
        _deviceName = nil;
        _connectType = 0;
        _kyDeviceSize = 0;
        _accountiCloud = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)setIsConnected:(BOOL *)isConnected
{
    if (isConnected == NULL) {
        
    }else{
        _isConnected = isConnected;
    }
}

- (BOOL)isIsConnected
{
    return *_isConnected;
}

-(void)dealloc{
    [self setAccountiCloud:nil];
    [super dealloc];
}

@end

#pragma mark -- IMBDeviceConnection  Class
static id _instance = nil;

@interface IMBDeviceConnection()<NSCopying,MobileDeviceAccessListener>
{
    NSOperationQueue *_processingQueue;
    NSMutableArray *_serialArray;
    MobileDeviceAccess *_deviceAccess;
}
//@property(nonatomic, retain)MobileDeviceAccess *deviceAccess;

@end

@implementation IMBDeviceConnection

@synthesize allDevices = _allDevices;
@synthesize alliPods = _alliPods;


#pragma mark -- 单例实现
+ (instancetype)singleton {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[IMBDeviceConnection alloc] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}
/**
 *  销毁操作
 */
- (void)dealloc {
    
    [_serialArray release];
    _serialArray = nil;
    
    [_allDevices release];
    _allDevices = nil;
    
    [_alliPods release];
    _alliPods = nil;
    
    [_processingQueue release];
    _processingQueue = nil;
    
    [super dealloc];
}

#pragma mark --  初始化操作

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}
/**
 *  初始化操作
 */
- (void)setUp {
    _serialArray = [[NSMutableArray alloc] init];//这里尽量不要用[NSMutableArray array];这种方法进行创建，这种方法容易造成crash
    _allDevices = [[NSMutableArray alloc] init];
    _alliPods = [[NSMutableArray alloc] init];
    _deviceAccess = [MobileDeviceAccess singleton];
    _processingQueue = [[NSOperationQueue alloc] init];
    [_processingQueue setMaxConcurrentOperationCount:4];//设置并发数
}

- (BOOL)isConnectedDevice {
    if (_serialArray) {
        return _serialArray.count;
    }
    return NO;
}

/**
 *  开始监听
 */
- (void)startListening {
    [_deviceAccess setListener:self];
    
}
/**
 *  注销监听
 */
- (void)stopListening {
    [_deviceAccess stopListener];
    
}

#pragma mark --  通知方法


#pragma mark --  设备连接监听方法
/**
 *  设备成功连接
 *
 *  @param device 设备
 */
- (void)deviceConnected:(AMDevice *)device {
    IMBFFuncLog;
    [[IMBLogManager singleton] writeInfoLog:@"DeviceConnected Successfully"];
    if (device) {
        if (self.IMBDeviceConnected) {
            self.IMBDeviceConnected();
        }
        NSString *deviceSerialNumber = device.serialNumber;
        if (deviceSerialNumber) {
            [_serialArray addObject:deviceSerialNumber];
        }
        
        device.isValid = YES;
        [_processingQueue addOperationWithBlock:^(void){
            sleep(2.0f);
            if ([_serialArray containsObject:deviceSerialNumber]) {
                [self getDeviceInfoWithDevice:device];
            }
        }];
    }else {
        IMBFLog(@"preSerialNumber is nil");
    }
}
/**
 *  设备断开连接
 *
 *  @param device 设备
 */
- (void)deviceDisconnected:(AMDevice *)device {
    IMBFFuncLog;
    [[IMBLogManager singleton] writeInfoLog:@"DeviceDisConnected Successfully"];
    device.isValid = NO;
    NSString *serialNumber = [device serialNumber];
    
    //删除设备
    [self removeDeviceByKey:serialNumber];
    
    if ([_serialArray containsObject:serialNumber]) {
        [_serialArray removeObject:serialNumber];
    }
    
    if (_IMBDeviceDisconnected) {
        _IMBDeviceDisconnected(serialNumber);
    }
}
/**
 *  设备需要密码
 *
 *  @param device 设备
 */
- (void)deviceNeedPassword:(am_device)device {
    [[IMBLogManager singleton] writeInfoLog:@"DeviceNeededPassword"];
    IMBFFuncLog;
    
    if (self.IMBDeviceNeededPassword) {
        self.IMBDeviceNeededPassword(device);
    }
}

/**
 *  是否支持wifi连接
 *
 *  @return 设备
 */

- (BOOL)canSupportWifi {
    return NO;
}


- (void)getDeviceInfoWithDevice:(AMDevice *)dev {
//    IMBAMDeviceInfo *deviceInfo = [[[IMBAMDeviceInfo alloc] initWithDevice:dev] autorelease];
    IMBiPod *ipod = [[[IMBiPod alloc] initWithDevice:dev] autorelease];
    ipod.uniqueKey = dev.serialNumber;

    
    IMBBaseInfo *baseInfo =[[[IMBBaseInfo alloc] init] autorelease];
    [baseInfo setUniqueKey:ipod.uniqueKey];
    [baseInfo setDeviceName:ipod.deviceInfo.deviceName];
    [baseInfo setAllDeviceSize:ipod.deviceInfo.totalDiskCapacity];
    [baseInfo setKyDeviceSize:ipod.deviceInfo.totalDataAvailable];
    [baseInfo setIsLoaded:NO];
    if ([dev isKindOfClass:[AMDevice class]]) {
        [baseInfo setIsConnected:dev.isConnected];
    }
    [baseInfo setConnectType:ipod.deviceInfo.family];
    [baseInfo setIsiPod:YES];
    
    [_allDevices addObject:baseInfo];
    [_alliPods addObject:ipod];
    if (self.IMBDeviceConnectedCompletion) {
        self.IMBDeviceConnectedCompletion(baseInfo);
    }
}
/**
 *  重新连接设备
 *
 *  @param dev 设备
 */
- (void)reConnectDevice:(am_device)dev {
    [[MobileDeviceAccess singleton] connectDevice:dev];
}

#pragma mark -- 获取/删除设备
/**
 *  根据serialNum获取已连接设备
 *
 *  @param key serialNum
 *
 *  @return 基本设备信息
 */
- (IMBBaseInfo *)getDeviceByKey:(NSString *)key {
    if (key) {
        for (IMBBaseInfo *baseInfo in _allDevices) {
            if ([baseInfo.uniqueKey isEqualToString:key]) {
                return baseInfo;
            }
        }
    }
    return nil;
}
/**
 *  通过key获取iPod
 *
 *  @param key eky
 *
 *  @return iPod
 */
- (IMBiPod *)getiPodByKey:(NSString *)key {
    if (key) {
        for (IMBiPod *ipod in _alliPods) {
            if ([ipod.uniqueKey isEqualToString:key]) {
                return ipod;
            }
        }
    }
    return nil;
}
/**
 *  根据serialNum删除设备
 *
 *  @param key serialNum
 */
- (void)removeDeviceByKey:(NSString *)key {
    if (key) {
        IMBBaseInfo *baseInfo = [self getDeviceByKey:key];
        if (baseInfo) {
            [_allDevices removeObject:baseInfo];
        }
        IMBiPod *ipod = [self getiPodByKey:key];
        if (ipod) {
            [_alliPods removeObject:ipod];
        }
        
    }
}

#pragma mark --

@end
