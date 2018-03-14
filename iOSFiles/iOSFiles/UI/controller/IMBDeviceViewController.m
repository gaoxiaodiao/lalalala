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
#import "IMBInformation.h"
#import "IMBInformationManager.h"
#import "IMBCommonDefine.h"
#import "DateHelper.h"
#import "StringHelper.h"
#import "IMBDriveEntity.h"
#import "IMBDriveManage.h"
#import "StringHelper.h"
#import "IMBDriveWindow.h"
#import "IMBAppsListViewController.h"
#import "IMBViewAnimation.h"


#import "IMBDropBoxManage.h"
#import <Quartz/Quartz.h>



static CGFloat const SelectedBtnTextFont = 15.0f;


@interface IMBDeviceViewController ()
{
    @private
    NSMutableArray *_devicesArray;
    IMBMainWindowController *_mainWindowController;
}

@end

@implementation IMBDeviceViewController

#pragma mark -
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
    _isSecureMode = YES;
    _isCheckBoxSelected = NO;
    [(IMBBackgroundBorderView*)self.view setHasRadius:YES];
    [(IMBBackgroundBorderView*)self.view setBackgroundColor:COLOR_MAIN_WINDOW_BG];
    _windowControllerDic = [[NSMutableDictionary alloc] init];
    _driveControllerDic = [[NSMutableDictionary alloc] init];
}

/**
 *  初始化
 */
- (void)setupView {
    
    [icloudLoginbtn WithMouseExitedtextColor:[NSColor whiteColor] WithMouseUptextColor:[NSColor whiteColor] WithMouseDowntextColor:IMBGrayColor(240) withMouseEnteredtextColor:IMBGrayColor(245)];
    [icloudLoginbtn WithMouseExitedfillColor:COLOR_BTN_BLUE_BG WithMouseUpfillColor:[COLOR_BTN_BLUE_BG colorWithAlphaComponent:0.8] WithMouseDownfillColor:[COLOR_BTN_BLUE_BG colorWithAlphaComponent:0.7] withMouseEnteredfillColor:[COLOR_BTN_BLUE_BG colorWithAlphaComponent:0.8]];
    [icloudLoginbtn setTitleName:@"Login Now" WithDarwRoundRect:4.f WithLineWidth:0 withFont:[NSFont systemFontOfSize:14.f]];
    
    
    [dropboxLoginBtn WithMouseExitedtextColor:[NSColor whiteColor] WithMouseUptextColor:[NSColor whiteColor] WithMouseDowntextColor:IMBGrayColor(240) withMouseEnteredtextColor:IMBGrayColor(245)];
    [dropboxLoginBtn WithMouseExitedfillColor:COLOR_BTN_BLUE_BG WithMouseUpfillColor:[COLOR_BTN_BLUE_BG colorWithAlphaComponent:0.8] WithMouseDownfillColor:[COLOR_BTN_BLUE_BG colorWithAlphaComponent:0.7] withMouseEnteredfillColor:[COLOR_BTN_BLUE_BG colorWithAlphaComponent:0.8]];
    [dropboxLoginBtn setTitleName:@"Login Now" WithDarwRoundRect:4.f WithLineWidth:0 withFont:[NSFont systemFontOfSize:14.f]];
    
    [_devicesView setIsDevicesOriginalFrame:YES];
    [_loginTextField setTextColor:COLOR_TEXT_ORDINARY];
    [((customTextFieldCell *)_loginTextField.cell) setCursorColor:COLOR_TEXT_ORDINARY];
    
    NSMutableAttributedString *as5 = [[[NSMutableAttributedString alloc] initWithString:@"User"] autorelease];
    [as5 addAttribute:NSForegroundColorAttributeName value:COLOR_MAIN_WINDOW_TEXTFIELD_TEXT range:NSMakeRange(0, as5.string.length)];
    [as5 setAlignment:NSLeftTextAlignment range:NSMakeRange(0, as5.string.length)];
    [as5 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range:NSMakeRange(0, as5.string.length)];
    [_loginTextField.cell setPlaceholderAttributedString:as5];
    
    [_iCloudUserTextField setTextColor:COLOR_TEXT_ORDINARY];
    [((customTextFieldCell *)_iCloudUserTextField.cell) setCursorColor:COLOR_TEXT_ORDINARY];
    
    NSMutableAttributedString *as6 = [[[NSMutableAttributedString alloc] initWithString:@"iCloud ID"] autorelease];
    [as6 addAttribute:NSForegroundColorAttributeName value:COLOR_MAIN_WINDOW_TEXTFIELD_TEXT range:NSMakeRange(0, as6.string.length)];
    [as6 setAlignment:NSLeftTextAlignment range:NSMakeRange(0, as6.string.length)];
    [as6 addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica Neue" size:13] range:NSMakeRange(0, as6.string.length)];
    [_iCloudUserTextField.cell setPlaceholderAttributedString:as6];

//    [_selectedDeviceBtn configButtonName:@"No Device Connected" WithTextColor:IMBGrayColor(51) WithTextSize:12.0f WithIsShowIcon:YES WithIsShowTrangle:NO WithIsDisable:YES withConnectType:0];
    [(IMBSecureTextFieldCell *)_passTextField.cell setDelegate:self];
    [((IMBSecureTextFieldCell *)_passTextField.cell) setCursorColor:COLOR_TEXT_ORDINARY];
    
    [(IMBSecureTextFieldCell *)_iCloudSecireTextField.cell setDelegate:self];
    [((IMBSecureTextFieldCell *)_iCloudSecireTextField.cell) setCursorColor:COLOR_TEXT_ORDINARY];
    
    [_icloudDrivebox setContentView:_midiumSizeiCloudView];
    [_oneDriveBox setContentView:_midiumSizeOneDriveView];
    [_devicesBox setContentView:_midiumSizeDevicesView];
    
    
    _iCloudDriveView.isOriginalFrame = YES;
    _oneDriveView.isOriginalFrame = YES;
    _devicesView.isOriginalFrame = YES;
    
    /***  界面上的三个view的鼠标点击响应事件 ***/
    /***  _iCloudDriveView的鼠标点击响应事件 ***/
    _iCloudDriveView.mouseClicked = ^(void){
        [self setShadowHidden:YES];
        [_icloudDrivebox setContentView:_bigSizeiCloudView];
        
        NSRect cloudF = NSMakeRect(12.f, 85.f, 302.f, 306.f);
        NSRect oneDriveF = NSMakeRect(12.f, 15.f, 302.f, 54.f);
        NSRect devicesF = NSMakeRect(327.f, 15.f, 253.f, 376.f);
        
        NSArray *views = @[_iCloudDriveView,_oneDriveView,_devicesView];
        NSArray *frames = @[[NSValue valueWithRect:cloudF],[NSValue valueWithRect:oneDriveF],[NSValue valueWithRect:devicesF]];
        [IMBViewAnimation animationWithViews:views frames:frames completion:^{
            [self setOriginalFrame:NO];
            _devicesView.isDevicesOriginalFrame = YES;
            
            [_smallSizeTitle setStringValue:@"DropBox"];
            [_oneDriveBox setContentView:_smallSizeView];
            if ([[IMBDeviceConnection singleton] isConnectedDevice]) {
                [_bigDevicesImageView setImage:[NSImage imageNamed:@"symbols-phone.png"]];
            }else {
                [_bigDevicesImageView setImage:[NSImage imageNamed:@"phone001"]];
            }
        }];
    };
    /***  _oneDriveView的鼠标点击响应事件 ***/
    _oneDriveView.mouseClicked = ^(void){
        [self setShadowHidden:YES];
        [_oneDriveBox setContentView:_bigSizeOneDriveView];
        
        NSRect cloudF = NSMakeRect(12.f, 337.f, 302.f, 54.f);
        NSRect oneDriveF = NSMakeRect(12.f, 15.f, 302.f, 306.f);
        NSRect devicesF = NSMakeRect(327.f, 15.f, 253.f, 376.f);
        
        NSArray *views = @[_iCloudDriveView,_oneDriveView,_devicesView];
        NSArray *frames = @[[NSValue valueWithRect:cloudF],[NSValue valueWithRect:oneDriveF],[NSValue valueWithRect:devicesF]];
        [IMBViewAnimation animationWithViews:views frames:frames completion:^{
            [self setOriginalFrame:NO];
            _devicesView.isDevicesOriginalFrame = YES;
            
            [_smallSizeTitle setStringValue:@"iCloud"];
            [_icloudDrivebox setContentView:_smallSizeView];
            if ([[IMBDeviceConnection singleton] isConnectedDevice]) {
                [_bigDevicesImageView setImage:[NSImage imageNamed:@"symbols-phone.png"]];
            }else {
                [_bigDevicesImageView setImage:[NSImage imageNamed:@"phone001"]];
            }
        }];
    };
    /***  _devicesView的鼠标点击响应事件 ***/
    _devicesView.mouseClicked = ^(void){
        [self setShadowHidden:YES];
        NSRect cloudF = NSMakeRect(12.f, 211.f, 134.f, 180.f);
        NSRect oneDriveF = NSMakeRect(12.f, 15.f, 134.f, 180.f);
        NSRect devicesF = NSMakeRect(162.0f, 15.0f, 418.f, 376.f);
        
        NSArray *views = @[_iCloudDriveView,_oneDriveView,_devicesView];
        NSArray *frames = @[[NSValue valueWithRect:cloudF],[NSValue valueWithRect:oneDriveF],[NSValue valueWithRect:devicesF]];
        [IMBViewAnimation animationWithViews:views frames:frames completion:^{
            [self setOriginalFrame:NO];
            _devicesView.isDevicesOriginalFrame = NO;
            
            [_icloudDrivebox setContentView:_smalliCloudDriveView];
            [_oneDriveBox setContentView:_smallOneDriveView];
            if ([[IMBDeviceConnection singleton] isConnectedDevice]) {
                [_bigDevicesImageView setImage:[NSImage imageNamed:@"symbols-phone.png"]];
            }else {
                [_bigDevicesImageView setImage:[NSImage imageNamed:@"symbols-no-device"]];
            }
            
            
        }];
    };
    
    /***  鼠标进出view响应事件 ***/
    /***  鼠标进入view响应事件 ***/
    _iCloudDriveView.mouseEntered = ^(void){
        NSRect newFrame = NSMakeRect(9.0f, 207.0f, 308.0f, 188.0f);
        [IMBViewAnimation animationScaleWithView:_icloudShadowView frame:newFrame timeInterval:MidiumSizeAnimationTimeInterval + 0.15f completion:nil];
        [self setMouseEnteredMidiumContentViewWithView:_midiumiCloudContentView btn:_midiumiCloudClickLoginBtn];
    };
    _oneDriveView.mouseEntered = ^(void){
        NSRect newFrame = NSMakeRect(9.0f, 11.0f, 308.0f, 188.0f);
        [IMBViewAnimation animationScaleWithView:_dropboxShadowView frame:newFrame timeInterval:MidiumSizeAnimationTimeInterval + 0.15f completion:nil];
        [self setMouseEnteredMidiumContentViewWithView:_midiumDropBoxContentView btn:_midiumDropBoxClickLoginBtn];
    };
    _devicesView.mouseEntered = ^(void){
        NSRect newFrame = NSMakeRect(323.5f, 11.0f, 260.0f, 384.0f);
        [IMBViewAnimation animationScaleWithView:_devicesShadowView frame:newFrame timeInterval:MidiumSizeAnimationTimeInterval + 0.15f completion:nil];
    };
    
    /***  鼠标移除view响应事件 ***/
    _iCloudDriveView.mouseExited = ^(void){
        _icloudShadowView.frame = NSMakeRect(12.0f, 211.0f, 302.0f, 180.0f);
        [self setMouseExitedMidiumContentViewWithView:_midiumiCloudContentView btn:_midiumiCloudClickLoginBtn];
    };
    _oneDriveView.mouseExited = ^(void){
        _dropboxShadowView.frame = NSMakeRect(12.0f, 15.0f, 302.0f, 180.0f);
        [self setMouseExitedMidiumContentViewWithView:_midiumDropBoxContentView btn:_midiumDropBoxClickLoginBtn];
    };
    _devicesView.mouseExited = ^(void){
        _devicesShadowView.frame = NSMakeRect(327.0f, 15.0f, 253.0f, 376.0f);
    };
    
}

- (void)setOriginalFrame:(BOOL)isOriginalFrame {
    _iCloudDriveView.isOriginalFrame = isOriginalFrame;
    _oneDriveView.isOriginalFrame = isOriginalFrame;
    _devicesView.isOriginalFrame = isOriginalFrame;
}

- (void)setShadowHidden:(BOOL)hidden {
    [_icloudShadowView setHidden:hidden];
    [_dropboxShadowView setHidden:hidden];
    [_devicesShadowView setHidden:hidden];
}

- (void)setMouseEnteredMidiumContentViewWithView:(NSView *)view btn:(NSView *)btn {
    NSRect f = view.frame;
    f.origin.y = 18;
    [IMBViewAnimation animationWithView:view frame:f timeInterval:MidiumSizeAnimationTimeInterval completion:nil];
    
    [btn setHidden:NO];
    NSRect btnF = btn.frame;
    [IMBViewAnimation animationMouseMovedWithView:btn frame:btnF timeInterval:MidiumSizeAnimationTimeInterval completion:^{
        
    }];
}
- (void)setMouseExitedMidiumContentViewWithView:(NSView *)view btn:(NSView *)btn {
    NSRect f = view.frame;
    f.origin.y = 0;
    [IMBViewAnimation animationWithView:view frame:f timeInterval:MidiumSizeAnimationTimeInterval - 0.2f completion:nil];
    
    
    NSRect btnF = btn.frame;
    [IMBViewAnimation animationMouseMovedWithView:btn frame:btnF timeInterval:MidiumSizeAnimationTimeInterval - 0.2f completion:^{
        [btn setHidden:YES];
    }];
}


- (void)mouseDown:(NSEvent *)theEvent {
    [self setShadowHidden:NO];
    _icloudShadowView.frame = NSMakeRect(12.0f, 211.0f, 302.0f, 180.0f);
    _dropboxShadowView.frame = NSMakeRect(12.0f, 15.0f, 302.0f, 180.0f);
    _devicesShadowView.frame = NSMakeRect(327.0f, 15.0f, 253.0f, 376.0f);
    
    NSRect cloudF = NSMakeRect(12.f, 211.f, 302.f, 180.f);
    NSRect oneDriveF = NSMakeRect(12.f, 15.f, 302.f, 180.f);
    NSRect devicesF = NSMakeRect(327.f, 15.f, 253.f, 376.f);
    
    
    NSArray *views = @[_iCloudDriveView,_oneDriveView,_devicesView];
    NSArray *frames = @[[NSValue valueWithRect:cloudF],[NSValue valueWithRect:oneDriveF],[NSValue valueWithRect:devicesF]];
    [IMBViewAnimation animationWithViews:views frames:frames completion:^{
        _iCloudDriveView.isOriginalFrame = YES;
        _oneDriveView.isOriginalFrame = YES;
        _devicesView.isOriginalFrame = YES;
        
        [_oneDriveBox setContentView:_midiumSizeOneDriveView];
        [_icloudDrivebox setContentView:_midiumSizeiCloudView];
        [self setMouseExitedMidiumContentViewWithView:_midiumDropBoxContentView btn:_midiumDropBoxClickLoginBtn];
    }];
//    [self setMouseExitedMidiumContentViewWithView:_midiumiCloudContentView btn:_midiumiCloudClickLoginBtn];
//    [self setMouseExitedMidiumContentViewWithView:_midiumDropBoxContentView btn:_midiumDropBoxClickLoginBtn];
}

/**
 *  添加通知
 */
- (void)addNotis {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedDeviceDidChangeNoti:) name:IMBSelectedDeviceDidChangeNotiWithParams object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertTabKey:) name:INSERT_TAB object:nil];
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
            [_selectedDeviceBtn configButtonName:baseInfo.deviceName WithTextColor:COLOR_MAIN_WINDOW_SELECTEDBTN_TEXT WithTextSize:SelectedBtnTextFont WithIsShowIcon:YES WithIsShowTrangle:YES WithIsDisable:NO withConnectType:baseInfo.connectType];
            [self setDeviceInfosWithiPod:baseInfo];
            [self deviceDisconnected:serialNum];
        }else {
            [_selectedDeviceBtn setHidden:YES];
            [_selectedDeviceBtn configButtonName:@"No Device Connected" WithTextColor:COLOR_MAIN_WINDOW_SELECTEDBTN_TEXT WithTextSize:SelectedBtnTextFont WithIsShowIcon:YES WithIsShowTrangle:NO WithIsDisable:YES withConnectType:0];
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
        
        IMBInformation *information = [[IMBInformation alloc] initWithiPod:[[deviceConnection getiPodByKey:baseInfo.uniqueKey] retain]];
        _iPod = [deviceConnection getiPodByKey:baseInfo.uniqueKey];
        IMBInformationManager *manager = [IMBInformationManager shareInstance];
        [manager.informationDic setObject:information forKey:baseInfo.uniqueKey];
        [self setDeviceInfosWithiPod:baseInfo];
    };
}

#pragma mark -
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
    if (_devicesView.isDevicesOriginalFrame) {
        [_bigDevicesImageView setImage:[NSImage imageNamed:@"phone001.png"]];
    }else {
        [_bigDevicesImageView setImage:[NSImage imageNamed:@"symbols-no-device"]];
    }
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
        [_selectedDeviceBtn setHidden:NO];
        [_selectedDeviceBtn configButtonName:baseInfo.deviceName WithTextColor:COLOR_MAIN_WINDOW_SELECTEDBTN_TEXT WithTextSize:SelectedBtnTextFont WithIsShowIcon:YES WithIsShowTrangle:YES WithIsDisable:NO withConnectType:baseInfo.connectType];
        [_bigDevicesImageView setImage:[NSImage imageNamed:@"symbols-phone.png"]];
    });
}

#pragma mark -- action

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
        _devPopover.behavior = 0;
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

- (IBAction)oneDriveLogin:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_ENTER_SIGNIN object:nil userInfo:nil];
    [self signDown:sender];
}

- (IBAction)enterTextView:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_ENTER_SIGNIN object:nil userInfo:nil];
    [self iCloudLogIn:sender];
}


- (IBAction)checkoutPwdClicked:(NSButton *)sender {
    if (_isSecureMode) {
        _isSecureMode = NO;
        [_iCloudSecireTextField setHidden:YES];
      
        _icloudLoginPwdTextfield.stringValue = _iCloudSecireTextField.stringValue;
        [_icloudLoginPwdTextfield becomeFirstResponder];
    }else {
        _isSecureMode = YES;
        _iCloudSecireTextField.stringValue = _icloudLoginPwdTextfield.stringValue;
        [_iCloudSecireTextField setHidden:NO];
        [_iCloudSecireTextField becomeFirstResponder];
        
    }
}
- (IBAction)checkBoxClicked:(NSButton *)sender {
    _isCheckBoxSelected = !_isCheckBoxSelected;
}

#pragma mark -
#pragma mark -- Dropbox Login
- (void)signDown:(id)sender{
    [_loginTextField.cell setEnabled:NO];
    [_passTextField.cell setEnabled:NO];
    NSString *loginTextId = [@"imobie@yahoo.com" stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    if ([loginTextId isEqualToString: @""]){
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
//        return;
//    }else{
//        if (_driveManage != nil) {
            if ([_baseDriveManage.userID isEqualToString:loginTextId]) {
                if ([_driveControllerDic.allKeys containsObject:_baseDriveManage.userID]) {
                    IMBDriveWindow *driveWindow = [_driveControllerDic objectForKey:_baseDriveManage.userID];
                    [driveWindow showWindow:self];
                }
            }else{
                _baseDriveManage = [[IMBDropBoxManage alloc]initWithUserID:loginTextId withDelegate:self];
            }
//        }else{
//            _driveManage = [[IMBDriveManage alloc]initWithUserID:loginTextId withDelegate:self];
//        }
//    }
    [_loginTextField.cell setEnabled:YES];
    [_passTextField.cell setEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
}

- (void)switchViewController {
    if ([_driveControllerDic.allKeys containsObject:_baseDriveManage.userID]) {
        IMBDriveWindow *driveWindow = [_driveControllerDic objectForKey:_baseDriveManage.userID];
        [driveWindow showWindow:self];
    }else{
        IMBDriveWindow *driveWindow = [[IMBDriveWindow alloc]initWithDrivemanage:(IMBDriveManage *)_baseDriveManage withisiCloudDrive:NO];
        [_driveControllerDic setObject:driveWindow forKey:_baseDriveManage.userID];
        //    IMBDevicePageWindow *devicePagewindow = [[IMBDevicePageWindow alloc] initWithiPod:ipod];
        [[driveWindow window] center];
        [driveWindow showWindow:self];
        [driveWindow release];
    }
}

#pragma mark -- One Diver Login

//- (void)signDown:(id)sender{
//    [_loginTextField.cell setEnabled:NO];
//    [_passTextField.cell setEnabled:NO];
//    NSString *loginTextId = [_loginTextField.stringValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
////    if ([loginTextId isEqualToString: @""]){
////        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
////        return;
////    }else{
////        if (_driveManage != nil) {
//            if ([_baseDriveManage.userID isEqualToString:loginTextId]) {
//                if ([_driveControllerDic.allKeys containsObject:_baseDriveManage.userID]) {
//                    IMBDriveWindow *driveWindow = [_driveControllerDic objectForKey:_baseDriveManage.userID];
//                    [driveWindow showWindow:self];
//                }
//            }else{
//                _baseDriveManage = [[IMBDriveManage alloc]initWithUserID:loginTextId withDelegate:self];
//            }
////        }else{
////            _driveManage = [[IMBDriveManage alloc]initWithUserID:loginTextId withDelegate:self];
////        }
////    }
//    [_loginTextField.cell setEnabled:YES];
//    [_passTextField.cell setEnabled:YES];
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ICLOUD_SIGNIN_FAIL object:nil userInfo:nil];
//}
//
//- (void)switchViewController {
//    if ([_driveControllerDic.allKeys containsObject:_baseDriveManage.userID]) {
//        IMBDriveWindow *driveWindow = [_driveControllerDic objectForKey:_baseDriveManage.userID];
//        [driveWindow showWindow:self];
//    }else{
//        IMBDriveWindow *driveWindow = [[IMBDriveWindow alloc]initWithDrivemanage:(IMBDriveManage *)_baseDriveManage withisiCloudDrive:NO];
//        [_driveControllerDic setObject:driveWindow forKey:_baseDriveManage.userID];
//        //    IMBDevicePageWindow *devicePagewindow = [[IMBDevicePageWindow alloc] initWithiPod:ipod];
//        [[driveWindow window] center];
//        [driveWindow showWindow:self];
//        [driveWindow release];
//    }
//}

#pragma mark -- iCloud Diver Login

- (IBAction)iCloudLogIn:(id)sender {

    if (_isCheckBoxSelected && _iCloudUserTextField.stringValue.length) {
        //当checkbox选中并且用户名有值的情况下，存储用户名
        [[NSUserDefaults standardUserDefaults] setValue:_iCloudUserTextField.stringValue forKey:IMBiCloudUserName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self addLoginLoadingAnimation];
    _baseDriveManage = [[IMBiCloudDriveManager alloc]initWithUserID:_iCloudUserTextField.stringValue WithPassID:_iCloudSecireTextField.stringValue WithDelegate:self];
}
//登录错误
- (void)driveLogInFial:(ResponseCode)responseCode {
    if (responseCode == ResponseUserNameOrPasswordError) {//密码或者账号错误
        [self removeLoginLoadingAnimation];
    }else if (responseCode == ResonseSecurityCodeError) {//<沿验证码错误
        [self removeLoginLoadingAnimation];
    }else if (responseCode == ResponseUnknown) {//未知错误
        [self removeLoginLoadingAnimation];
    }else if (responseCode == ResponseInvalid) {///<响应无效 一般参数错误
        [self removeLoginLoadingAnimation];
    }
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Error"];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    
}

- (void)driveNeedSecurityCode:(iCloudDrive *)iCloudDrive {
    [self removeLoginLoadingAnimation];
}

- (IBAction)codeDown:(id)sender {
    [(IMBiCloudDriveManager *)_baseDriveManage  setTwoCodeID:_twoCode.stringValue];
}

//时间转换
- (NSString *)dateForm2001DateSting:(NSString *) dateSting {
    if ([StringHelper stringIsNilOrEmpty:dateSting] ) {
        return @"";
    }
    NSString *replacString = [dateSting stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    NSString * replacString1 = [replacString substringToIndex:19];
    NSDate *replacDate = [DateHelper dateFromString:replacString1 Formate:nil];
    NSString *replacDateString = [DateHelper dateFrom2001ToDate:replacDate withMode:2];
    return replacDateString;
}

- (void)switchiCloudDriveViewController {
    [self removeLoginLoadingAnimation];
//    if ([_driveControllerDic.allKeys containsObject:_driveManage.userID]) {
//        IMBDriveWindow *driveWindow = [_driveControllerDic objectForKey:_driveManage.userID];
//        [driveWindow showWindow:self];
//    }else{
    IMBDriveWindow *driveWindow = [[IMBDriveWindow alloc]initWithDrivemanage:_baseDriveManage withisiCloudDrive:YES];
    [_driveControllerDic setObject:driveWindow forKey:_baseDriveManage.userID];
        //    IMBDevicePageWindow *devicePagewindow = [[IMBDevicePageWindow alloc] initWithiPod:ipod];
    [[driveWindow window] center];
    [driveWindow showWindow:self];
    [driveWindow release];
    IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc] init];
    IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
    [baseInfo setDeviceName:_iCloudDrive.userName];
    [baseInfo setUniqueKey:_iCloudUserTextField.stringValue];
    [baseInfo setConnectType:general_iCloud];
    [baseInfo setIsicloudView:YES];
    [[connection allDevices] addObject:baseInfo];
    [baseInfo release];
    baseInfo = nil;
//    }
}
#pragma mark -
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

- (void)insertTabKey:(id)sender {
    [_passTextField becomeFirstResponder];
    if (_isSecureMode) {
        [_iCloudSecireTextField becomeFirstResponder];
    }else{
        [_icloudLoginPwdTextfield becomeFirstResponder];
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
    
    if (_driveControllerDic) {
        [_driveControllerDic release];
        _driveControllerDic = nil;
    }

    if (_baseDriveManage) {
        [_baseDriveManage release];
        _baseDriveManage = nil;
    }

    [[IMBDeviceConnection singleton] stopListening];
    //移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMBSelectedDeviceDidChangeNotiWithParams object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:INSERT_TAB object:nil];
    [super dealloc];
}

#pragma mark -

#pragma mark - 其他
#pragma mark - 加载动画的添加和移除
- (void)addLoginLoadingAnimation {
    [icloudLoginbtn setEnabled:NO];
    _loadLayer = [CALayer layer];
    _loadLayer.contents = [NSImage imageNamed:@"other_sending"];
    [_checkoutPwdBtn setHidden:YES];
    [_loadLayer setFrame:NSMakeRect(_checkoutPwdBtn.frame.origin.x, _checkoutPwdBtn.frame.origin.y, 12, 12)];
    [_icloudCustomView setWantsLayer:YES];
    [[_icloudCustomView layer] addSublayer:_loadLayer];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(2*M_PI);
    animation.toValue = 0;
    animation.repeatCount = MAXFLOAT;
    animation.duration = 1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    //    [_loadingImg setWantsLayer:YES];
    [_loadLayer addAnimation:animation forKey:@""];
}

- (void)removeLoginLoadingAnimation {
    if (_loadLayer) {
        [_loadLayer removeFromSuperlayer];
    }
    [icloudLoginbtn setEnabled:YES];
    [_checkoutPwdBtn setHidden:NO];
}

@end
