//
//  IMBDeviceViewController.m
//  AnyTrans
//
//  Created by LuoLei on 16-7-13.
//  Copyright (c) 2016年 imobie. All rights reserved.
//

#import "IMBDeviceViewController.h"
#import "IMBDeviceConnection.h"
#import "IMBDeviceInfo.h"
#import "IMBiPod.h"
#import "IMBMainWindowController.h"
#import "IMBBackgroundBorderView.h"
#import "IMBDevViewController.h"
#import "IMBDevicePageWindow.h"
#import "NSString+Category.h"


@interface IMBDeviceViewController ()
{
    @private
    NSMutableArray *_devicesArray;
    IMBMainWindowController *_mainWindowController;
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
    [self addNotis];
    [(IMBBackgroundBorderView*)self.view setHasRadius:YES];
    [(IMBBackgroundBorderView*)self.view setBackgroundColor:[NSColor whiteColor]];
    _windowControllerDic = [[NSMutableDictionary alloc]init];
}

/**
 *  初始化
 */
- (void)setupView {
    [_selectedDeviceBtn configButtonName:@"No Device Connected" WithTextColor:IMBGrayColor(51) WithTextSize:12.0f WithIsShowIcon:YES WithIsShowTrangle:NO WithIsDisable:YES withConnectType:0];
}

/**
 *  添加通知
 */
- (void)addNotis {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedDeviceDidChangeNoti:) name:IMBSelectedDeviceDidChangeNotiWithParams object:nil];
}
/**
 *  设备连接监听以及相应的监听方法
 */
- (void)deviceConnection {
    IMBDeviceConnection *deviceConnection = [IMBDeviceConnection singleton];
    [deviceConnection startListening];
    
    deviceConnection.IMBDeviceConnected = ^{
        //设备连接成功
        [self deviceConnectedWithConnection:deviceConnection];
    };
    deviceConnection.IMBDeviceDisconnected = ^(NSString *serialNum){
        //设备断开连接
        
        if (deviceConnection.allDevices.count) {
            IMBBaseInfo *baseInfo = [deviceConnection.allDevices firstObject];
            [_selectedDeviceBtn configButtonName:baseInfo.deviceName WithTextColor:IMBGrayColor(51) WithTextSize:12.0f WithIsShowIcon:YES WithIsShowTrangle:YES WithIsDisable:NO withConnectType:baseInfo.connectType];
//            IMBiPod *ipod = [deviceConnection getiPodByKey:baseInfo.uniqueKey];
            [self setDeviceInfosWithiPod:baseInfo];
            [self deviceDisconnected:serialNum];
        }else {
            [_selectedDeviceBtn configButtonName:@"No Device Connected" WithTextColor:IMBGrayColor(51) WithTextSize:12.0f WithIsShowIcon:YES WithIsShowTrangle:NO WithIsDisable:YES withConnectType:0];
            [self deviceDisconnected:serialNum];
        }
    };
    deviceConnection.IMBDeviceNeededPassword = ^(am_device device){
        //设备连接需要密码
        if (deviceConnection.allDevices.count == 0) {
//            _disConnectController.promptTF.stringValue = @"Device Needs Password";
//            [self emptyDeviceInfo];
        }
        [self deviceNeededPwd:device];
    };
    deviceConnection.IMBDeviceConnectedCompletion = ^(IMBBaseInfo *baseInfo) {
        //加载设备信息完成,ipod中含有设备详细信息
        [self setDeviceInfosWithiPod:baseInfo];
    };
}

#pragma mark -- 设备连接状态
- (void)deviceConnectedWithConnection:(IMBDeviceConnection *)connection {
//    if (connection.allDevices.count) {
//        _disConnectController.promptTF.stringValue = @"Connecting another device";
//    }else {
//        _disConnectController.promptTF.stringValue = @"Connecting";
//    }
    
    
//    [self emptyDeviceInfo];
}

- (void)deviceDisconnected:(NSString *)serialNum {
    [[IMBLogManager singleton] writeInfoLog:@"Disconneted"];
    if (_windowControllerDic.count >0) {
        IMBDevicePageWindow *devicePageWindow = [_windowControllerDic objectForKey:serialNum];
        [devicePageWindow.window close];
//        [devicePageWindow release];
//        devicePageWindow = nil;
        [_windowControllerDic removeObjectForKey:serialNum];
    }
    if (_devPopover != nil) {
        if (_devPopover.isShown) {
            [_devPopover close];
        }
    }
}

- (void)deviceNeededPwd:(am_device)device {
    [[IMBLogManager singleton] writeInfoLog:@"Connetion Needs Password"];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Device Needs Password" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Make sure you give access to us"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 1) {
            IMBFLog(@"clicked OK button");
            //点击确定，重新链接设备
            [[IMBDeviceConnection singleton] performSelector:@selector(reConnectDevice:) withObject:(id)device afterDelay:1.0f];
        }
    }];
}

/**
 *  设置显示设备信息
 *
 *  @param iPod iPod
 */
- (void)setDeviceInfosWithiPod:(IMBBaseInfo *)baseInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
         [_selectedDeviceBtn configButtonName:baseInfo.deviceName WithTextColor:IMBGrayColor(51) WithTextSize:12.0f WithIsShowIcon:YES WithIsShowTrangle:YES WithIsDisable:NO withConnectType:baseInfo.connectType];
    });
}

/**
 *  设备选择按钮点击
 *
 *  @param sender 按钮
 */
- (IBAction)selectedDeviceBtnClicked:(IMBSelecedDeviceBtn *)sender {
    IMBFFuncLog;
    
    IMBDeviceConnection *deviceConnection = [IMBDeviceConnection singleton];
    if (!_selectedDeviceBtn.isDisable) {
        if (_devPopover != nil) {
            if (_devPopover.isShown) {
                [_devPopover close];
                return;
            }
        }
        if (_devPopover != nil) {
            [_devPopover release];
            _devPopover = nil;
        }
        _devPopover = [[NSPopover alloc] init];
        
        if ([[self getSystemLastNumberString] isVersionMajorEqual:@"10"]) {
            _devPopover.appearance = (NSPopoverAppearance)[NSAppearance appearanceNamed:NSAppearanceNameAqua];
        }else {
            _devPopover.appearance = NSPopoverAppearanceMinimal;
        }
    
        _devPopover.animates = YES;
        _devPopover.behavior = NSPopoverBehaviorTransient;
        _devPopover.delegate = self;
        
        IMBDevViewController *devController = [[IMBDevViewController alloc] initWithNibName:@"IMBDevViewController" bundle:nil];
        CGFloat w = 300.0f;
        CGFloat h = 50.0f*deviceConnection.allDevices.count;
        h = h > 200.0f ? 200.0f : h;
        
        devController.view.frame = NSMakeRect(0, 0, w, h);
        
        NSMutableArray *allDevices = [[NSMutableArray alloc] init];
        
        if (deviceConnection.allDevices.count) {
            for (IMBBaseInfo *baseInfo in deviceConnection.allDevices) {
                [allDevices addObject:baseInfo];
            }
            if (_devPopover != nil) {
                _devPopover.contentViewController = devController;
            }
            devController.devices = allDevices;
            NSRectEdge prefEdge = NSMaxYEdge;
            NSRect rect = NSMakeRect(sender.bounds.origin.x, sender.bounds.origin.y, sender.bounds.size.width, sender.bounds.size.height);
            [_devPopover showRelativeToRect:rect ofView:sender preferredEdge:prefEdge];
        }
    }
}

#pragma mark -- 通知
/**
 *  设备选择切换响应方法
 *
 *  @param noti noti
 */
- (void)selectedDeviceDidChangeNoti:(NSNotification *)noti {
    IMBBaseInfo *baseInfo = [noti object];
    
    if (_devPopover.isShown) {
        [_devPopover close];
    }
    [self setDeviceInfosWithiPod:baseInfo];
    IMBDeviceConnection *deviceConnection = [IMBDeviceConnection singleton];
    IMBiPod *ipod = [deviceConnection getiPodByKey:baseInfo.uniqueKey];
    
    if (!baseInfo.isSelected) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            baseInfo.isSelected = YES;
            IMBDevicePageWindow *devicePagewindow = [[IMBDevicePageWindow alloc] initWithiPod:ipod];
            [[devicePagewindow window] center];
            [devicePagewindow showWindow:self];
            [_windowControllerDic setObject:devicePagewindow forKey:ipod.uniqueKey];
            [devicePagewindow release];
            devicePagewindow = nil;
        });
    }else{
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            IMBDevicePageWindow *devicePagewindow = [_windowControllerDic objectForKey:ipod.uniqueKey];
            [[devicePagewindow window] center];
            [devicePagewindow showWindow:self];
        });
    }
}

- (NSString*)getSystemLastNumberString {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *systemVersion = processInfo.operatingSystemVersionString;
    NSArray *array = [systemVersion componentsSeparatedByString:@"."];
    NSString *lastStr = @"0";
    if (array.count >= 2) {
        lastStr = [array objectAtIndex:1];
    }
    return lastStr;
}

- (void)mainWindowClose{
    if (_windowControllerDic.count > 0) {
        for (NSWindowController * chooseWindow in _windowControllerDic.allValues) {
            [chooseWindow.window close];
        }
    }
}

- (void)dealloc {
    
    [_mainWindowController release];
    _mainWindowController = nil;
    
    [_windowControllerDic release];
    _windowControllerDic = nil;
    
    if (_devPopover) {
        [_devPopover release];
        _devPopover = nil;
    }
    
    [[IMBDeviceConnection singleton] stopListening];
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMBSelectedDeviceDidChangeNotiWithParams object:nil];
    [super dealloc];
}


@end