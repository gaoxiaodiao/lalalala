//
//  IMBiCloudDriverViewController.m
//  iOSFiles
//
//  Created by smz on 18/3/14.
//  Copyright © 2018年 iMobie. All rights reserved.
//

#import "IMBDeviceAllDataViewController.h"
#import "CNGridViewItemLayout.h"
#import "IMBCommonDefine.h"
#import "IMBImageAndTextFieldCell.h"
#import "HoverButton.h"
#import "IMBiCloudPathSelectBtn.h"
#import "IMBTagImageView.h"
#import "TempHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "IMBDownloadListViewController.h"
#import "IMBAnimation.h"
#import "IMBTranferViewController.h"
#import "IMBBookEntity.h"
#import "IMBAirSyncImportTransfer.h"
#import "IMBDeleteTrack.h"
#import "IMBDeleteApps.h"
#import "IMBBetweenDeviceHandler.h"
#import "IMBCommonTool.h"
#import "IMBPhotoFileExport.h"
#import "IMBiBooksExport.h"
#import "IMBMediaFileExport.h"
#import "IMBAppExport.h"
#import "IMBCommonTool.h"
#import "IMBDevicePageViewController.h"

@interface IMBDeviceAllDataViewController ()
{
    IMBBaseTransfer *_baseTransfer;
    
}
@end

@implementation IMBDeviceAllDataViewController

- (id)initWithCategoryNodesEnum:(CategoryNodesEnum )nodeEnum withiPod:(IMBiPod *)iPod WithDelegete:(id)delegete {
    if (self = [super initWithNibName:@"IMBDeviceAllDataViewController" bundle:nil]) {
        _categoryNodeEunm = nodeEnum;
        _iPod = iPod;
        _delegate = delegete;
    }
    return self;
}

- (void)dealloc {
    if (_dataSourceArray != nil) {
        [_dataSourceArray release];
        _dataSourceArray = nil;
    }
    if (_driveBaseManage != nil) {
        [_driveBaseManage release];
        _driveBaseManage = nil;
    }
    if (_oldWidthDic != nil) {
        [_oldWidthDic release];
        _oldWidthDic = nil;
    }
    if (_tempDic != nil) {
        [_tempDic release];
        _tempDic = nil;
    }
    if (_oldDocwsidDic != nil) {
        [_oldDocwsidDic release];
        _oldDocwsidDic = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_HIDE_ICLOUDDETAIL object:nil];
    [super dealloc];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configNoDataView];
    _currentSelectView = 1;
    [self changeToolButtonsIsSelectedIntems:NO];
    [_leftContentView setFrame:NSMakeRect(0, 0, 1100, 547)];
    [_rightContentView setFrame:NSMakeRect(1100, 0, 282, 547)];
    
    _oldWidthDic = [[NSMutableDictionary alloc] init];
    _oldDocwsidDic = [[NSMutableDictionary alloc] init];
    _tempDic = [[NSMutableDictionary alloc] init];
    [self configSelectPathButtonWithButtonTag:1 WithButtonTitle:_iPod.deviceInfo.deviceName];
    if (_categoryNodeEunm == Category_CameraRoll || _categoryNodeEunm == Category_PhotoStream || _categoryNodeEunm == Category_PhotoStream) {
        [self configSelectPathButtonWithButtonTag:2 WithButtonTitle:[StringHelper getCategeryStr:Category_Photos]];
        [self configSelectPathButtonWithButtonTag:3 WithButtonTitle:[StringHelper getCategeryStr:_categoryNodeEunm]];
    } else {
        [self configSelectPathButtonWithButtonTag:2 WithButtonTitle:[StringHelper getCategeryStr:_categoryNodeEunm]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFileDetailView:) name:NOTIFY_HIDE_ICLOUDDETAIL object:nil];
    
    _doubleclickCount = 2;
    [_topLineView setBackgroundColor:COLOR_TEXT_LINE];
    
    _gridView.itemSize = NSMakeSize(154, 154);
//    _gridView.backgroundColor = [NSColor whiteColor];
    _gridView.scrollElasticity = NO;
    _gridView.allowsDragAndDrop = YES;
    _gridView.allowsMultipleSelection = YES;
    _gridView.allowsMultipleSelectionWithDrag = YES;
    _gridView.allowClickMultipleSelection = NO;
    [_gridView setIsFileManager:YES];
    [_tableViewBgView setBackgroundColor:[NSColor whiteColor]];
    
  
    if (_categoryNodeEunm == Category_System) {
        _currentDevicePath = @"/";
        [_loadAnimationView startAnimation];
        [_contentBox setContentView:_loadingView];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            _systemManager = [[IMBFileSystemManager alloc] initWithiPodByExport:_iPod];
            [_systemManager setDelegate:self];
            _dataSourceArray = [(NSMutableArray *)[_systemManager recursiveDirectoryContentsDics:@"/"] retain];
            _currentDevicePath = @"/";
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_oldDocwsidDic setObject:_currentDevicePath forKey:[NSString stringWithFormat:@"%d",_doubleclickCount]];
                [_tempDic setObject:_dataSourceArray forKey:[NSString stringWithFormat:@"%d",_doubleclickCount]];
                
                if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
                    [_itemTableView reloadData];
                    [_gridView reloadData];
                    [_contentBox setContentView:_gridBgView];
                } else {
                    [_contentBox setContentView:_nodataView];
                }
                [_loadAnimationView endAnimation];
                [_itemTableView reloadData];
                [_gridView reloadData];
            });
        });
    }else {
        [self loadDataAry];
        if (_categoryNodeEunm == Category_Media) {
            [self setInitlializationViewWithIsDataLoadCompleted:_iPod.mediaLoadFinished];
        }else if (_categoryNodeEunm == Category_Video) {
            [self setInitlializationViewWithIsDataLoadCompleted:_iPod.videoLoadFinished];
        }else if (_categoryNodeEunm == Category_iBooks) {
            [self setInitlializationViewWithIsDataLoadCompleted:_iPod.bookLoadFinished];
        }else if (_categoryNodeEunm == Category_Applications) {
            [self setInitlializationViewWithIsDataLoadCompleted:_iPod.appsLoadFinished];
        }else if (_categoryNodeEunm == Category_PhotoStream) {
            [self setInitlializationViewWithIsDataLoadCompleted:_iPod.photoLoadFinished];
        }else if (_categoryNodeEunm == Category_PhotoLibrary) {
            [self setInitlializationViewWithIsDataLoadCompleted:_iPod.photoLoadFinished];
        }else if (_categoryNodeEunm == Category_CameraRoll) {
            [self setInitlializationViewWithIsDataLoadCompleted:_iPod.photoLoadFinished];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoLoadFinished:) name:DeviceDataLoadCompletePhoto object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLoadFinished:) name:DeviceDataLoadCompleteApp object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookLoadFinished:) name:deviceDataLoadCompleteBooks object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaLoadFinished:) name:deviceDataLoadCompleteMedia object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoLoadFinished:) name:DeviceDataLoadCompleteVideo object:nil];

        [_itemTableView reloadData];
        [_gridView reloadData];
    }

}

- (void)setInitlializationViewWithIsDataLoadCompleted:(BOOL)isCompleted {
    if (isCompleted) {
        if (_dataSourceArray != nil && _dataSourceArray.count > 0 ) {
            [_contentBox setContentView:_gridBgView];
        } else {
            [_contentBox setContentView:_nodataView];
        }
    }else {
        [_loadAnimationView startAnimation];
        [_contentBox setContentView:_loadingView];
    }
}

- (void)loadDataAry {
    IMBInformationManager *inforManager = [IMBInformationManager shareInstance];
    _information = [inforManager.informationDic objectForKey:_iPod.uniqueKey];
    if (_categoryNodeEunm == Category_Photos) {
        _dataSourceArray = [_information.allPhotoArray retain];
    }else if (_categoryNodeEunm == Category_Media) {
        _dataSourceArray = [_information.mediaArray retain];
    }else if (_categoryNodeEunm == Category_Video) {
        _dataSourceArray = [_information.videoArray retain];
    }else if (_categoryNodeEunm == Category_iBooks) {
        _dataSourceArray = [_information.allBooksArray retain];
    }else if (_categoryNodeEunm == Category_Applications) {
        _dataSourceArray = [_information.appArray retain];
    }else if (_categoryNodeEunm == Category_PhotoStream) {
        _dataSourceArray = [_information.photostreamArray retain];
    }else if (_categoryNodeEunm == Category_PhotoLibrary) {
        _dataSourceArray = [_information.photolibraryArray retain];
    }else if (_categoryNodeEunm == Category_CameraRoll) {
        _dataSourceArray = [_information.allPhotoArray retain];
    }
}

- (void)configNoDataView {
    
    [_nodataImageView setImage:[StringHelper imageNamed:@"nodata_myfiles"]];
    NSString *promptStr = [NSString stringWithFormat:CustomLocalizedString(@"NO_DATA_TITLE_1", nil),CustomLocalizedString(@"MenuItem_id_81", nil)];
    NSMutableAttributedString *promptAs = [TempHelper setSingleTextAttributedString:promptStr withFont:[NSFont fontWithName:@"Helvetica Neue" size:12] withColor:COLOR_TEXT_EXPLAIN];
    NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
    [mutParaStyle setAlignment:NSCenterTextAlignment];
    [mutParaStyle setLineSpacing:5.0];
    [promptAs addAttributes:[NSDictionary dictionaryWithObject:mutParaStyle forKey:NSParagraphStyleAttributeName] range:NSMakeRange(0,[[promptAs string] length])];
    [_nodataTextView setEditable:NO];
    [_nodataTextView setSelectable:NO];
    [[_nodataTextView textStorage] setAttributedString:promptAs];
    [mutParaStyle release];
    mutParaStyle = nil;
    
}

#pragma mark - 搜索
- (void)doSearchBtn:(NSString *)searchStr withSearchBtn:(IMBSearchView *)searchView {
    _searhView = searchView;
    _isSearch = YES;
    if (searchStr != nil && ![searchStr isEqualToString:@""]) {
        NSPredicate *predicate = nil;
        if (_categoryNodeEunm == Category_Media||_categoryNodeEunm == Category_Video) {
            predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@ ",searchStr];
        }else if (_categoryNodeEunm == Category_iBooks) {
             predicate = [NSPredicate predicateWithFormat:@"bookName CONTAINS[cd] %@ ",searchStr];
        }else if (_categoryNodeEunm == Category_Applications) {
             predicate = [NSPredicate predicateWithFormat:@"appName CONTAINS[cd] %@ ",searchStr];
        }else if (_categoryNodeEunm == Category_System) {
             predicate = [NSPredicate predicateWithFormat:@"fileName CONTAINS[cd] %@ ",searchStr];
        }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
             predicate = [NSPredicate predicateWithFormat:@"photoName CONTAINS[cd] %@ ",searchStr];
        }
        [_researchdataSourceArray removeAllObjects];
        [_researchdataSourceArray addObjectsFromArray:[_dataSourceArray  filteredArrayUsingPredicate:predicate]];
    }else{
        _isSearch = NO;
        [_researchdataSourceArray removeAllObjects];
    }
    NSMutableArray *disAry = nil;
    if (_isSearch) {
        disAry = _researchdataSourceArray;
    }else{
        disAry = _dataSourceArray;
    }
    
    int checkCount = 0;
    for (int i=0; i<[disAry count]; i++) {
        IMBDriveEntity *entity = [disAry objectAtIndex:i];
        if (entity.checkState == NSOnState) {
            checkCount ++;
        }
    }
    if (checkCount == [disAry count]&&[disAry count]>0) {
        [_itemTableView changeHeaderCheckState:NSOnState];
    }else if (checkCount  == 0)
    {
        [_itemTableView changeHeaderCheckState:NSOffState];
    }else
    {
        [_itemTableView changeHeaderCheckState:NSMixedState];
    }
    
    [_itemTableView reloadData];
    [_gridView reloadData];
    
}

#pragma mark - path button config
- (void)configSelectPathButtonWithButtonTag:(int)buttonTag WithButtonTitle:(NSString *)buttonTitle {
    NSString *fileName = buttonTitle;
    if (fileName.length > 15) {
        fileName = [[fileName substringWithRange:NSMakeRange(0, 13)] stringByAppendingString:@"..."];
    }
    NSRect textRect = [StringHelper calcuTextBounds:fileName fontSize:14.0];
    int width = textRect.size.width + 10;
    [_oldWidthDic setObject:[NSString stringWithFormat:@"%d",width] forKey:[NSString stringWithFormat:@"%d",buttonTag]];
    int height = textRect.size.height + 4;
    int oldWidth = 0;
    for (int i = 1; i <= buttonTag; i++) {
        if ([_oldWidthDic.allKeys containsObject:[NSString stringWithFormat:@"%d",i - 1]]) {
            oldWidth += [[_oldWidthDic objectForKey:[NSString stringWithFormat:@"%d",i - 1]] intValue];
        }
    }
    
    IMBiCloudPathSelectBtn *button = [[IMBiCloudPathSelectBtn alloc] initWithFrame:NSMakeRect(20 + (buttonTag - 1)*10 + oldWidth, (_topView.frame.size.height - height)/2 - 2, width, height)];
    if (_categoryNodeEunm == Category_CameraRoll || _categoryNodeEunm == Category_PhotoStream || _categoryNodeEunm == Category_PhotoStream) {
        if (buttonTag == 3) {
            [button setEnabled:NO];
        }
    } else {
        if (buttonTag == 2 && _categoryNodeEunm != Category_System) {
            [button setEnabled:NO];
        }
    }
    [button setButtonName:fileName];
    [button setToolTip:buttonTitle];
    [button setTag:buttonTag];
    [button setTarget:self];
    [button setAction:@selector(iCloudButtonClick:)];
    [_topView addSubview:button];
    if (buttonTag - 1) {
        IMBTagImageView *arrowImageView = [[IMBTagImageView alloc] initWithFrame:NSMakeRect(button.frame.origin.x - 10, (_topView.frame.size.height - 9)/2.0 - 3, 10, 9)];
        [arrowImageView setImage:[NSImage imageNamed:@"addcontent_arrowright1"]];
        [arrowImageView setViewTag:buttonTag];
        [_topView addSubview:arrowImageView];
        [arrowImageView release];
        arrowImageView = nil;
    }
    [button release];
    button = nil;
}

- (void)iCloudButtonClick:(id)sender {
    int tag = (int)((IMBiCloudPathSelectBtn *)sender).tag;
    if (tag == 1 || _categoryNodeEunm == Category_CameraRoll || _categoryNodeEunm == Category_PhotoStream || _categoryNodeEunm == Category_PhotoStream) {
        [_delegate backAction:sender];
    } else {
        int viewCount = (int)[_topView subviews].count;
        for (int i = viewCount - 1; i > 0; i--) {
            NSView *subView = [[_topView subviews] objectAtIndex:i];
            if ([subView isKindOfClass:[NSClassFromString(@"IMBiCloudPathSelectBtn") class]]) {
                if (subView.tag > tag) {
                    [subView removeFromSuperview];
                }
            }
            if ([subView isKindOfClass:[NSClassFromString(@"IMBTagImageView") class]]) {
                if (((IMBTagImageView *)subView).viewTag > tag) {
                    [subView removeFromSuperview];
                }
            }
        }
        
        for (int i = 1; i <= _doubleclickCount; i++) {
            if (tag == i) {
                [self changeContentViewWithDataArr:[_tempDic objectForKey:[NSString stringWithFormat:@"%d",i]]];
                for (int j = i + 1; j <= _doubleclickCount; j++) {
                    if ([_tempDic.allKeys containsObject:[NSString stringWithFormat:@"%d",j]]) {
                        [_tempDic removeObjectForKey:[NSString stringWithFormat:@"%d",j]];
                    }
                    if ([_oldWidthDic.allKeys containsObject:[NSString stringWithFormat:@"%d",j]]) {
                        [_oldWidthDic removeObjectForKey:[NSString stringWithFormat:@"%d",j]];
                    }
                    if ([_oldDocwsidDic.allKeys containsObject:[NSString stringWithFormat:@"%d",j]]) {
                        [_oldDocwsidDic removeObjectForKey:[NSString stringWithFormat:@"%d",j]];
                    }
                }
                _doubleclickCount = i;
                
                break;
            }
        }
        
        if ([_oldDocwsidDic.allKeys containsObject:[NSString stringWithFormat:@"%d",tag]]) {
            _currentDevicePath = [_oldDocwsidDic objectForKey:[NSString stringWithFormat:@"%d",tag]];
        }
    }
}

- (void)changeContentViewWithDataArr:(NSMutableArray *)dataArr {
    if (_dataSourceArray != nil) {
        [_dataSourceArray release];
        _dataSourceArray = nil;
    }
    _dataSourceArray = [dataArr retain];
    [_gridView reloadData];
    [_itemTableView reloadData];
    [self changeToolButtonsIsSelectedIntems:NO];
    if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
        if (_currentSelectView == 0) {
            [_contentBox setContentView:_tableViewBgView];
        } else {
            [_contentBox setContentView:_gridBgView];
        }
    } else {
        [_contentBox setContentView:_nodataView];
    }
}

#pragma mark - CNGridView DataSource
- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section {
    if (_isSearch) {
        return _researchdataSourceArray.count;
    }else {
        return _dataSourceArray.count;
    }
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section {
    static NSString *reuseIdentifier = @"CNGridViewItem";
    
    CNGridViewItem *item = [gridView dequeueReusableItemWithIdentifier:@(index)];
    if (item == nil) {
        item = [[[CNGridViewItem alloc] initWithLayout:self.defaultLayout reuseIdentifier:reuseIdentifier] autorelease];
        item.hoverLayout = self.hoverLayout;
        item.selectionLayout = self.selectionLayout;
    }
    NSArray *array = nil;
    if (_isSearch) {
        array = _researchdataSourceArray;
    }else {
        array = _dataSourceArray;
    }
    if (index >= array.count) {
        return item;
    }
    item.isFileManager = YES;
    
    if (_categoryNodeEunm == Category_Media || _categoryNodeEunm == Category_Video) {
        IMBTrack *track = [array objectAtIndex:index];
        if (_categoryNodeEunm == Category_Media) {
            item.bgImg = [NSImage imageNamed:@"cnt_fileicon_music"];
        } else {
            item.bgImg = [NSImage imageNamed:@"cnt_fileicon_video"];
        }
        item.itemTitle = track.title;
        item.selected = track.checkState;
        
        if (track.thumbImage) {
            item.itemImage = track.thumbImage;
        } else {
            NSData *data = [self createThumbImage:track];
            NSImage *itemImage = [[NSImage alloc] initWithData:data];
            item.itemImage = itemImage;
            if (itemImage) {
                track.thumbImage = itemImage;
            } else {
                track.thumbImage = item.bgImg;
            }
        }
        
        if (track.checkState == Check) {
            if (![gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] setObject:item forKey:@(item.index)];
            }
        }else{
            if ([gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] removeObjectForKey:@(item.index)];
            }
        }
    }else if (_categoryNodeEunm == Category_iBooks) {
        
        IMBBookEntity *bookEntity = [array objectAtIndex:index];
        item.bgImg = [NSImage imageNamed:@"cnt_fileicon_books"];
        item.itemTitle = bookEntity.bookName;
        item.selected = bookEntity.checkState;
        item.itemImage = bookEntity.coverImage;
        if (bookEntity.checkState == Check) {
            if (![gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] setObject:item forKey:@(item.index)];
            }
        }else{
            if ([gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] removeObjectForKey:@(item.index)];
            }
        }
    }else if (_categoryNodeEunm == Category_Applications) {
        
        IMBAppEntity *appEntit = [array objectAtIndex:index];
        item.bgImg = [NSImage imageNamed:@"folder_icon_app"];
        item.itemTitle = appEntit.appName;
        item.selected = appEntit.checkState;
        item.itemImage = appEntit.appIconImage;
        if (appEntit.checkState == Check) {
            if (![gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] setObject:item forKey:@(item.index)];
            }
        }else{
            if ([gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] removeObjectForKey:@(item.index)];
            }
        }
    }else if (_categoryNodeEunm == Category_System) {
        SimpleNode *simpleNode = [array objectAtIndex:index];
        item.bgImg = [NSImage imageNamed:@"cnt_fileicon_common"];
        item.itemTitle = simpleNode.fileName;
        item.selected = simpleNode.checkState;
        item.itemImage = simpleNode.image;
        if (simpleNode.checkState == Check) {
            if (![gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] setObject:item forKey:@(item.index)];
            }
        }else{
            if ([gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] removeObjectForKey:@(item.index)];
            }
        }
    }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
        IMBPhotoEntity *photoEntity = [array objectAtIndex:index];
        item.bgImg = [NSImage imageNamed:@"cnt_fileicon_img"];
        item.itemTitle = photoEntity.photoName;
        item.selected = photoEntity.checkState;
        if (photoEntity.photoImage) {
            item.itemImage = photoEntity.photoImage;
        } else {
            NSData *imageData = [self createImageToTableView:photoEntity];
            NSImage *photoImage = [[NSImage alloc]initWithData:imageData];
            item.itemImage = photoImage;
            if (photoImage) {
                photoEntity.photoImage = photoImage;
            } else {
                photoEntity.photoImage = item.bgImg;
            }
            
            [photoImage release];
        }
        
        if (photoEntity.checkState == Check) {
            if (![gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] setObject:item forKey:@(item.index)];
            }
        }else{
            if ([gridView.selectedItems containsObject:item]) {
                [[gridView getSelectedItemsDic] removeObjectForKey:@(item.index)];
            }
        }
    }
    return item;
}

#pragma mark - CNGridView Delegate
- (void)gridView:(CNGridView *)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
    [self changeToolButtonsIsSelectedIntems:YES];
    NSArray *array = nil;
    if (_isSearch) {
        array = _researchdataSourceArray;
    }else {
        array = _dataSourceArray;
    }
    if (index < array.count) {
        
        if (_categoryNodeEunm == Category_Media) {
        }else if (_categoryNodeEunm == Category_Video) {
        }else if (_categoryNodeEunm == Category_iBooks) {
        }else if (_categoryNodeEunm == Category_Applications) {
        }else if (_categoryNodeEunm == Category_System) {
        }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
            IMBPhotoEntity *photoEnity = [array objectAtIndex:index];
            photoEnity.checkState = Check;
            int count = 0;
            for (IMBPhotoEntity *entity in array) {
                if (entity.checkState == Check) {
                    count ++ ;
                }
            }
        }
    }
    
}

- (void)gridView:(CNGridView *)gridView didDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
    NSArray *array = nil;
    if (_isSearch) {
        array = _researchdataSourceArray;
    }else {
        array = _dataSourceArray;
    }
    if (index < array.count) {
        if (_categoryNodeEunm == Category_Media) {
        }else if (_categoryNodeEunm == Category_Video) {
        }else if (_categoryNodeEunm == Category_iBooks) {
        }else if (_categoryNodeEunm == Category_Applications) {
        }else if (_categoryNodeEunm == Category_System) {
        }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
            IMBPhotoEntity *photoEnity = [array objectAtIndex:index];
            photoEnity.checkState = UnChecked;
            
        }
    }
}

- (void)gridViewDidDeselectAllItems:(CNGridView *)gridView {
    [self changeToolButtonsIsSelectedIntems:NO];
    NSArray *array = nil;
    if (_isSearch) {
        array = _researchdataSourceArray;
    }else {
        array = _dataSourceArray;
    }
    if (_categoryNodeEunm == Category_Media) {
    }else if (_categoryNodeEunm == Category_Video) {
    }else if (_categoryNodeEunm == Category_iBooks) {
    }else if (_categoryNodeEunm == Category_Applications) {
    }else if (_categoryNodeEunm == Category_System) {
    }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
        for (IMBPhotoEntity *photoEnity in array) {
            photoEnity.checkState = UnChecked;
        }
    }
    [_gridView reloadSelecdImage];
}

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
    if ((int)index >= 0 && index < _dataSourceArray.count) {
        if (_categoryNodeEunm == Category_System) {
            [_loadAnimationView startAnimation];
            [_contentBox setContentView:_loadingView];
            SimpleNode *selectedNode = [_dataSourceArray objectAtIndex:index];
            if (selectedNode.container) {
                _doubleclickCount ++;
                [self configSelectPathButtonWithButtonTag:_doubleclickCount WithButtonTitle:selectedNode.fileName];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    @autoreleasepool {
                        NSArray *array = [_systemManager recursiveDirectoryContentsDics:selectedNode.path];
                        _currentDevicePath = selectedNode.path;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (_dataSourceArray) {
                                [_dataSourceArray release];
                                _dataSourceArray = nil;
                            }
                            _dataSourceArray = [(NSMutableArray *)array retain];
                            [_oldDocwsidDic setObject:_currentDevicePath forKey:[NSString stringWithFormat:@"%d",_doubleclickCount]];
                            [_tempDic setObject:_dataSourceArray forKey:[NSString stringWithFormat:@"%d",_doubleclickCount]];
                            
                            if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
                                [_contentBox setContentView:_gridBgView];
                            } else {
                                [_contentBox setContentView:_nodataView];
                            }
                            [_gridView reloadData];
                        });
                    }
                });
            }
        }
    }
}

- (void)gridView:(CNGridView *)gridView didClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
    if (index < _dataSourceArray.count && (int)index >= 0) {
        _curEntity = [_dataSourceArray objectAtIndex:index];
        if (_isShow) {
            [self showFileDetailViewWithEntity:_curEntity];
        }
    }
}
//排序
- (void)sortClick:(id)sender {
    [_devPopover close];
    NSMutableArray *disPalyAry = nil;
    if (_isSearch) {
        disPalyAry = _researchdataSourceArray;
    }else{
        disPalyAry = _dataSourceArray;
    }
    if (disPalyAry.count <=0) {
        return;
    }
    if([sender isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)sender;
        NSString *key = nil;
        if ([str isEqualToString:CustomLocalizedString(@"List_Header_id_Name", nil)]) {
            if (_categoryNodeEunm == Category_Media||_categoryNodeEunm == Category_Video) {
                key = @"title";
            }else if (_categoryNodeEunm == Category_iBooks) {
                 key = @"bookName";
            }else if (_categoryNodeEunm == Category_Applications) {
                key = @"appName";
            }else if (_categoryNodeEunm == Category_System) {
                key = @"fileName";
            }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
                key = @"photoName";
            }
        }else if ([str isEqualToString:CustomLocalizedString(@"List_Header_id_Date", nil)]) {
            if (_categoryNodeEunm == Category_Media||_categoryNodeEunm == Category_Video) {
                
            }else if (_categoryNodeEunm == Category_iBooks) {
                
            }else if (_categoryNodeEunm == Category_Applications) {
                
            }else if (_categoryNodeEunm == Category_System) {
                
            }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
                
            }
            key = @"";
        }else if ([str isEqualToString:CustomLocalizedString(@"List_Header_id_Type", nil)]) {
            if (_categoryNodeEunm == Category_Media||_categoryNodeEunm == Category_Video) {
                
            }else if (_categoryNodeEunm == Category_iBooks) {
                
            }else if (_categoryNodeEunm == Category_Applications) {
                
            }else if (_categoryNodeEunm == Category_System) {
                
            }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
                
            }
            key = @"";
        }else if ([str isEqualToString:CustomLocalizedString(@"List_Header_id_Size", nil)]) {
            if (_categoryNodeEunm == Category_Media||_categoryNodeEunm == Category_Video) {
                key = @"fileSize";
            }else if (_categoryNodeEunm == Category_iBooks) {
                key = @"size";
            }else if (_categoryNodeEunm == Category_Applications) {
                key = @"appSize";
            }else if (_categoryNodeEunm == Category_System) {
                key = @"itemSize";
            }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
                key = @"photoSize";
            }
            
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];//其中，price为数组中的对象的属性，这个针对数组中存放对象比较更简洁方便
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [disPalyAry sortUsingDescriptors:sortDescriptors];
        [_gridView reloadData];
        [sortDescriptor release];
    }
}

- (void)showFileDetailViewWithEntity:(IMBBaseEntity *)entity {
    [_rightLineView setBackgroundColor:COLOR_TEXT_LINE];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        NSRect rect= NSMakeRect(814, 0, 282, 556);
        NSRect rect2 = NSMakeRect(0, 0, 814, 556);
        [context setDuration:0.3];
        [[_rightContentView animator] setFrame:rect];
        [[_leftContentView animator] setFrame:rect2];
        
    } completionHandler:^{
        [self configDetailViewWith:entity];
    }];
}

- (IBAction)hideFileDetailView:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        NSRect rect;
        rect = NSMakeRect(1100, 0, 282,556);
        NSRect rect2 = NSMakeRect(0, 0, 1100, 556);
        [context setDuration:0.3];
        [[_rightContentView animator] setFrame:rect];
        [[_leftContentView animator] setFrame:rect2];
    } completionHandler:^{
        _isShow = NO;
    }];
    
    if (_isShowTranfer) {
        IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
        _isShowTranfer = NO;
        [tranferView.view setFrame:NSMakeRect([_delegate window].contentView.frame.size.width - tranferView.view.frame.size.width + 8, -8, 360, tranferView.view.frame.size.height)];
        
        NSView *view = nil;
        for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
            if ([subView isMemberOfClass:[NSClassFromString(@"IMBTranferBackgroundView") class]]&& [subView.subviews count] == 0) {
                view = subView;
                break;
            }
        }
        [view setHidden:NO];
        [view setWantsLayer:YES];
        [view addSubview:tranferView.view];
        [tranferView.view setWantsLayer:YES];
        
        [tranferView.view.layer addAnimation:[IMBAnimation moveX:0.5 fromX:[NSNumber numberWithInt:0] toX:[NSNumber numberWithInt:tranferView.view.frame.size.width] repeatCount:1 beginTime:0]  forKey:@"moveX"];
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{

            [view setHidden:YES];
            [view.layer removeAllAnimations];
            [tranferView.view removeFromSuperview];
            [tranferView.view.layer removeAllAnimations];
            [tranferView.view setFrame:NSMakeRect([_delegate window].contentView.frame.size.width +8, -8, 360, tranferView.view.frame.size.height)];
        });
    }
}

- (void)configDetailViewWith:(IMBBaseEntity *)entity {
    
    [_detailSize setStringValue:CustomLocalizedString(@"List_Header_id_Size", nil)];
    [_detailCount setStringValue:CustomLocalizedString(@"iCloud_detailView_count", nil)];
    [_detailLastTime setStringValue:CustomLocalizedString(@"iCloud_detailView_lastTime", nil)];
    [_detailCreateTime setStringValue:CustomLocalizedString(@"iCloud_detailView_creatTime", nil)];
    
    [_detailSize setTextColor:COLOR_TEXT_ORDINARY];
    [_detailCount setTextColor:COLOR_TEXT_ORDINARY];
    [_detailLastTime setTextColor:COLOR_TEXT_ORDINARY];
    [_detailCreateTime setTextColor:COLOR_TEXT_ORDINARY];
    [_detailTitle setTextColor:COLOR_TEXT_ORDINARY];
    
    
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (_isSearch) {
        if (_researchdataSourceArray != nil && _researchdataSourceArray.count > 0) {
            return _researchdataSourceArray.count;
        }
    }else {
        if (_dataSourceArray != nil && _dataSourceArray.count > 0) {
            return _dataSourceArray.count;
        }
    }
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *array = nil;
    if (_isSearch) {
        array = _researchdataSourceArray;
    }else {
        array = _dataSourceArray;
    }
    if (_categoryNodeEunm == Category_Media || _categoryNodeEunm == Category_Video) {
        IMBTrack *track = [array objectAtIndex:row];
        if ([@"Formats" isEqualToString:tableColumn.identifier]){
            if (![StringHelper stringIsNilOrEmpty:@""]) {
                return @"";
            }else {
                return @"--";
            }
        }else if ([@"LastTime" isEqualToString:tableColumn.identifier]){
            if (track.dateLastModified == 0) {
                return @"--";
            }else{
                return [DateHelper dateFrom1970ToString:track.dateLastModified withMode:2];
            }
        }else if ([@"Size" isEqualToString:tableColumn.identifier]){
            return [StringHelper getFileSizeString:track.fileSize reserved:2];
        }
        return @"";
    }else if (_categoryNodeEunm == Category_iBooks) {
        IMBBookEntity *bookEntity = [array objectAtIndex:row];
        if ([@"Formats" isEqualToString:tableColumn.identifier]){
            if (![StringHelper stringIsNilOrEmpty:bookEntity.extension]) {
                return bookEntity.extension;
            }else {
                return @"--";
            }
        }else if ([@"LastTime" isEqualToString:tableColumn.identifier]){
            if ([StringHelper stringIsNilOrEmpty:@""]) {
                return @"--";
            }else{
                return @"";
            }
        }else if ([@"Size" isEqualToString:tableColumn.identifier]){
            return [StringHelper getFileSizeString:bookEntity.size reserved:2];
        }
        return @"";
        
    }else if (_categoryNodeEunm == Category_Applications) {
        IMBAppEntity *appEntity = [array objectAtIndex:row];
        if ([@"Formats" isEqualToString:tableColumn.identifier]){
            if (![StringHelper stringIsNilOrEmpty:@""]) {
                return @"";
            }else {
                return @"";
            }
        }else if ([@"LastTime" isEqualToString:tableColumn.identifier]){
            if ([StringHelper stringIsNilOrEmpty:@""]) {
                return @"--";
            }else{
                return @"";
            }
        }else if ([@"Size" isEqualToString:tableColumn.identifier]){
            return [StringHelper getFileSizeString:appEntity.appSize reserved:2];
        }
        return @"";
        
    }else if (_categoryNodeEunm == Category_System) {
        SimpleNode *simpleNode = [array objectAtIndex:row];
        if ([@"Formats" isEqualToString:tableColumn.identifier]){
            if (![StringHelper stringIsNilOrEmpty:simpleNode.extension]) {
                return simpleNode.extension;
            }else {
                return @"--";
            }
        }else if ([@"LastTime" isEqualToString:tableColumn.identifier]){
            if (![StringHelper stringIsNilOrEmpty:simpleNode.creatDate]) {
                return simpleNode.creatDate;
            }else{
                return @"--";
            }
        }else if ([@"Size" isEqualToString:tableColumn.identifier]){
            return [StringHelper getFileSizeString:simpleNode.itemSize reserved:2];
        }
        return @"";
        
    }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
        IMBPhotoEntity *photoEnity = [array objectAtIndex:row];
        if ([@"Formats" isEqualToString:tableColumn.identifier]){
            if (![StringHelper stringIsNilOrEmpty:photoEnity.photoName]) {
                return [[photoEnity.photoName lastPathComponent] lowercaseString];
            }else {
                return @"--";
            }
        }else if ([@"LastTime" isEqualToString:tableColumn.identifier]){
            if (photoEnity.photoDateData == 0) {
                return @"--";
            }else{
                return [DateHelper dateFrom1970ToString:photoEnity.photoDateData withMode:2];
            }
        }else if ([@"Size" isEqualToString:tableColumn.identifier]){
            return [StringHelper getFileSizeString:photoEnity.photoSize reserved:2];
        }
        return @"--";
        
        
    }
    return @"";
}

#pragma mark - NSTableViewdelegate
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *array = nil;
    if (_isSearch) {
        array = _researchdataSourceArray;
    }else {
        array = _dataSourceArray;
    }
    if ([tableColumn.identifier isEqualToString:@"ImageText"] && row < array.count) {
        if (_categoryNodeEunm == Category_Media||_categoryNodeEunm == Category_Video) {
            IMBTrack *track = [array objectAtIndex:row];
            IMBImageAndTextFieldCell *curCell = (IMBImageAndTextFieldCell *)cell;
            [curCell setImageSize:NSMakeSize(24, 24)];
            curCell.image = track.thumbImage;
            curCell.imageText = track.title;
            [curCell setIsDataImage:YES];
            curCell.marginX = 12;
        }else if (_categoryNodeEunm == Category_iBooks) {
            IMBBookEntity *bookEntity = [array objectAtIndex:row];
            IMBImageAndTextFieldCell *curCell = (IMBImageAndTextFieldCell *)cell;
            [curCell setImageSize:NSMakeSize(24, 24)];
            curCell.image = bookEntity.coverImage;
            curCell.imageText = bookEntity.bookName;
            [curCell setIsDataImage:YES];
            curCell.marginX = 12;
        }else if (_categoryNodeEunm == Category_Applications) {
            IMBAppEntity *appEntity = [array objectAtIndex:row];
            IMBImageAndTextFieldCell *curCell = (IMBImageAndTextFieldCell *)cell;
            [curCell setImageSize:NSMakeSize(24, 24)];
            curCell.image = appEntity.appIconImage;
            curCell.imageText = appEntity.appName;
            [curCell setIsDataImage:YES];
            curCell.marginX = 12;
        }else if (_categoryNodeEunm == Category_System) {
            SimpleNode *simpleNode = [array objectAtIndex:row];
            IMBImageAndTextFieldCell *curCell = (IMBImageAndTextFieldCell *)cell;
            [curCell setImageSize:NSMakeSize(24, 24)];
            curCell.image = simpleNode.image;
            curCell.imageText = simpleNode.fileName;
            [curCell setIsDataImage:YES];
            curCell.marginX = 12;
        }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
            IMBPhotoEntity *photoEnity = [array objectAtIndex:row];
            IMBImageAndTextFieldCell *curCell = (IMBImageAndTextFieldCell *)cell;
            [curCell setImageSize:NSMakeSize(24, 24)];
            curCell.image = photoEnity.photoImage;
            curCell.imageText = photoEnity.photoName;
            [curCell setIsDataImage:YES];
            curCell.marginX = 12;
        }
    }
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 40;
}

- (void)tableView:(NSTableView *)tableView WithSelectIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray *disPalyAry = nil;
    if (_isSearch) {
        disPalyAry = _researchdataSourceArray;
    }else{
        disPalyAry = _dataSourceArray;
    }
    if (disPalyAry.count <=0) {
        return;
    }
}

- (void)tableViewDoubleClick:(NSTableView *)tableView row:(NSInteger)index {
    [self gridView:_gridView didDoubleClickItemAtIndex:index inSection:0];
}

//排序
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    id cell = [tableColumn headerCell];
    NSString *identify = [tableColumn identifier];
    NSArray *array = [tableView tableColumns];
    NSMutableArray *disPalyAry = nil;
    if (_isSearch) {
        disPalyAry = _researchdataSourceArray;
    }else{
        disPalyAry = _dataSourceArray;
    }
    if (disPalyAry.count <=0) {
        return;
    }
    for (NSTableColumn  *column in array) {
        if ([column.headerCell isKindOfClass:[IMBCustomHeaderCell class]]) {
            IMBCustomHeaderCell *columnHeadercell = (IMBCustomHeaderCell *)column.headerCell;
            if ([column.identifier isEqualToString:identify]) {
                [columnHeadercell setIsShowTriangle:YES];
            }else {
                [columnHeadercell setIsShowTriangle:NO];
            }
        }
        
    }
    
    if ( [@"ImageText" isEqualToString:identify] || [@"Formats" isEqualToString:identify] || [@"CreateTime" isEqualToString:identify] || [@"LastTime" isEqualToString:identify] || [@"Size" isEqualToString:identify]) {
        if ([cell isKindOfClass:[IMBCustomHeaderCell class]]) {
            IMBCustomHeaderCell *customHeaderCell = (IMBCustomHeaderCell *)cell;
            if (customHeaderCell.ascending) {
                customHeaderCell.ascending = NO;
            }else {
                customHeaderCell.ascending = YES;
            }
            [self sort:customHeaderCell.ascending key:identify dataSource:disPalyAry];
        }
    }
    [_itemTableView reloadData];
}

- (void)sort:(BOOL)isAscending key:(NSString *)key dataSource:(NSMutableArray *)array {
    if ([key isEqualToString:@"ImageText"]) {
        key = @"fileName";
    } else if ([key isEqualToString:@"Formats"]) {
        key = @"extension";
    }else if ([key isEqualToString:@"Size"]) {
        key = @"fileSize";
    }else if ([key isEqualToString:@"CreateTime"]) {
        key = @"createdDateString";
    }else if ([key isEqualToString:@"LastTime"]) {
        key = @"lastModifiedDateString";
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:isAscending];//其中，price为数组中的对象的属性，这个针对数组中存放对象比较更简洁方便
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    [array sortUsingDescriptors:sortDescriptors];
    [_itemTableView reloadData];
    
    [sortDescriptor release];
    [sortDescriptors release];
}

- (void)setAllselectState:(CheckStateEnum)checkState {
    NSArray *disPalyAry = nil;
    if (_isSearch) {
        disPalyAry = _researchdataSourceArray;
    }else {
        disPalyAry = _dataSourceArray;
    }
    
    if (_categoryNodeEunm == Category_Media||_categoryNodeEunm == Category_Video) {
        for (int i=0;i<[disPalyAry count]; i++) {
            IMBTrack *item= [disPalyAry objectAtIndex:i];
            [item setCheckState:checkState];
        }
    }else if (_categoryNodeEunm == Category_iBooks) {
        for (int i=0;i<[disPalyAry count]; i++) {
            IMBBookEntity *item= [disPalyAry objectAtIndex:i];
            [item setCheckState:checkState];
        }
    }else if (_categoryNodeEunm == Category_Applications) {
        for (int i=0;i<[disPalyAry count]; i++) {
            IMBAppEntity *item= [disPalyAry objectAtIndex:i];
            [item setCheckState:checkState];
        }
    }else if (_categoryNodeEunm == Category_System) {
        for (int i=0;i<[disPalyAry count]; i++) {
            SimpleNode *simpleNode = [disPalyAry objectAtIndex:i];
            [simpleNode setCheckState:checkState];
        }
        
    }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
        for (int i=0;i<[disPalyAry count]; i++) {
            IMBPhotoEntity *item= [disPalyAry objectAtIndex:i];
            [item setCheckState:checkState];
        }
    }
    [_itemTableView reloadData];
}

- (void)doSwitchView:(id)sender {
    HoverButton *segBtn = (HoverButton *)sender;
    if (segBtn.switchBtnState == 1) {
        if (_dataSourceArray.count > 0) {
            [_contentBox setContentView:_tableViewBgView];
        }else {
            [_contentBox setContentView:_nodataView];
        }
        NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
        for (int i=0;i<[_dataSourceArray count]; i++) {
            
            if (_categoryNodeEunm == Category_Media || _categoryNodeEunm == Category_Video) {
                
                IMBTrack *item= [_dataSourceArray objectAtIndex:i];
                if (item.checkState == Check) {
                    [set addIndex:i];
                }
            }else if (_categoryNodeEunm == Category_iBooks) {
                IMBBookEntity *item= [_dataSourceArray objectAtIndex:i];
                if (item.checkState == Check) {
                    [set addIndex:i];
                }
            }else if (_categoryNodeEunm == Category_Applications) {
                IMBAppEntity *item= [_dataSourceArray objectAtIndex:i];
                if (item.checkState == Check) {
                    [set addIndex:i];
                }
            }else if (_categoryNodeEunm == Category_System) {
                SimpleNode *simpleNode = [_dataSourceArray objectAtIndex:i];
                if (simpleNode.checkState == Check) {
                    [set addIndex:i];
                }
            }else if (_categoryNodeEunm == Category_CameraRoll||_categoryNodeEunm == Category_PhotoLibrary||_categoryNodeEunm == Category_PhotoStream) {
                IMBPhotoEntity *item= [_dataSourceArray objectAtIndex:i];
                if (item.checkState == Check) {
                    [set addIndex:i];
                }
            }
        }
        _currentSelectView = 0;
        [_itemTableView selectRowIndexes:set byExtendingSelection:YES];
        [_itemTableView reloadData];
        
    }else if (segBtn.switchBtnState == 0) {
        _currentSelectView = 1;
        if (_dataSourceArray.count > 0) {
            [_contentBox setContentView:_gridBgView];
            [_gridView reloadData];
        }else {
            [_contentBox setContentView:_nodataView];
        }

    }
    [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:_currentSelectView];
}

- (NSIndexSet *)selectedItems {
    NSIndexSet *selectedItems = nil;
    if (_currentSelectView == 0) {
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
        selectedItems = sets;
    }else {
        selectedItems = _gridView.selectedIndexes;
    }
    return selectedItems;
}

#pragma mark - Notification
- (void)photoLoadFinished:(NSNotification *)object {
    dispatch_async(dispatch_get_main_queue(), ^{
        IMBiPod *ipod = (IMBiPod *)object.object;
        IMBInformationManager *inforManager = [IMBInformationManager shareInstance];
        _information = [inforManager.informationDic objectForKey:_iPod.uniqueKey];
       
        if ([ipod.uniqueKey isEqualToString: _iPod.uniqueKey]) {
            if (_dataSourceArray) {
                [_dataSourceArray release];
                _dataSourceArray = nil;
            }
            if (_categoryNodeEunm == Category_PhotoStream) {
                _dataSourceArray = [_information.photostreamArray retain];
            }else if (_categoryNodeEunm == Category_PhotoLibrary) {
                _dataSourceArray = [_information.photolibraryArray retain];
            }else if (_categoryNodeEunm == Category_CameraRoll) {
                _dataSourceArray = [_information.allPhotoArray retain];
            }else{
                return ;
            }
            if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
                [_contentBox setContentView:_gridBgView];
            } else {
                [_contentBox setContentView:_nodataView];
            }
            [_loadAnimationView endAnimation];
            [_gridView reloadData];
            [_itemTableView reloadData];
        }
    });
}

- (void)appLoadFinished:(NSNotification *)object {
    IMBInformationManager *inforManager = [IMBInformationManager shareInstance];
    _information = [inforManager.informationDic objectForKey:_iPod.uniqueKey];
    IMBiPod *ipod = (IMBiPod *)object.object;
    if (_categoryNodeEunm == Category_Applications ) {
        if ([ipod.uniqueKey isEqualToString: _iPod.uniqueKey]) {
            if (_dataSourceArray) {
                [_dataSourceArray release];
                _dataSourceArray = nil;
            }
            _dataSourceArray = [_information.appArray retain];
            if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
                [_contentBox setContentView:_gridBgView];
            } else {
                [_contentBox setContentView:_nodataView];
            }
        }
        
        [_gridView reloadData];
        [_itemTableView reloadData];
        [_loadAnimationView endAnimation];
    }
}

- (void)bookLoadFinished:(NSNotification *)object {
    dispatch_async(dispatch_get_main_queue(), ^{
        IMBInformationManager *inforManager = [IMBInformationManager shareInstance];
        _information = [inforManager.informationDic objectForKey:_iPod.uniqueKey];
        IMBiPod *ipod = (IMBiPod *)object.object;
        if (_categoryNodeEunm == Category_iBooks) {
            if ([ipod.uniqueKey isEqualToString: _iPod.uniqueKey]) {
                if (_dataSourceArray) {
                    [_dataSourceArray release];
                    _dataSourceArray = nil;
                }
                _dataSourceArray = [_information.allBooksArray retain];
                if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
                    [_contentBox setContentView:_gridBgView];
                } else {
                    [_contentBox setContentView:_nodataView];
                }
            }
            [_gridView reloadData];
            [_itemTableView reloadData];
            [_loadAnimationView endAnimation];
        }
    });
}

- (void)mediaLoadFinished:(NSNotification *)object {
    IMBInformationManager *inforManager = [IMBInformationManager shareInstance];
    _information = [inforManager.informationDic objectForKey:_iPod.uniqueKey];
    IMBiPod *ipod = (IMBiPod *)object.object;
    if (_categoryNodeEunm == Category_Media) {
        if ([ipod.uniqueKey isEqualToString: _iPod.uniqueKey]) {
            if (_dataSourceArray) {
                [_dataSourceArray release];
                _dataSourceArray = nil;
            }
            _dataSourceArray = [_information.mediaArray retain];
            if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
                [_contentBox setContentView:_gridBgView];
            } else {
                [_contentBox setContentView:_nodataView];
            }
        }
        [_gridView reloadData];
        [_itemTableView reloadData];
        [_loadAnimationView endAnimation];
    }
}

- (void)videoLoadFinished:(NSNotification *)object {
    IMBInformationManager *inforManager = [IMBInformationManager shareInstance];
    _information = [inforManager.informationDic objectForKey:_iPod.uniqueKey];
    IMBiPod *ipod = (IMBiPod *)object.object;
    if (_categoryNodeEunm == Category_Video) {
        if ([ipod.uniqueKey isEqualToString: _iPod.uniqueKey]) {
            if (_dataSourceArray) {
                [_dataSourceArray release];
                _dataSourceArray = nil;
            }
            _dataSourceArray = [_information.videoArray retain];
            if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
                [_contentBox setContentView:_gridBgView];
            } else {
                [_contentBox setContentView:_nodataView];
            }
        }
        [_gridView reloadData];
        [_itemTableView reloadData];
        [_loadAnimationView endAnimation];
    }
}

#pragma mark - operation action
- (void)showDetailView:(id)sender {
    if (_curEntity) {
        _isShow = YES;
        [self showFileDetailViewWithEntity:_curEntity];
    }
}

- (void)reload:(id)sender {
    [_toolBarButtonView toolBarButtonIsEnabled:NO];
    [_contentBox setContentView:_loadingView];
    [_loadAnimationView startAnimation];
    NSOperationQueue *opQueue = [[[NSOperationQueue alloc] init] autorelease];
    switch (_categoryNodeEunm) {
        case Category_Media:
        {
            [opQueue addOperationWithBlock:^{
                [_dataSourceArray removeAllObjects];
                [_information refreshMedia];
                NSArray *audioArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:(int)Audio],nil];
                NSArray *trackArray = [[NSMutableArray alloc] initWithArray:[_information getTrackArrayByMediaTypes:audioArray]];
                
                [_dataSourceArray addObjectsFromArray:trackArray];
                [trackArray release];
                trackArray = nil;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [self reloadEnd];
                });
            }];
        }
            break;
        case Category_Video:
        {
            [opQueue addOperationWithBlock:^{
            
                [_dataSourceArray removeAllObjects];
                [_information refreshMedia];
                NSArray *videoArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:(int)Video],
                                       [NSNumber numberWithInt:(int)TVShow],
                                       [NSNumber numberWithInt:(int)MusicVideo],
                                       [NSNumber numberWithInt:(int)HomeVideo],
                                       nil];
                NSArray *trackArray = [[NSMutableArray alloc] initWithArray:[_information getTrackArrayByMediaTypes:videoArray]];
                [_dataSourceArray addObjectsFromArray:trackArray];
                [trackArray release];
                trackArray = nil;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self reloadEnd];
                });
             
            }];
        }
            break;
        case Category_iBooks:
        {
            [opQueue addOperationWithBlock:^{
                [_dataSourceArray removeAllObjects];
                [_information loadiBook];
                NSArray *ibooks = [[_information allBooksArray] retain];
                [IMBCommonTool loadbookCover:ibooks ipod:_iPod];
                [_dataSourceArray addObjectsFromArray:ibooks];
                
                [ibooks release];
                ibooks = nil;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self reloadEnd];
                });
                
            }];
        }
            break;
        case Category_Applications:
        {
            [opQueue addOperationWithBlock:^{
                [_dataSourceArray removeAllObjects];
                IMBApplicationManager *appManager = [[_information applicationManager] retain];
                [appManager loadAppArray];
                NSArray *appArray = [appManager appEntityArray];
                [_dataSourceArray addObjectsFromArray:appArray];
                
                [appArray release];
                appArray = nil;
                
                [appManager release];
                appManager = nil;
                
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self reloadEnd];
                });
                
            }];
        }
            break;
        case Category_PhotoStream:
        {
            [opQueue addOperationWithBlock:^{
                [_dataSourceArray removeAllObjects];
                [_information refreshPhotoStream];
                NSArray *photoArr = [_information photostreamArray];
                if (photoArr.count) {
                    [_dataSourceArray addObjectsFromArray:photoArr];
                }
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self reloadEnd];
                });
            }];
        }
            break;
        case Category_CameraRoll:
        {
            [opQueue addOperationWithBlock:^{
                [_dataSourceArray removeAllObjects];
                [_information refreshCameraRoll];
                [_information refreshVideoAlbum];
                NSMutableArray *cameraRoll = [[NSMutableArray alloc] init];
                [cameraRoll addObjectsFromArray:[_information camerarollArray] ? [_information camerarollArray] : [NSArray array]];
                [cameraRoll addObjectsFromArray:[_information photovideoArray] ? [_information photovideoArray] : [NSArray array]];
                [cameraRoll addObjectsFromArray:[_information photoSelfiesArray] ? [_information photoSelfiesArray] : [NSArray array]];
                [cameraRoll addObjectsFromArray:[_information screenshotArray] ? [_information screenshotArray] : [NSArray array]];
                [cameraRoll addObjectsFromArray:[_information slowMoveArray] ? [_information slowMoveArray] : [NSArray array]];
                [cameraRoll addObjectsFromArray:[_information timelapseArray] ? [_information timelapseArray] : [NSArray array]];
                [cameraRoll addObjectsFromArray:[_information panoramasArray] ? [_information panoramasArray] : [NSArray array]];
                if (cameraRoll.count) {
                    [_dataSourceArray addObjectsFromArray:cameraRoll];
                }
                [cameraRoll release];
                cameraRoll = nil;
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self reloadEnd];
                });
            }];
        }
          break;
        case Category_PhotoLibrary:
        {
            [opQueue addOperationWithBlock:^{
                [_dataSourceArray removeAllObjects];
                [_information refreshPhotoLibrary];
                NSArray *photoArr = [_information photolibraryArray];
                if (photoArr.count) {
                    [_dataSourceArray addObjectsFromArray:photoArr];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self reloadEnd];
                });
            }];
        }
            break;
        case Category_System:
        {
            [opQueue addOperationWithBlock:^{
                [_dataSourceArray removeAllObjects];
                NSArray *array = [_systemManager recursiveDirectoryContentsDics:_currentDevicePath];
                if (array.count) {
                    [_dataSourceArray addObjectsFromArray:array];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self reloadEnd];
                });
            }];
        }
            break;
        default:
            break;
    }
}

- (void)reloadEnd {
    
    [_loadAnimationView endAnimation];
    [_gridView reloadData];
    [_itemTableView reloadData];
    [self changeToolButtonsIsSelectedIntems:NO];
    if (_currentSelectView == 0) {
        if (_dataSourceArray != nil && _dataSourceArray.count > 0) {
            [_contentBox setContentView:_tableViewBgView];
        } else {
            [_contentBox setContentView:_nodataView];
        }
        
    } else {
        if (_dataSourceArray != nil && _dataSourceArray.count > 0) {
            [_contentBox setContentView:_gridBgView];
        } else {
            [_contentBox setContentView:_nodataView];
        }
    }
    [_toolBarButtonView toolBarButtonIsEnabled:YES];
    
}

#pragma mark - reload toolButton
- (void)changeToolButtonsIsSelectedIntems:(BOOL)isSelected {
    if (isSelected) {
        if (_toolBarArr != nil) {
            [_toolBarArr release];
            _toolBarArr = nil;
        }
        switch (_categoryNodeEunm) {
            case Category_Media:
            {
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(AddFunctionType),@(DeleteFunctionType),@(ToMacFunctionType),@(ToDeviceFunctionType),@(DeviceDatailFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
            }
                break;
            case Category_Video:
            {
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(AddFunctionType),@(DeleteFunctionType),@(ToMacFunctionType),@(ToDeviceFunctionType),@(DeviceDatailFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
            }
                break;
            case Category_iBooks:
            {
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(AddFunctionType),@(DeleteFunctionType),@(ToMacFunctionType),@(ToDeviceFunctionType),@(DeviceDatailFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
            }
                break;
            case Category_Applications:
            {
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(AddFunctionType),@(DeleteFunctionType),@(ToMacFunctionType),@(ToDeviceFunctionType),@(DeviceDatailFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
            }
                break;
            case Category_PhotoStream:
            case Category_CameraRoll:
            {
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(ToMacFunctionType),@(ToDeviceFunctionType),@(DeviceDatailFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
            }
                break;
            case Category_System:
            {
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(AddFunctionType),@(DeleteFunctionType),@(ToMacFunctionType),@(ToDeviceFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
            }
                break;
            case Category_PhotoLibrary:
            {
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(AddFunctionType),@(DeleteFunctionType),@(ToMacFunctionType),@(ToDeviceFunctionType),@(DeviceDatailFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
            }
                break;
                
            default:
                break;
        }
    }else {
        switch (_categoryNodeEunm) {
            case Category_PhotoStream:
            case Category_CameraRoll:
            {
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(DeviceDatailFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
            }
                break;
            default:
                _toolBarArr = [[NSArray alloc] initWithObjects:@(ReloadFunctionType),@(AddFunctionType),@(SortFunctionType),@(SwitchFunctionType),nil];
                break;
        }
    }
    [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:_currentSelectView];
}
/**
 *  到电脑
 */
- (void)toMac:(id)sender {
    [self toMacSettingsWithInformation:_information];
}

- (void)toMacSettingsWithInformation:(IMBInformation *)information {
    
    NSIndexSet *selectedSet = [self selectedItems];
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else {
        displayArr = _dataSourceArray;
    }
    
    if (!selectedSet || selectedSet.count == 0) {
        [IMBCommonTool showSingleBtnAlertInMainWindow:_iPod.uniqueKey btnTitle:CustomLocalizedString(@"Button_Ok", nil) msgText:CustomLocalizedString(@"AlertView_Select_Items", nil) btnClickedBlock:nil];
    }else {
        if (_categoryNodeEunm == Category_Applications) {
            if ([_iPod.deviceInfo.getDeviceFloatVersionNumber isVersionMajorEqual:@"8.3"]) {
                [IMBCommonTool showSingleBtnAlertInMainWindow:_iPod.uniqueKey btnTitle:CustomLocalizedString(@"Button_Ok", nil) msgText:CustomLocalizedString(@"AlertView_RunInHigherVersion", nil) btnClickedBlock:nil];
                return;
            }
        }
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setCanChooseFiles:NO];
        [openPanel setCanChooseDirectories:YES];
        [openPanel setCanCreateDirectories:YES];
        [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
            if (NSModalResponseOK == result) {
                    NSString *path = [[openPanel URL] path];
                    NSString *filePath = [TempHelper createCategoryPath:[TempHelper createExportPath:path] withString:[IMBCommonEnum categoryNodesEnumToName:_categoryNodeEunm]];
                    NSMutableArray *exportArray = [NSMutableArray array];
                    switch (_categoryNodeEunm) {
                        case Category_CameraRoll:
                        case Category_PhotoStream:
                        case Category_PhotoLibrary:
                        {
                            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                IMBPhotoEntity *photo = [[displayArr objectAtIndex:idx] retain];
                                [exportArray addObject:photo];
                                [photo release];
                                photo = nil;
                            }];
                            
                            IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
                     
                            [tranferView deviceAddDataSoure:exportArray WithIsDown:YES WithiPod:_iPod withCategoryNodesEnum:_categoryNodeEunm isExportPath:filePath withSystemPath:nil];
                        }
                            break;
                        case Category_iBooks:
                        {
                            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                IMBBookEntity *book = [[displayArr objectAtIndex:idx] retain];
                                [exportArray addObject:book];
                                [book release];
                            }];
                            IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
                            
                            [tranferView deviceAddDataSoure:exportArray WithIsDown:YES WithiPod:_iPod withCategoryNodesEnum:_categoryNodeEunm isExportPath:filePath withSystemPath:nil];
                            
                        }
                            break;
                        case Category_Media:
                        {
                            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                IMBTrack *track = [[displayArr objectAtIndex:idx] retain];
                                [exportArray addObject:track];
                                [track release];
                            }];
                            
                            IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
                            
                            [tranferView deviceAddDataSoure:exportArray WithIsDown:YES WithiPod:_iPod withCategoryNodesEnum:_categoryNodeEunm isExportPath:filePath withSystemPath:nil];
                            
                        }
                            break;
                        case Category_Applications:
                        {
                            
                            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                IMBAppEntity *app = [[displayArr objectAtIndex:idx] retain];
                                [exportArray addObject:app];
                                [app release];
                            }];
                            
                            _baseTransfer = [[IMBAppExport alloc] initWithIPodkey:information.ipod.uniqueKey exportTracks:exportArray exportFolder:filePath withDelegate:self];
                            
                        }
                            break;
                        case Category_Video:
                        {
                            
                            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                IMBTrack *track = [[displayArr objectAtIndex:idx] retain];
                                [exportArray addObject:track];
                                [track release];
                            }];
                            IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
                            
                            [tranferView deviceAddDataSoure:exportArray WithIsDown:YES WithiPod:_iPod withCategoryNodesEnum:_categoryNodeEunm isExportPath:filePath withSystemPath:nil];
                            
                        }
                            break;
                        case Category_System:
                        {
                            [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                SimpleNode *track = [[displayArr objectAtIndex:idx] retain];
                                [exportArray addObject:track];
                                [track release];
                            }];
                            IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
                            
                            [tranferView deviceAddDataSoure:exportArray WithIsDown:YES WithiPod:_iPod withCategoryNodesEnum:_categoryNodeEunm isExportPath:filePath withSystemPath:_currentDevicePath];
//                                    _baseTransfer = [[IMBFileSystemExport alloc] initWithIPodkey:_ipodKey exportTracks:_selectedItems exportFolder:_exportFolder withDelegate:self];
                        }
                            break;
                        default:
                            break;
                            
                    }
                    
                    
//                    [_baseTransfer startTransfer];
            }
        }];
    }
}

- (void)downloadToMac:(id)sender {
    
    _openPanel = [NSOpenPanel openPanel];
    [_openPanel setAllowsMultipleSelection:YES];
    [_openPanel setCanChooseFiles:YES];
    [_openPanel setCanChooseDirectories:YES];
    [_openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode== NSFileHandlingPanelOKButton) {
            NSArray *urlArr = [_openPanel URLs];
            NSMutableArray *paths = [NSMutableArray array];
            for (NSURL *url in urlArr) {
                [paths addObject:url.path];
            }
            [self performSelector:@selector(downloadWithPath:) withObject:paths afterDelay:0.3];
        }
    }];
}

- (void)downloadWithPath:(NSMutableArray *)paths {
    
    NSString *pathStr = [paths objectAtIndex:0];
    NSIndexSet *selectedSet = [self selectedItems];
    NSMutableArray *preparedArray = [NSMutableArray array];
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else {
        displayArr = _dataSourceArray;
    }
    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [preparedArray addObject:[displayArr objectAtIndex:idx]];
    }];
    
    IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
    [tranferView deviceAddDataSoure:preparedArray WithIsDown:YES WithiPod:_iPod withCategoryNodesEnum:_categoryNodeEunm isExportPath:pathStr];
}
/**
 *  到设备
 */
- (void)toDevice:(id)sender {
    [self toDeviceSettingsWithInformation:_information];
}

- (void)toDeviceSettingsWithInformation:(IMBInformation *)information {
    //当链接三个或者以上设备的时候，需要让用户选择到底传输到哪一个设备，这里现在暂时还没加
    IMBDeviceConnection *conn = [IMBDeviceConnection singleton];
    IMBiPod *desIpod = nil;
    for (IMBiPod *ipod in conn.alliPods) {
        if (![ipod.uniqueKey isEqualToString:information.ipod.uniqueKey]) {
            desIpod = ipod;
            break;
        }
    }
    if (!desIpod) {
        [self showAlertWithoutMultiDevices];
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *selectAry = [NSMutableArray array];
        NSIndexSet *selectedSet = [self selectedItems];
        IMBCategoryInfoModel *model = [[IMBCategoryInfoModel alloc] init];
        if (_categoryNodeEunm == Category_Media) {
            model.categoryNodes = Category_Music;
        }else if (_categoryNodeEunm == Category_Video) {
            model.categoryNodes = Category_Movies;
        }else {
            model.categoryNodes = _categoryNodeEunm;
        }
        
        NSArray *displayArr = nil;
        if (_isSearch) {
            displayArr = _researchdataSourceArray;
        }else {
            displayArr = _dataSourceArray;
        }
        switch (_categoryNodeEunm) {
            case Category_PhotoStream:
            case Category_PhotoLibrary:
            case Category_CameraRoll:
            {
                if (desIpod.photoLoadFinished) {
                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        IMBPhotoEntity *pe = [displayArr objectAtIndex:idx];
                        [selectAry addObject:pe];
                    }];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_current_queue(), ^{
                        _baseTransfer = [[IMBBetweenDeviceHandler alloc] initWithSelectedArray:selectAry categoryModel:model srcIpodKey:information.ipod.uniqueKey desIpodKey:desIpod.uniqueKey withPlaylistArray:[NSArray array] albumEntity:nil Delegate:self];
                        [_baseTransfer startTransfer];
                    });
                    
                }else {
                    [self showAlertLoadingAnotherDeviceData];
                }
                
            }
                break;
            case Category_iBooks:
            {
                if (desIpod.bookLoadFinished) {
                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        IMBBookEntity *be = [displayArr objectAtIndex:idx];
                        //                        be.path = [NSString stringWithFormat:@"%@.pdf",be.bookName];
                        [selectAry addObject:be];
                    }];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_current_queue(), ^{
                        _baseTransfer = [[IMBBetweenDeviceHandler alloc] initWithSelectedArray:selectAry categoryModel:model srcIpodKey:information.ipod.uniqueKey desIpodKey:desIpod.uniqueKey withPlaylistArray:[NSArray array] albumEntity:nil Delegate:self];
                        [_baseTransfer startTransfer];
                        //                        _baseTransfer = [[IMBBookToDevice alloc] initWithSrcIpod:information.ipod desIpod:desIpod bookList:selectAry Delegate:self];
                        //                        if ([(IMBBookToDevice *)_baseTransfer prepareData]) {
                        //                            [_baseTransfer startTransfer];
                        //                        }
                    });
                    
                }else {
                    [self showAlertLoadingAnotherDeviceData];
                }
                
            }
                break;
            case Category_Applications:
            {
                if (desIpod.appsLoadFinished) {
                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        //TODO
                        IMBAppEntity *be = [displayArr objectAtIndex:idx];
                        [selectAry addObject:be];
                    }];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_current_queue(), ^{
                        _baseTransfer = [[IMBBetweenDeviceHandler alloc] initWithSelectedArray:selectAry categoryModel:model srcIpodKey:information.ipod.uniqueKey desIpodKey:desIpod.uniqueKey withPlaylistArray:[NSArray array] albumEntity:nil Delegate:self];
                        [_baseTransfer startTransfer];
                    });
                    
                }else {
                    [self showAlertLoadingAnotherDeviceData];
                }
                
            }
                break;
            case Category_Media:
            {
                if (desIpod.mediaLoadFinished) {
                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        //TODO
                        IMBTrack *track = [displayArr objectAtIndex:idx];
                        [selectAry addObject:track];
                    }];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_current_queue(), ^{
                        _baseTransfer = [[IMBBetweenDeviceHandler alloc] initWithSelectedArray:selectAry categoryModel:model srcIpodKey:information.ipod.uniqueKey desIpodKey:desIpod.uniqueKey withPlaylistArray:[NSArray array] albumEntity:nil Delegate:self];
                        [_baseTransfer startTransfer];
                    });
                    
                }else {
                    [self showAlertLoadingAnotherDeviceData];
                }
                
            }
                break;
            case Category_Video:
            {
                if (desIpod.videoLoadFinished) {
                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                        //TODO
                        IMBTrack *track = [displayArr objectAtIndex:idx];
                        [selectAry addObject:track];
                    }];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_current_queue(), ^{
                        _baseTransfer = [[IMBBetweenDeviceHandler alloc] initWithSelectedArray:selectAry categoryModel:model srcIpodKey:information.ipod.uniqueKey desIpodKey:desIpod.uniqueKey withPlaylistArray:[NSArray array] albumEntity:nil Delegate:self];
                        [_baseTransfer startTransfer];
                    });
                    
                }else {
                    [self showAlertLoadingAnotherDeviceData];
                }
                
            }
                break;
            default:
                break;
        }
        
        [model release];
        model = nil;
    });
    
    
}
/**
 *  显示提示连接多设备的下拉框
 */
- (void)showAlertWithoutMultiDevices {
    dispatch_async(dispatch_get_main_queue(), ^{
       [IMBCommonTool showSingleBtnAlertInMainWindow:_iPod.uniqueKey btnTitle:CustomLocalizedString(@"Button_Ok", nil)  msgText:CustomLocalizedString(@"AlertView_RemindTo_Connect_Multi_Devices", nil) btnClickedBlock:nil];
    });
}
- (void)showAlertLoadingAnotherDeviceData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [IMBCommonTool showSingleBtnAlertInMainWindow:_iPod.uniqueKey btnTitle:CustomLocalizedString(@"Button_Ok", nil)  msgText:CustomLocalizedString(@"AlertView_RemindTo_Loading_Data", nil) btnClickedBlock:nil];
    });
}
/**
 *  添加
 */
- (void)addItems:(id)sender {
    [self addToDeviceSettingsWithInformation:_information];
}

- (void)addToDeviceSettingsWithInformation:(IMBInformation *)information {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowsMultipleSelection:YES];
    
    [openPanel setAllowedFileTypes:[IMBCommonTool getOpenPanelSuffxiWithCategory:_categoryNodeEunm]];
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (NSModalResponseOK == result) {
//            [_contentBox setContentView:_loadAnimationView];
//            [_loadAnimationView startAnimation];
            
            NSMutableArray *paths = [NSMutableArray array];
            for (NSURL *urlPath in openPanel.URLs) {
                [paths addObject:urlPath.path];
            }
            IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
            [tranferView deviceAddDataSoure:paths WithIsDown:NO WithiPod:_iPod withCategoryNodesEnum:_categoryNodeEunm isExportPath:nil withSystemPath:_currentDevicePath];
            [paths release];
            paths = nil;
        }
    }];
}

/**
 *  删除
 */
- (void)deleteItems:(id)sender {
    [self deleteSettings];
}

- (void)deleteSettings {
    NSIndexSet *selectedSet = [self selectedItems];
    NSMutableArray *preparedArray = [NSMutableArray array];
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else {
        displayArr = _dataSourceArray;
    }
    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [preparedArray addObject:[displayArr objectAtIndex:idx]];
    }];
    if (!preparedArray || preparedArray.count == 0) {
        [IMBCommonTool showSingleBtnAlertInMainWindow:_iPod.uniqueKey btnTitle:CustomLocalizedString(@"Button_Ok", nil) msgText:CustomLocalizedString(@"AlertView_Select_Items", nil) btnClickedBlock:nil];
    }else {

        [IMBCommonTool showTwoBtnsAlertInMainWindow:_iPod.uniqueKey firstBtnTitle:CustomLocalizedString(@"Button_Cancel", nil) secondBtnTitle:CustomLocalizedString(@"Button_Ok", nil)  msgText:CustomLocalizedString(@"AlertView_AskSureToDelete", nil) firstBtnClickedBlock:nil secondBtnClickedBlock:^{
            IMBFLog(@"clicked OK button");
            
                if (_categoryNodeEunm == Category_System) {
    
//                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [_loadAnimationView startAnimation];
                            [_contentBox setContentView:_loadingView];
//                        });

                    AFCMediaDirectory *afcMedia = [_iPod.deviceHandle newAFCMediaDirectory];
                    [_systemManager setCurItems:0];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        int deleteTotalItems = [_systemManager caculateTotalFileCount:preparedArray afcMedia:afcMedia];
                        [_systemManager removeFiles:preparedArray afcMediaDir:afcMedia];
                        [afcMedia close];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_loadAnimationView startAnimation];
                        [_contentBox setContentView:_gridBgView];
                        [_gridView reloadData];
                    });
    
                    });
                }else {
                    NSOperationQueue *opQueue = [[[NSOperationQueue alloc] init] autorelease];
                    [opQueue addOperationWithBlock:^{
                            NSMutableArray *delArray = [[NSMutableArray alloc] init];
                            switch (_categoryNodeEunm) {
                                case Category_CameraRoll:
                                    return;
                                    break;
                                case Category_PhotoLibrary:
                                {
                                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                        IMBPhotoEntity *photo = [[displayArr objectAtIndex:idx] retain];
                                        IMBTrack *track = [[IMBTrack alloc] init];
                                        track.photoZpk = photo.photoZpk;
                                        [track setMediaType:Photo];
                                        [delArray addObject:track];
                                        [track release];
                                        [photo release];
                                    }];
                                }
                                    break;
                                case Category_iBooks:
                                {
                                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                        IMBBookEntity *bookEntity = [[displayArr objectAtIndex:idx] retain];
                                        IMBTrack *newTrack = [[IMBTrack alloc] init];
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
                                            [newTrack setFileSize:(uint)[[_iPod fileSystem] getFolderSize:[[[_iPod fileSystem] driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"Books/%@",[path lastPathComponent]]]]];
                                        }
                                        else{
                                            type = PDFBooks;
                                            [newTrack setFileSize:(uint)[[_iPod fileSystem] getFileLength:[[[_iPod fileSystem] driveLetter] stringByAppendingPathComponent:[NSString stringWithFormat:@"Books/%@",[path lastPathComponent]]]]];
                                        }
                                        [newTrack setMediaType:type];
                                        newTrack.dbID = dbid;
                                        newTrack.uuid = publisherUniqueID;
                                        newTrack.mediaType = type;
                                        newTrack.packageHash = packageHash;
                                        [delArray addObject:newTrack];
                                        [newTrack release];
                                        newTrack = nil;
                                    }];
                                }
                                    break;
                                case Category_Applications:
                                {
                                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                        IMBAppEntity *app = [[displayArr objectAtIndex:idx] retain];
                                        [delArray addObject:app];
                                        [app release];
                                        app = nil;
                                    }];
                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                        [[NSNotificationCenter defaultCenter] postNotificationName:IMBDevicePageStartLoadingAnimNoti object:_iPod.uniqueKey];
                                    });
                                    IMBDeleteApps *procedure = [[IMBDeleteApps alloc] initWithIPod:_iPod deleteArray:delArray];
                                    [procedure startDelete];
                                    [procedure release];
                                    
                                    //                            [self setCompletionWithSuccessCount:(int)delArray.count totalCount:(int)delArray.count title:@"Delete Success"];
                                    
                                    return;
                                }
                                    break;
                                case Category_Media:
                                {
                                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                        IMBTrack *track = [[displayArr objectAtIndex:idx] retain];
                                        [delArray addObject:track];
                                        [track release];
                                        track = nil;
                                    }];
                                }
                                    break;
                                case Category_Video:
                                {
                                    [selectedSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                                        IMBTrack *track = [[displayArr objectAtIndex:idx] retain];
                                        [delArray addObject:track];
                                        [track release];
                                        track = nil;
                                    }];
                                }
                                    break;
                                case Category_System:
                                    break;
                                default:
                                    break;
                            }
                            
                            dispatch_sync(dispatch_get_main_queue(), ^{
                                [_contentBox setContentView:_loadingView];
                                [_loadAnimationView startAnimation];
                            });
                            IMBDeleteTrack *deleteTrack = [[IMBDeleteTrack alloc] initWithIPod:_iPod deleteArray:delArray Category:_categoryNodeEunm];
                            [deleteTrack setDelegate:self];
                            [deleteTrack startDelete];
                            [deleteTrack release];
                            [delArray release];
                            delArray = nil;
                            
                        
                    }];

                }
            }];
    }
}

#pragma mark -- 删除代理方法
- (void)setDeleteProgress:(float)progress withWord:(NSString *)msgStr {
    
}

- (void)setDeleteComplete:(int)success totalCount:(int)totalCount {
    [self setCompletionWithSuccessCount:success totalCount:totalCount title:@"Delete Completed"];
}

- (void)setCompletionWithSuccessCount:(int)successCount totalCount:(int)totalCount title:(NSString *)title {
    if (![[IMBDeviceConnection singleton] getiPodByKey:_iPod.uniqueKey]) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [IMBCommonTool showSingleBtnAlertInMainWindow:_iPod.uniqueKey btnTitle:CustomLocalizedString(@"Button_Ok", nil) msgText:[NSString stringWithFormat:CustomLocalizedString(@"AlertView_Transfer_Success_Format", nil),successCount,totalCount] btnClickedBlock:^{
                [self reload:nil];
            }];
        });
        
        
    });
}

//medie 和video图片获取
- (NSData *)createThumbImage:(IMBTrack *)track {
    NSString *filePath = nil;
    if (track.artwork.count>0) {
        id entityObj = [track.artwork objectAtIndex:0];
        if ([entityObj isKindOfClass:[IMBArtworkEntity class]]) {
            IMBArtworkEntity *entity = (IMBArtworkEntity*)entityObj;
            filePath = entity.filePath;
            if (filePath.length == 0) {
                filePath = entity.localFilepath;
            }
        }
    }else{
        filePath =track.artworkPath;
    }
    NSData *data = [self readFileData:filePath];;
    if (data) {
        NSImage *sourceImage = [[NSImage alloc] initWithData:data];
        NSData *imageData = [IMBHelper createThumbnail:sourceImage withWidth:80 withHeight:60];
        [sourceImage release];
        
        return imageData;
    }else {
        return nil;
    }
}

//photo 图片获取
- (NSData *)createImageToTableView:(IMBPhotoEntity *)entity {
    NSString *filePath = nil;
    if (entity.photoKind == 0) {
        if ([_iPod.deviceHandle.productVersion isVersionMajorEqual:@"7"]) {
            if ([_iPod.fileSystem fileExistsAtPath:entity.thumbPath]) {
                filePath = entity.thumbPath;
            }else {
                filePath = entity.allPath;
            }
        }else {
            if ([_iPod.fileSystem fileExistsAtPath:entity.allPath]) {
                filePath = entity.allPath;
            }
        }
    }else if (entity.photoKind == 1) {
        if ([_iPod.deviceHandle.productVersion isVersionMajorEqual:@"7"]) {
            if ([_iPod.fileSystem fileExistsAtPath:entity.thumbPath]) {
                filePath = entity.thumbPath;
            }else {
                filePath = entity.videoPath;
            }
        }else {
            if ([_iPod.fileSystem fileExistsAtPath:entity.videoPath]) {
                filePath = entity.videoPath;
            }
        }
    }
    
    NSData *data = [self readFileData:filePath];
    NSImage *sourceImage = [[NSImage alloc] initWithData:data];
    
    NSData *imageData = [IMBHelper createThumbnail:sourceImage withWidth:80 withHeight:60];
    [sourceImage release];
    
    return imageData;
}

- (int)cacuCount:(NSString *)nodePath{
    AFCMediaDirectory *afcMedia = [_iPod.deviceHandle newAFCMediaDirectory];
    NSArray *array = [afcMedia directoryContents:nodePath];
    [afcMedia close];
    return (int)[array count];
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

- (NSData *)readFileData:(NSString *)filePath {
    if (![_iPod.fileSystem fileExistsAtPath:filePath]) {
        return nil;
    }
    else{
        long long fileLength = [_iPod.fileSystem getFileLength:filePath];
        AFCFileReference *openFile = [_iPod.fileSystem openForRead:filePath];
        const uint32_t bufsz = 10240;
        char *buff = (char*)malloc(bufsz);
        NSMutableData *totalData = [[[NSMutableData alloc] init] autorelease];
        while (1) {
            
            uint64_t n = [openFile readN:bufsz bytes:buff];
            if (n==0) break;
            //将字节数据转化为NSdata
            NSData *b2 = [[NSData alloc] initWithBytesNoCopy:buff length:n freeWhenDone:NO];
            [totalData appendData:b2];
            [b2 release];
        }
        if (totalData.length == fileLength) {
            
        }
        free(buff);
        [openFile closeFile];
        return totalData;
    }
}

@end
