//
//  IMBBaseViewController.m
//  AnyTrans
//
//  Created by LuoLei on 16-7-13.
//  Copyright (c) 2016年 imobie. All rights reserved.
//

#import "IMBBaseViewController.h"
#import "IMBBlankDraggableCollectionView.h"
#import "IMBAirSyncImportTransfer.h"
#import "IMBExportSetting.h"
#import "IMBSMSChatDataEntity.h"
#import "IMBDeviceMainPageViewController.h"
#import "IMBAnimation.h"
#import "IMBCustomHeaderCell.h"
#import "IMBRecordingEntry.h"
#import "IMBCalendarEventEntity.h"
#import "IMBSafariHistoryEntity.h"
#import "IMBDevicePlaylistsViewController.h"
#import "IMBDeleteTrack.h"
#import "IMBNotificationDefine.h"
#import "IMBMyAlbumsViewController.h"
#import "IMBFileSystem.h"
#import "IMBBookEntity.h"
#import "IMBSyncBookPlistBuilder.h"
#import "IMBDeleteApps.h"
#import "IMBCategoryInfoModel.h"
#import "IMBPhotosCollectionViewController.h"
#import "IMBPhotosListViewController.h"
#import "IMBToDevicePopoverViewController.h"
#import "ToDeviceViewItem.h"
#import "SystemHelper.h"
#import "IMBDeleteCameraRollPhotos.h"
#import "IMBiCloudMainPageViewController.h"
#import "ContactConversioniCloud.h"
#import "IMBADContactToiCloud.h"
#import "IMBCalendarViewController.h"
#import "IMBCalendarEntity.h"
#import "IMBAndroidMainPageViewController.h"
#import "IMBMainWindowController.h"

#import "IMBPhotoExportSettingConfig.h"

#import "IMBBackupCollectionViewController.h"


@implementation IMBBaseViewController
@synthesize researchdataSourceArray = _researchdataSourceArray;
@synthesize dataSourceArray = _dataSourceArray;
@synthesize navigationController = _navigationController;
@synthesize searchFieldBtn = _searchFieldBtn;
@synthesize category = _category;
@synthesize itemTableViewcanDrag = _itemTableViewcanDrag;
@synthesize itemTableViewcanDrop = _itemTableViewcanDrop;
@synthesize collectionViewcanDrag = _collectionViewcanDrag;
@synthesize collectionViewcanDrop = _collectionViewcanDrop;
@synthesize iCloudManager = _iCloudManager;
@synthesize isPause = _isPause;
@synthesize condition = _condition;
@synthesize isStop = _isStop;
@synthesize isAndroid = _isAndroid;
@synthesize isSearch = _isSearch;
@synthesize mainTopLineView = _mainTopLineView;
@synthesize isShowLineView = _isShowLineView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkin:) name:NOTIFY_CHANGE_SKIN object:nil];
    }
    return self;
}

- (void)setDelegate:(id)delegate {
    _delegate = delegate;
}

- (void)setIsShowLineView:(BOOL)isShowLineView {
    _isShowLineView = isShowLineView;
    if (_delegate && [_delegate respondsToSelector:@selector(setTopLineViewIsHidden:)]) {
        [_delegate setTopLineViewIsHidden:!isShowLineView];
    }
}

- (id)init
{
    if (self = [super initWithNibName:[self className] bundle:nil]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSkin:) name:NOTIFY_CHANGE_SKIN object:nil];
    }
    return self;
}
- (id)initWithNodesEnum:(CategoryNodesEnum)category withDelegate:(id)delegate WithProductVersion:(SimpleNode *)node WithIMBBackupDecryptAbove4:(IMBBackupDecryptAbove4 *)abve4{
    if (self = [self init]) {
        _simpleNode= node;
        _category = category;
        _delegate = delegate;
        _decryptAbove = abve4;
        _delArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithIpod:(IMBiPod *)ipod withCategoryNodesEnum:(CategoryNodesEnum)category withDelegate:(id)delegate {
    if (self = [self init]) {
        _ipod = [ipod retain];
        _information = [[IMBInformationManager shareInstance].informationDic objectForKey:_ipod.uniqueKey];
        _category = category;
        _delegate = delegate;
        _delArray = [[NSMutableArray alloc]init];
    }
    return self;
}
//Android 初始化
- (id)initwithAndroid:(IMBAndroid *)android withCategoryNodesEnum:(CategoryNodesEnum)category withDelegate:(id)delegate{
    if (self = [self init]) {
        _android = [android retain];
        _category = category;
        _delegate = delegate;
        _delArray = [[NSMutableArray alloc]init];
        _isAndroidView = YES;
    }
    return self;
}

//backup界面初始化函数
- (id)initWithProductVersion:(SimpleNode *)node withDelegate:(id)delegate WithIMBBackupDecryptAbove4:(IMBBackupDecryptAbove4*)abve4 {
    if (self = [self init]) {
    }
    return self;
}
//icloud
-(id)initiCloudWithiCloudBackUp:(IMBiCloudBackup *)icloudBackup WithDelegate:(id)delegate {
    if (self = [self init]) {
    }
    return self;
}

-(id)initiCloudWithiCloudBackUp:(IMBiCloudBackup *)icloudBackup WithDelegate:(id)delegate withCategoryNodesEnum:(CategoryNodesEnum)category{
    if (self = [self init]) {
        
    }
    return self;
}

- (id)initWithiCloudManager:(IMBiCloudManager *)iCloudManager withDelegate:(id)delegate withiCloudView:(BOOL)isiCloudView withCategory:(CategoryNodesEnum)Category  withiCloudPhotoEntity:(IMBToiCloudPhotoEntity *)iCloudPhotoEntity{
    if (self = [self init]) {
        _iCloudManager = iCloudManager;
        _delegate = delegate;
        _isiCloudView = isiCloudView;
        _category = Category;
    }
    return self;
}

- (id)initWithiCloudManager:(IMBiCloudManager *)iCloudManager withDelegate:(id)delegate withiCloudView:(BOOL)isiCloudView withCategory:(CategoryNodesEnum)Category
{
    if (self = [self init]) {
        _iCloudManager = iCloudManager;
        _delegate = delegate;
        _isiCloudView = isiCloudView;
        _category = Category;
    }
    return self;
}

-(void)loadData:(NSMutableArray *)ary{
    
}

- (void)doChangeLanguage:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_isloadingPopBtn) {
            for (NSMenuItem *item in [[_sortRightPopuBtn menu] itemArray])
            {
                if (item.tag == 0) {
                    [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                    [item setState:NSOnState];
                }else if (item.tag == 1)
                {
                    [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                    [item setState:NSOnState];
                }else if (item.tag == 2)
                {
                    [item setTitle:CustomLocalizedString(@"SortBy_Date", nil)];
                }else if (item.tag == 3)
                {
                    [item setTitle:CustomLocalizedString(@"Sort_Ascend", nil)];
                }else if (item.tag == 4)
                {
                    [item setTitle:CustomLocalizedString(@"Sort_Descend", nil)];
                }
            }
            NSString *titleStr = CustomLocalizedString(@"SortBy_Name", nil);
            if (![TempHelper stringIsNilOrEmpty:titleStr]) {
                NSRect rect = [TempHelper calcuTextBounds:titleStr fontSize:12];
                int w = rect.size.width + 30;
                //        if ((rect.size.width + 30) > 180) {
                //            w = 180;
                //        }else
                if ((rect.size.width + 30) < 50) {
                    w = 50;
                }
                
                [_sortRightPopuBtn setFrame:NSMakeRect(_topWhiteView.frame.size.width  - w -12, _sortRightPopuBtn.frame.origin.y, w, _sortRightPopuBtn.frame.size.height)];
            }
            [_sortRightPopuBtn setNeedsDisplay:YES];
            [_sortRightPopuBtn setTitle:titleStr];
            
            
            for (NSMenuItem *item in _selectSortBtn.itemArray) {
                if (item.tag == 0) {
                    [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                    
                }else if (item.tag == 1){
                    [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                    
                }else if (item.tag == 2){
                    [item setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
                    
                }
            }
            
            [_selectSortBtn setNeedsDisplay:YES];
            [_selectSortBtn setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
            
            NSRect rect1 = [TempHelper calcuTextBounds:CustomLocalizedString(@"Menu_Unselect_All", nil) fontSize:12];
            int wide = 0;
            if (rect1.size.width >170) {
                wide = 170;
            }else{
                wide = rect1.size.width;
            }
            [_selectSortBtn setFrame:NSMakeRect(-2,_selectSortBtn.frame.origin.y , wide +30, _selectSortBtn.frame.size.height)];
            
            for (NSMenuItem *item in [[_sortRightPopuBtn2 menu] itemArray])
            {
                if (item.tag == 0) {
                    [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                    [item setState:NSOnState];
                }else if (item.tag == 1)
                {
                    [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                    [item setState:NSOnState];
                }else if (item.tag == 2)
                {
                    [item setTitle:CustomLocalizedString(@"SortBy_Date", nil)];
                }else if (item.tag == 3)
                {
                    [item setTitle:CustomLocalizedString(@"Sort_Ascend", nil)];
                }else if (item.tag == 4)
                {
                    [item setTitle:CustomLocalizedString(@"Sort_Descend", nil)];
                }
            }
            NSString *titleStr2 = CustomLocalizedString(@"SortBy_Name", nil);
            if (![TempHelper stringIsNilOrEmpty:titleStr2]) {
                NSRect rect = [TempHelper calcuTextBounds:titleStr2 fontSize:12];
                int w = rect.size.width + 30;
                if ((rect.size.width + 30) < 50) {
                    w = 50;
                }
                
                [_sortRightPopuBtn2 setFrame:NSMakeRect(_topwhiteView2.frame.size.width  - w -12, _sortRightPopuBtn2.frame.origin.y, w, _sortRightPopuBtn2.frame.size.height)];
                [_sortRightPopuBtn2 setTitle:titleStr];
            }
            
            
            for (NSMenuItem *item in _selectSortBtn2.itemArray) {
                if (item.tag == 0) {
                    [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                    [item setState:NSOffState];
                }else if (item.tag == 1){
                    [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                    [item setState:NSOffState];
                }else if (item.tag == 2){
                    [item setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
                    [item setState:NSOnState];
                }
            }
            
            [_selectSortBtn2 setNeedsDisplay:YES];
            [_selectSortBtn2 setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
            
            NSRect rect2 = [TempHelper calcuTextBounds:CustomLocalizedString(@"Menu_Unselect_All", nil) fontSize:12];
            int wide2 = 0;
            if (rect2.size.width >170) {
                wide2 = 170;
            }else{
                wide2 = rect2.size.width;
            }
            [_selectSortBtn2 setFrame:NSMakeRect(-2,_selectSortBtn2.frame.origin.y , wide2 +30, _selectSortBtn2.frame.size.height)];
        }
        
        [_propertyMenuItem setTitle:CustomLocalizedString(@"Menu_Property", nil)];
        [_deleteMenuItem setTitle:CustomLocalizedString(@"Menu_Delete", nil)];
        [_toDeviceMenuItem setTitle:CustomLocalizedString(@"Menu_ToDevice", nil)];
        [_toMacMenuItem setTitle:CustomLocalizedString(@"Menu_ToPc", nil)];
        [_toiTunesMenuItem setTitle:CustomLocalizedString(@"Menu_ToiTunes", nil)];
        [_addToPlaylistMenuItem setTitle:CustomLocalizedString(@"Menu_Playlist", nil)];
        [_addToDeviceMenuItem setTitle:CustomLocalizedString(@"Menu_ToDevice", nil)];
        [_toDeleteMenuItem setTitle:CustomLocalizedString(@"Menu_Delete", nil)];
        [_refreshMenuItem setTitle:CustomLocalizedString(@"Common_id_1", nil)];
        [_preViewMenuItem setTitle:CustomLocalizedString(@"ToolContextMenuButton_id_9", nil)];
        [_addMenuItem setTitle:CustomLocalizedString(@"Common_id_7", nil)];
        [_toiCloudMenuItem setTitle:CustomLocalizedString(@"icloud_toiCloud", nil)];
        [_upLoadMenuItem setTitle:CustomLocalizedString(@"icloud_upLoad", nil)];
        [_downLoadMenuItem setTitle:CustomLocalizedString(@"icloud_DownLoad", nil)];
        [_creatFolderMenuItem setTitle:CustomLocalizedString(@"icloud_greateFile", nil)];
        
        [_androidReloadItem setTitle:CustomLocalizedString(@"Common_id_1", nil)];
        [_androidToDeviceItem setTitle:CustomLocalizedString(@"Menu_ToDevice", nil)];
        [_androidToiCloudItem setTitle:CustomLocalizedString(@"icloud_toiCloud", nil)];
        [_androidToiTunesItem setTitle:CustomLocalizedString(@"Menu_ToiTunes", nil)];
        
        for (NSMenuItem *item in [[_sortRightPopuBtn2 menu] itemArray])
        {
            if (item.tag == 0) {
                [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                [item setState:NSOnState];
            }else if (item.tag == 1)
            {
                [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                [item setState:NSOnState];
            }else if (item.tag == 2)
            {
                [item setTitle:CustomLocalizedString(@"SortBy_Date", nil)];
            }else if (item.tag == 3)
            {
                [item setTitle:CustomLocalizedString(@"Sort_Ascend", nil)];
            }else if (item.tag == 4)
            {
                [item setTitle:CustomLocalizedString(@"Sort_Descend", nil)];
            }
        }
        NSString *titleStr2 = CustomLocalizedString(@"SortBy_Name", nil);
        if (![TempHelper stringIsNilOrEmpty:titleStr2]) {
            NSRect rect = [TempHelper calcuTextBounds:titleStr2 fontSize:12];
            int w = rect.size.width + 30;
            if ((rect.size.width + 30) < 50) {
                w = 50;
            }
            
            [_sortRightPopuBtn2 setFrame:NSMakeRect(_topwhiteView2.frame.size.width  - w -12, _sortRightPopuBtn2.frame.origin.y, w, _sortRightPopuBtn2.frame.size.height)];
        }
        [_sortRightPopuBtn2 setNeedsDisplay:YES];
        [_sortRightPopuBtn2 setTitle:titleStr2];
        
        for (NSMenuItem *item in _selectSortBtn2.itemArray) {
            if (item.tag == 0) {
                [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                
            }else if (item.tag == 1){
                [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                
            }else if (item.tag == 2){
                [item setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
                
            }
        }
        
        [_selectSortBtn2 setNeedsDisplay:YES];
        [_selectSortBtn2 setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
        
        NSRect rect2 = [TempHelper calcuTextBounds:CustomLocalizedString(@"Menu_Unselect_All", nil) fontSize:12];
        int wide = 0;
        if (rect2.size.width >170) {
            wide = 170;
        }else{
            wide = rect2.size.width;
        }
        [_selectSortBtn2 setFrame:NSMakeRect(-2,_selectSortBtn2.frame.origin.y , wide +30, _selectSortBtn2.frame.size.height)];
        
    });
}

- (void)awakeFromNib
{
    _condition = [[NSCondition alloc]init];
    _endRunloop = NO;
    _itemTableViewcanDrag = YES;
    _itemTableViewcanDrop = YES;
    _collectionViewcanDrag = YES;
    _collectionViewcanDrop = YES;
    _isMerge = NO;
    _isClone = NO;
    _isContentToMac = NO;
    _isAddContent = NO;
    [_toAlbumMenuItem setHidden:YES];
    _researchdataSourceArray = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doChangeLanguage:) name:NOTIFY_CHANGE_ALLANGUAGE object:nil];
    if (_itemTableView != nil && _collectionView == nil) {
        
        if (!_isAndroid) {
            [_itemTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
            [_itemTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
            //注册该表的拖动类型
            [_itemTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType,NSFilenamesPboardType,nil]];
            
        }else{
            _itemTableViewcanDrag = NO;
            _itemTableViewcanDrop = NO;
        }
        _itemTableView.dataSource = self;
        _itemTableView.delegate = self;
        _itemTableView.allowsMultipleSelection = YES;
        [_itemTableView setListener:self];
        [_itemTableView setFocusRingType:NSFocusRingTypeNone];
        
    } else if (_itemTableView == nil && _collectionView != nil) {
        _collectionView.delegate = self;
        [_collectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
        [_collectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
        [_collectionView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType, NSFilenamesPboardType,NSStringPboardType,nil]];
        [_collectionView setSelectable:YES];
        [_collectionView setAllowsMultipleSelection:YES];
    }
    //判断Android tableview 是否可以拖拽
    if (_isAndroid) {
        _itemTableViewcanDrag = NO;
        _itemTableViewcanDrop = NO;
    }
    [_noDataViewScrollView setBackgroundColor:[NSColor clearColor]];
    NSArray *array = @[[NSColor clearColor],[NSColor clearColor]];
    [_noDataCollectionView setBackgroundColors:array];
    _noDataCollectionView.delegate = self;
    [_noDataCollectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    [_noDataCollectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
    [_noDataCollectionView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType, NSFilenamesPboardType,NSStringPboardType,nil]];
    [_noDataCollectionView setSelectable:YES];
    _alertViewController = [[IMBAlertViewController alloc] initWithNibName:@"IMBAlertViewController" bundle:nil];
    [_alertViewController setDelegate:self];
    
    _androidAlertViewController = [[IMBAndroidAlertViewController alloc] initWithNibName:@"IMBAndroidAlertViewController" bundle:nil];
    [_androidAlertViewController setDelegate:self];
    
    if (_isloadingPopBtn) {
        for (NSMenuItem *item in [[_sortRightPopuBtn menu] itemArray])
        {
            if (item.tag == 0) {
                [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                [item setState:NSOnState];
            }else if (item.tag == 1)
            {
                [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                [item setState:NSOnState];
            }else if (item.tag == 2)
            {
                [item setTitle:CustomLocalizedString(@"SortBy_Date", nil)];
            }else if (item.tag == 3)
            {
                [item setTitle:CustomLocalizedString(@"Sort_Ascend", nil)];
            }else if (item.tag == 4)
            {
                [item setTitle:CustomLocalizedString(@"Sort_Descend", nil)];
            }
        }
        NSString *titleStr = CustomLocalizedString(@"SortBy_Name", nil);
        if (![TempHelper stringIsNilOrEmpty:titleStr]) {
            NSRect rect = [TempHelper calcuTextBounds:titleStr fontSize:12];
            int w = rect.size.width + 30;
            //        if ((rect.size.width + 30) > 180) {
            //            w = 180;
            //        }else
            if ((rect.size.width + 30) < 50) {
                w = 50;
            }
            
            [_sortRightPopuBtn setFrame:NSMakeRect(_topWhiteView.frame.size.width  - w -12, _sortRightPopuBtn.frame.origin.y, w, _sortRightPopuBtn.frame.size.height)];
            [_sortRightPopuBtn setTitle:titleStr];
        }
        
        
        for (NSMenuItem *item in _selectSortBtn.itemArray) {
            if (item.tag == 0) {
                [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                [item setState:NSOffState];
            }else if (item.tag == 1){
                [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                [item setState:NSOffState];
            }else if (item.tag == 2){
                [item setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
                [item setState:NSOnState];
            }
        }
        
        [_selectSortBtn setNeedsDisplay:YES];
        [_selectSortBtn setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
        
        NSRect rect1 = [TempHelper calcuTextBounds:CustomLocalizedString(@"Menu_Unselect_All", nil) fontSize:12];
        int wide = 0;
        if (rect1.size.width >170) {
            wide = 170;
        }else{
            wide = rect1.size.width;
        }
        [_selectSortBtn setFrame:NSMakeRect(-2,_selectSortBtn.frame.origin.y , wide +30, _selectSortBtn.frame.size.height)];
        
        for (NSMenuItem *item in [[_sortRightPopuBtn2 menu] itemArray])
        {
            if (item.tag == 0) {
                [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                [item setState:NSOnState];
            }else if (item.tag == 1)
            {
                [item setTitle:CustomLocalizedString(@"SortBy_Name", nil)];
                [item setState:NSOnState];
            }else if (item.tag == 2)
            {
                [item setTitle:CustomLocalizedString(@"SortBy_Date", nil)];
            }else if (item.tag == 3)
            {
                [item setTitle:CustomLocalizedString(@"Sort_Ascend", nil)];
            }else if (item.tag == 4)
            {
                [item setTitle:CustomLocalizedString(@"Sort_Descend", nil)];
            }
        }
        NSString *titleStr2 = CustomLocalizedString(@"SortBy_Name", nil);
        if (![TempHelper stringIsNilOrEmpty:titleStr2]) {
            NSRect rect = [TempHelper calcuTextBounds:titleStr2 fontSize:12];
            int w = rect.size.width + 30;
            if ((rect.size.width + 30) < 50) {
                w = 50;
            }
            
            [_sortRightPopuBtn2 setFrame:NSMakeRect(_topwhiteView2.frame.size.width  - w -12, _sortRightPopuBtn2.frame.origin.y, w, _sortRightPopuBtn2.frame.size.height)];
            [_sortRightPopuBtn2 setTitle:titleStr];
        }
        
        
        for (NSMenuItem *item in _selectSortBtn2.itemArray) {
            if (item.tag == 0) {
                [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                [item setState:NSOffState];
            }else if (item.tag == 1){
                [item setTitle:CustomLocalizedString(@"Menu_Select_All", nil)];
                [item setState:NSOffState];
            }else if (item.tag == 2){
                [item setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
                [item setState:NSOnState];
            }
        }
        
        [_selectSortBtn2 setNeedsDisplay:YES];
        [_selectSortBtn2 setTitle:CustomLocalizedString(@"Menu_Unselect_All", nil)];
        
        NSRect rect2 = [TempHelper calcuTextBounds:CustomLocalizedString(@"Menu_Unselect_All", nil) fontSize:12];
        int wide2 = 0;
        if (rect2.size.width >170) {
            wide2 = 170;
        }else{
            wide2 = rect2.size.width;
        }
        [_selectSortBtn2 setFrame:NSMakeRect(-2,_selectSortBtn2.frame.origin.y , wide2 +30, _selectSortBtn2.frame.size.height)];
        
    }
    _mergeCloneAppVC = [[IMBMergeCloneAppViewController alloc]initWithNibName:@"IMBMergeCloneAppViewController" bundle:nil];
    [_propertyMenuItem setTitle:CustomLocalizedString(@"Menu_Property", nil)];
    [_deleteMenuItem setTitle:CustomLocalizedString(@"Menu_Delete", nil)];
    [_toDeviceMenuItem setTitle:CustomLocalizedString(@"Menu_ToDevice", nil)];
    [_toMacMenuItem setTitle:CustomLocalizedString(@"Menu_ToPc", nil)];
    [_toiTunesMenuItem setTitle:CustomLocalizedString(@"Menu_ToiTunes", nil)];
    [_addToPlaylistMenuItem setTitle:CustomLocalizedString(@"Menu_Playlist", nil)];
    [_addToDeviceMenuItem setTitle:CustomLocalizedString(@"Menu_ToDevice", nil)];
    [_addToDeviceMenuItem setHidden:YES];
    [_toDeleteMenuItem setTitle:CustomLocalizedString(@"Menu_Delete", nil)];
    [_refreshMenuItem setTitle:CustomLocalizedString(@"Common_id_1", nil)];
    [_preViewMenuItem setTitle:CustomLocalizedString(@"ToolContextMenuButton_id_9", nil)];
    [_addMenuItem setTitle:CustomLocalizedString(@"Common_id_7", nil)];
    [_itemTableView setBackgroundColor:[NSColor clearColor]];
    [_toiCloudMenuItem setTitle:CustomLocalizedString(@"icloud_toiCloud", nil)];
    [_upLoadMenuItem setTitle:CustomLocalizedString(@"icloud_upLoad", nil)];
    [_downLoadMenuItem setTitle:CustomLocalizedString(@"icloud_DownLoad", nil)];
    [_creatFolderMenuItem setTitle:CustomLocalizedString(@"icloud_greateFile", nil)];
    
    [_androidReloadItem setTitle:CustomLocalizedString(@"Common_id_1", nil)];
    [_androidToDeviceItem setTitle:CustomLocalizedString(@"Menu_ToDevice", nil)];
    [_androidToiCloudItem setTitle:CustomLocalizedString(@"icloud_toiCloud", nil)];
    [_androidToiTunesItem setTitle:CustomLocalizedString(@"Menu_ToiTunes", nil)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeOpenPanel:) name:DeviceDisConnectedNotification object:nil];
}

- (void)setToolBar:(IMBToolBarView *)toolbar{
    _toolBar = toolbar;
}
#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_dataSourceArray count];
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    self.dataSourceArray  = [NSMutableArray arrayWithArray:[self.dataSourceArray sortedArrayUsingDescriptors:[aTableView sortDescriptors]]];
    [aTableView reloadData];
}

#pragma mark - NSTableViewDelegate
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 30;
}

//NSTableView drop and drag
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    NSArray *fileTypeList = [NSArray arrayWithObject:@"export"];
    [pboard setPropertyList:fileTypeList
                    forType:NSFilesPromisePboardType];
    if (_category == Category_PhotoVideo ||_category == Category_Photo||_category == Category_ContinuousShooting) {
        return YES;
    }else{
        if (_itemTableViewcanDrag) {
            return YES;
        }else
        {
            return NO;
        }
    }
    
}
//_itemTableView drag destination support
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pastboard = [info draggingPasteboard];
    NSArray *fileTypeList = [pastboard propertyListForType:NSFilesPromisePboardType];
    if ( _category == 0 || _category == Category_iTunes_Playlist || _category  == Category_iTunes_Movie || _category  == Category_iTunes_Music || _category  == Category_iTunes_TVShow || _category  == Category_iTunes_PodCasts || _category  == Category_iTunes_iTunesU || _category  == Category_iTunes_iBooks || _category  == Category_iTunes_VoiceMemos || _category  == Category_iTunes_Audiobook || _category  == Category_iTunes_App || _category  == Category_PhotoVideo || _category  == Category_CameraRoll || _category  == Category_PhotoStream || _category == Category_PhotoShare || _category  == Category_Panoramas || _category  == Category_ContinuousShooting || _category  == Category_SafariHistory || _category  == Category_Notes || _category  == Category_Voicemail || _category  == Category_Message || _category  == Category_Calendar) {
        NSLog(@"**********can't drag to tableView");
        return NSDragOperationNone;
    }else if (fileTypeList == nil) {
        if (_itemTableViewcanDrop) {
            return NSDragOperationCopy;
        }else
        {
            return NSDragOperationNone;
        }
        
    }else
    {
        return NSDragOperationNone;
    }
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pastboard = [info draggingPasteboard];
    NSArray *boarditemsArray = [pastboard pasteboardItems];
    NSMutableArray *itemArray = [NSMutableArray array];
    for (NSPasteboardItem *item in boarditemsArray) {
        NSString *urlPath = [item stringForType:@"public.file-url"];
        NSURL *url = [NSURL URLWithString:urlPath];
        NSString *path = [url relativePath];
        if (path == nil) {
            return NO;
        }
        if (_isiCloudView) {
            BOOL isDir = NO;
            [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
            if(!isDir)//不是文件夹
            {
                if(![StringHelper stringIsNilOrEmpty:path]) {
                    [itemArray addObject:path];
                }
            }
        }else{
            [itemArray addObject:path];
        }
    }
    
    if (_isiCloudView) {
        if (itemArray.count > 0) {
            [self dropicloudToTabView:tableView paths:itemArray];
            return YES;
        }else{
            return NO;
        }
    }else {
        [self dropToTabView:tableView paths:itemArray];
    }
    return YES;
}

- (NSArray *)tableView:(NSTableView *)tableView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet
{
    NSArray *namesArray = nil;
    //获取目的url
    BOOL iconHide = NO;
    NSString *url = [dropDestination relativePath];
    //此处调用导出方法
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:indexSet,@"indexSet",url,@"url",tableView,@"tableView", nil];
    [self performSelector:@selector(delayTableViewdragToMac:) withObject:dic afterDelay:0.1];
    iconHide = YES;
    return namesArray;
}

- (void)delayTableViewdragToMac:(NSDictionary *)param
{
    NSIndexSet *indexSet = [param objectForKey:@"indexSet"];
    NSString *url = [param objectForKey:@"url"];
    NSTableView *tableView = [param objectForKey:@"tableView"];
    [self dragToMac:indexSet withDestination:url withView:tableView];
}

#pragma mark - IMBImageRefreshListListener
- (void)tableView:(NSTableView *)tableView row:(NSInteger)index {
    
}

-(void)setAllselectState:(CheckStateEnum)sender{
}

#pragma mark drop and drag Actions
- (void)dragToMac:(NSIndexSet *)indexSet withDestination:(NSString *)destinationPath withView:(NSView *)view {
    NSLog(@"dragToMac：category：%d",_category);
    if (indexSet.count > 0){
        if (_category == Category_Applications) {
            //弹出路径选择框
            if ([_ipod.deviceInfo.getDeviceFloatVersionNumber isVersionMajorEqual:@"8.3"]) {
                //弹出警告确认框
                [self showAlertText:CustomLocalizedString(@"MSG_Device_Edition_Too_high", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }
        NSViewController *annoyVC = nil;
        long long result =  10;
        if (!_isiCloudView) {
            result = [self checkNeedAnnoy:&(annoyVC)];
            if (result == 0) {
                return;
            }
        }
        
        if (_category != Category_iCloudDriver){
            destinationPath = [TempHelper createCategoryPath:[TempHelper createExportPath:destinationPath] withString:[IMBCommonEnum categoryNodesEnumToName:_category]];
        }
        if (!_isiCloudView || (_isiCloud && (_category == Category_CameraRoll || _category == Category_PhotoVideo))) {
            if (_category == Category_Music||_category == Category_CloudMusic||_category == Category_Movies||_category == Category_TVShow||_category == Category_MusicVideo||_category == Category_PodCasts||_category == Category_iTunesU||_category == Category_Audiobook||_category == Category_Ringtone||_category == Category_Playlist||_category == Category_HomeVideo||  _category == Category_VoiceMemos||  _category == Category_Applications||  _category == Category_PhotoLibrary || _category == Category_PhotoStream || _category == Category_PhotoVideo || _category == Category_CameraRoll||_category==Category_TimeLapse||_category==Category_SlowMove||_category==Category_Panoramas||_category == Category_ContinuousShooting||_category == Category_PhotoShare||  _category == Category_Voicemail || _category == Category_MyAlbums||_category == Category_Thumil||_category == Category_LivePhoto||_category == Category_Screenshot||_category == Category_PhotoSelfies||_category == Category_Location||_category == Category_Favorite) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self copyTableViewContentToMac:destinationPath indexSet:indexSet Result:result AnnoyVC:annoyVC];
                });
            }
            //system、Storage 导出到Mac
            else if (_category == Category_System || _category == Category_Storage||_category == Category_iBooks || _category == Category_Explorer) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self copyCollectionContentToMac:destinationPath Result:result AnnoyVC:annoyVC];
                });
            }else if(_category == Category_Notes||_category == Category_Message||_category == Category_Calendar||_category == Category_Bookmarks||_category == Category_Contacts||_category == Category_SafariHistory||_category == Category_CallHistory || _category == 0 || _category == Category_iTunes_Playlist || _category  == Category_iTunes_Movie || _category  == Category_iTunes_Music || _category  == Category_iTunes_TVShow || _category  == Category_iTunes_PodCasts || _category  == Category_iTunes_iTunesU || _category  == Category_iTunes_iBooks || _category  == Category_iTunes_VoiceMemos || _category  == Category_iTunes_Audiobook || _category  == Category_iTunes_App) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self copyInfomationToMac:destinationPath indexSet:indexSet Result:result AnnoyVC:annoyVC];
                });
            }
            
        }else{
            if (_category == Category_iCloudDriver){
                [self copyInfomationToMac:destinationPath indexSet:indexSet];
            }else if (_category == Category_Photo||_category == Category_PhotoVideo||_category == Category_ContinuousShooting){
                [self copyInPhotofomationToMac:destinationPath indexSet:indexSet];
            }else if(_category == Category_Notes||_category == Category_Calendar||_category == Category_Contacts||_category == Category_Reminder) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self copyInfomationToMac:destinationPath indexSet:indexSet Result:result AnnoyVC:annoyVC];
                });
            }
        }
    }
}

- (void)dropToTabView:(NSTableView *)tableView paths:(NSArray *)pathArray {
    [self dropToTabviewAndCollectionViewWithPaths:pathArray];
}

- (void)copyInfomationToMac:(NSString *)filePath indexSet:(NSIndexSet *)set{
    
}

- (void)dropUpLoad:(NSMutableArray *)pathArray{
    
}

- (void)copyInPhotofomationToMac:(NSString *)filePath indexSet:(NSIndexSet *)set{
    
}

- (void)dropicloudToTabView:(NSTableView *)tableView paths:(NSArray *)pathArray{
    [self dropToTabviewAndCollectionViewWithPaths:pathArray];
}

- (void)dropToCollectionView:(NSCollectionView *)collectionView paths:(NSMutableArray *)pathArray {
    [self dropToTabviewAndCollectionViewWithPaths:pathArray];
}

- (void)dropIcloudToCollectionView:(NSCollectionView *)collectionView paths:(NSMutableArray *)pathArray {
    [self dropToTabviewAndCollectionViewWithPaths:pathArray];
}

- (void)dropToTabviewAndCollectionViewWithPaths:(NSArray *)pathArray {
    NSMutableArray *allPaths = [[NSMutableArray alloc] init];
    NSArray *supportExtension = [[MediaHelper getSupportFileTypeArray:_category supportVideo:_ipod.deviceInfo.isSupportVideo supportConvert:YES withiPod:_ipod] componentsSeparatedByString:@";"];
    //限制每次只能导入1000首，超过的就不导入
    if (_category == Category_Music || _category == Category_Ringtone || _category == Category_Audiobook || _category == Category_VoiceMemos  || _category == Category_Playlist || _category == Category_Movies || _category == Category_HomeVideo || _category == Category_TVShow || _category == Category_MusicVideo || _category == Category_PhotoLibrary || _category == Category_MyAlbums) {
        if (_ipod.beingSynchronized) {
            [self showAlertText:CustomLocalizedString(@"AirsyncTips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }
        [self getFileNames:pathArray byFileExtensions:supportExtension toArray:allPaths];
        
        if (allPaths.count > 1000) {
            NSView *view = nil;
            for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
                if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                    view = subView;
                    [view setHidden:NO];
                    break;
                }
            }
            [_alertViewController showAlertText:CustomLocalizedString(@"MSG_AddData_Tips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil) SuperView:view];
            int i = (int)allPaths.count;
            [allPaths removeObjectsInRange:NSMakeRange(999, i - 1000)];
        }
    }else {
        [allPaths addObjectsFromArray:pathArray];
    }
    
    if (_category == Category_iCloudDriver){
        [self dropUpLoad:allPaths];
        return;
        //        [self copyInfomationToMac:destinationPath indexSet:indexSet];
    }
    long long playlistID = 0;
    if (_category == Category_Playlist) {
        if ([self isKindOfClass:[IMBDevicePlaylistsViewController class]]) {
            IMBDevicePlaylistsViewController *playlistsViewController = (IMBDevicePlaylistsViewController *)self;
            int seletedIndex =  (int)playlistsViewController.playlistsTableView.selectedRow;
            if (seletedIndex < _playlistArray.count && seletedIndex != -1) {
                IMBPlaylist *playlist = [_playlistArray objectAtIndex:seletedIndex];
                playlistID = playlist.iD;
            }
        }
    }
    
    IMBPhotoEntity *albumEntity = nil;
    if (_category == Category_MyAlbums) {
        if ([self isKindOfClass:[IMBMyAlbumsViewController class]]) {
            IMBMyAlbumsViewController *albumsContorller = (IMBMyAlbumsViewController *)self;
            int seletedIndex = (int)[albumsContorller.albumTableView selectedRow];
            if (seletedIndex == -1) {
                return;
            }
            albumEntity = [_playlistArray objectAtIndex:seletedIndex];
        }else if ([self isKindOfClass:[IMBPhotosCollectionViewController class]]) {
            IMBPhotosCollectionViewController *contorller = (IMBPhotosCollectionViewController *)self;
            if (contorller.curEntity != nil) {
                albumEntity = contorller.curEntity;
            }
        }else if ([self isKindOfClass:[IMBPhotosListViewController class]]) {
            IMBPhotosListViewController *contorller = (IMBPhotosListViewController *)self;
            if (contorller.curEntity != nil) {
                albumEntity = contorller.curEntity;
            }
        }
        if (albumEntity.albumKind == 2) {
            return;
        }
    }
    
    BOOL isAlloc = NO;
    if (_category == Category_PhotoLibrary) {
        if (_ipod.deviceInfo.isIOSDevice) {
            if (albumEntity == nil) {
                NSArray *albumArray = [_information myAlbumsArray];
                for (IMBPhotoEntity *entity in albumArray) {
                    if ([entity.albumTitle isEqualToString:CustomLocalizedString(@"MSG_AddPhotoToDefaultAlbum", nil)] && entity.albumKind == 1550) {
                        albumEntity = entity;
                        isAlloc = YES;
                        break;
                    }
                }
                if (!isAlloc) {
                    isAlloc = YES;
                    albumEntity = [[IMBPhotoEntity alloc] init];
                    albumEntity.albumZpk = -4;
                    albumEntity.albumKind = 1550;
                    albumEntity.albumTitle = CustomLocalizedString(@"MSG_AddPhotoToDefaultAlbum", nil);
                    albumEntity.albumType = SyncAlbum;
                }else {
                    isAlloc = NO;
                }
            }
        }
    }
    
    if (_category == Category_Storage || _category == Category_System) {
        //        NSViewController *annoyVC = nil;
        //        long long result = [self checkNeedAnnoy:&(annoyVC)];
        //        if (result == 0) {
        //            return;
        //        }
        //
        //        [self importToDevice:[NSMutableArray arrayWithArray:allPaths] photoAlbum:albumEntity playlistID:playlistID Result:result AnnoyVC:annoyVC];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:allPaths, @"supportArray", albumEntity, @"albumEntity", playlistID, @"playlistID", nil];
        [self performSelector:@selector(executeAction:) withObject:dic afterDelay:0.1];
        
        [allPaths autorelease], allPaths = nil;
        return;
    }
    
    
    NSMutableArray *supportArray = [[NSMutableArray alloc]init];
    NSArray *supportFiles = [[MediaHelper getSupportFileTypeArray:_category supportVideo:_ipod.deviceInfo.isSupportVideo supportConvert:YES withiPod:_ipod] componentsSeparatedByString:@";"];
    for (NSString *path in allPaths) {
        NSLog(@"%@",path.pathExtension);
        if ([supportFiles containsObject:[path.pathExtension lowercaseString]]) {
            [supportArray addObject:path];
        }
    }
    
    if (supportArray.count > 0) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:supportArray, @"supportArray", albumEntity, @"albumEntity", playlistID, @"playlistID", nil];
        [self performSelector:@selector(executeAction:) withObject:dic afterDelay:0.1];
    }
    [supportArray autorelease], supportArray = nil;
    [allPaths autorelease], allPaths = nil;
}

- (void)executeAction:(NSDictionary *)dic {
    NSViewController *annoyVC = nil;
    long long result = [self checkNeedAnnoy:&(annoyVC)];
    if (result == 0) {
        return;
    }
    IMBPhotoEntity *albumEntity = [dic objectForKey:@"albumEntity"];
    NSMutableArray *supportArray = [dic objectForKey:@"supportArray"];
    long long playlistID = [[dic objectForKey:@"playlistID"] longLongValue];
    [self importToDevice:supportArray photoAlbum:albumEntity playlistID:playlistID Result:result AnnoyVC:annoyVC];
    if (_category != Category_Storage && _category != Category_System) {
        [self refeash];
    }
}

#pragma mark - NSCollectionViewDelegate
- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event
{
    return YES;
}

- (BOOL)collectionView:(NSCollectionView *)cv writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
    NSArray *fileTypeList = [NSArray arrayWithObject:@"export"];
    [pasteboard setPropertyList:fileTypeList
                        forType:NSFilesPromisePboardType];
    if (_collectionViewcanDrag) {
        return YES;
    }else
    {
        return NO;
    }
    
    return YES;
}

- (NSImage *)collectionView:(NSCollectionView *)collectionView draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset
{
    NSImage *image = [_collectionView draggingImageForItemsAtIndexes:indexes withEvent:event offset:dragImageOffset];
    NSImage *scalingimage = [[NSImage alloc] initWithSize:NSMakeSize(image.size.width, image.size.height)];
    [scalingimage lockFocus];
    [[NSColor clearColor] setFill];
    NSRectFill(NSMakeRect(0, 0, image.size.width/3.0, image.size.height/3.0));
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
    [image drawInRect:NSMakeRect(0, 0, image.size.width/3.0, image.size.height/3.0) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    NSArray *selectedArray = [_arrayController selectedObjects];
    int count = (int)[selectedArray count];
    NSString *countstr = [NSString stringWithFormat:@"%d",count];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:countstr?:@""];
    [str addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12] range:NSMakeRange(0, str.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, str.length)];
    //    NSRect drawRect = NSMakeRect(image.size.width/6.0, image.size.height/6.0, str.size.width+8, 20);
    //    NSBezierPath *path = nil;
    //    if (count <= 9) {
    //        path = [NSBezierPath bezierPathWithRoundedRect:drawRect xRadius:10 yRadius:10];
    //    }else
    //    {
    //        path = [NSBezierPath bezierPathWithRoundedRect:drawRect xRadius:8 yRadius:8];
    //    }
    
    NSRect drawRect = NSMakeRect(image.size.width/6.0, image.size.height/6.0, str.size.width + 8, str.size.width + 8);
    
    NSBezierPath *path = nil;
    path = [NSBezierPath bezierPathWithRoundedRect:drawRect xRadius:(str.size.width + 8)/2.0 yRadius:(str.size.width + 8)/2.0];
    
    [[NSColor redColor] setFill];
    [path fill];
    [[NSColor whiteColor] setStroke];
    [path stroke];
    
    //    [str drawInRect: NSMakeRect(image.size.width/6.0 + (str.size.width+8 - str.size.width)/2.0, image.size.height/6.0+(20-str.size.height)/2.0 - 3.5, str.size.width+8, 20)];
    [str drawInRect: NSMakeRect(drawRect.origin.x+4,drawRect.origin.y +(drawRect.size.height - str.size.height )/2.0 + 1, str.size.width+8, str.size.height)];
    
    NSData *tempdata = nil;
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect: NSMakeRect(0, 0, image.size.width/3.0, image.size.height/3.0)];
    tempdata = [bitmap representationUsingType:NSPNGFileType properties:nil];
    [bitmap release];
    [scalingimage unlockFocus];
    [scalingimage release];
    
    NSImage *dragImage = [[[NSImage alloc] initWithData:tempdata] autorelease];
    return dragImage;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id <NSDraggingInfo>)draggingInfo proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    NSPasteboard *pastboard = [draggingInfo draggingPasteboard];
    NSArray *fileTypeList = [pastboard propertyListForType:NSFilesPromisePboardType];
    if (!_isiCloudView) {
        if (_category == 0 || _category == Category_iTunes_Playlist || _category  == Category_iTunes_Movie || _category  == Category_iTunes_Music || _category  == Category_iTunes_TVShow || _category  == Category_iTunes_PodCasts || _category  == Category_iTunes_iTunesU || _category  == Category_iTunes_iBooks || _category  == Category_iTunes_VoiceMemos || _category  == Category_iTunes_Audiobook || _category  == Category_iTunes_App || _category  == Category_PhotoVideo || _category  == Category_CameraRoll || _category  == Category_PhotoStream || _category == Category_PhotoShare || _category  == Category_Panoramas || _category  == Category_ContinuousShooting || _category  == Category_SafariHistory || _category  == Category_Notes || _category  == Category_Voicemail || _category  == Category_Message || _category  == Category_Calendar || _category == Category_TimeLapse || _category == Category_SlowMove) {
            return NSDragOperationNone;
        }else if (fileTypeList == nil) {
            if (_collectionViewcanDrop) {
                return NSDragOperationCopy;
            }else
            {
                return NSDragOperationNone;
            }
        }else
        {
            return NSDragOperationNone;
        }
        
    }else{
        return NSDragOperationCopy;
    }
}

- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id <NSDraggingInfo>)draggingInfo index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    if (collectionView == _collectionView) {
        NSPasteboard *pastboard = [draggingInfo draggingPasteboard];
        NSArray *boarditemsArray = [pastboard pasteboardItems];
        NSMutableArray *itemArray = [NSMutableArray array];
        for (NSPasteboardItem *item in boarditemsArray) {
            NSString *urlPath = [item stringForType:@"public.file-url"];
            NSURL *url = [NSURL URLWithString:urlPath];
            NSString *path = [url relativePath];
            if (_isiCloudView) {
                BOOL isDir = NO;
                [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
                if(!isDir)//不是文件夹
                {
                    if(![StringHelper stringIsNilOrEmpty:path]) {
                        [itemArray addObject:path];
                    }
                }
            }else{
                if(![StringHelper stringIsNilOrEmpty:path]) {
                    [itemArray addObject:path];
                }
            }
        }
        if (_isiCloudView) {
            if (itemArray.count >0) {
                [self dropIcloudToCollectionView:collectionView paths:itemArray];
                return YES;
            }else{
                return NO;
            }
        }else{
            [self dropToCollectionView:collectionView paths:itemArray];
        }
    }else if (collectionView == _noDataCollectionView) {
        NSPasteboard *pastboard = [draggingInfo draggingPasteboard];
        NSArray *boarditemsArray = [pastboard pasteboardItems];
        NSMutableArray *itemArray = [NSMutableArray array];
        for (NSPasteboardItem *item in boarditemsArray) {
            NSString *urlPath = [item stringForType:@"public.file-url"];
            NSURL *url = [NSURL URLWithString:urlPath];
            NSString *path = [url relativePath];
            [itemArray addObject:path];
        }
        if (_itemTableView != nil) {
            [self dropToTabviewAndCollectionViewWithPaths:itemArray];
        }else if (_collectionView != nil) {
            [self dropToCollectionView:collectionView paths:itemArray];
        }
        return YES;
    }
    return NO;
}

- (NSArray *)collectionView:(NSCollectionView *)collectionView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropURL forDraggedItemsAtIndexes:(NSIndexSet *)indexes
{
    NSArray *namesArray = nil;
    //获取目的url
    NSString *url = [dropURL relativePath];
    //此处调用导出方法
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:indexes,@"indexSet",url,@"url",collectionView,@"collectionView", nil];
    [self performSelector:@selector(delayCollectionViewdragToMac:) withObject:dic afterDelay:0.1];
    return namesArray;
}

- (void)delayCollectionViewdragToMac:(NSDictionary *)param
{
    NSIndexSet *indexSet = [param objectForKey:@"indexSet"];
    NSString *url = [param objectForKey:@"url"];
    NSCollectionView *collectionView = [param objectForKey:@"collectionView"];
    if (_isiCloud && (_category == Category_CameraRoll || _category == Category_PhotoVideo)) {
        [self dragToMac:indexSet withDestination:url withView:collectionView];
    }else {
        if (_isiCloudView && (_category == Category_PhotoVideo||_category == Category_Photo||_category == Category_ContinuousShooting)) {
            [self iClouddragDownDataToMac:url];
        }else{
            [self dragToMac:indexSet withDestination:url withView:collectionView];
        }
    }
}

- (void)iClouddragDownDataToMac:(NSString *)pathUrl{
    
}

#pragma mark Operaiton Actions
- (void)reload:(id)sender
{
    NSLog(@"reload");
}
- (void)addItems:(id)sender
{
    if (_ipod.beingSynchronized) {
        [self showAlertText:CustomLocalizedString(@"AirsyncTips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        return;
    }
    if (_category != Category_PhotoLibrary && _category != Category_MyAlbums) {
        if (![self checkInternetAvailble]) {
            return;
        }
    }
    if (_category == Category_Ringtone) {
        if (![IMBRingtoneConfig singleton].allSkip) {
            [_alertViewController setIsStopPan:YES];
            int ret = [self showAlertText:CustomLocalizedString(@"ringtone_setting_window_11", nil) OKButton:CustomLocalizedString(@"Button_Yes", nil) CancelButton:CustomLocalizedString(@"Button_No", nil)];
            [_alertViewController setIsStopPan:NO];
            if (ret == 1) {
                [self performSelector:@selector(doSetting:) withObject:nil afterDelay:0.6];
                return;
            }
        }
    }
    
    [self addItemContent];
}

- (void)addItemContent {
    long long playlistID = 0;
    if (_category == Category_Playlist) {
        if ([self isKindOfClass:[IMBDevicePlaylistsViewController class]]) {
            IMBDevicePlaylistsViewController *playlistsViewController = (IMBDevicePlaylistsViewController *)self;
            int seletedIndex =  (int)playlistsViewController.playlistsTableView.selectedRow;
            if (seletedIndex < _playlistArray.count && seletedIndex != -1) {
                IMBPlaylist *playlist = [_playlistArray objectAtIndex:seletedIndex];
                playlistID = playlist.iD;
            }
        }
    }
    __block IMBPhotoEntity *albumEntity = nil;
    if (_category == Category_MyAlbums) {
        if ([self isKindOfClass:[IMBMyAlbumsViewController class]]) {
            IMBMyAlbumsViewController *albumsContorller = (IMBMyAlbumsViewController *)self;
            int seletedIndex = (int)[albumsContorller.albumTableView selectedRow];
            if (seletedIndex == -1) {
                return;
            }
            albumEntity = [_playlistArray objectAtIndex:seletedIndex];
        }else if ([self isKindOfClass:[IMBPhotosCollectionViewController class]]) {
            IMBPhotosCollectionViewController *contorller = (IMBPhotosCollectionViewController *)self;
            if (contorller.curEntity != nil) {
                albumEntity = contorller.curEntity;
            }
        }else if ([self isKindOfClass:[IMBPhotosListViewController class]]) {
            IMBPhotosListViewController *contorller = (IMBPhotosListViewController *)self;
            if (contorller.curEntity != nil) {
                albumEntity = contorller.curEntity;
            }
        }
        if (albumEntity.albumKind == 2) {
            return;
        }
    }
    BOOL isAlloc = NO;
    if (_category == Category_PhotoLibrary) {
        if (_ipod.deviceInfo.isIOSDevice) {
            if (albumEntity == nil) {
                NSArray *albumArray = [_information myAlbumsArray];
                for (IMBPhotoEntity *entity in albumArray) {
                    if ([entity.albumTitle isEqualToString:CustomLocalizedString(@"MSG_AddPhotoToDefaultAlbum", nil)] && entity.albumKind == 1550) {
                        albumEntity = entity;
                        isAlloc = YES;
                        break;
                    }
                }
                if (!isAlloc) {
                    isAlloc = YES;
                    albumEntity = [[IMBPhotoEntity alloc] init];
                    albumEntity.albumZpk = -4;
                    albumEntity.albumKind = 1550;
                    albumEntity.albumTitle = CustomLocalizedString(@"MSG_AddPhotoToDefaultAlbum", nil);
                    albumEntity.albumType = SyncAlbum;
                }else {
                    isAlloc = NO;
                }
            }
        }
    }
    NSArray *supportFiles = [[MediaHelper getSupportFileTypeArray:_category supportVideo:_ipod.deviceInfo.isSupportVideo supportConvert:YES withiPod:_ipod] componentsSeparatedByString:@";"];
    
    _openPanel = [NSOpenPanel openPanel];
    _isOpen = YES;
    [_openPanel setCanChooseDirectories:YES];
    [_openPanel setCanChooseFiles:YES];
    [_openPanel setAllowsMultipleSelection:YES];
    [_openPanel setAllowedFileTypes:supportFiles];
    [_openPanel beginSheetModalForWindow:[(IMBDeviceMainPageViewController *)_delegate view].window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSFileHandlingPanelOKButton) {
            NSDictionary *param = nil;
            if (albumEntity == nil) {
                param = [NSDictionary dictionaryWithObjectsAndKeys:_openPanel,@"openPanel",[NSNull null],@"albumEntity",@(playlistID),@"playlistID",@(isAlloc),@"isAlloc",nil];
                
            }else{
                param = [NSDictionary dictionaryWithObjectsAndKeys:_openPanel,@"openPanel",albumEntity,@"albumEntity",@(playlistID),@"playlistID",@(isAlloc),@"isAlloc",nil];
                
            }
            [self performSelector:@selector(addItemsDelay:) withObject:param afterDelay:0.1];
        }
        _isOpen = NO;
    }];
}

- (void)addItemsDelay:(NSDictionary *)param
{
    NSViewController *annoyVC = nil;
    long long result = [self checkNeedAnnoy:&(annoyVC)];
    if (result == 0) {
        return;
    }
    BOOL isAlloc = [[param objectForKey:@"isAlloc"] boolValue];
    NSOpenPanel *openPanel = [param objectForKey:@"openPanel"];
    long long playlistID = [[param objectForKey:@"playlistID"] longLongValue];
    IMBPhotoEntity *albumEntity = [param objectForKey:@"albumEntity"];
    if ([albumEntity isKindOfClass:[NSNull class]]) {
        albumEntity = nil;
    }
    NSArray *urlArr = [openPanel URLs];
    NSMutableArray *paths = [NSMutableArray array];
    for (NSURL *url in urlArr) {
        [paths addObject:url.path];
    }
    NSMutableArray *allPaths = [[NSMutableArray alloc] init];
    NSArray *supportExtension = [[MediaHelper getSupportFileTypeArray:_category supportVideo:_ipod.deviceInfo.isSupportVideo supportConvert:YES withiPod:_ipod] componentsSeparatedByString:@";"];
    //限制每次只能导入1000首，超过的就不导入
    if (_category == Category_Music || _category == Category_Ringtone || _category == Category_Audiobook || _category == Category_VoiceMemos  || _category == Category_Playlist || _category == Category_Movies || _category == Category_HomeVideo || _category == Category_TVShow || _category == Category_MusicVideo || _category == Category_PhotoLibrary || _category == Category_MyAlbums) {
        [self getFileNames:paths byFileExtensions:supportExtension toArray:allPaths];
        if (allPaths.count > 1000) {
            NSView *view = nil;
            for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
                if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                    view = subView;
                    [view setHidden:NO];
                    break;
                }
            }
            [_alertViewController showAlertText:CustomLocalizedString(@"MSG_AddData_Tips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil) SuperView:view];
            int i = (int)allPaths.count;
            [allPaths removeObjectsInRange:NSMakeRange(999, i - 1000)];
        }
    }else {
        [allPaths addObjectsFromArray:paths];
    }
    NSDictionary *dimensionDict = nil;
    @autoreleasepool {
        dimensionDict = [[TempHelper customDimension] copy];
    }
    [ATTracker event:Device_Content action:Import actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Start transferCount:allPaths.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
    if (dimensionDict) {
        [dimensionDict release];
        dimensionDict = nil;
    }
    [self importToDevice:allPaths photoAlbum:albumEntity playlistID:playlistID Result:result AnnoyVC:annoyVC];
    if (isAlloc && albumEntity != nil) {
        [albumEntity release];
    }
    [allPaths autorelease], allPaths = nil;
}

- (void)deleteItems:(id)sender
{
    if (_category != Category_PhotoLibrary && _category != Category_MyAlbums && _category != Category_CameraRoll && _category != Category_CameraRoll && _category != Category_PhotoVideo &&_category == Category_TimeLapse &&_category !=Category_Panoramas && _category == Category_SlowMove&& _category != Category_LivePhoto&& _category != Category_Screenshot&& _category != Category_PhotoSelfies&& _category != Category_Location&& _category != Category_Favorite) {
        if (![self checkInternetAvailble]) {
            return;
        }
    }
    NSLog(@"deleteItems");
    
    NSIndexSet *selectedSet = [self selectedItems];
    if (selectedSet.count > 0) {
        _isDeletePlaylist = NO;
        NSString *str = nil;
        if (selectedSet.count == 1) {
            str = CustomLocalizedString(@"MSG_COM_Confirm_Before_Delete_2", nil);
        }else {
            str = CustomLocalizedString(@"MSG_COM_Confirm_Before_Delete", nil);
        }
        NSDictionary *dimensionDict = nil;
        @autoreleasepool {
            dimensionDict = [[TempHelper customDimension] copy];
        }
        [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Start transferCount:0 screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        if (dimensionDict) {
            [dimensionDict release];
            dimensionDict = nil;
        }
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil) CancelButton:CustomLocalizedString(@"Button_Cancel", nil)];
    }else {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_delete", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"iCloudBackup_View_Selected_Tips", nil);
        }
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }
}
- (void)toiTunes:(id)sender
{
    NSLog(@"toiTunes");
    NSIndexSet *selectedSet = [self selectedItems];
    if ([selectedSet count] <= 0) {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"iCloudBackup_View_Selected_Tips", nil);
        }
        
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }else {
        if (_category == Category_Applications) {
            //弹出路径选择框
            if ([_ipod.deviceInfo.getDeviceFloatVersionNumber isVersionMajorEqual:@"8.3"]) {
                //弹出警告确认框
                [self showAlertText:CustomLocalizedString(@"MSG_Device_Edition_Too_high", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }
        
        NSViewController *annoyVC = nil;
        long long result = [self checkNeedAnnoy:&(annoyVC)];
        if (result == 0) {
            return;
        }
        
        NSDictionary *toiTunesDic = nil;
        if (_category == Category_iBooks) {
            NSArray *selectedFile = [_arrayController selectedObjects];
            toiTunesDic = [NSDictionary dictionaryWithObjectsAndKeys:selectedFile, [NSNumber numberWithInt:_category], nil];
        }else {
            NSMutableArray *selectedTracks = [NSMutableArray array];
            NSArray *displayArray = nil;
            //            if (_isSearching) {
            //                displayArray = _searchingArray;
            //            }
            //            else{
            displayArray = _dataSourceArray;
            //            }
            
            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [selectedTracks addObject:[displayArray objectAtIndex:idx]];
            }];
            
            if (_category == Category_Playlist) {
                NSMutableArray *playlistArray = [NSMutableArray array];
                int row = (int)[[(IMBDevicePlaylistsViewController *)self playlistsTableView] selectedRow];
                [playlistArray addObject:[_playlistArray objectAtIndex:row]];
                NSDictionary *playlistDic = [NSDictionary dictionaryWithObjectsAndKeys:selectedTracks, @"TracksArray", playlistArray, @"PlaylistArray", nil];
                toiTunesDic = [NSDictionary dictionaryWithObjectsAndKeys:playlistDic, [NSNumber numberWithInt:_category], nil];
            }else {
                if (_category == Category_VoiceMemos) {
                    NSMutableArray *voiceMemosArray = [NSMutableArray array];
                    for (IMBRecordingEntry *entity in selectedTracks) {
                        IMBTrack *track = [[IMBTrack alloc] init];
                        int64_t dbid = entity.persistentID;
                        [track setFilePath:entity.path];
                        [track setIsVideo:NO];
                        NSString *path = [NSString stringWithFormat:@"Recordings/%@",[entity.path lastPathComponent]];
                        if (![[_ipod fileSystem] fileExistsAtPath:[[_ipod.fileSystem driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"/Books/%@",path.lastPathComponent]]]) {
                            NSLog(@"not exist");
                        }
                        [track setFileSize:(uint)[[_ipod fileSystem] getFileLength:[[[_ipod fileSystem] driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"Recordings/%@",[path lastPathComponent]]]]];
                        track.filePath = path;
                        track.dbID = dbid;
                        [track setTitle: entity.name];
                        [track setMediaType:VoiceMemo];
                        [voiceMemosArray addObject:track];
                        [track release];
                    }
                    toiTunesDic = [NSDictionary dictionaryWithObjectsAndKeys:voiceMemosArray, [NSNumber numberWithInt:_category], nil];
                    
                }else{
                    toiTunesDic = [NSDictionary dictionaryWithObjectsAndKeys:selectedTracks, [NSNumber numberWithInt:_category], nil];
                }
            }
            NSDictionary *dimensionDict = nil;
            @autoreleasepool {
                dimensionDict = [[TempHelper customDimension] copy];
            }
            [ATTracker event:Device_Content action:ToiTunes actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Start transferCount:selectedTracks.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            if (dimensionDict) {
                [dimensionDict release];
                dimensionDict = nil;
            }
        }
        
        if (_transferController != nil) {
            [_transferController release];
            _transferController = nil;
        }
        _transferController = [[IMBTransferViewController alloc] initWithIPodkey:_ipod.uniqueKey SelectDic:toiTunesDic];
        if (result>0) {
            [self animationAddTransferViewfromRight:_transferController.view AnnoyVC:annoyVC];
        }else {
            [self animationAddTransferView:_transferController.view];
        }
    }
}

- (void)toMac:(id)sender
{
    NSIndexSet *selectedSet = [self selectedItems];
    if ([selectedSet count] <= 0) {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"Export_View_Selected_Tips", nil);
        }
        
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }else {
        if (_category == Category_Applications) {
            //弹出路径选择框
            if ([_ipod.deviceInfo.getDeviceFloatVersionNumber isVersionMajorEqual:@"8.3"]) {
                //弹出警告确认框
                [self showAlertText:CustomLocalizedString(@"MSG_Device_Edition_Too_high", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }
    
        if ((_category == Category_PhotoLibrary||_category == Category_CameraRoll||_category == Category_PhotoStream||_category == Category_PhotoShare||_category == Category_Panoramas||_category == Category_ContinuousShooting||_category == Category_MyAlbums||_category == Category_LivePhoto||_category == Category_Screenshot||_category == Category_PhotoSelfies||_category == Category_Location||_category == Category_Favorite)&&!_isiCloudView) {
            IMBPhotoExportSettingConfig *exportSettingConfig = [IMBPhotoExportSettingConfig singleton];
            if (!exportSettingConfig.sureSaveCheckBtnState) {
                [self photoToMac];
            }else{
                NSString *str = CustomLocalizedString(@"Photo_Export_Set_id_14", nil);
                NSView *view = nil;
                for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
                    if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                        view = subView;
                        break;
                    }
                }
                if (view) {
                    [view setHidden:NO];
                    int i = [_alertViewController showDeleteConfrimText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)  CancelButton:CustomLocalizedString(@"Button_Cancel", nil) SuperView:view];
                    if (i == 1) {
                        int64_t delayInSeconds = 1;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [_alertViewController showPhotoAlertSettingSuperView:view withContinue:YES];
                        });
                    }else{
                        [self photoToMac];
                    }
                }
            }
        }else{
            //弹出路径选择框
            _openPanel = [NSOpenPanel openPanel];
            _isOpen = YES;
            [_openPanel setAllowsMultipleSelection:NO];
            [_openPanel setCanChooseFiles:NO];
            [_openPanel setCanChooseDirectories:YES];
            if (_ipod != nil) {
                [_openPanel setDirectory:_ipod.exportSetting.exportPath];
            }
            if (_category == Category_Music||_category == Category_CloudMusic||_category == Category_Movies||_category == Category_TVShow||_category == Category_MusicVideo||_category == Category_PodCasts||_category == Category_iTunesU||_category == Category_Audiobook||_category == Category_Ringtone||_category == Category_Playlist||_category == Category_HomeVideo||  _category == Category_VoiceMemos||  _category == Category_Applications||  _category == Category_PhotoLibrary || _category == Category_PhotoStream || _category == Category_PhotoVideo || _category == Category_CameraRoll||_category==Category_TimeLapse||_category==Category_SlowMove||_category==Category_Panoramas||_category == Category_ContinuousShooting||  _category == Category_Voicemail || _category == Category_MyAlbums|| _category == Category_LivePhoto|| _category == Category_Screenshot|| _category == Category_PhotoSelfies|| _category == Category_Location|| _category == Category_Favorite) {
                [_openPanel beginSheetModalForWindow:[(IMBDeviceMainPageViewController *)_delegate view].window completionHandler:^(NSInteger result) {
                    if (result== NSFileHandlingPanelOKButton) {
                        [self performSelector:@selector(mediatoMacDelay:) withObject:_openPanel afterDelay:0.1];
                    }
                    _isOpen = NO;
                }];
            }
            //system、Storage 导出到Mac
            else if (_category == Category_System || _category == Category_Storage||_category == Category_iBooks) {
                [_openPanel beginSheetModalForWindow:[(IMBDeviceMainPageViewController *)_delegate view].window completionHandler:^(NSInteger result) {
                    if (result== NSFileHandlingPanelOKButton) {
                        [self performSelector:@selector(systemtoMacDelay:) withObject:_openPanel afterDelay:0.1];
                    }else{
                        NSLog(@"other other other");
                    }
                    _isOpen = NO;
                }];
            }
            else if (_category == Category_Notes||_category == Category_Message||_category == Category_Calendar||_category == Category_Bookmarks||_category == Category_Contacts||_category == Category_SafariHistory||_category == Category_CallHistory) {
                [_openPanel beginSheetModalForWindow:[(IMBDeviceMainPageViewController *)_delegate view].window completionHandler:^(NSInteger result) {
                    if (result== NSFileHandlingPanelOKButton) {
                        [self performSelector:@selector(infortoMacDelay:) withObject:_openPanel afterDelay:0.1];
                    }else{
                        NSLog(@"other other other");
                    }
                    _isOpen = NO;
                }];
            }
            NSDictionary *dimensionDict = nil;
            @autoreleasepool {
                dimensionDict = [[TempHelper customDimension] copy];
            }
            if (_isiCloud) {
                [ATTracker event:iCloud_Content action:ContentToMac actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Start transferCount:selectedSet.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            }else{
                if (_ipod) {
                    [ATTracker event:Device_Content action:ContentToMac actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Start transferCount:selectedSet.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
                }else
                    [ATTracker event:iTunes_Backup action:ContentToMac actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Start transferCount:selectedSet.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            }
            if (dimensionDict) {
                [dimensionDict release];
                dimensionDict = nil;
            }
        }
    }
}

- (void)photoToMac{
    [self performSelector:@selector(photoToMacAler) withObject:nil afterDelay:0.1];
}

- (void)photoToMacAler{
    NSIndexSet *selectedSet = [self selectedItems];
    NSViewController *annoyVC = nil;
    long long result1 = 10;
    if (!_isiCloudView) {
        result1 = [self checkNeedAnnoy:&(annoyVC)];
        if (result1 == 0) {
            return;
        }
    }
    IMBPhotoExportSettingConfig *photoExport = [IMBPhotoExportSettingConfig singleton];
    NSString *path = photoExport.exportPath;
    NSString *filePath = [TempHelper createCategoryPath:[TempHelper createExportPath:path] withString:[IMBCommonEnum categoryNodesEnumToName:_category]];
    if (_category == Category_Playlist) {
        IMBPlaylist *currentPlaylist = nil;
        IMBDevicePlaylistsViewController *playlistsViewController = (IMBDevicePlaylistsViewController *)self;
        int seletedIndex =  (int)playlistsViewController.playlistsTableView.selectedRow;
        if (seletedIndex < _playlistArray.count && seletedIndex != -1) {
            currentPlaylist = [_playlistArray objectAtIndex:seletedIndex];
            filePath = [TempHelper createCategoryPath:filePath withString:currentPlaylist.name];
        }
    }
    [self copyTableViewContentToMac:filePath indexSet:selectedSet Result:result1 AnnoyVC:annoyVC];
}

- (void)mediatoMacDelay:(NSOpenPanel *)openPanel
{
    NSIndexSet *selectedSet = [self selectedItems];
    NSViewController *annoyVC = nil;
    long long result1 = 10;
    if (!_isiCloudView) {
        result1 = [self checkNeedAnnoy:&(annoyVC)];
        if (result1 == 0) {
            return;
        }
    }
    NSString * path =[[openPanel URL] path];
    NSString *filePath = [TempHelper createCategoryPath:[TempHelper createExportPath:path] withString:[IMBCommonEnum categoryNodesEnumToName:_category]];
    if (_category == Category_Playlist) {
        IMBPlaylist *currentPlaylist = nil;
        IMBDevicePlaylistsViewController *playlistsViewController = (IMBDevicePlaylistsViewController *)self;
        int seletedIndex =  (int)playlistsViewController.playlistsTableView.selectedRow;
        if (seletedIndex < _playlistArray.count && seletedIndex != -1) {
            currentPlaylist = [_playlistArray objectAtIndex:seletedIndex];
            filePath = [TempHelper createCategoryPath:filePath withString:currentPlaylist.name];
        }
    }
    [self copyTableViewContentToMac:filePath indexSet:selectedSet Result:result1 AnnoyVC:annoyVC];
}

- (void)systemtoMacDelay:(NSOpenPanel *)openPanel
{
    NSViewController *annoyVC = nil;
    long long result1 = [self checkNeedAnnoy:&(annoyVC)];
    if (result1 == 0) {
        return;
    }
    NSString *path = [[openPanel URL] path];
    NSString *filePath = [TempHelper createCategoryPath:[TempHelper createExportPath:path] withString:[IMBCommonEnum categoryNodesEnumToName:_category]];
    [self copyCollectionContentToMac:filePath Result:result1 AnnoyVC:annoyVC];
}
- (void)infortoMacDelay:(NSOpenPanel *)openPanel
{
    NSIndexSet *selectedSet = [self selectedItems];
    NSViewController *annoyVC = nil;
    long long result1 = 10;
    if (!_isiCloudView) {
        result1 = [self checkNeedAnnoy:&(annoyVC)];
        if (result1 == 0) {
            return;
        }
    }
    NSString *path = [[openPanel URL] path];
    NSString *filePath = [TempHelper createCategoryPath:[TempHelper createExportPath:path] withString:[IMBCommonEnum categoryNodesEnumToName:_category]];
    [self copyInfomationToMac:filePath indexSet:selectedSet Result:result1 AnnoyVC:annoyVC];
}

- (void)toDevice:(id)sender
{
    IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
    NSArray *array = [connection getOtherConnectedIPod:_ipod.uniqueKey];
    NSMutableArray *baseInfoArr = [NSMutableArray array];
    for (IMBiPod *ipod in array) {
        if (ipod.infoLoadFinished) {
            IMBBaseInfo *baseInfo = [connection getDeviceByKey:ipod.uniqueKey];
            [baseInfoArr addObject:baseInfo];
        }
    }
    if (baseInfoArr.count == 0) {
        [self showAlertText:CustomLocalizedString(@"Nothave_toDevices", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        return;
    }
    
    NSIndexSet *selectedSet = [self selectedItems];
    NSArray *playlistsArray = nil;
    if (_category == Category_Playlist) {
        IMBDevicePlaylistsViewController *controller = (IMBDevicePlaylistsViewController *)self;
        playlistsArray = controller.selectedPlaylists;
    }
    if ([selectedSet count] > 0 || playlistsArray.count > 0) {
        NSDictionary *dimensionDict = nil;
        @autoreleasepool {
            dimensionDict = [[TempHelper customDimension] copy];
        }
        [ATTracker event:Device_Content action:ToDevice actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Start transferCount:selectedSet.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        if (dimensionDict) {
            [dimensionDict release];
            dimensionDict = nil;
        }
        if (baseInfoArr.count == 1) {
            IMBBaseInfo *baseInfo = [baseInfoArr objectAtIndex:0];
            IMBiPod *tarIpod = [connection getIPodByKey:baseInfo.uniqueKey];
            if (_category == Category_Calendar) {
                BOOL open = [self chekiCloud:@"Calendars" withCategoryEnum:_category];
                if (!open) {
                    return;
                }
            }
            if (tarIpod.beingSynchronized) {
                [self showAlertText:CustomLocalizedString(@"AirsyncTips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
            if (_category == Category_Applications) {
                NSMutableArray *sourceApps = [[[NSMutableArray alloc] init] autorelease];
                [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [sourceApps addObject:[_dataSourceArray objectAtIndex:idx]];
                }];
                int i = [self addAppTodevice:tarIpod withSourceAppArray:sourceApps];
                if (i != 0) {
                    [self contentToDevice:playlistsArray indexSet:selectedSet tarIpod:tarIpod];
                }
            }else {
                [self contentToDevice:playlistsArray indexSet:selectedSet tarIpod:tarIpod];
            }
            
        }else {
            
            [self toDeviceWithSelectArray:baseInfoArr WithView:sender];
        }
    }
    else {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"iCloudBackup_View_Selected_Tips", nil);
        }
        
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }
}
- (void)doDeviceDetail:(id)sender
{
    NSLog(@"doDeviceDetail");
}
- (void)doSetting:(id)sender
{
    NSDictionary *dimensionDict = nil;
    @autoreleasepool {
        dimensionDict = [[TempHelper customDimension] copy];
    }
    [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Settings" label:Click transferCount:0 screenView:@"iCloud View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
    if (dimensionDict) {
        [dimensionDict release];
        dimensionDict = nil;
    }
    NSView *view = nil;
    if (_alertViewController == nil) {
        _alertViewController = [[IMBAlertViewController alloc] initWithNibName:@"IMBAlertViewController" bundle:nil];
        [_alertViewController setDelegate:self];
    }
    for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
        if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]) {
            view = subView;
            break;
        }
    }
    [view setHidden:NO];
    if (_category == Category_Ringtone) {
        if (sender) {
            [_alertViewController showRingToneAlertSettingSuperView:view withContinue:NO];
        }else {
            [_alertViewController showRingToneAlertSettingSuperView:view withContinue:YES];
        }
    }else if (_category == Category_PhotoLibrary||_category == Category_CameraRoll||_category == Category_PhotoStream||_category == Category_PhotoShare||_category == Category_Panoramas||_category == Category_ContinuousShooting||_category == Category_MyAlbums||_category == Category_LivePhoto||_category == Category_Screenshot||_category == Category_PhotoSelfies||_category == Category_Location||_category == Category_Favorite) {
        [_alertViewController showPhotoAlertSettingSuperView:view withContinue:NO];
    }else {
        [_alertViewController showAlertSettingSuperView:view withIpod:_ipod];
    }
}
- (void)doExit:(id)sender
{
    NSLog(@"doExit");
}
- (void)doEdit:(id)sender
{
    NSLog(@"doEdit");
}
- (void)doBackup:(id)sender
{
    NSLog(@"doBackup");
}
- (void)doExitiCloud:(id)sender
{
    NSLog(@"doExitiCloud");
}

- (void)dofindPath:(id)sender{
    NSLog(@"dofindPath");
}

- (void)doSwitchView:(id)sender
{
    NSLog(@"doSwitchView");
    [_delegate doSwitchView:sender];
}
- (void)doBack:(id)sender{
    NSLog(@"doBack");
    //TODO:屏蔽语言选择-----long
    NSString *str = @"open";
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ENTER_CHANGELAGUG_IPOD object:str];
    [_delegate doBackView:sender];
}

- (void)doImportContact:(id)sender{
    NSLog(@"doImportContact");
}

- (void)doToContact:(id)sender{
    NSLog(@"doToContact");
}

- (void)back:(id)sender
{
    [self.navigationController popViewController:self AnimationStyle:0];
}

- (void)setTableViewHeadCheckBtn{

}

#pragma mark - export Action
- (void)copyTableViewContentToMac:(NSString *)filePath indexSet:(NSIndexSet *)set Result:(long long)result AnnoyVC:(NSViewController *)annoyVC{
    //得出选中的track
    NSLog(@"===========");
    NSIndexSet *selectedSet = set;
    NSMutableArray *selectedTracks = [NSMutableArray array];
    NSArray *displayArray = nil;
    if (_isSearch) {
        displayArray = _researchdataSourceArray;
    }else{
        displayArray = _dataSourceArray;
    }
    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [selectedTracks addObject:[displayArray objectAtIndex:idx]];
    }];
    
    if (_category == Category_Voicemail) {
        [selectedTracks removeAllObjects];
        for (IMBVoiceMailAccountEntity *entity in displayArray) {
            for (IMBVoiceMailEntity *voiceEntity in entity.subArray) {
                if (voiceEntity.checkState == Check) {
                    [selectedTracks addObject:voiceEntity];
                }
            }
        }
    }
    
    if (_transferController != nil) {
        [_transferController release];
        _transferController = nil;
    }
    
    int exportType = 1;
    if (_isiCloud) {
        exportType = 3;
    }else {
        if ([self isKindOfClass:[IMBBackupCollectionViewController class]]) {
            exportType = 2;
        }
    }
    _transferController = [[IMBTransferViewController alloc] initWithIPodkey:_ipod.uniqueKey Type:_category SelectItems:selectedTracks ExportFolder:filePath];
    [_transferController setExportType:exportType];
    if (result>0) {
        [self animationAddTransferViewfromRight:_transferController.view AnnoyVC:annoyVC];
    }else{
        [self animationAddTransferView:_transferController.view];
    }
}

- (void)copyCollectionContentToMac:(NSString *)filePath Result:(long long)result AnnoyVC:(NSViewController *)annoyVC{
    NSArray *selectedFile = [_arrayController selectedObjects];
    
    if (_transferController != nil) {
        [_transferController release];
        _transferController = nil;
    }
    _transferController = [[IMBTransferViewController alloc] initWithIPodkey:_ipod.uniqueKey Type:_category SelectItems:(NSMutableArray *)selectedFile ExportFolder:filePath];
    if (result>0) {
        [self animationAddTransferViewfromRight:_transferController.view AnnoyVC:annoyVC];
    }else{
        [self animationAddTransferView:_transferController.view];
        
    }
}

- (void)copyInfomationToMac:(NSString *)filePath indexSet:(NSIndexSet *)set Result:(long long)result AnnoyVC:(NSViewController *)annoyVC{
    NSMutableArray *disAry = nil;
    if (_isSearch) {
        disAry = _researchdataSourceArray;
    }else{
        disAry = _dataSourceArray;
    }
    NSMutableArray *selectedArray = [NSMutableArray array];
    if (_category == Category_Calendar && [self isKindOfClass:[IMBCalendarViewController class]]) {
        [selectedArray addObjectsFromArray:[(IMBCalendarViewController *)self selectItems]];
    }else {
        NSIndexSet *selectedSet = set;
        NSArray *displayArray = disAry;
        [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [selectedArray addObject:[displayArray objectAtIndex:idx]];
        }];
    }
    
    NSString *mode = @"";
    if (_ipod != nil) {
        if (_category == Category_Notes) {
            mode = [_ipod.exportSetting getExportExtension:_ipod.exportSetting.notesType];
        }
        //message 导出到Mac
        else if (_category == Category_Message) {
            mode = [_ipod.exportSetting getExportExtension:_ipod.exportSetting.messageType];
        }
        else if (_category == Category_Calendar){
            mode = [_ipod.exportSetting getExportExtension:_ipod.exportSetting.calenderType];
        }
        else if (_category == Category_Bookmarks) {
            mode = [_ipod.exportSetting getExportExtension:_ipod.exportSetting.safariType];
        }
        else if (_category == Category_Contacts){
            mode = [_ipod.exportSetting getExportExtension:_ipod.exportSetting.contactType];
        }
        else if (_category == Category_SafariHistory){
            mode = [_ipod.exportSetting getExportExtension:_ipod.exportSetting.safariHistoryType];
        }
        else if (_category == Category_CallHistory) {
            mode = [_ipod.exportSetting getExportExtension:_ipod.exportSetting.callHistoryType];
        }
        else if (_category == Category_Reminder) {
            mode = [_ipod.exportSetting getExportExtension:_ipod.exportSetting.reminderType];
        }
    }else {
        if (_exportSetting != nil) {
            [_exportSetting release];
            _exportSetting = nil;
        }
        _exportSetting = [[IMBExportSetting alloc] initWithIPod:nil];
        NSDictionary *dimensionDict = nil;
        @autoreleasepool {
            dimensionDict = [[TempHelper customDimension] copy];
        }
        if (_category == Category_Notes) {
            mode = [_exportSetting getExportExtension:_exportSetting.notesType];
            [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Notes Send to Mac" label:Finish transferCount:0 screenView:@"Notes View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        }
        //message 导出到Mac
        else if (_category == Category_Message) {
            mode = [_exportSetting getExportExtension:_exportSetting.messageType];
        }
        else if (_category == Category_Calendar){
            mode = [_exportSetting getExportExtension:_exportSetting.calenderType];
            [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Calendar Send to Mac" label:Finish transferCount:0 screenView:@"Calendar View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        }
        else if (_category == Category_Bookmarks) {
            mode = [_exportSetting getExportExtension:_exportSetting.safariType];
        }
        else if (_category == Category_Contacts){
            mode = [_exportSetting getExportExtension:_exportSetting.contactType];
            [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Contacts Send to Mac" label:Finish transferCount:0 screenView:@"Contacts View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        }
        else if (_category == Category_SafariHistory){
            mode = [_exportSetting getExportExtension:_exportSetting.safariHistoryType];
        }
        else if (_category == Category_CallHistory) {
            mode = [_exportSetting getExportExtension:_exportSetting.callHistoryType];
        }
        else if (_category == Category_Reminder) {
            mode = [_exportSetting getExportExtension:_exportSetting.reminderType];
            [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Reminder Send to Mac" label:Finish transferCount:0 screenView:@"Reminder View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        }
        if (dimensionDict) {
            [dimensionDict release];
            dimensionDict = nil;
        }
    }
    if (_transferController != nil) {
        [_transferController release];
        _transferController = nil;
    }
    
    if (_isiCloudView) {
        _transferController =[[IMBTransferViewController alloc] initWithType:_category SelectItems:selectedArray ExportFolder:filePath Mode:mode IsicloudView:_isiCloudView];
    } else {
        _transferController = [[IMBTransferViewController alloc] initWithType:_category SelectItems:selectedArray ExportFolder:filePath Mode:mode];
    }
    
    if (result>0) {
        [self animationAddTransferViewfromRight:_transferController.view AnnoyVC:annoyVC];
    }else{
        [self animationAddTransferView:_transferController.view];
        
    }
}

#pragma mark - import Action
- (void)importToDevice:(NSMutableArray *)paths photoAlbum:(IMBPhotoEntity *)photoAlbum playlistID:(int64_t)playlistID Result:(long long)result AnnoyVC:(NSViewController *)annoyVC{
    if (_transferController != nil) {
        [_transferController release];
        _transferController = nil;
    }
    _transferController = [[IMBTransferViewController alloc] initWithIPodkey:_ipod.uniqueKey Type:_category importFiles:paths photoAlbum:photoAlbum playlistID:playlistID];
    [_transferController setDelegate:self];
    if (result>0) {
        [self animationAddTransferViewfromRight:_transferController.view AnnoyVC:annoyVC];
    }else{
        [self animationAddTransferView:_transferController.view];
        
        
    }
}

#pragma mark - delete Action
-(void)deleteBackupSelectedItems:(id)sender {
    if (_delArray != nil) {
        [_delArray release];
        _delArray = nil;
    }
    _delArray = [[NSMutableArray alloc]init];
    [_alertViewController._removeprogressAnimationView setProgress:0];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSIndexSet *selectedSet = [self selectedItems];
        NSMutableArray *disAry = nil;
        if (_isSearch) {
            disAry = _researchdataSourceArray;
        }else{
            disAry = _dataSourceArray;
        }
        NSMutableArray *selectedTracks = [[[NSMutableArray alloc] init] autorelease];
        [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [selectedTracks addObject:[disAry objectAtIndex:idx]];
        }];
        NSDictionary *dimensionDict = nil;
        @autoreleasepool {
            dimensionDict = [[TempHelper customDimension] copy];
        }

        if (_category == Category_LivePhoto||_category == Category_Screenshot||_category == Category_PhotoSelfies||_category == Category_Location||_category == Category_Favorite) {
            NSMutableArray *photoLibraryAry = [[NSMutableArray alloc]init];
            NSMutableArray *cameraRollAry = [[NSMutableArray alloc]init];
            for (IMBPhotoEntity *entity in selectedTracks) {
                if ([entity.thumbPath rangeOfString:@"PhotoData/Sync"].location != NSNotFound||[entity.thumbPath rangeOfString:@"PhotoData/CPLAssets"].location != NSNotFound) {
                    [photoLibraryAry addObject:entity];
                }else{
                    [cameraRollAry addObject:entity];
                }
            }
            if (photoLibraryAry.count > 0 && cameraRollAry.count == 0) {
                for (IMBPhotoEntity *entity in selectedTracks) {
                    IMBTrack *track = [[IMBTrack alloc] init];
                    track.photoZpk = entity.photoZpk;
                    [track setMediaType:Photo];
                    [_delArray addObject:track];
                    [track release];
                }
                IMBDeleteTrack *deleteTrack = [[IMBDeleteTrack alloc] initWithIPod:_ipod deleteArray:_delArray Category:_category];
                [deleteTrack setDelegate:self];
                [deleteTrack startDelete];
                [deleteTrack release];
            }else if (photoLibraryAry.count == 0 && cameraRollAry.count > 0) {
                if (camera != nil) {
                    [camera release];
                    camera = nil;
                }
                camera = [[IMBDeleteCameraRollPhotos alloc] initWithArray:selectedTracks withIpod:_ipod];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_alertViewController._removeprogressAnimationView setProgressWithOutAnimation:96];
                    [camera startDeviceBrowser];
                    sleep(1);
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        [_alertViewController._removeprogressAnimationView setProgressWithOutAnimation:100];
                        [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:selectedTracks.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
                        [self showRemoveSuccessAlertText:CustomLocalizedString(@"MSG_COM_Delete_Complete", nil) withCount:(int)selectedTracks.count];
                        [self reload:nil];
                    });
                    
                });
            }else{
                for (IMBPhotoEntity *entity in photoLibraryAry) {
                    IMBTrack *track = [[IMBTrack alloc] init];
                    track.photoZpk = entity.photoZpk;
                    [track setMediaType:Photo];
                    [_delArray addObject:track];
                    [track release];
                }
                IMBDeleteTrack *deleteTrack = [[IMBDeleteTrack alloc] initWithIPod:_ipod deleteArray:_delArray Category:_category];
                [deleteTrack setDelegate:self];
                [deleteTrack startDelete];
                [deleteTrack release];
                
                if (camera != nil) {
                    [camera release];
                    camera = nil;
                }
                camera = [[IMBDeleteCameraRollPhotos alloc] initWithArray:cameraRollAry withIpod:_ipod];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_alertViewController._removeprogressAnimationView setProgressWithOutAnimation:100];
                    [camera startDeviceBrowser];
                    sleep(1);
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        [_alertViewController._removeprogressAnimationView setProgressWithOutAnimation:100];
                        [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:selectedTracks.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
                        [self showRemoveSuccessAlertText:CustomLocalizedString(@"MSG_COM_Delete_Complete", nil) withCount:(int)selectedTracks.count];
                        [self reload:nil];
                    });
                });
            }

            [photoLibraryAry release];
            [cameraRollAry release];
            cameraRollAry = nil;
            photoLibraryAry = nil;
        }else if (_category == Category_PhotoLibrary || _category == Category_MyAlbums ) {
            for (IMBPhotoEntity *entity in selectedTracks) {
                IMBTrack *track = [[IMBTrack alloc] init];
                track.photoZpk = entity.photoZpk;
                [track setMediaType:Photo];
                [_delArray addObject:track];
                [track release];
            }
            IMBDeleteTrack *deleteTrack = [[IMBDeleteTrack alloc] initWithIPod:_ipod deleteArray:_delArray Category:_category];
            [deleteTrack setDelegate:self];
            [deleteTrack startDelete];
            [deleteTrack release];
            [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:0 screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        }else if (_category == Category_Music||_category == Category_Movies||_category == Category_TVShow||_category == Category_MusicVideo||_category == Category_PodCasts||_category == Category_iTunesU||_category == Category_Audiobook||_category == Category_Ringtone || _category == Category_Playlist||_category == Category_HomeVideo)
        {
            IMBDeleteTrack *deleteTrack = [[IMBDeleteTrack alloc] initWithIPod:_ipod deleteArray:selectedTracks Category:_category];
            [deleteTrack setDelegate:self];
            [deleteTrack startDelete];
            [deleteTrack release];
            [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:0 screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        }else if (_category == Category_Applications)
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                IMBDeleteApps *procedure = [[IMBDeleteApps alloc]initWithIPod:_ipod deleteArray:selectedTracks]; //initWithIPodKey:_ipod.uniqueKey deleteAppsArray:selectedItems];
                [procedure startDelete];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_alertViewController._removeprogressAnimationView setProgressWithOutAnimation:100];
                    [self showRemoveSuccessAlertText:CustomLocalizedString(@"MSG_COM_Delete_Complete", nil) withCount:(int)selectedTracks.count];
                    [self reload:nil];
                    [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:0 screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
                });
                [procedure release];
            });
        }
        else if(_category == Category_iBooks){
            for (IMBBookEntity *bookEntity in selectedTracks) {
                IMBTrack *newTrack = [[[IMBTrack alloc] init] autorelease];
                int64_t dbid = 0;
                if ([self isUnusualPersistentID:bookEntity.bookID]) {
                    [newTrack setIsUnusual:YES];
                    [newTrack setHexPersistentID:bookEntity.bookID];
                }else{
                    dbid = [bookEntity.bookID longLongValue];
                }
                [newTrack setArtist:bookEntity.author];
                [newTrack setGenre:bookEntity.genre];
                
                NSString *path = [NSString stringWithFormat:@"Books/%@",[bookEntity.path lastPathComponent]];
                
                [newTrack setAlbumArtist:bookEntity.album];
                [newTrack setTitle:bookEntity.bookName.length == 0 ? @"0":bookEntity.bookName];
                [newTrack setFilePath:path];
                [newTrack setIsVideo:NO];
                NSString *publisherUniqueID = bookEntity.publisherUniqueID;
                NSString *packageHash = bookEntity.packageHash;
                MediaTypeEnum type;
                if ([[path pathExtension].lowercaseString isEqualToString:@"epub"]) {
                    type = Books;
                    [newTrack setFileSize:(uint)[[_ipod fileSystem] getFolderSize:[[[_ipod fileSystem] driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"Books/%@",[path lastPathComponent]]]]];
                }
                else{
                    type = PDFBooks;
                    [newTrack setFileSize:(uint)[[_ipod fileSystem] getFileLength:[[[_ipod fileSystem] driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"Books/%@",[path lastPathComponent]]]]];
                }
                [newTrack setMediaType:type];
                //                if (![[_ipod fileSystem] fileExistsAtPath:[[_ipod.fileSystem driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"/Books/%@",path.lastPathComponent]]]) {
                //                    NSLog(@"not exsit");
                //                }
                //                else{
                //                    if ((packageHash == nil || packageHash.length == 0) && type == Books) {
                //                        NSDictionary *dic = [IMBSyncBookPlistBuilder getRemoteEpubInfoDic:[NSString stringWithFormat:@"Books/%@",[path lastPathComponent]] withIpod:_ipod];
                //                        publisherUniqueID = [dic objectForKey:@"uuid"];
                //                        [newTrack setArtist:[dic objectForKey:@"artist"]];
                //                        [newTrack setTitle:((NSString *)[dic objectForKey:@"name"]).length == 0 ? @"0":[dic objectForKey:@"name"]];
                //                        [newTrack setGenre:[dic objectForKey:@"genre"]];
                //                        packageHash = [dic objectForKey:@"file-package-hash"];
                //                    }
                //                }
                newTrack.dbID = dbid;
                newTrack.uuid = publisherUniqueID;
                newTrack.mediaType = type;
                newTrack.packageHash = packageHash;
                [_delArray addObject:newTrack];
                [newTrack release];
            }
            IMBDeleteTrack *deleteTrack = [[IMBDeleteTrack alloc] initWithIPod:_ipod deleteArray:_delArray Category:_category];
            [deleteTrack setDelegate:self];
            [deleteTrack startDelete];
            [deleteTrack release];
            [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:0 screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            
        }
        else if (_category == Category_VoiceMemos)
        {
            for (IMBRecordingEntry *entity in selectedTracks) {
                IMBTrack *track = [[IMBTrack alloc] init];
                int64_t dbid = entity.persistentID;
                [track setFilePath:entity.path];
                [track setIsVideo:NO];
                NSString *path = [NSString stringWithFormat:@"Recordings/%@",[entity.path lastPathComponent]];
                if (![[_ipod fileSystem] fileExistsAtPath:[[_ipod.fileSystem driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"/Books/%@",path.lastPathComponent]]]) {
                    NSLog(@"not exist");
                }
                [track setFileSize:(uint)[[_ipod fileSystem] getFileLength:[[[_ipod fileSystem] driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"Recordings/%@",[path lastPathComponent]]]]];
                track.filePath = path;
                track.dbID = dbid;
                [track setTitle: entity.name];
                [track setMediaType:VoiceMemo];
                [_delArray addObject:track];
                [track release];
            }
            IMBDeleteTrack *deleteTrack = [[IMBDeleteTrack alloc] initWithIPod:_ipod deleteArray:_delArray Category:_category];
            [deleteTrack setDelegate:self];
            [deleteTrack startDelete];
            [deleteTrack release];
            [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:0 screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        }else if (_category == Category_Notes){
            IMBNotesManager *noteManager = [[IMBNotesManager alloc] initWithAMDevice:_ipod.deviceHandle];
            [noteManager openMobileSync];
            [noteManager delNotes:selectedTracks];
            [noteManager closeMobileSync];
            [noteManager release];
            
            IMBInformationManager *manager = [IMBInformationManager shareInstance];
            IMBInformation *information = [manager.informationDic objectForKey:_ipod.deviceHandle.udid];
            [information loadNote];
            [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:0 screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            
        }else if (_category == Category_CameraRoll || _category == Category_PhotoVideo||_category == Category_TimeLapse||_category==Category_Panoramas||_category == Category_SlowMove) {
            if (camera != nil) {
                [camera release];
                camera = nil;
            }
            camera = [[IMBDeleteCameraRollPhotos alloc] initWithArray:selectedTracks withIpod:_ipod];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [_alertViewController._removeprogressAnimationView setProgressWithOutAnimation:96];
                [camera startDeviceBrowser];
                sleep(1);
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [_alertViewController._removeprogressAnimationView setProgressWithOutAnimation:100];
                    [ATTracker event:Device_Content action:Delete actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Finish transferCount:selectedTracks.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
                    [self showRemoveSuccessAlertText:CustomLocalizedString(@"MSG_COM_Delete_Complete", nil) withCount:(int)selectedTracks.count];
                    [self reload:nil];
                });
                
            });
        }
        if (dimensionDict) {
            [dimensionDict release];
            dimensionDict = nil;
        }
    });
}

- (BOOL)isUnusualPersistentID:(NSString *)persistentID{
    for (int i = 0; i < persistentID.length; i ++) {
        unichar charcode = [persistentID characterAtIndex:i];
        if ((charcode > 'a' && charcode < 'z') || (charcode >= 'A' && charcode <= 'Z')) {
            return YES;
        }
    }
    return NO;
}

- (void)setDeleteProgress:(float)progress withWord:(NSString *)msgStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_alertViewController._removeprogressAnimationView setProgress:progress];
        [_alertViewController showChangeRemoveProgressViewTitle:msgStr];
    });
}

- (void)setDeleteComplete:(int)success totalCount:(int)totalCount {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_alertViewController._removeprogressAnimationView setProgressWithOutAnimation:100];
        [self showRemoveSuccessAlertText:CustomLocalizedString(@"MSG_COM_Delete_Complete", nil) withCount:success];
        [self reload:nil];
    });
}

#pragma mark - toDevice Action
//检查是否有另一个设备准备好 可以clone和merge、todevice
- (BOOL)checkDeviceReady:(BOOL)todevice {
    BOOL ready = NO;
    IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
    NSArray *array = [connection getConnectedIPods];
    int totalDeviceCount = 0;
    for (IMBiPod *ipod in array) {
        if (![ipod.uniqueKey isEqualToString:_ipod.uniqueKey]/* && ipod.infoLoadFinished*/) {
            if (todevice) {
                totalDeviceCount ++;
            }else {
                if (ipod.deviceInfo.isIOSDevice) {
                    totalDeviceCount ++;
                }
            }
        }
    }
    if (totalDeviceCount == 0) {
        if (todevice) {
            [self showAlertText:CustomLocalizedString(@"Nothave_toDevices", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        }else {
            [self showAlertText:CustomLocalizedString(@"Nothave_iOS_toDevices", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        }
    }else{
        ready = YES;
    }
    return ready;
}

- (void)toDeviceWithSelectArray:(NSMutableArray *)selectArry WithView:(NSView *)view{
    if (_toDevicePopover != nil) {
        [_toDevicePopover release];
        _toDevicePopover = nil;
    }
    _toDevicePopover = [[NSPopover alloc] init];
    
    if ([[SystemHelper getSystemLastNumberString] isVersionMajorEqual:@"10"]) {
        _toDevicePopover.appearance = (NSPopoverAppearance)[NSAppearance appearanceNamed:NSAppearanceNameAqua];
    }else {
        _toDevicePopover.appearance = NSPopoverAppearanceMinimal;
    }
    
    _toDevicePopover.animates = YES;
    _toDevicePopover.behavior = NSPopoverBehaviorTransient;
    _toDevicePopover.delegate = self;
    
    IMBToDevicePopoverViewController *toDevicePopVC = [[IMBToDevicePopoverViewController alloc]initWithNibName:@"IMBToDevicePopoverViewController" bundle:nil WithDevice:selectArry];
    [toDevicePopVC setTarget:self];
    if (view.tag == 1111) {
        [toDevicePopVC setAction:@selector(toiCloudItemClicked:)];
    }else{
        if (_isiCloudView) {
            [toDevicePopVC setAction:@selector(onItemiCloudClicked:)];
        }else if (_isAndroidView) {
            [toDevicePopVC setAction:@selector(onItemAndroidClicked:)];
        }else {
            [toDevicePopVC setAction:@selector(onItemClicked:)];
        }
    }
    
    if (_toDevicePopover != nil) {
        _toDevicePopover.contentViewController = toDevicePopVC;
    }
    
    [toDevicePopVC release];
    
    NSRectEdge prefEdge = NSMaxYEdge;
    NSRect rect = NSMakeRect(0, 0,  0, 0);
    [_toDevicePopover showRelativeToRect:rect ofView:view preferredEdge:prefEdge];
}

- (void)toiCloudItemClicked:(id)sender{
    [_toDevicePopover close];
    IMBBaseInfo *baseInfo = (IMBBaseInfo *)sender;
    IMBDeviceConnection *deviceConnection = [IMBDeviceConnection singleton];
    _iCloudManager = [[deviceConnection.iCloudDic objectForKey:baseInfo.uniqueKey] iCloudManager];
    _iCloudManager.delegate = self;
    if (_isAndroid) {
        [self androidChooseiCloudToiCloud:nil];
    }else{
        [self deviceToiCloud:nil];
    }
}

- (void)onItemClicked:(id)sender {
    IMBBaseInfo *baseInfo = (IMBBaseInfo *)sender;
    [_toDevicePopover close];
    
    NSIndexSet *selectedSet = [self selectedItems];
    NSArray *playlistsArray = nil;
    if (_category == Category_Playlist) {
        IMBDevicePlaylistsViewController *controller = (IMBDevicePlaylistsViewController *)self;
        playlistsArray = controller.selectedPlaylists;
    }
    
    if ([selectedSet count] > 0 || playlistsArray.count > 0) {
        IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
        IMBiPod *tarIpod = [connection getIPodByKey:baseInfo.uniqueKey];
        if (_category == Category_Calendar) {
            BOOL open = [self chekiCloud:@"Calendars" withCategoryEnum:_category];
            if (!open) {
                return;
            }
        }
        if (tarIpod.beingSynchronized) {
            [self showAlertText:CustomLocalizedString(@"AirsyncTips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }
        if (_category == Category_Applications) {
            NSMutableArray *disAry = nil;
            if (_isSearch) {
                disAry = _researchdataSourceArray;
            }else{
                disAry = _dataSourceArray;
            }
            NSMutableArray *sourceApps = [[[NSMutableArray alloc] init] autorelease];
            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [sourceApps addObject:[disAry objectAtIndex:idx]];
            }];
            int i = [self addAppTodevice:tarIpod withSourceAppArray:sourceApps];
            if (i != 0) {
                [self contentToDevice:playlistsArray indexSet:selectedSet tarIpod:tarIpod];
            }
        }else {
            [self contentToDevice:playlistsArray indexSet:selectedSet tarIpod:tarIpod];
        }
    }else {
        //弹出警告确认框
        [self showAlertText:CustomLocalizedString(@"MSG_COM_No_Item_Selected", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }
}

- (void)onItemAndroidClicked:(id)sender {
    IMBBaseInfo *baseInfo = (IMBBaseInfo *)sender;
    [_toDevicePopover close];
    NSIndexSet *selectedSet = [self selectedAndroidItems];
    if ([selectedSet count] > 0 ) {
        IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
        IMBiPod *tarIpod = [connection getIPodByKey:baseInfo.uniqueKey];
        if (tarIpod.beingSynchronized) {
            [self showAlertText:CustomLocalizedString(@"AirsyncTips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }
        if (_category == Category_Music) {
            if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.Music"] == nil) {
                NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"MenuItem_id_1", nil)];
                [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }else if (_category == Category_Contacts){
            if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.MobileAddressBook"] == nil) {
                NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"MenuItem_id_20", nil)];
                [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }else if (_category == Category_Calendar){
            if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.mobilecal"] == nil) {
                NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"MenuItem_id_62", nil)];
                [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }else if (_category == Category_Movies){
            if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.videos"] == nil) {
                
                NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"MenuItem_id_33", nil)];
                [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }else if (_category == Category_iBooks){
            if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.iBooks"] == nil) {
                NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"iBook_id_3", nil)];
                [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }
        if (![tarIpod.deviceInfo.deviceClass isEqualToString:@"iPhone"]) {
            if (_category == Category_CallHistory) {
                [self showAlertText:CustomLocalizedString(@"Android_to_iOS_message_1", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            }else{
                [self contentAndroidToiOSDeviceIndexSet:selectedSet tarIpod:tarIpod];
            }
        }else{
            [self contentAndroidToiOSDeviceIndexSet:selectedSet tarIpod:tarIpod];
        }
    }else {
        //弹出警告确认框
        [self showAlertText:CustomLocalizedString(@"MSG_COM_No_Item_Selected", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }
}

- (void)onItemiCloudClicked:(id)sender {
    
}

- (void)contentAndroidToiCloudIndexSet:(NSIndexSet *)selectedSet iCloudManager:(IMBiCloudManager *)iCloudManager withAndroid:(IMBAndroid *)android{
    NSMutableArray *preparedArray = [NSMutableArray array];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *selectedAry = [NSMutableArray array];
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else{
        if (_category == Category_Photo) {
            displayArr = _baseAry;
        } else {
            displayArr = _dataSourceArray;
        }
        
    }
    NSArray *contactArray = nil;
    if (_category == Category_Calendar) {
        for (IMBCalendarAccountEntity *accountEntity in displayArr) {
            if (accountEntity.checkState != UnChecked) {
                IMBCalendarAccountEntity *calendarEntity = [[IMBCalendarAccountEntity alloc]init];
                calendarEntity.accountName = accountEntity.accountName;
                calendarEntity.displayName = accountEntity.displayName;
                calendarEntity.accountId = accountEntity.accountId;
                for (IMBADCalendarEntity *entity in accountEntity.eventArray) {
                    if (entity.checkState == Check) {
                        [calendarEntity.eventArray addObject:entity];
                    }
                }
                [selectedAry addObject:calendarEntity];
                [calendarEntity release];
                calendarEntity = nil;
            }
        }
        contactArray = selectedAry;
        [dataDic setObject:selectedAry forKey:@(Category_Calendar)];
    }else if (_category == Category_Photo) {
        [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [preparedArray addObject:[displayArr objectAtIndex:idx]];
        }];
        NSMutableArray *photoSelectedAry = [[[NSMutableArray alloc] init] autorelease];
        if (preparedArray != nil && preparedArray.count >0) {
            IMBADPhotoEntity *photoEntity = [preparedArray objectAtIndex:0];
            IMBADAlbumEntity *newAlbumEntity = [[IMBADAlbumEntity alloc]init];
            for (IMBADAlbumEntity *albumEntity in _dataSourceArray) {
                if ([albumEntity.photoArray containsObject:photoEntity]) {
                    newAlbumEntity.albumName = albumEntity.albumName;
                    break;
                }
            }
            newAlbumEntity.photoArray = preparedArray;
            [photoSelectedAry addObject:newAlbumEntity];
            [newAlbumEntity release];
            newAlbumEntity = nil;
        }
        contactArray = photoSelectedAry;
        [dataDic setObject:contactArray forKey:@(Category_Photo)];
    }else{
        [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [preparedArray addObject:[displayArr objectAtIndex:idx]];
        }];
        contactArray = preparedArray;
        if (contactArray.count>0) {
            if (_category == Category_Contacts) {
                [dataDic setObject:contactArray forKey:@(Category_Contacts)];
            }
        }
    }
    if (_androidTransController != nil) {
        [_androidTransController release];
        _androidTransController = nil;
    }
    _androidTransController = [[IMBAndroidTransferViewController alloc] initWithAndroidToiCloud:_iCloudManager withAndroid:_android SelectDic:dataDic withDataAry:contactArray withCategoryNodesEnum:_category];
    [self animationAddTransferView:_androidTransController.view];
}

- (void)contentAndroidToiOSDeviceIndexSet:(NSIndexSet *)selectedSet tarIpod:(IMBiPod *)tarIpod {
    NSMutableArray *preparedArray = [NSMutableArray array];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else{
        if (_category == Category_Photo) {
            displayArr = _baseAry;
        } else {
            displayArr = _dataSourceArray;
        }
    }
    if (_category == Category_Calendar) {
        
        [preparedArray addObjectsFromArray:[self selectAndroidCalendarItems]];
        if (preparedArray.count <= 0) {
            //弹出警告确认框,提示至少要选择一个有效的数据
            [self showAlertText:CustomLocalizedString(@"MSG_COM_No_Item_Selected", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }
        IMBInformationManager *manager= [IMBInformationManager shareInstance];
        IMBInformation *information = [manager.informationDic objectForKey:tarIpod.uniqueKey];
        if (information.calendarArray.count > 0) {
            IMBCalendarEntity *calendarEntity = [information.calendarArray objectAtIndex:0];
            [dictionary setObject:calendarEntity.calendarID forKey:@"calendarID"];
        }else {
            //弹出警告确认框,提示目标设备没有calendar 组
            [self showAlertText:CustomLocalizedString(@"MSG_COM_No_Item_Selected", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }
        
    } else if (_category == Category_Photo){
        [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [preparedArray addObject:[displayArr objectAtIndex:idx]];
        }];
        
        if (preparedArray.count <= 0) {
            //弹出警告确认框,提示至少要选择一个有效的数据
            [self showAlertText:CustomLocalizedString(@"MSG_COM_No_Item_Selected", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }
    } else {
        [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [preparedArray addObject:[displayArr objectAtIndex:idx]];
        }];
        
        if (preparedArray.count <= 0) {
            //弹出警告确认框,提示至少要选择一个有效的数据
            [self showAlertText:CustomLocalizedString(@"MSG_COM_No_Item_Selected", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }
    }
    if (_category == Category_Photo) {
        NSMutableArray *photoSelectedAry = [[NSMutableArray alloc]init];
        if (preparedArray != nil && preparedArray.count >0) {
            IMBADPhotoEntity *photoEntity = [preparedArray objectAtIndex:0];
            IMBADAlbumEntity *newAlbumEntity = [[IMBADAlbumEntity alloc]init];
            for (IMBADAlbumEntity *albumEntity in _dataSourceArray) {
                if ([albumEntity.photoArray containsObject:photoEntity]) {
                    newAlbumEntity.albumName = albumEntity.albumName;
                    break;
                }
            }
            newAlbumEntity.photoArray = preparedArray;
            [photoSelectedAry addObject:newAlbumEntity];
            [newAlbumEntity release];
            newAlbumEntity = nil;
        }
        
        if (photoSelectedAry.count <= 0) {
            //弹出警告确认框,提示至少要选择一个有效的数据
            [self showAlertText:CustomLocalizedString(@"MSG_COM_No_Item_Selected", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }
        
        [dictionary setObject:photoSelectedAry forKey:@(Category_MyAlbums)];
        [photoSelectedAry release];
        photoSelectedAry = nil;
    }else if (_category == Category_CallHistory){
        NSMutableArray *seletedArray = [NSMutableArray array];
        for (IMBADCallContactEntity *adcon in preparedArray) {
            if (adcon.checkState != NSOffState) {
                IMBADCallContactEntity *newadcon = [[IMBADCallContactEntity alloc] init];
                for (IMBADCallHistoryEntity *call in adcon.callArray) {
                    if (call.checkState == NSOnState) {
                        [newadcon.callArray addObject:call];
                    }
                }
                [seletedArray addObject:newadcon];
                [newadcon release];
            }
        }
        [dictionary setObject:seletedArray forKey:@(Category_CallHistory)];
    }else {
        if (preparedArray == nil) {
            preparedArray= [NSMutableArray array];
        }
        [dictionary setObject:preparedArray forKey:@(_category)];
    }
    
    
    
    if (_androidTransController != nil) {
        [_androidTransController release];
        _androidTransController = nil;
    }
    _androidTransController = [[IMBAndroidTransferViewController alloc] initWithIpodKey:tarIpod withAndroid:_android SelectDic:dictionary withCategoryNodesEnum:_category];
    [self animationAddTransferView:_androidTransController.view];
}

- (void)contentToDevice:(NSArray *)playlistsArray indexSet:(NSIndexSet *)selectedSet tarIpod:(IMBiPod *)tarIpod {
    NSViewController *annoyVC = nil;
    long long result = [self checkNeedAnnoy:&(annoyVC)];
    if (result == 0) {
        return;
    }
    
    BOOL isSupportCategory = FALSE;
    if (_category == Category_Music||_category == Category_Movies||_category == Category_TVShow||_category == Category_MusicVideo||_category == Category_PodCasts||_category == Category_iTunesU||_category == Category_Audiobook||_category == Category_Ringtone||_category == Category_Playlist||_category == Category_HomeVideo||_category == Category_VoiceMemos||_category == Category_Applications||_category == Category_iBooks) {
        if (![self checkInternetAvailble]) {
            return;
        }
        isSupportCategory = YES;
    }else if (_category == Category_PhotoLibrary || _category == Category_PhotoStream || _category == Category_PhotoVideo || _category == Category_CameraRoll || _category == Category_Panoramas||_category == Category_ContinuousShooting||_category == Category_MyAlbums || _category == Category_PhotoShare||_category == Category_Notes||_category == Category_Contacts||_category == Category_Bookmarks||_category == Category_System||_category == Category_Calendar || _category == Category_SlowMove || _category == Category_TimeLapse || _category == Category_LivePhoto || _category == Category_Screenshot || _category == Category_PhotoSelfies || _category == Category_Location || _category == Category_Favorite) {
        isSupportCategory = YES;
    }
    if (isSupportCategory) {
        NSMutableArray *preparedArray = [NSMutableArray array];
        IMBPhotoEntity *albumEntity = nil;
        if ([self isKindOfClass:[IMBMyAlbumsViewController class]]) {
            int row = (int)[[(IMBMyAlbumsViewController *)self albumTableView] selectedRow];
            albumEntity = [_playlistArray objectAtIndex:row];
            preparedArray = [(IMBMyAlbumsViewController *)self getSelectedItemsArray:selectedSet];
        }
        else if ([self isKindOfClass:[IMBDevicePlaylistsViewController class]]) {
            IMBDevicePlaylistsViewController *controller = (IMBDevicePlaylistsViewController *)self;
            preparedArray = [[[controller selectedItemsByPlaylist] copy] autorelease];
            playlistsArray = [controller selectedPlaylists];
        }
        else {
            if (_category == Category_Calendar) {
                [preparedArray addObjectsFromArray:[(IMBCalendarViewController *)self selectItems]];
            }else {
                [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [preparedArray addObject:[_dataSourceArray objectAtIndex:idx]];
                }];
            }
        }
        
        if (preparedArray == nil) {
            preparedArray= [NSMutableArray array];
        }
        if (playlistsArray == nil) {
            playlistsArray = [NSMutableArray array];
        }
        
        IMBCategoryInfoModel *model = [[IMBCategoryInfoModel alloc] init];
        model.categoryNodes = _category;
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:preparedArray forKey:@"selectArr"];
        [dictionary setObject:model forKey:@"category"];
        [dictionary setObject:playlistsArray forKey:@"playlists"];
        if (albumEntity != nil) {
            [dictionary setObject:albumEntity forKey:@"albumentity"];
        }
        
        if (_category == Category_Calendar) {
            IMBInformationManager *manager= [IMBInformationManager shareInstance];
            IMBInformation *information = [manager.informationDic objectForKey:tarIpod.uniqueKey];
            if (information.calendarArray.count > 0) {
                IMBCalendarEntity *calendarEntity = [information.calendarArray objectAtIndex:0];
                [dictionary setObject:calendarEntity.calendarID forKey:@"calendarID"];
            } else {
                //弹出警告确认框,提示目标设备没有calendar 组
                [self showAlertText:CustomLocalizedString(@"transferCalendar_toDevicePrompt", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                [model release];
                return;
            }
        }
        
        if (_transferController != nil) {
            [_transferController release];
            _transferController = nil;
        }
        _transferController = [[IMBTransferViewController alloc] initWithIPodkey:_ipod.uniqueKey DesIpodKey:tarIpod.uniqueKey SelectDic:dictionary];
        if (result>0) {
            [self animationAddTransferViewfromRight:_transferController.view AnnoyVC:annoyVC];
        }else {
            [self animationAddTransferView:_transferController.view];
        }
        [model release];
        
    }
}

//获得选中的item
- (NSIndexSet *)selectedItems {
    NSMutableArray *disAry = nil;
    if (_isSearch) {
        disAry = _researchdataSourceArray;
    }else{
        disAry = _dataSourceArray;
    }
    NSMutableIndexSet *sets = [NSMutableIndexSet indexSet];
    for (int i=0;i<[disAry count]; i++) {
        IMBBaseEntity *entity = [disAry objectAtIndex:i];
        if (entity.checkState == Check||entity.checkState == SemiChecked) {
            [sets addIndex:i];
        }
    }
    return sets;
}

#pragma mark - Android - 获得选中的item
- (NSIndexSet *)selectedAndroidItems {
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else{
        if (_category == Category_Photo) {
            displayArr = _baseAry;
        } else {
            displayArr = _dataSourceArray;
        }
        
    }
    NSMutableIndexSet *sets = [NSMutableIndexSet indexSet];
    for (int i=0;i<[displayArr count]; i++) {
        IMBBaseEntity *entity = [displayArr objectAtIndex:i];
        if (entity.checkState == Check||entity.checkState == SemiChecked) {
            [sets addIndex:i];
        }
    }
    return sets;
}

- (void)setTableViewHeadOrCollectionViewCheck{
    return;
}

- (void)animationAddTransferViewfromRight:(NSView *)view AnnoyVC:(NSViewController *)AnnoyVC;
{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [view setFrame:NSMakeRect(0, 0, [(IMBDeviceMainPageViewController *)_delegate view].frame.size.width, [(IMBDeviceMainPageViewController *)_delegate view].frame.size.height)];
        [[(IMBDeviceMainPageViewController *)_delegate view] addSubview:view];
        [view setWantsLayer:YES];
        [view.layer  addAnimation:[IMBAnimation moveX:0.5 fromX:[NSNumber numberWithInt:view.frame.size.width] toX:[NSNumber numberWithInt:0] repeatCount:1 beginTime:0] forKey:@"movex"];
    } completionHandler:^{
        [(AnnoyVC).view removeFromSuperview];
        [(AnnoyVC) release];
    }];
}

- (void)animationAddTransferView:(NSView *)view
{
    //    [[(IMBDeviceMainPageViewController *)_delegate view] setWantsLayer:YES];
    //    CATransition *transition = [self pushAnimation:kCATransitionPush withSubType:kCATransitionFromTop durTimes:0.5];
    //    [[(IMBDeviceMainPageViewController *)_delegate view].layer removeAllAnimations];
    //    [[(IMBDeviceMainPageViewController *)_delegate view].layer addAnimation:transition forKey:@"animation"];
    
    [view setFrame:NSMakeRect(0, 0, [(IMBDeviceMainPageViewController *)_delegate view].frame.size.width, [(IMBDeviceMainPageViewController *)_delegate view].frame.size.height)];
    [[(IMBDeviceMainPageViewController *)_delegate view] addSubview:view];
    [view setWantsLayer:YES];
    [view.layer addAnimation:[IMBAnimation moveY:0.5 X:[NSNumber numberWithInt:-view.frame.size.height] Y:[NSNumber numberWithInt:0] repeatCount:1] forKey:@"moveY"];
    
    //    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    //        CABasicAnimation *anima1 = [IMBAnimation moveY:0.5 X:[NSNumber numberWithInt:-view.frame.size.height] Y:[NSNumber numberWithInt:0] repeatCount:1];
    //        [view.layer addAnimation:anima1 forKey:@"deviceImageView"];
    //    } completionHandler:^{
    //        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
    //            CABasicAnimation *anima1 = [IMBAnimation moveY:0.3 X:[NSNumber numberWithInt:0] Y:[NSNumber numberWithInt:-40] repeatCount:1];
    //            [view.layer addAnimation:anima1 forKey:@"deviceImageView"];
    //        } completionHandler:^{
    //            CABasicAnimation *anima1 = [IMBAnimation moveY:0.3 X:[NSNumber numberWithInt:-40] Y:[NSNumber numberWithInt:0] repeatCount:1];
    //            [view.layer addAnimation:anima1 forKey:@"deviceImageView"];
    //        }];
    //    }];
}

#pragma mark rightKeyClick
- (IBAction)doDeleteItem:(id)sender {
    NSLog(@"doDeleteItem");
    [self deleteItems:nil];
}

- (IBAction)doToDeviceItem:(id)sender {
    NSLog(@"doToDeviceItem");
    //    [self toDevice:nil];
}

- (IBAction)doToMacItem:(id)sender {
    NSLog(@"doToMacItem");
    if (_isiCloudView) {
        [self iClouditemtoMac:nil];
    }else {
        [self toMac:nil];
    }
}

- (IBAction)doToiTunesItem:(id)sender {
    NSLog(@"doToiTunesItem");
    [self toiTunes:nil];
}

- (IBAction)doRefreshItem:(id)sender {
    if (_isiCloudView) {
        [self iCloudReload:nil];
    }else {
        [self reload:nil];
    }
}

- (IBAction)doAddItem:(id)sender {
    [self addItems:nil];
}

- (IBAction)doToiCloudItem:(id)sender {
    //    [self iCloudSyncTransfer:nil];
}

- (IBAction)doUpLoadItem:(id)sender {
    [self upLoad:nil];
}

- (IBAction)doDownLoadItem:(id)sender {
    [self downLoad:nil];
}

- (IBAction)doCreatFolderItem:(id)sender {
    [self createAlbum:nil];
}

//NSMenu的回调函数
- (void)menuWillOpen:(NSMenu *)menu {
    if ([menu.title isEqualToString:@"Add to Playlist"]) {
        [self initPlaylistMenuItem];
    }else if ([menu.title isEqualToString:@"to Device"]) {
        [self initDeviceMenuItem];
    }else if ([menu.title isEqualToString:@"to iCloud"]) {
        [self initiCloudMenuItem];
    }else if ([menu.title isEqualToString:@"to Album"]){
        [self initiCloudPhotoAlbumMenuItem];
    }
}

- (void)initAndroidDeviceMenuItem {
    IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
    NSArray *array = [connection getConnectedIPods];
    NSMutableArray *baseInfoArr = [NSMutableArray array];
    for (IMBiPod *ipod in array) {
        if (ipod.infoLoadFinished&&ipod.deviceInfo.isIOSDevice) {
            IMBBaseInfo *baseInfo = [connection getDeviceByKey:ipod.uniqueKey];
            [baseInfoArr addObject:baseInfo];
        }
    }
    if (baseInfoArr.count == 0) {
        return;
    }
    NSMenu *toDeviceMenu = _androidToDeviceItem.submenu;
    [toDeviceMenu removeAllItems];
    [toDeviceMenu setAutoenablesItems:NO];
    int i = 0;
    for (IMBBaseInfo *baseInfo in baseInfoArr) {
        i ++;
        NSMenuItem *menuItem = nil;
        NSString *deviceName = baseInfo.deviceName;
        if (deviceName.length >= 15) {
            deviceName = [deviceName substringToIndex:15];
            deviceName = [deviceName stringByAppendingString:@"..."];
        }
        menuItem = [[NSMenuItem alloc] initWithTitle:deviceName action:@selector(toDeviceAndroidMenuAction:) keyEquivalent:@""];
        [menuItem setTag:i];
        [menuItem setKeyEquivalent:baseInfo.uniqueKey];
        [menuItem setTarget:self];
        [menuItem setEnabled:YES];
        [toDeviceMenu addItem:menuItem];
        [menuItem release];
    }
}

- (void)toDeviceAndroidMenuAction:(id)sender{
    NSMenu *menu = _androidToDeviceItem.submenu;
    for (NSMenuItem *menuItem in menu.itemArray) {
        if (menuItem == sender) {
            IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
            IMBBaseInfo *baseInfo = [connection getDeviceByKey:menuItem.keyEquivalent];
            if (baseInfo != nil) {
                [self onItemAndroidClicked:baseInfo];
                break;
            }
        }
    }
}

- (void)initDeviceMenuItem {
    IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
    NSArray *array = [connection getOtherConnectedIPod:_ipod.uniqueKey];
    NSMutableArray *baseInfoArr = [NSMutableArray array];
    for (IMBiPod *ipod in array) {
        if (ipod.infoLoadFinished) {
            IMBBaseInfo *baseInfo = [connection getDeviceByKey:ipod.uniqueKey];
            [baseInfoArr addObject:baseInfo];
        }
    }
    if (baseInfoArr.count == 0) {
        //        [self showAlertText:CustomLocalizedString(@"Nothave_toDevices", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        return;
    }
    
    //    [_toDeviceMenuItem setTitle:CustomLocalizedString(@"Menu_ToDevice", nil)];
    NSMenu *toDeviceMenu = _toDeviceMenuItem.submenu;
    [toDeviceMenu removeAllItems];
    [toDeviceMenu setAutoenablesItems:NO];
    
    int i = 0;
    for (IMBBaseInfo *baseInfo in baseInfoArr) {
        i ++;
        NSMenuItem *menuItem = nil;
        NSString *deviceName = baseInfo.deviceName;
        if (deviceName.length >= 15) {
            deviceName = [deviceName substringToIndex:15];
            deviceName = [deviceName stringByAppendingString:@"..."];
        }
        menuItem = [[NSMenuItem alloc] initWithTitle:deviceName action:@selector(toDeviceMenuAction:) keyEquivalent:@""];
        [menuItem setTag:i];
        [menuItem setKeyEquivalent:baseInfo.uniqueKey];
        [menuItem setTarget:self];
        [menuItem setEnabled:YES];
        
        [toDeviceMenu addItem:menuItem];
        
        [menuItem release];
    }
}

- (void)toDeviceMenuAction:(id)sender{
    NSMenu *menu = _toDeviceMenuItem.submenu;
    for (NSMenuItem *menuItem in menu.itemArray) {
        if (menuItem == sender) {
            IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
            IMBBaseInfo *baseInfo = [connection getDeviceByKey:menuItem.keyEquivalent];
            if (baseInfo != nil) {
                if (_isiCloudView) {
                    [self onItemiCloudClicked:baseInfo];
                }else {
                    [self onItemClicked:baseInfo];
                }
                break;
            }
        }
    }
}

- (void)initiCloudPhotoAlbumMenuItem{
    NSMutableArray *baseInfoArr = [NSMutableArray array];
    if (_iCloudManager.albumArray.count >1) {
        for (IMBToiCloudPhotoEntity *entity in _iCloudManager.albumArray) {
            IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
            baseInfo.deviceName = entity.albumTitle;
            baseInfo.isicloudView = YES;
            baseInfo.uniqueKey = entity.clientId;
            [baseInfoArr addObject:baseInfo];
            [baseInfo release];
        }
        [_toAlbumMenuItem setHidden:NO];
        NSMenu *toAlbumMenu = _toAlbumMenuItem.submenu;
        [toAlbumMenu removeAllItems];
        [toAlbumMenu setAutoenablesItems:NO];
        
        int i = 0;
        for (IMBBaseInfo *baseInfo in baseInfoArr) {
            i ++;
            NSMenuItem *menuItem = nil;
            NSString *deviceName = baseInfo.deviceName;
            if (deviceName.length >= 15) {
                deviceName = [deviceName substringToIndex:15];
                deviceName = [deviceName stringByAppendingString:@"..."];
            }
            menuItem = [[NSMenuItem alloc] initWithTitle:deviceName action:@selector(toiCloudMenuAction:) keyEquivalent:@""];
            [menuItem setTag:i];
            [menuItem setKeyEquivalent:baseInfo.uniqueKey];
            [menuItem setTarget:self];
            [menuItem setEnabled:YES];
            [toAlbumMenu addItem:menuItem];
            [menuItem release];
        }
        
    }
    
}

- (void)initiCloudMenuItem {
    NSMutableArray *baseInfoArr = [NSMutableArray array];
    if (_isiCloudView) {
        NSDictionary *iCloudDic = [_delegate getiCloudAccountViewCollection];
        for (NSString *key in iCloudDic.allKeys) {
            if (![key isEqualToString:_iCloudManager.netClient.loginInfo.appleID]) {
                IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
                IMBiCloudManager *otheriCloudManager = [[iCloudDic objectForKey:key] iCloudManager];
                baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
                baseInfo.isicloudView = YES;
                baseInfo.uniqueKey = key;
                [baseInfoArr addObject:baseInfo];
                [baseInfo release];
            }
        }
    }else {
        //判断有没有icloud账号登陆
        IMBDeviceConnection *deviceConntection = [IMBDeviceConnection singleton];
        for (NSString *key in deviceConntection.iCloudDic.allKeys) {
            IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
            IMBiCloudManager *otheriCloudManager = [[deviceConntection.iCloudDic objectForKey:key] iCloudManager];
            baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
            baseInfo.isicloudView = YES;
            baseInfo.uniqueKey = key;
            [baseInfoArr addObject:baseInfo];
            [baseInfo release];
        }
    }
    
    if (baseInfoArr.count == 0) {
        //        //提示用户，没有其他iCloud账号登录
        //        if (_isiCloudView) {
        //            NSString *str = nil;
        //            str = CustomLocalizedString(@"NoAcount_Tips", nil);
        //            [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        //        }else {
        //            NSString *str = nil;
        //            str = CustomLocalizedString(@"NoAcount_Tip", nil);
        //            [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        //        }
        return;
    }
    
    //    [_toDeviceMenuItem setTitle:CustomLocalizedString(@"Menu_ToDevice", nil)];
    NSMenu *toiCloudMenu = _toiCloudMenuItem.submenu;
    [toiCloudMenu removeAllItems];
    [toiCloudMenu setAutoenablesItems:NO];
    
    int i = 0;
    for (IMBBaseInfo *baseInfo in baseInfoArr) {
        i ++;
        NSMenuItem *menuItem = nil;
        NSString *deviceName = baseInfo.deviceName;
        if (deviceName.length >= 15) {
            deviceName = [deviceName substringToIndex:15];
            deviceName = [deviceName stringByAppendingString:@"..."];
        }
        menuItem = [[NSMenuItem alloc] initWithTitle:deviceName action:@selector(toiCloudMenuAction:) keyEquivalent:@""];
        [menuItem setTag:i];
        [menuItem setKeyEquivalent:baseInfo.uniqueKey];
        [menuItem setTarget:self];
        [menuItem setEnabled:YES];
        
        [toiCloudMenu addItem:menuItem];
        
        [menuItem release];
    }
}

- (void)toiCloudMenuAction:(id)sender{
    NSMenu *menu = _toiCloudMenuItem.submenu;
    for (NSMenuItem *menuItem in menu.itemArray) {
        if (menuItem == sender) {
            NSDictionary *iCloudDic = nil;
            if (_isiCloudView) {
                iCloudDic = [_delegate getiCloudAccountViewCollection];
            }else {
                IMBDeviceConnection *deviceConntection = [IMBDeviceConnection singleton];
                iCloudDic = deviceConntection.iCloudDic;
            }
            
            IMBiCloudManager *otheriCloudManager = [[iCloudDic objectForKey:menuItem.keyEquivalent] iCloudManager];
            IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
            baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
            baseInfo.isicloudView = YES;
            baseInfo.uniqueKey = menuItem.keyEquivalent;
            if (baseInfo != nil) {
                if (_isiCloudView) {
                    [self onItemiCloudClicked:baseInfo];
                }else {
                    [self toiCloudItemClicked:baseInfo];
                }
                break;
            }
            [baseInfo release];
        }
    }
}

- (void)initAndroidiCloudMenuItem {
    NSMutableArray *baseInfoArr = [NSMutableArray array];
    if (_isiCloudView) {
        NSDictionary *iCloudDic = [_delegate getiCloudAccountViewCollection];
        for (NSString *key in iCloudDic.allKeys) {
            if (![key isEqualToString:_iCloudManager.netClient.loginInfo.appleID]) {
                IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
                IMBiCloudManager *otheriCloudManager = [[iCloudDic objectForKey:key] iCloudManager];
                baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
                baseInfo.isicloudView = YES;
                baseInfo.uniqueKey = key;
                [baseInfoArr addObject:baseInfo];
                [baseInfo release];
            }
        }
    }else {
        //判断有没有icloud账号登陆
        IMBDeviceConnection *deviceConntection = [IMBDeviceConnection singleton];
        for (NSString *key in deviceConntection.iCloudDic.allKeys) {
            IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
            IMBiCloudManager *otheriCloudManager = [[deviceConntection.iCloudDic objectForKey:key] iCloudManager];
            baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
            baseInfo.isicloudView = YES;
            baseInfo.uniqueKey = key;
            [baseInfoArr addObject:baseInfo];
            [baseInfo release];
        }
    }
    
    if (baseInfoArr.count == 0) {
        return;
    }
    NSMenu *toiCloudMenu = _androidToiCloudItem.submenu;
    [toiCloudMenu removeAllItems];
    [toiCloudMenu setAutoenablesItems:NO];
    int i = 0;
    for (IMBBaseInfo *baseInfo in baseInfoArr) {
        i ++;
        NSMenuItem *menuItem = nil;
        NSString *deviceName = baseInfo.deviceName;
        if (deviceName.length >= 15) {
            deviceName = [deviceName substringToIndex:15];
            deviceName = [deviceName stringByAppendingString:@"..."];
        }
        menuItem = [[NSMenuItem alloc] initWithTitle:deviceName action:@selector(toiCloudAnroidMenuAction:) keyEquivalent:@""];
        [menuItem setTag:i];
        [menuItem setKeyEquivalent:baseInfo.uniqueKey];
        [menuItem setTarget:self];
        [menuItem setEnabled:YES];
        [toiCloudMenu addItem:menuItem];
        [menuItem release];
    }
}

- (void)toiCloudAnroidMenuAction:(id)sender{
    NSMenu *menu = _androidToiCloudItem.submenu;
    for (NSMenuItem *menuItem in menu.itemArray) {
        if (menuItem == sender) {
            NSDictionary *iCloudDic = nil;
            if (_isiCloudView) {
                iCloudDic = [_delegate getiCloudAccountViewCollection];
            }else {
                IMBDeviceConnection *deviceConntection = [IMBDeviceConnection singleton];
                iCloudDic = deviceConntection.iCloudDic;
            }
            IMBiCloudManager *otheriCloudManager = [[iCloudDic objectForKey:menuItem.keyEquivalent] iCloudManager];
            IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
            baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
            baseInfo.isicloudView = YES;
            baseInfo.uniqueKey = menuItem.keyEquivalent;
            if (baseInfo != nil) {
                [self toiCloudItemClicked:baseInfo];
                break;
            }
            [baseInfo release];
        }
    }
}

- (void)initPlaylistMenuItem {
    NSMenu *submenu = _addToPlaylistMenuItem.submenu;
    [submenu removeAllItems];
    
    if (_playlistArray != nil ) {
        if (_playlistArray.count> 0) {
            if (![[_playlistArray objectAtIndex:0] isKindOfClass:[IMBBookmarkEntity class]]) {
                for (int i = 0; i < _playlistArray.count; i++) {
                    IMBPlaylist *pl = [_playlistArray objectAtIndex:i];
                    if ([pl isUserDefinedPlaylist]) {
                        NSMenuItem *item = [[NSMenuItem alloc] init];
                        item.title = pl.name;
                        item.tag = i;
                        [item setTarget:self];
                        [item setAction:@selector(doAddToPlaylist:)];
                        [submenu addItem:item];
                        [item release];
                    }
                }
            };
        }
    }
}

- (void)doAddToPlaylist:(id)sender {
    int row = (int)[sender tag];
    IMBPlaylist *pl = [_playlistArray objectAtIndex:row];
    if (pl != nil) {
        [self addToPlaylist:pl.iD];
    }
}

#pragma mark - 将歌曲添加到指定播放列表
- (void)addToPlaylist:(long long)playlistID{
    
}

- (void)doSearchBtn:(NSString *)searchStr withSearchBtn:(IMBSearchView *)searchBtn{
    NSLog(@"search");
}

- (void)reloadTableView{
    if (_itemTableView != nil) {
        _isSearch = NO;
        [_itemTableView reloadData];
        
    }else if (_collectionView != nil){
        _isSearch = NO;
        [self loadCollectionView:NO];
    }
}

- (void)loadCollectionView:(BOOL)isFrist{
    return;
}

- (void)ShowWindowControllerCategory {
    return;
}

#pragma mark - text
//点击链接文字
- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex{
    NSString *overStr = CustomLocalizedString(@"NO_DATA_TITLE_2", nil);
    NSLog(@"%@",overStr);
    if ([link isEqualToString:overStr]) {
        [self addItems:nil];
    }
    return YES;
}

#pragma mark - Alert
- (void)showiCloudAnnoyAlertTitleText:(NSString *)titleText withSubStr:(NSString *)subText withImageName:(NSString *)imageName buyButtonText:(NSString *)OkText CancelButton:(NSString *)cancelText{
    
    NSView *view = nil;
    for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
        if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
            view = subView;
            break;
        }
    }
    [view setHidden:NO];
    _alertViewController.isIcloudOneOpen = NO;
    [_alertViewController showiCloudAnnoyAlertTitleText:titleText withSubStr:subText withImageName:imageName buyButtonText:OkText CancelButton:cancelText SuperView:view];
}

- (int)showAlertText:(NSString *)alertText OKButton:(NSString *)OkText CancelButton:(NSString *)cancelText
{
    NSView *view = nil;
    for (NSView *subView in ((NSView *)[NSApplication sharedApplication].mainWindow.contentView).subviews) {
        if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]) {
            view = subView;
            break;
        }
    }
    [view setHidden:NO];
    return [_alertViewController showAlertText:alertText OKButton:OkText CancelButton:cancelText SuperView:view];
}

- (int)showAlertText:(NSString *)alertText OKButton:(NSString *)OkText
{
    if (_alertViewController == nil) {
        return 0;
    }
    NSView *view = nil;
    for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
        if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
            view = subView;
            break;
        }
    }
    [view setHidden:NO];
    return [_alertViewController showAlertText:alertText OKButton:OkText SuperView:view];
}

- (void)showRemoveSuccessAlertText:(NSString *)alertText withCount:(int)successCount
{
    [_alertViewController showRemoveSuccessViewAlertText:alertText withCount:successCount];
}

- (BOOL)chekiCloud:(NSString *)itemKey withCategoryEnum:(CategoryNodesEnum)categoryEnum
{
    BOOL open = [self checkItemsValidWithIPod:itemKey];
    if (!open) {
        //弹出提示框
        NSView *view = nil;
        for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
            if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                view = subView;
                break;
            }
        }
        
        [view setHidden:NO];
        [_alertViewController showAlertTextSuperView:view withClosenodeEnum:categoryEnum withisIcloudClose:YES];
    }
    return open;
}

- (void)doOkBtnOperation:(id)sender {
    return;
}

- (BOOL)checkItemsValidWithIPod:(NSString *)itemKey{
    BOOL isPass = YES;
    NSDictionary *dataSyncStr = [_ipod.deviceHandle deviceValueForKey:nil inDomain:@"com.apple.mobile.data_sync"];
    if (dataSyncStr != nil) {
        NSArray *allKey = [dataSyncStr allKeys];
        if ([allKey containsObject:itemKey]) {
            NSDictionary *contDic = [dataSyncStr objectForKey:itemKey];
            if (contDic != nil) {
                if (isPass) {
                    NSArray *sourcesInfoArray = [contDic objectForKey:@"Sources"];
                    if (sourcesInfoArray != nil && [sourcesInfoArray count] > 0) {
                        isPass = NO;
                    }
                }
            }
        }
    }
    return isPass;
}


- (BOOL)AndroidCheckItemsValidWithIPodKey:(NSString *)itemKey withIpod:(IMBiPod *)ipod{
    BOOL isPass = YES;
    NSDictionary *dataSyncStr = [ipod.deviceHandle deviceValueForKey:nil inDomain:@"com.apple.mobile.data_sync"];
    if (dataSyncStr != nil) {
        NSArray *allKey = [dataSyncStr allKeys];
        if ([allKey containsObject:itemKey]) {
            NSDictionary *contDic = [dataSyncStr objectForKey:itemKey];
            if (contDic != nil) {
                if (isPass) {
                    NSArray *sourcesInfoArray = [contDic objectForKey:@"Sources"];
                    if (sourcesInfoArray != nil && [sourcesInfoArray count] > 0) {
                        isPass = NO;
                    }
                }
            }
        }
    }
    return isPass;
}
// 检查备份是否被加密
- (BOOL)checkBackupEncrypt {
    BOOL isEncrypt = [[_ipod.deviceHandle deviceValueForKey:@"WillEncrypt" inDomain:@"com.apple.mobile.backup"] boolValue];
    return isEncrypt;
}
//android  检测备份加密
- (BOOL)AndroidCheckBackupEncrypt:(IMBiPod *)ipod {
    BOOL isEncrypt = [[ipod.deviceHandle deviceValueForKey:@"WillEncrypt" inDomain:@"com.apple.mobile.backup"] boolValue];
    return isEncrypt;
}

//检查网络和服务器是否正常连接
- (BOOL) checkInternetAvailble {
    //    if (![MediaHelper isInternetAvail]) {
    //        [self showAlertText:CustomLocalizedString(@"IMBTrans_NO_Internet_MSG", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    //        return false;
    //    }
    //
    //    if (![TempHelper checkInternetAvailble]) {
    //        [self showAlertText:CustomLocalizedString(@"IMBTrans_Server_Not_Avail_MSG", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    //        return false;
    //    }
    return true;
}

//检查数据库是否损坏
- (void)checkCDBcorrupted {
    if (_information.CDBCorrupted) {
        [self showAlertText:[NSString stringWithFormat: CustomLocalizedString(@"MSG_COM_Device_Database_Damaged", nil), _ipod.deviceInfo.deviceName] OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }
}
//屏蔽按钮
- (void)disableFunctionBtn:(BOOL)isDisable {
    if ([_delegate respondsToSelector:@selector(disableFunctionBtn:)]) {
        [_delegate disableFunctionBtn:isDisable];
    }
}

- (void)refeash {
    if (_delegate != nil && [_delegate respondsToSelector:@selector(refeashBadgeConut:WithCategory:)] ) {
        [_delegate refeashBadgeConut:(int)_dataSourceArray.count WithCategory:_category];
    }
}

- (long long)checkNeedAnnoy:(NSViewController **)annoyVC;
{
    IMBSoftWareInfo *soft = [IMBSoftWareInfo singleton];
    _endRunloop = NO;
    if (!soft.isRegistered) {
        OperationLImitation *limit = [OperationLImitation singleton];
        long long redminderCount = (long long)limit.remainderCount;
        //弹出骚扰窗口
        (*annoyVC) = [[IMBAnnoyViewController alloc] initWithNibName:@"IMBAnnoyViewController" Delegate:self Result:&redminderCount];
        ((IMBAnnoyViewController *)(*annoyVC)).category = _category;
        ((IMBAnnoyViewController *)(*annoyVC)).isClone = _isClone;
        ((IMBAnnoyViewController *)(*annoyVC)).isMerge = _isMerge;
        ((IMBAnnoyViewController *)(*annoyVC)).isContentToMac = _isContentToMac;
        ((IMBAnnoyViewController *)(*annoyVC)).isAddContent = _isAddContent;
        [(*annoyVC).view setFrameSize:NSMakeSize(NSWidth([(IMBBaseViewController *)_delegate view].frame), NSHeight([(IMBBaseViewController *)_delegate view].frame))];
        [(*annoyVC).view setWantsLayer:YES];
        [[(IMBBaseViewController *)_delegate view] addSubview:(*annoyVC).view];
        [(*annoyVC).view.layer addAnimation:[IMBAnimation moveY:0.5 X:[NSNumber numberWithInt:-(*annoyVC).view.frame.size.height] Y:[NSNumber numberWithInt:0] repeatCount:1] forKey:@"moveY"];
        NSModalSession session =  [NSApp beginModalSessionForWindow:self.view.window];
        NSInteger result1 = NSRunContinuesResponse;
        while ((result1 = [NSApp runModalSession:session]) == NSRunContinuesResponse&&!_endRunloop)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        [NSApp endModalSession:session];
        _endRunloop = NO;
        return redminderCount;
    }else{
        return -1;
    }
}

-(void)getFileNames:(NSArray *)fileNames byFileExtensions:(NSArray *)fileExtensions toArray:(NSMutableArray *)array{
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSString *string in fileNames) {
            if ([[fileManager attributesOfItemAtPath:string error:nil] fileType] == NSFileTypeDirectory) {
                NSError *error = nil;
                NSArray *items = [fileManager subpathsOfDirectoryAtPath:string error:&error];
                if (error != nil) {
                    NSLog(@"error:%@",error);
                }
                for (NSString *path in items) {
                    path = [string stringByAppendingPathComponent:path];
                    //                    if (array.count >= 1000) {
                    //                        break;
                    //                    }
                    NSString *extension = [path pathExtension].lowercaseString;
                    if ([fileExtensions containsObject:extension]) {
                        [array addObject:path];
                    }
                }
            }
            else{
                //                if (array.count >= 1000) {
                //                    break;
                //                }
                NSString *extension = [string pathExtension].lowercaseString;
                if(extension.length > 0 && [fileExtensions containsObject:extension]){
                    [array addObject:string];
                }
            }
        }
    }
}

- (void)changeSkin:(NSNotification *)notification
{
    
}

- (int)addAppTodevice:(IMBiPod *)targetiPod withSourceAppArray:(NSMutableArray *)sourceApps{
    //判断选择的分类中是否包含App
    NSArray *sourceAppArray = [sourceApps retain];
    NSArray *targetAppArray = targetiPod.applicationManager.appEntityArray;
    NSMutableArray *downAppM = [[NSMutableArray alloc]init];
    for (IMBAppEntity *app in sourceAppArray) {
        int i = 0;
        for (IMBAppEntity *targetApp in targetAppArray) {
            if ([targetApp.appKey isEqualToString:app.appKey]) {
                i = 1;
                break;
            }
        }
        if (i == 0) {
            [downAppM addObject:app];
        }
    }
    [sourceAppArray release];
    if (downAppM.count == 0) {
        return 1;
    }
    
    BOOL version = NO;
    if ([targetiPod.deviceInfo.getDeviceFloatVersionNumber isVersionMajorEqual:@"8.3"] || [_ipod.deviceInfo.getDeviceFloatVersionNumber isVersionMajorEqual:@"8.3"]) {
        version = YES;
    }
    
    if (downAppM.count > 0 && version) {
        NSView *view = nil;
        for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
            if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                view = subView;
                break;
            }
        }
        [view setHidden:NO];
        NSString *str = nil;
        if (downAppM.count <= 1) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"Above9AppToDeviceTipsSin", nil),targetiPod.deviceInfo.deviceName,targetiPod.deviceInfo.deviceName];
        }else {
            str = [NSString stringWithFormat:CustomLocalizedString(@"Above9AppToDeviceTipsDou", nil),targetiPod.deviceInfo.deviceName,targetiPod.deviceInfo.deviceName];
        }
        [_mergeCloneAppVC setIsToDevice:YES];
        [_mergeCloneAppVC setSourceApps:downAppM];
        int i = [_mergeCloneAppVC showTitleString:str OkButton:CustomLocalizedString(@"Button_Ok", nil) CancelButton:CustomLocalizedString(@"Button_Cancel", nil) TargetiPod:targetiPod sourceiPod:_ipod SuperView:view];
        if (i == 0) {
            return 0;
        }
    }else {
        return 1;
    }
    return 0;
}

- (void)closeOpenPanel:(NSNotification *)noti {
    if ([noti.object isEqualToString:_ipod.uniqueKey] && _openPanel != nil && _isOpen) {
        [_openPanel cancel:nil];
        _openPanel = nil;
    }
}

#pragma mark - iCloud Actions
- (void)toiCloud:(id)sender
{
    NSIndexSet *selectedSet = [self selectedItems];
    if ([selectedSet count] <= 0) {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"iCloudBackup_View_Selected_Tips", nil);
        }
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }else {
        //判断有没有icloud账号登陆
        IMBDeviceConnection *deviceConntection = [IMBDeviceConnection singleton];
        NSMutableArray *baseInfoArr = [NSMutableArray array];
        for (NSString *key in deviceConntection.iCloudDic.allKeys) {
            IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
            IMBiCloudManager *otheriCloudManager = [[deviceConntection.iCloudDic objectForKey:key] iCloudManager];
            baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
            baseInfo.isicloudView = YES;
            baseInfo.uniqueKey = key;
            [baseInfoArr addObject:baseInfo];
            [baseInfo release];
        }
        if (baseInfoArr.count >1) {
            [self toDeviceWithSelectArray:baseInfoArr WithView:sender];
        }else if (baseInfoArr.count == 1){
            IMBBaseInfo *baseInfo = [baseInfoArr objectAtIndex:0];
            _iCloudManager = [[deviceConntection.iCloudDic objectForKey:baseInfo.uniqueKey] iCloudManager];
            _iCloudManager.delegate = self;
            [self deviceToiCloud:sender];
        }else{
            NSString *str = CustomLocalizedString(@"NoAcount_Tip", nil);
//            [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            NSView *view = nil;
            for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
                if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                    view = subView;
                    break;
                }
            }
            if (view) {
                [view setHidden:NO];
                int i = [_alertViewController showDeleteConfrimText:str OKButton:CustomLocalizedString(@"Button_Login", nil)  CancelButton:CustomLocalizedString(@"Button_Cancel", nil) SuperView:view];
                if (i == 1) {//跳转到iCloud登录页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_JUMP_ICLOUD_VIEW object:nil];
                }
            }
        }
    }
}
- (void)upLoad:(id)sender
{
    NSLog(@"upLoad");
}
- (void)downLoad:(id)sender
{
    NSLog(@"downLoad");
}
- (void)movePicture:(id)sender
{
    NSLog(@"movePicture");
}
- (void)createAlbum:(id)sender
{
    NSLog(@"createAlbum");
}
- (void)newGroup:(id)sender
{
    NSLog(@"newGroup");
}
- (void)iCloudSyncTransfer:(id)sender {
    IMBiCloudManager *otheriCloudManager = [self getOtheriCloudAccountManager];
    if (otheriCloudManager != nil) {
        NSDictionary *iCloudDic = [_delegate getiCloudAccountViewCollection];
        
        NSMutableArray *baseInfoArr = [NSMutableArray array];
        
        for (NSString *key in iCloudDic.allKeys) {
            if (![key isEqualToString:_iCloudManager.netClient.loginInfo.appleID]) {
                IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
                IMBiCloudManager *otheriCloudManager = [[iCloudDic objectForKey:key] iCloudManager];
                baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
                baseInfo.uniqueKey = key;
                [baseInfoArr addObject:baseInfo];
                [baseInfo release];
            }
        }
        [self toDeviceWithSelectArray:baseInfoArr WithView:sender];
    }else {
        //提示用户，没有其他iCloud账号登录
        NSString *str = nil;
        str = CustomLocalizedString(@"NoAcount_Tips", nil);
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }
}

- (void)deviceToiCloud:(id)sender{
    NSViewController *annoyVC = nil;
    long long result = [self checkNeedAnnoy:&(annoyVC)];
    if (result == 0) {
        return;
    }
    if (_category == Category_PhotoLibrary || _category == Category_PhotoStream|| _category == Category_CameraRoll || _category == Category_Panoramas || _category == Category_LivePhoto|| _category == Category_Screenshot|| _category == Category_PhotoSelfies|| _category == Category_Location|| _category == Category_Favorite) {
        NSPredicate *cate = [NSPredicate predicateWithFormat:@"self.checkState == %d",Check];
        NSArray *selectedArray = [_dataSourceArray filteredArrayUsingPredicate:cate];
        if (_transferController != nil) {
            [_transferController release];
            _transferController = nil;
        }
        _transferController = [[IMBTransferViewController alloc] initWithIPodkey:_ipod.uniqueKey Type:_category SelectItems:(NSMutableArray *)selectedArray iCloudManager:_iCloudManager];
        if (result>0) {
            [self animationAddTransferViewfromRight:_transferController.view AnnoyVC:annoyVC];
        }else{
            [self animationAddTransferView:_transferController.view];
        }
    }
    NSLog(@"deviceToIcloud");
}

- (void)iCloudReload:(id)sender {
    NSLog(@"iCloudReload");
}

- (void)addiCloudItems:(id)sender
{
    NSLog(@"addiCloudItems");
}
- (void)deleteiCloudItems:(id)sender
{
    NSLog(@"deleteiCloudItems");
}
- (void)iClouditemtoMac:(id)sender
{
    NSLog(@"iClouditemtoMac");
    NSIndexSet *selectedSet = [self selectedItems];
    if ([selectedSet count] <= 0) {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"Export_View_Selected_Tips", nil);
        }
        
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }else {
        //弹出路径选择框
        _openPanel = [NSOpenPanel openPanel];
        _isOpen = YES;
        [_openPanel setAllowsMultipleSelection:NO];
        [_openPanel setCanChooseFiles:NO];
        [_openPanel setCanChooseDirectories:YES];
        NSDictionary *dimensionDict = nil;
        @autoreleasepool {
            dimensionDict = [[TempHelper customDimension] copy];
        }
        if(_category == Category_Notes) {
            [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Notes Send to Mac" label:Start transferCount:0 screenView:@"Notes View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            [_openPanel beginSheetModalForWindow:[(IMBDeviceMainPageViewController *)_delegate view].window completionHandler:^(NSInteger result) {
                if (result== NSFileHandlingPanelOKButton) {
                    [self performSelector:@selector(infortoMacDelay:) withObject:_openPanel afterDelay:0.1];
                }else{
                    NSLog(@"other other other");
                }
            }];
        }
        if (_category == Category_Calendar || _category == Category_Reminder) {
            if (_category == Category_Calendar) {
                [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Calendar Send to Mac" label:Start transferCount:0 screenView:@"Calendar View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            }else if (_category == Category_Reminder) {
                [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Reminder Send to Mac" label:Start transferCount:0 screenView:@"Reminder View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            }
            [_openPanel beginSheetModalForWindow:[(IMBDeviceMainPageViewController *)_delegate view].window completionHandler:^(NSInteger result) {
                if (result== NSFileHandlingPanelOKButton) {
                    [self performSelector:@selector(infortoMacDelay:) withObject:_openPanel afterDelay:0.1];
                }else{
                    NSLog(@"other other other");
                }
            }];
        }
        if (_category == Category_Contacts) {
            [ATTracker event:iCloud_Content action:ActionNone actionParams:@"Contacts Send to Mac" label:Start transferCount:0 screenView:@"Contacts View" userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
            [_openPanel beginSheetModalForWindow:[(IMBDeviceMainPageViewController *)_delegate view].window completionHandler:^(NSInteger result) {
                if (result== NSFileHandlingPanelOKButton) {
                    [self performSelector:@selector(infortoMacDelay:) withObject:_openPanel afterDelay:0.1];
                }else{
                    NSLog(@"other other other");
                }
            }];
        }
        if (dimensionDict) {
            [dimensionDict release];
            dimensionDict = nil;
        }
    }
}
- (void)doiClouditemEdit:(id)sender
{
    NSLog(@"doiClouditemEdit");
}
- (void)doiCloudImportContact:(id)sender
{
    NSLog(@"doiCloudImportContact");
}

- (IMBiCloudManager *)getOtheriCloudAccountManager {
    
    if (_delegate != nil) {
        NSDictionary *iCloudDic = [_delegate getiCloudAccountViewCollection];
        if (iCloudDic.allKeys.count >= 2) {
            for (NSString *appleId in iCloudDic.allKeys) {
                if (![appleId isEqualToString:_iCloudManager.netClient.loginInfo.appleID]) {
                    return [[iCloudDic objectForKey:appleId] iCloudManager];
                }
            }
        }
    }
    return nil;
}


#pragma mark - Android Actions
- (void)androidReload:(id)sender{
    
}

- (void)androidToDevice:(id)sender {
    NSIndexSet *selectedSet = [self selectedAndroidItems];
    if ([selectedSet count] > 0) {
        IMBDeviceConnection *connection = [IMBDeviceConnection singleton];
        NSMutableArray *baseInfoArr = [NSMutableArray array];
        NSArray *array = [connection getConnectedIPods];
        //判断是否是iOS设备 屏蔽非iOS 设备
        for (IMBiPod *ipod in array) {
            if (ipod.infoLoadFinished&&ipod.deviceInfo.isIOSDevice) {
                IMBBaseInfo *baseInfo = [connection getDeviceByKey:ipod.uniqueKey];
                [baseInfoArr addObject:baseInfo];
            }
        }
        //判断设备是否是iOS 设备 并弹出提示窗口
        if (array.count ==1) {
            IMBiPod *ipod = [array objectAtIndex:0];
            if (![ipod.deviceInfo isIOSDevice]) {
                [self showAlertText:CustomLocalizedString(@"android_toDevices_NoIOSDeviceTips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
        }
      
        if (baseInfoArr.count == 0) {
            [self showAlertText:CustomLocalizedString(@"android_toDevices_NoIOSDeviceTips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            return;
        }else if (baseInfoArr.count == 1) {
            IMBBaseInfo *baseInfo = [baseInfoArr objectAtIndex:0];
            IMBiPod *tarIpod = [connection getIPodByKey:baseInfo.uniqueKey];
            //检测设备是否是 非ios 设备不能传输CallHistory
            if (![tarIpod.deviceInfo.deviceClass isEqualToString:@"iPhone"]) {
                if (_category == Category_CallHistory) {
                    [self showAlertText:CustomLocalizedString(@"Android_to_iOS_message_1", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                    return;
                }
            }
            if (tarIpod.beingSynchronized) {
                [self showAlertText:CustomLocalizedString(@"AirsyncTips", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                return;
            }
            
            if (_category == Category_Music) {
                if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.Music"] == nil) {
                    NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"MenuItem_id_1", nil)];
                    [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                    return;
                }
            }else if (_category == Category_Contacts){
                if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.MobileAddressBook"] == nil) {
                    NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"MenuItem_id_20", nil)];
                    [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                    return;
                }
            }else if (_category == Category_Calendar){
                if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.mobilecal"] == nil) {
                    NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"MenuItem_id_62", nil)];
                    [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                    return;
                }
            }else if (_category == Category_Movies){
                if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.videos"] == nil) {
                    
                    NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"MenuItem_id_33", nil)];
                    [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                    return;
                }
            }else if (_category == Category_iBooks){
                if ([tarIpod.deviceHandle installedApplicationWithId:@"com.apple.iBooks"] == nil) {
                    NSString *tip = [NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_2", nil),CustomLocalizedString(@"iBook_id_3", nil)];
                    [self showAlertText:tip OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                    return;
                }
            }
            //检测icloud calender 是否开启
            if (_category == Category_Calendar) {
                BOOL open = [self AndroidCheckItemsValidWithIPodKey:@"Calendars" withIpod:tarIpod];
                if (!open) {
                    //弹出提示框
                    NSView *view = nil;
                    for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
                        if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                            view = subView;
                            break;
                        }
                    }
                    
                    [view setHidden:NO];
                    [_alertViewController showAlertTextSuperView:view withClosenodeEnum:Category_Calendar withisIcloudClose:YES];
                    return;
                }
            }
            //检测icloud contact 是否开启
            if (_category == Category_Contacts) {
                BOOL open = [self AndroidCheckItemsValidWithIPodKey:@"Contacts" withIpod:tarIpod];
                if (!open) {
                    //弹出提示框
                    NSView *view = nil;
                    for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
                        if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                            view = subView;
                            break;
                        }
                    }
                    
                    [view setHidden:NO];
                    [_alertViewController showAlertTextSuperView:view withClosenodeEnum:Category_Calendar withisIcloudClose:YES];
                    return;
                }
            }
            //检测备份是否加密
            if (_category == Category_Message || _category == Category_CallHistory) {
                if ([self AndroidCheckBackupEncrypt:tarIpod]) {
                    [self showAlertText:[NSString stringWithFormat:CustomLocalizedString(@"Clone_id_24", nil),tarIpod.deviceInfo.deviceName] OKButton:CustomLocalizedString(@"Button_Ok", nil)];
                    return;
                }
                if ([self isFindMyiCloud:tarIpod.deviceHandle]) {
                    NSView *view = nil;
                    for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
                        if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                            view = subView;
                            [view setHidden:NO];
                            break;
                        }
                    }
                    [_alertViewController showAlertTextSuperView:view withClosenodeEnum:0 withisIcloudClose:NO];
                    return;
                }
            }
            if (_category == Category_Message || _category == Category_CallHistory) {
                [_alertViewController setIsStopPan:YES];
                NSString *str = [NSString stringWithFormat:@"'%@/%@'",CustomLocalizedString(@"MenuItem_CallLog", nil),CustomLocalizedString(@"MenuItem_id_19", nil)];
                int tag = [self showAlertText:[NSString stringWithFormat:CustomLocalizedString(@"Android_to_iOS_message_3", nil),str] OKButton:CustomLocalizedString(@"Button_Ok", nil) CancelButton:CustomLocalizedString(@"Button_Cancel", nil)];
                [_alertViewController setIsStopPan:NO];
                if (tag != 1) {
                    return;
                }
            }
            [self contentAndroidToiOSDeviceIndexSet:selectedSet tarIpod:tarIpod];
        }else {
            [self toDeviceWithSelectArray:baseInfoArr WithView:sender];
        }
    }else {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"iCloudBackup_View_Selected_Tips", nil);
        }
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }
}

- (void)androidToiCloud:(id)sender{
    
    NSIndexSet *selectedSet = [self selectedAndroidItems];
    if ([selectedSet count] <= 0) {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"iCloudBackup_View_Selected_Tips", nil);
        }
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }else {
        //判断有没有icloud账号登陆
        IMBDeviceConnection *deviceConntection = [IMBDeviceConnection singleton];
        NSMutableArray *baseInfoArr = [NSMutableArray array];
        for (NSString *key in deviceConntection.iCloudDic.allKeys) {
            IMBBaseInfo *baseInfo = [[IMBBaseInfo alloc]init];
            IMBiCloudManager *otheriCloudManager = [[deviceConntection.iCloudDic objectForKey:key] iCloudManager];
            baseInfo.deviceName = otheriCloudManager.netClient.loginInfo.loginInfoEntity.fullName;
            baseInfo.isicloudView = YES;
            baseInfo.uniqueKey = key;
            [baseInfoArr addObject:baseInfo];
            [baseInfo release];
        }
        if (baseInfoArr.count >1) {
            [self toDeviceWithSelectArray:baseInfoArr WithView:sender];
        }else if (baseInfoArr.count == 1){
            IMBBaseInfo *baseInfo = [baseInfoArr objectAtIndex:0];
            _iCloudManager = [[deviceConntection.iCloudDic objectForKey:baseInfo.uniqueKey] iCloudManager];
            _iCloudManager.delegate = self;
            [self contentAndroidToiCloudIndexSet:selectedSet iCloudManager:_iCloudManager withAndroid:_android];
        }else{
            NSString *str = CustomLocalizedString(@"NoAcount_Tip", nil);
//            [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
            NSView *view = nil;
            for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
                if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                    view = subView;
                    break;
                }
            }
            if (view) {
                [view setHidden:NO];
                int i = [_alertViewController showDeleteConfrimText:str OKButton:CustomLocalizedString(@"Button_Login", nil)  CancelButton:CustomLocalizedString(@"Button_Cancel", nil) SuperView:view];
                if (i == 1) {//跳转到iCloud登录页面
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_JUMP_ICLOUD_VIEW object:nil];
                }
            }
        }
    }
}

- (void)androidToiTunes:(id)sender{
    
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else{
        if (_category == Category_Photo) {
            displayArr = _baseAry;
        } else {
            displayArr = _dataSourceArray;
        }
    }
    NSIndexSet *selectedSet = [self selectedAndroidItems];
    if ([selectedSet count] <= 0) {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"iCloudBackup_View_Selected_Tips", nil);
        }
        
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }else {
        NSMutableArray *selectedTracks = [NSMutableArray array];
        if (_category == Category_Photo) {
            NSMutableArray *albums = [[[NSMutableArray alloc] init] autorelease];
            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [albums addObject:[displayArr objectAtIndex:idx]];
            }];

            if (albums != nil && albums.count >0) {
                IMBADPhotoEntity *photoEntity = [albums objectAtIndex:0];
                IMBADAlbumEntity *newAlbumEntity = [[IMBADAlbumEntity alloc]init];
                for (IMBADAlbumEntity *albumEntity in _dataSourceArray) {
                    if ([albumEntity.photoArray containsObject:photoEntity]) {
                        newAlbumEntity.albumName = albumEntity.albumName;
                        break;
                    }
                }
                newAlbumEntity.photoArray = albums;
                [selectedTracks addObject:newAlbumEntity];
                [newAlbumEntity release];
                newAlbumEntity = nil;
            }
        }else {
            
            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [selectedTracks addObject:[displayArr objectAtIndex:idx]];
            }];
        }
        
        NSDictionary *toiTunesDic = [NSDictionary dictionaryWithObjectsAndKeys:selectedTracks, [NSNumber numberWithInt:_category], nil];
        NSDictionary *dimensionDict = nil;
        @autoreleasepool {
            dimensionDict = [[TempHelper customDimension] copy];
        }
        [ATTracker event:Device_Content action:ToiTunes actionParams:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] label:Start transferCount:selectedTracks.count screenView:[IMBCommonEnum attrackerCategoryNodesEnumToString:_category] userLanguageName:[TempHelper currentSelectionLanguage] customParameters:dimensionDict];
        if (dimensionDict) {
            [dimensionDict release];
            dimensionDict = nil;
        }
        
        
        if (_androidTransController != nil) {
            [_androidTransController release];
            _androidTransController = nil;
        }
        _androidTransController = [[IMBAndroidTransferViewController alloc] initWithAndroidToiTunesAndroid:_android SelectDic:toiTunesDic withCategoryNodesEnum:_category];
        [self animationAddTransferView:_androidTransController.view];
    }
}

- (void)androidChooseiCloudToiCloud:(id)sender{
    NSIndexSet *selectedSet = [self selectedAndroidItems];
    if ([selectedSet count] <= 0) {
        //弹出警告确认框
        NSString *str = nil;
        if (_dataSourceArray.count == 0) {
            str = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_transfer", nil),[StringHelper getCategeryStr:_category]];
        }else {
            str = CustomLocalizedString(@"iCloudBackup_View_Selected_Tips", nil);
        }
        [self showAlertText:str OKButton:CustomLocalizedString(@"Button_Ok", nil)];
    }else {
        _iCloudManager.delegate = self;
        [self contentAndroidToiCloudIndexSet:selectedSet iCloudManager:_iCloudManager withAndroid:_android];
    }
}

#pragma mark - Android rightKeyClick
- (void)androidRightKeyReload:(id)sender
{
    [self androidReload:sender];
}
- (void)androidRightKeyToDevice:(id)sender
{
    [self androidToDevice:sender];
}
- (void)androidRightKeyToiCloud:(id)sender
{
    [self androidToiCloud:sender];
}
- (void)androidRightKeyToiTunes:(id)sender
{
    [self androidToiTunes:sender];
}

- (void)reloadData {
    return;
}

- (void)cancelReload {
    return;
}

#pragma mark - 设备选择按钮事件
- (void)onItemClickedd:(NSString *)account
{
    //        if ([account isEqualToString:CustomLocalizedString(@"icloud_addAcount", nil)]) {
    ////            [self cleanTextField];
    ////            [devPopover close];
    ////            [_rootBox setContentView:_icloudLogView];
    ////            [self.view setBounds:_rootBox.bounds];
    //            return;
    //        }
    //        [_appleID release];
    //        _appleID = [account retain];
    //        [self setiCloudTitle];
    //        NSDictionary *iCloudDic = [_delegate getiCloudAccountViewCollection];
    //        _otheriCloudManager = [[iCloudDic objectForKey:account] iCloudManager];
    //        IMBiCloudMainPageViewController *icloudMainPage = [_iCloudDic objectForKey:account];
    //        //    [icloudMainPage setCookieStorage];
    //        [_rootBox setContentView:icloudMainPage.view];
    //        [icloudMainPage.view setBounds:_rootBox.bounds];
    //        [_devPopover close];
    
    //        for (NSString *str in iCloudDic.allKeys) {
    //            IMBBaseInfo *base = [[IMBBaseInfo alloc]init];
    //            base.isSelected = NO;
    //            i++;
    //            base.uniqueKey = [NSString stringWithFormat:@"%d",i];
    //            base.deviceName = str;
    //            if (![str isEqualToString:_iCloudManager.netClient.loginInfo.appleID]) {
    //                [allDevice addObject:base];
    //            }
    //            [base release];
    //        }
    //    }
}

- (NSData *)readFileData:(NSString *)filePath {
    if (![_ipod.fileSystem fileExistsAtPath:filePath]) {
        return nil;
    }
    else{
        long long fileLength = [_ipod.fileSystem getFileLength:filePath];
        AFCFileReference *openFile = [_ipod.fileSystem openForRead:filePath];
        const uint32_t bufsz = 10240;
        char *buff = (char*)malloc(bufsz);
        NSMutableData *totalData = [[[NSMutableData alloc] init] autorelease];
        while (1) {
            
            uint64_t n = [openFile readN:bufsz bytes:buff];
            if (n==0) break;
            //将字节数据转化为NSdata
            NSData *b2 = [[NSData alloc]
                          initWithBytesNoCopy:buff length:n freeWhenDone:NO];
            [totalData appendData:b2];
            [b2 release];
        }
        free(buff);
        [openFile closeFile];
        return totalData;
    }
}

- (BOOL)isFindMyiCloud:(AMDevice *)device
{
    bool isFindMyDevice = false;
    @try {
        isFindMyDevice = [[device deviceValueForKey:@"IsAssociated" inDomain:@"com.apple.fmip"] boolValue];
    }
    @catch (NSException *exception) {
        [[IMBLogManager singleton] writeInfoLog:[NSString stringWithFormat:@"Android Get IsAssociated exception %@", exception.reason]];
    }
    return isFindMyDevice;
}

-(void)showAlert{
    if (_alertViewController.isIcloudOneOpen) {
        _isPause = YES;
        [self showiCloudAnnoyAlertTitleText:CustomLocalizedString(@"iclouddriver_annoyView_titleStr", nil) withSubStr:CustomLocalizedString(@"iclouddriver_annoyView_subtitleStr", nil) withImageName:@"iCloud_pause" buyButtonText:CustomLocalizedString(@"harassment_buyBtn", nil) CancelButton:CustomLocalizedString(@"iCloudBackup_View_Tips3", nil)];
    }
}

- (void)cancelTimerData{
    if (_annoyTimer != nil) {
        [_annoyTimer invalidate];
        _annoyTimer = nil;
    }
}

- (void)continueloadData{
    [_condition lock];
    if(_isPause)
    {
        _isPause = NO;
        [_condition signal];
    }
    [_condition unlock];
}

#pragma mark - select android calendar data
- (NSArray *)selectAndroidCalendarItems {
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else{
        displayArr = _dataSourceArray;
    }
    NSMutableArray *arrayM = [NSMutableArray array];
    for (IMBCalendarAccountEntity *entity in displayArr) {
        if (entity.checkState == SemiChecked ||entity.checkState == Check) {
            for (IMBADCalendarEntity *eventEntity in entity.eventArray) {
                if (eventEntity.checkState == Check) {
                    IMBCalendarEventEntity *calendarEventEntity = [[IMBCalendarEventEntity alloc]init];
                    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:eventEntity.calendarStartTime/1000 ];
                    [calendarEventEntity setStartCurDate:startDate];
                    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:eventEntity.calendarEndTime/1000 ];
                    [calendarEventEntity setEndCurDate:endDate];
                    [calendarEventEntity setSummary:eventEntity.calendarTitle];
                    [calendarEventEntity setLocation:eventEntity.calendarLocation];
                    [calendarEventEntity setUrl:@""];
                    [calendarEventEntity setEventdescription:eventEntity.calendarDescription];
                    [arrayM addObject:calendarEventEntity];
                    [calendarEventEntity release];
                }
            }
        }
    }
    return arrayM;
}

-(void)dealloc
{
    if (_annoyTimer != nil) {
        [_annoyTimer invalidate];
        _annoyTimer = nil;
    }
    if (_researchdataSourceArray != nil) {
        [_researchdataSourceArray release];
        _researchdataSourceArray = nil;
    }
    [_android release],_android = nil;
    [_ipod release],_ipod = nil;
    [_delArray release],_delArray = nil;
    [_playlistArray release],_playlistArray = nil;
    [_dataSourceArray release],_dataSourceArray = nil;
    [_alertViewController release],_alertViewController = nil;
    [_androidAlertViewController release],_androidAlertViewController = nil;
    [_transferController release],_transferController = nil;
    [_exportSetting release],_exportSetting = nil;
    [camera release], camera = nil;
    [_mergeCloneAppVC release], _mergeCloneAppVC = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_CHANGE_ALLANGUAGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_CHANGE_SKIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DeviceDisConnectedNotification object:nil];
    [super dealloc];
}
@end