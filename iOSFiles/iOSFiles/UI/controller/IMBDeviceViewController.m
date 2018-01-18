//
//  IMBDeviceViewController.m
//  AnyTrans
//
//  Created by LuoLei on 16-7-13.
//  Copyright (c) 2016年 imobie. All rights reserved.
//

#import "IMBDeviceViewController.h"
#import "IMBDisconnectViewController.h"
#import "IMBDeviceConnection.h"
#import "IMBDeviceInfo.h"
#import "IMBiPod.h"

#import "TestDeviceInfoController.h"


@interface IMBDeviceViewController ()

{
    @private
    IMBDisconnectViewController *_disConnectController;
    NSMutableArray *_devicesArray;
    
}

@end

@implementation IMBDeviceViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

/**
 * 初始化操作
 */
- (void)awakeFromNib {
    [self setupView];
    [self deviceConnection];
    
}

- (void)setupView {
    _disConnectController = [[IMBDisconnectViewController alloc]initWithNibName:@"IMBDisconnectViewController" bundle:nil];
    [_deviceBox addSubview:_disConnectController.view];
    
    
}

- (void)deviceConnection {
    
    IMBDeviceConnection *deviceConnection = [IMBDeviceConnection singleton];
    [deviceConnection startListening];
    
//    __block typeof(self) weakSelf = self;
    deviceConnection.IMBDeviceConnected = ^{
        //设备连接成功
        [self deviceConnected];
    };
    deviceConnection.IMBDeviceDisconnected = ^(NSString *serialNum){
        //设备断开连接
        [self deviceDisconnected:serialNum];
    };
    deviceConnection.IMBDeviceNeededPassword = ^(am_device device){
        //设备连接需要密码
        [self deviceNeededPwd:device];
    };
    deviceConnection.IMBDeviceConnectedCompletion = ^(IMBiPod *iPod) {
        //加载设备信息完成,ipod中含有设备详细信息
        IMBDeviceInfo *deviceInfo = [iPod.deviceInfo retain];
        _disConnectController.promptTF.stringValue = [NSString stringWithFormat:@"Device Name:%@\nSerial Num:%@\nDevice Class:%@\nProduct Type:%@\nProduct Version:%@\nPhone Num:%@",deviceInfo.deviceName,deviceInfo.serialNumber,deviceInfo.deviceClass,deviceInfo.productType,deviceInfo.productVersion,deviceInfo.phoneNumber];
        
//        IMBDeviceInfo *deviceInfo = [iPod.deviceInfo retain];
        IMBFLog(@"");
        
//        TestDeviceInfoController *infoController = [[TestDeviceInfoController alloc] init];
//        infoController.view.frame = _disConnectController.cusContentView.bounds;
//        
//        infoController.ipod = iPod;
//        [_disConnectController.cusContentView addSubview:infoController.view];
//        [infoController release];
//        infoController = nil;
        
    };
}

- (void)dealloc {
    [_disConnectController release];
    _disConnectController = nil;
    [[IMBDeviceConnection singleton] stopListening];
    
    [super dealloc];
}

#pragma mark -- 设备连接状态
/**
 *  设备连接成功
 */
- (void)deviceConnected {
    _disConnectController.promptTF.stringValue = @"Connected";
}
/**
 *  设备断开连接
 */
- (void)deviceDisconnected:(NSString *)serialNum {
    [[IMBLogManager singleton] writeInfoLog:@"Disonneted"];
    _disConnectController.promptTF.stringValue = @"Please plug-in your iPhone,iPad or iPod, Start your journey";
    
}
/**
 *  设备连接需要密码
 */
- (void)deviceNeededPwd:(am_device)device {
    [[IMBLogManager singleton] writeInfoLog:@"Connetion Needs Password"];
    _disConnectController.promptTF.stringValue = @"Device Needs Password";
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Device Needs Password" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Make sure you give access to us"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 1) {
            IMBFLog(@"111111111");
            //点击确定，重新链接设备
            [[IMBDeviceConnection singleton] performSelector:@selector(resConnectDevice:) withObject:(id)device afterDelay:1.0f];
        }
    }];
}


@end