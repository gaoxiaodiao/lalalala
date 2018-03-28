//
//  IMBDownloadListViewController.h
//  AnyTrans
//
//  Created by LuoLei on 16-12-21.
//  Copyright (c) 2016年 imobie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IMBBackgroundBorderView.h"
#import "IMBBasedViewTableView.h"
#import "DownLoadView.h"
@class IMBCustomPopupButton;
#import "IMBBaseViewController.h"
@class VideoBaseInfoEntity;
#import "IMBTextButtonView.h"
#import "IMBGridientButton.h"
#import "IMBDriveBaseManage.h"
#import "IMBBorderRectAndColorView.h"
#import "IMBDownWhiteView.h"
#import "IMBiPod.h"
@interface IMBDownloadListViewController : NSViewController<NSTableViewDataSource,NSTableViewDelegate,NSTextViewDelegate>
{
    
    IBOutlet NSBox *_rootBox;
    IBOutlet IMBBorderRectAndColorView *mainBgView;
    IBOutlet IMBTextButtonView *_cleanList;
    IBOutlet IMBBasedViewTableView *_tableView;
    IBOutlet IMBBackgroundBorderView *_titleView;
    IBOutlet NSTextField *_titleTextField;
    NSMutableArray *_downloadDataSource;
    NSMutableArray *_uploadDataSource;
    NSOperationQueue *_operationQueue;
    IBOutlet NSBox *_contentBox;
    IBOutlet NSImageView *_nodataImageView;
    IBOutlet NSTextField *_noTipTextField;
    IBOutlet NSScrollView *_scrollView;
    IBOutlet NSView *_nodataView;
    
    IBOutlet NSView *_reslutSuperView;
    int successCount;
    
    int _tempCount;
@public
    DownLoadView *_rightUpDownbgView;
    IMBCustomPopupButton *_popUpButton;
    IMBDriveBaseManage *_deviceManager;
    IMBiPod *_iPod;
    int _downCount;
    int _upCount;
    NSString *_exportPath;
}
@property (nonatomic, retain)NSString *exportPath;
@property (nonatomic,retain)IMBiPod *iPod;
@property (nonatomic,retain)NSMutableArray *downloadDataSource;
@property (nonatomic,retain)IMBDriveBaseManage *deviceManager;
/**
 *  给进度赋值
 *  @param addDataSource  选择的数据 分为文件和文件夹
 *  @param isdown  是否是下载  yes 是下载  No是上传
 *  @param categoryNodesEnum device 不同数据的枚举   icloud 传 Category_Normal
 *  @param addDataSource  ipod  针对设备  icloud 传空
 *  @param isiCloudDrive  选择下载的是否是iCloudDrive  其他的都为No
 */
- (void)addDataSource:(NSMutableArray *)addDataSource withIsDown:(BOOL)isdown withCategoryNodesEnum:(CategoryNodesEnum)categoryNodesEnum withipod:(IMBiPod *)ipod withIsiCloudDrive:(BOOL) isiCloudDrive;




- (void)deviceAddDataSoure:(NSMutableArray *)addDataSource WithIsDown:(BOOL)isDown WithiPod:(IMBiPod *) ipod withCategoryNodesEnum:(CategoryNodesEnum)categoryNodesEnum;
- (void)dropBoxAddDataSource:(NSMutableArray *)addDataSource WithIsDown:(BOOL)isDown WithDriveBaseManage:(IMBDriveBaseManage *)driveBaseManage;
- (void)icloudDriveAddDataSource:(NSMutableArray *)addDataSource WithIsDown:(BOOL)isDown WithDriveBaseManage:(IMBDriveBaseManage *)driveBaseManage;

- (void)reloadData:(BOOL)isAdd;
- (void)reloadBgview;

- (void)switchUpDownViewAndDownView;
@end