//
//  IMBiCloudDriverViewController.m
//  iOSFiles
//
//  Created by smz on 18/3/14.
//  Copyright © 2018年 iMobie. All rights reserved.
//

#import "IMBiCloudDriverViewController.h"
#import "CNGridViewItemLayout.h"
#import "IMBDriveEntity.h"
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
#import "IMBAlertViewController.h"
#import "IMBiCloudDriveManager.h"

@interface IMBiCloudDriverViewController ()

@end

@implementation IMBiCloudDriverViewController

- (id)initWithDrivemanage:(IMBDriveBaseManage *)driveManage withDelegete:(id)delegete withChooseLoginModelEnum:(ChooseLoginModelEnum) chooseLogModelEnum{
    if (self = [super initWithNibName:@"IMBiCloudDriverViewController" bundle:nil]) {
        _dataSourceArray = [[NSMutableArray alloc] initWithArray:driveManage.driveDataAry];
        _tempDic  = [[NSMutableDictionary alloc] init];
        [_tempDic setObject:_dataSourceArray forKey:@"1"];
        _driveBaseManage = [driveManage retain];
        _delegate = delegete;
        [_driveBaseManage setDriveWindowDelegate:self];
        _chooseLogModelEnmu = chooseLogModelEnum;
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
    if (_toolBarArr != nil) {
        [_toolBarArr release];
        _toolBarArr = nil;
    }
    if (_editTextField) {
        [_editTextField release];
        _editTextField = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_HIDE_ICLOUDDETAIL object:nil];
    [super dealloc];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configNoDataView];
    if (_toolBarArr != nil) {
        [_toolBarArr release];
        _toolBarArr = nil;
    }
    _toolBarArr = [[NSArray alloc]initWithObjects:@(21),@(17),@(0),@(24),@(12), nil];
    [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:YES];
    
    [_rightContentView setWantsLayer:YES];
    [_leftContentView setWantsLayer:YES];
    [_leftContentView setFrame:NSMakeRect(0, 0, 1096, 548)];
    [_rightContentView setFrame:NSMakeRect(1096, 0, 282, 548)];
    
    _oldWidthDic = [[NSMutableDictionary alloc] init];
    _oldDocwsidDic = [[NSMutableDictionary alloc] init];
    [self configSelectPathButtonWithButtonTag:1 WithButtonTitle:CustomLocalizedString(@"NotConnectiCLoudTitle", nil)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideFileDetailView:) name:NOTIFY_HIDE_ICLOUDDETAIL object:nil];
    
    _doubleclickCount = 1;
    _currentDevicePath = @"0";
    [_oldDocwsidDic setObject:_currentDevicePath forKey:[NSString stringWithFormat:@"%d",_doubleclickCount]];
//    [_topLineView setWantsLayer:YES];
    [_topLineView setBackgroundColor:COLOR_TEXT_LINE];
    [_rightLineView setBackgroundColor:COLOR_TEXT_LINE];
    
    _itemTableView.dataSource = self;
    _itemTableView.delegate = self;
    _itemTableView.allowsMultipleSelection = YES;
    [_itemTableView setListener:self];
    [_itemTableView setFocusRingType:NSFocusRingTypeNone];
    _itemTableViewcanDrop = YES;
    [_itemTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    [_itemTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:YES];
    //注册该表的拖动类型
    [_itemTableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilesPromisePboardType,NSFilenamesPboardType,nil]];
    
    _gridView.itemSize = NSMakeSize(154, 154);
    _gridView.backgroundColor = [NSColor whiteColor];
    _gridView.scrollElasticity = NO;
    _gridView.allowsDragAndDrop = YES;
    _gridView.allowsMultipleSelection = YES;
    _gridView.allowsMultipleSelectionWithDrag = YES;
    _gridView.allowClickMultipleSelection = NO;
    
    [_gridView setIsFileManager:YES];
    [_gridView reloadData];
    [_itemTableView reloadData];
    [_tableViewBgView setBackgroundColor:[NSColor whiteColor]];
    _currentSelectView = 1;
    if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
        [_contentBox setContentView:_gridBgView];
    } else {
        [_contentBox setContentView:_nodataView];
    }
    
    _editTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 306, 40)];
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
    
    IMBDriveEntity *fileEntity = [array objectAtIndex:index];
    item.entity = fileEntity;
    item.category = _category;
    
    item.bgImg = fileEntity.image;
    item.itemTitle = fileEntity.fileName;
    
    item.isFileManager = YES;
    item.selected = fileEntity.checkState;
    item.isEdit = fileEntity.isEdit;
    
    if (fileEntity.checkState == Check) {
        if (![gridView.selectedItems containsObject:item]) {
            [[gridView getSelectedItemsDic] setObject:item forKey:@(item.index)];
        }
    }else{
        if ([gridView.selectedItems containsObject:item]) {
            [[gridView getSelectedItemsDic] removeObjectForKey:@(item.index)];
        }
    }
    return item;
}

#pragma mark - CNGridView Delegate
- (void)gridView:(CNGridView *)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
    NSArray *array = nil;
    if (_isSearch) {
        array = _researchdataSourceArray;
    }else {
        array = _dataSourceArray;
    }
    if (index < array.count) {
        IMBDriveEntity *fielEntity = [array objectAtIndex:index];
        if (_toolBarArr != nil) {
            [_toolBarArr release];
            _toolBarArr = nil;
        }
        _toolBarArr = [[NSArray alloc]initWithObjects:@(21),@(17),@(18),@(3),@(19),@(23),@(2),@(0),@(6),@(24),@(12), nil];
        [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:YES];
        fielEntity.checkState = Check;
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
        IMBDriveEntity *fielEntity = [array objectAtIndex:index];
        fielEntity.checkState = UnChecked;
    }
    
}

- (void)gridViewDidDeselectAllItems:(CNGridView *)gridView {
    
    if (_curEntity.isEdit) {
        NSArray *selectArr = [_gridView keyedVisibleItems];
        NSDictionary *dic = nil;
        NSString *newName = @"";
        CNGridViewItem *curItem = nil;
        for (CNGridViewItem *item in selectArr) {
            if (item.isEdit) {
                curItem = item;
                break;
            }
        }
        if (curItem) {
            if (![StringHelper stringIsNilOrEmpty:curItem.editText.stringValue] && ![curItem.editText.stringValue isEqualToString:_curEntity.fileName]) {
                _curEntity.fileName = curItem.editText.stringValue;
                if (_curEntity.extension && !_curEntity.isFolder){
                    newName = [[_curEntity.fileName stringByAppendingString:@"."] stringByAppendingString:_curEntity.extension];
                }else {
                    newName = _curEntity.fileName;
                }
                if (_curEntity.isCreate) {
                    [_driveBaseManage createFolder:newName parent:_currentDevicePath];
                } else {
                    dic = @{@"drivewsid":_curEntity.fileID,@"etag":_curEntity.etag,@"name":newName};
                    if (dic != nil) {
                        [(IMBiCloudDriveManager *)_driveBaseManage reNameWithDic:dic];
                    }
                }
            }else {
                if (_curEntity.isCreate) {
                    _curEntity.fileName = curItem.editText.stringValue;
                    [_driveBaseManage createFolder:_curEntity.fileName parent:_currentDevicePath];
                }
            }
        }
        _curEntity.isEditing = NO;
        _curEntity.isEdit = NO;
        _curEntity.isCreate = NO;
        [_toolBarButtonView toolBarButtonIsEnabled:YES];
        [_gridView reloadData];
    }
    
    NSArray *array = nil;
    if (_isSearch) {
        array = _researchdataSourceArray;
    }else {
        array = _dataSourceArray;
    }
    
    for (IMBDriveEntity *fileEntity in array) {
        fileEntity.checkState = UnChecked;
    }
    
    if (_toolBarArr != nil) {
        [_toolBarArr release];
        _toolBarArr = nil;
    }
    _toolBarArr = [[NSArray alloc]initWithObjects:@(21),@(17),@(0),@(24),@(12), nil];
    [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:YES];
    
    [_gridView reloadSelecdImage];
}

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
    if ((int)index >= 0 && index < _dataSourceArray.count) {
        IMBDriveEntity *driveEntity = [_dataSourceArray objectAtIndex:index];
        if (driveEntity.isFolder/*&& !driveEntity.isEdit*/) {
            [_contentBox setContentView:_loadingView];
            [_loadAnimationView startAnimation];
            _doubleclickCount ++;
            _doubleClick = YES;
            [self configSelectPathButtonWithButtonTag:_doubleclickCount WithButtonTitle:driveEntity.fileName];
            if (driveEntity.childCount>120) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    @autoreleasepool {
                        [_driveBaseManage recursiveDirectoryContentsDics:driveEntity.fileID];
                        _currentDevicePath = driveEntity.fileID;
                    }
                });
            }else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [_driveBaseManage recursiveDirectoryContentsDics:driveEntity.fileID];
                    _currentDevicePath = driveEntity.fileID;
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
            key = @"fileName";
        }else if ([str isEqualToString:CustomLocalizedString(@"List_Header_id_Date", nil)]) {
             key = @"lastModifiedDateString";
        }else if ([str isEqualToString:CustomLocalizedString(@"List_Header_id_Type", nil)]) {
            key = @"extension";
        }else if ([str isEqualToString:CustomLocalizedString(@"List_Header_id_Size", nil)]) {
            key = @"fileSize";
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];//其中，price为数组中的对象的属性，这个针对数组中存放对象比较更简洁方便

        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [disPalyAry sortUsingDescriptors:sortDescriptors];
        [_gridView reloadData];
        [sortDescriptor release];
    }
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
    IMBDriveEntity *fileEntity = nil;
    if (_isSearch) {
        if (row >= _researchdataSourceArray.count) {
            return @"";
        }
        fileEntity = [_researchdataSourceArray objectAtIndex:row];
    }else {
        if (row >= _dataSourceArray.count) {
            return @"";
        }
        fileEntity = [_dataSourceArray objectAtIndex:row];
    }
    if ([@"Formats" isEqualToString:tableColumn.identifier]){
        
        if (![StringHelper stringIsNilOrEmpty:fileEntity.extension]) {
            return fileEntity.extension;
        }else {
            return @"--";
        }
    }else if ([@"FileName" isEqualToString:tableColumn.identifier]){
        return fileEntity.fileName;
    }else if ([@"LastTime" isEqualToString:tableColumn.identifier]){
        if ([StringHelper stringIsNilOrEmpty:fileEntity.lastModifiedDateString]) {
            return @"--";
        }else{
            return fileEntity.lastModifiedDateString;
        }
    }else if ([@"Size" isEqualToString:tableColumn.identifier]){
        return [IMBHelper getFileSizeString:fileEntity.fileSize reserved:2];
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
        IMBDriveEntity *fileEntity = [array objectAtIndex:row];
        IMBImageAndTextFieldCell *curCell = (IMBImageAndTextFieldCell *)cell;
        [curCell setImageSize:NSMakeSize(24, 24)];
        curCell.image = fileEntity.image;
        curCell.imageText = @"";//fileEntity.fileName;
        [curCell setIsDataImage:YES];
        curCell.marginX = 12;
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSLog(@"shouldEditTableColumn");
    if (!_curEntity.isEdit) {
        _curEntity.isEdit = YES;
        _curEntity.isEditing = NO;
        [_toolBarButtonView toolBarButtonIsEnabled:NO];
    }
    return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 40;
}

- (void)tableView:(NSTableView *)tableView WithSelectIndexSet:(NSIndexSet *)indexSet {
    NSLog(@"WithSelectIndexSet");
    NSMutableArray *disPalyAry = nil;
    if (_isSearch) {
        disPalyAry = _researchdataSourceArray;
    }else{
        disPalyAry = _dataSourceArray;
    }
    if (disPalyAry.count <=0) {
        return;
    }
    
//    [self executeRenameOrCreate];
    
    NSArray *dataArr = nil;
    if (indexSet.count > 0) {
        dataArr = [disPalyAry objectsAtIndexes:indexSet];
        for (IMBDriveEntity *entity in dataArr) {
            entity.checkState = Check;
        }
        if (dataArr.count == 1) {
            _curEntity = [dataArr objectAtIndex:0];
            if (_isShow) {
                [self configDetailViewWith:_curEntity];
            }
        }
    }
    for (IMBDriveEntity *entity in disPalyAry) {
        if (![dataArr containsObject:entity]) {
            entity.checkState = UnChecked;
        }
    }
    for (IMBDriveEntity *entity in _dataSourceArray) {
        if (entity.checkState) {
            if (_toolBarArr != nil) {
                [_toolBarArr release];
                _toolBarArr = nil;
            }
            _toolBarArr = [[NSArray alloc]initWithObjects:@(21),@(17),@(18),@(3),@(19),@(23),@(2),@(0),@(6),@(24),@(12), nil];
            [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:NO];
            break;
        }
    }
    [_itemTableView reloadData];
}

- (void)tableViewDoubleClick:(NSTableView *)tableView row:(NSInteger)index {
    [self gridView:_gridView didDoubleClickItemAtIndex:index inSection:0];
}

- (void)tableViewSingleClick:(NSTableView *)tableView row:(NSInteger)index {
    [self executeRenameOrCreate];
}

- (void)tableView:(NSTableView *)tableView textDidEndEditing:(NSNotification *)notification {
    if (_curEntity) {
        _curEntity.isEditing = NO;
        _curEntity.isEdit = NO;
        _curEntity.isCreate = NO;
    }
    [_toolBarButtonView toolBarButtonIsEnabled:YES];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSLog(@"setObjectValue");
    if (_dataSourceArray.count > row) {
        IMBDriveEntity *entity = [_dataSourceArray objectAtIndex:row];
        if (entity.isEdit) {
            NSString *newName = (NSString *)object;
            entity.fileName = newName;
            if (entity.extension && !entity.isFolder){
                newName = [[newName stringByAppendingString:@"."] stringByAppendingString:entity.extension];
            }
            if (entity.isCreate) {
                [_driveBaseManage createFolder:newName parent:_currentDevicePath];
            } else {
                NSDictionary *dic = @{@"drivewsid":entity.fileID,@"etag":entity.etag,@"name":newName};
                if (dic != nil) {
                    [(IMBiCloudDriveManager *)_driveBaseManage reNameWithDic:dic];
                }
            }
            entity.isEditing = NO;
            entity.isEdit = NO;
            entity.isCreate = NO;
            [_toolBarButtonView toolBarButtonIsEnabled:YES];
            [_itemTableView reloadData];
        }
    }
}

//排序
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    //在重命名或者创建文件夹时，点击排序执行相应操作
    [self executeRenameOrCreate];
    
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
    
    if ([@"FileName" isEqualToString:identify] || [@"Formats" isEqualToString:identify] || [@"LastTime" isEqualToString:identify] || [@"Size" isEqualToString:identify]) {
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
    if ([key isEqualToString:@"FileName"]) {
        key = @"fileName";
    } else if ([key isEqualToString:@"Formats"]) {
        key = @"extension";
    }else if ([key isEqualToString:@"Size"]) {
        key = @"fileSize";
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

#pragma mark - NSTableView drop and drag
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSArray *fileTypeList = [NSArray arrayWithObject:@"export"];
    [pboard setPropertyList:fileTypeList
                    forType:NSFilesPromisePboardType];
    if (tableView == _itemTableView) {
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - _itemTableView drag destination support
- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pastboard = [info draggingPasteboard];
    NSArray *fileTypeList = [pastboard propertyListForType:NSFilesPromisePboardType];
    if (fileTypeList == nil) {
        if (_itemTableViewcanDrop && tableView == _itemTableView) {
            return NSDragOperationCopy;
        }else {
            return NSDragOperationNone;
        }
    }else {
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
        [itemArray addObject:path];
        
    }
    [self dropToCollectionViewTableViewWithpaths:itemArray];
    return YES;
}

- (NSArray *)tableView:(NSTableView *)tableView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet {
    NSArray *namesArray = nil;
    //获取目的url
    BOOL iconHide = NO;
    NSString *url = [dropDestination relativePath];
    //此处调用导出方法
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:indexSet,@"indexSet",url,@"url", nil];
    [self performSelector:@selector(delayCollectionViewTableViewdragToMac:) withObject:dic afterDelay:0.1];
    iconHide = YES;
    return namesArray;
}

#pragma mark - drag action
- (NSArray *)gridView:(CNGridView *)gridView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropURL forDraggedItemsAtIndexes:(NSIndexSet *)indexes {
    NSArray *namesArray = nil;
    //获取目的url
    NSString *url = [dropURL relativePath];
    //此处调用导出方法
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:indexes,@"indexSet",url,@"url", nil];
    [self performSelector:@selector(delayCollectionViewTableViewdragToMac:) withObject:dic afterDelay:0.1];
    return namesArray;
}

- (void)delayCollectionViewTableViewdragToMac:(NSDictionary *)param {
    NSString *url = [param objectForKey:@"url"];
    [self downloadWithPath:url];
}

#pragma mark - drop action
- (void)dropToCollectionViewTableViewWithpaths:(NSMutableArray *)pathsAry {
    [self addItemsDelay:pathsAry];
}

#pragma mark - operation action
- (void)reload:(id)sender {
    [_contentBox setContentView:_loadingView];
    [_loadAnimationView startAnimation];
    [_driveBaseManage recursiveDirectoryContentsDics:_currentDevicePath];
    _isSearch = NO;
    [_searhView setStringValue:@""];
}

- (void)showDetailView:(id)sender {
    if (_curEntity) {
        _isShow = YES;
        [self showFileDetailViewWithEntity:_curEntity];
    }
}

- (void)showFileDetailViewWithEntity:(IMBDriveEntity *)entity {
    [_rightContentView.layer removeAllAnimations];
    [_leftContentView.layer removeAllAnimations];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        
        NSRect rect= NSMakeRect(814, 0, 282, 544);
        NSRect rect2 = NSMakeRect(0, 0, 814, 544);
        [context setDuration:0.3];
        [[_rightContentView animator] setFrame:rect];
        [[_leftContentView animator] setFrame:rect2];
        
    } completionHandler:^{
        [self configDetailViewWith:entity];
    }];
}

- (IBAction)hideFileDetailView:(id)sender {
    if (_isShow) {
        [_rightContentView.layer removeAllAnimations];
        [_leftContentView.layer removeAllAnimations];
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            NSRect rect = NSMakeRect(1096, 0, 282,544);
            NSRect rect2 = NSMakeRect(0, 0, 1096, 544);
            [context setDuration:0.3];
            [[_rightContentView animator] setFrame:rect];
            [[_leftContentView animator] setFrame:rect2];
        } completionHandler:^{
            _isShow = NO;
        }];
    }
    
    if (_isShowTranfer) {
        IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
        _isShowTranfer = NO;
        [tranferView.view setFrame:NSMakeRect([_delegate window].contentView.frame.size.width - tranferView.view.frame.size.width +8, -8, 360, tranferView.view.frame.size.height)];
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
    }
}

- (void)configDetailViewWith:(IMBDriveEntity *)entity {
    
    [_detailSize setStringValue:CustomLocalizedString(@"List_Header_id_Size", nil)];
    [_detailCount setStringValue:CustomLocalizedString(@"iCloud_detailView_count", nil)];
    [_detailLastTime setStringValue:CustomLocalizedString(@"iCloud_detailView_lastTime", nil)];
    [_detailCreateTime setStringValue:CustomLocalizedString(@"iCloud_detailView_creatTime", nil)];
    
    [_detailSize setTextColor:COLOR_TEXT_ORDINARY];
    [_detailCount setTextColor:COLOR_TEXT_ORDINARY];
    [_detailLastTime setTextColor:COLOR_TEXT_ORDINARY];
    [_detailCreateTime setTextColor:COLOR_TEXT_ORDINARY];
    [_detailTitle setTextColor:COLOR_TEXT_ORDINARY];
    
    
    [_detailImageView setImage:entity.image];
    [_detailTitle setStringValue:entity.fileName];
    
    if ([StringHelper stringIsNilOrEmpty:entity.lastModifiedDateString]) {
        [_detailLastTimeContent setStringValue:@"--"];
    } else {
        [_detailLastTimeContent setStringValue:entity.lastModifiedDateString];
    }
    if ([StringHelper stringIsNilOrEmpty:entity.createdDateString]) {
        [_detailCreateTimeContent setStringValue:@"--"];
    } else {
        [_detailCreateTimeContent setStringValue:entity.createdDateString];
    }
    [_detailSizeContent setStringValue:[IMBHelper getFileSizeString:entity.fileSize reserved:2]];
    [_detailCountContent setStringValue:[NSString stringWithFormat:@"%d",entity.childCount]];
    
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
            NSString *exportPath = [paths objectAtIndex:0];
            [self performSelector:@selector(downloadWithPath:) withObject:exportPath afterDelay:0.3];
        }
    }];
}

- (void)downloadWithPath:(NSString *)path {

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
    [_driveBaseManage setDownloadPath:path];
    if (_chooseLogModelEnmu == iCloudLogEnum) {
         [tranferView icloudDriveAddDataSource:preparedArray WithIsDown:YES WithDriveBaseManage:_driveBaseManage withUploadParent:nil];
    }else {
       [tranferView dropBoxAddDataSource:preparedArray WithIsDown:YES WithDriveBaseManage:_driveBaseManage withUploadParent:nil];
    }
}

- (void)toiCloud:(id)sender {
 
}

- (void)addItems:(id)sender {
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
            [self performSelector:@selector(addItemsDelay:) withObject:paths afterDelay:0.3];
        }
    }];
}

- (void)addItemsDelay:(NSMutableArray *)paths {
    
//    [_contentBox setContentView:_loadingView];
//    [_loadAnimationView startAnimation];
//    [_driveBaseManage driveUploadItems:dataArr];
    IMBTranferViewController *tranferView = [IMBTranferViewController singleton];
//    [_driveBaseManage setDownloadPath:pathStr];
    if (_chooseLogModelEnmu == iCloudLogEnum) {
        [tranferView icloudDriveAddDataSource:paths WithIsDown:NO WithDriveBaseManage:_driveBaseManage withUploadParent:_currentDevicePath];
    }else {
        [tranferView icloudDriveAddDataSource:paths WithIsDown:NO WithDriveBaseManage:_driveBaseManage withUploadParent:_currentDevicePath];
//        [tranferView dropBoxAddDataSource:preparedArray WithIsDown:YES WithDriveBaseManage:_driveBaseManage];
    }
    
//    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0/*延迟执行时间*/ * NSEC_PER_SEC));
//    dispatch_after(delayTime, dispatch_get_global_queue(0, 0), ^{
//        [_driveBaseManage recursiveDirectoryContentsDics:_currentDevicePath];
//    });
}

- (void)deleteItems:(id)sender {
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
    NSMutableArray *folderIdArr = [NSMutableArray array];
    for (IMBDriveEntity *entity in preparedArray) {
        [folderIdArr addObject:@{@"etag":entity.etag,@"drivewsid":entity.fileID}];
    }
    if (folderIdArr.count > 0) {
        [_contentBox setContentView:_loadingView];
        [_loadAnimationView startAnimation];
        [_driveBaseManage deleteDriveItem:folderIdArr];
    }
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
            IMBDriveEntity *item= [_dataSourceArray objectAtIndex:i];
            if (item.checkState == NSOnState) {
                [set addIndex:i];
            }
        }
        [_itemTableView selectRowIndexes:set byExtendingSelection:NO];
        
        _currentSelectView = 0;
        [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:NO];
//        [_itemTableView reloadData];
    }else if (segBtn.switchBtnState == 0) {
        [_gridView reloadData];
        _currentSelectView = 1;
        if (_dataSourceArray.count > 0) {
            [_contentBox setContentView:_gridBgView];
        }else {
            [_contentBox setContentView:_nodataView];
        }
        [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:YES];
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
    if (_toolBarArr != nil) {
        [_toolBarArr release];
        _toolBarArr = nil;
    }
    _toolBarArr = [[NSArray alloc]initWithObjects:@(21),@(17),@(0),@(24),@(12), nil];
    if (_dataSourceArray.count > 0 && _dataSourceArray != nil) {
        if (_currentSelectView == 0) {
            [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:NO];
            [_contentBox setContentView:_tableViewBgView];
        } else {
            [_toolBarButtonView loadButtons:_toolBarArr Target:self DisplayMode:YES];
            [_contentBox setContentView:_gridBgView];
        }
    } else {
        [_contentBox setContentView:_nodataView];
    }
}

- (void)loadTransferComplete:(NSMutableArray *)transferAry WithEvent:(ActionTypeEnum)actionType {
    if (actionType == deleteAction) {
        if (transferAry.count > 0) {
            for (NSString *foldId in transferAry) {
                [_dataSourceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([[(IMBDriveEntity *)obj fileID] isEqualToString:foldId]) {
                        [_dataSourceArray removeObject:obj];
                    }
                }];
            }
        }
        [self changeContentViewWithDataArr:_dataSourceArray];
    }else if (actionType == loadAction) {
        if (_doubleClick) {
            [_oldDocwsidDic setObject:_currentDevicePath forKey:[NSString stringWithFormat:@"%d",_doubleclickCount]];
            [_tempDic setObject:transferAry forKey:[NSString stringWithFormat:@"%d",_doubleclickCount]];
        }
        [self changeContentViewWithDataArr:transferAry];
    }
    [_loadAnimationView endAnimation];

}

- (void)rename:(id)sender {
    NSIndexSet *selectedSet = [self selectedItems];
    if (selectedSet.count > 1) {
        [self showAlertText:CustomLocalizedString(@"System_id_1", nil) OKButton:CustomLocalizedString(@"Button_Ok", nil)];
        return;
    }
    
    if (_currentSelectView == 1) {
        _curEntity.isEdit = YES;
        _curEntity.isEditing = NO;
        [_gridView reloadData];
    }else {
        _isTableViewEdit = YES;
        NSUInteger row = [_itemTableView selectedRow];
        [_editTextField setFont:[NSFont fontWithName:@"Helvetica Neue" size:12]];
        [_editTextField setFocusRingType:NSFocusRingTypeDefault];
        [_editTextField setStringValue:_curEntity.fileName];
        [_editTextField setEditable:YES];
        [_editTextField setSelectable:YES];
        
        [_editTextField setFrameOrigin:NSMakePoint(44, row*40)];
        [_itemTableView addSubview:_editTextField];
        [_editTextField becomeFirstResponder];
    }
    [_toolBarButtonView toolBarButtonIsEnabled:NO];
}

- (void)createNewFloder:(id)sender {
    if (_dataSourceArray != nil) {
        [_gridView deselectAllItems];
        IMBDriveEntity *newEntity = [[IMBDriveEntity alloc] init];
        newEntity.fileName = @"new folder";
        newEntity.isFolder = YES;
        newEntity.image = [NSImage imageNamed:@"mac_cnt_fileicon_myfile"];
        newEntity.extension = @"Folder";
        newEntity.isEdit = YES;
        newEntity.isCreate = YES;
        newEntity.isEditing = NO;
        newEntity.checkState = Check;
        _curEntity = newEntity;
        [_dataSourceArray insertObject:newEntity atIndex:0];
        if (_currentSelectView == 1) {
            [_gridView reloadData];
        }else {
            [_itemTableView reloadData];
            NSMutableIndexSet *set = [NSMutableIndexSet indexSetWithIndex:0];
            [_itemTableView selectRowIndexes:set byExtendingSelection:NO];
            
            _isTableViewEdit = YES;
            [_editTextField setFont:[NSFont fontWithName:@"Helvetica Neue" size:12]];
            [_editTextField setFocusRingType:NSFocusRingTypeDefault];
            [_editTextField setStringValue:_curEntity.fileName];
            [_editTextField setEditable:YES];
            [_editTextField setSelectable:YES];

            [_editTextField setFrameOrigin:NSMakePoint(44, 0)];
            [_itemTableView addSubview:_editTextField];
            [_editTextField becomeFirstResponder];
        }
        [_toolBarButtonView toolBarButtonIsEnabled:NO];
        [newEntity release];
        newEntity = nil;
    }
}

- (void)executeRenameOrCreate {
    [_editTextField removeFromSuperview];
    if (_isTableViewEdit) {
        _isTableViewEdit = NO;
        if (_curEntity) {
            NSString *newName = _editTextField.stringValue;
            if (![StringHelper stringIsNilOrEmpty:newName] && ![_curEntity.fileName isEqualToString:newName]) {
                _curEntity.fileName = newName;
                if (_curEntity.extension && !_curEntity.isFolder){
                    newName = [[newName stringByAppendingString:@"."] stringByAppendingString:_curEntity.extension];
                }
                if (_curEntity.isCreate) {
                    [_driveBaseManage createFolder:newName parent:_currentDevicePath];
                } else {
                    NSDictionary *dic = @{@"drivewsid":_curEntity.fileID,@"etag":_curEntity.etag,@"name":newName};
                    if (dic != nil) {
                        [(IMBiCloudDriveManager *)_driveBaseManage reNameWithDic:dic];
                    }
                }
            }else {
                if (_curEntity.isCreate) {
                    _curEntity.fileName = newName;
                    [_driveBaseManage createFolder:newName parent:_currentDevicePath];
                }
            }
            _curEntity.isCreate = NO;
            [_toolBarButtonView toolBarButtonIsEnabled:YES];
        }
    }
}

- (void)moveToFolder:(id)sender {
    NSArray *displayArr = nil;
    if (_isSearch) {
        displayArr = _researchdataSourceArray;
    }else {
        displayArr = _dataSourceArray;
    }
    NSMutableArray *folderArr = [NSMutableArray array];
    for (IMBDriveEntity *entity in displayArr) {
        if (entity.isFolder && entity.checkState == UnChecked) {
            [folderArr addObject:entity];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSView *view = nil;
        for (NSView *subView in ((NSView *)self.view.window.contentView).subviews) {
            if ([subView isMemberOfClass:[NSClassFromString(@"IMBAlertSupeView") class]]&& [subView.subviews count] == 0) {
                view = subView;
                break;
            }
        }
        if (view) {
            [view setHidden:NO];
            [_alertViewController setDelegete:self];
            [_alertViewController showSelectFolderAlertViewWithSuperView:view WithFolderArray:folderArr];
        }
        
    });
    
}

- (void)startMoveTransferWith:(IMBDriveEntity *)entity {
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
    NSMutableArray *moveItemsArr = [NSMutableArray array];
    for (IMBDriveEntity *itemEntity in preparedArray) {
        [moveItemsArr addObject:@{@"drivewsid":itemEntity.fileID,@"etag":itemEntity.etag,@"clientId":itemEntity.fileID}];
    }
    if (moveItemsArr.count > 0) {
        [_contentBox setContentView:_loadingView];
        [_loadAnimationView startAnimation];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [_driveBaseManage moveToNewParent:entity.fileID itemDics:moveItemsArr];
        });
    }
}

#pragma mark 搜索 
- (void)doSearchBtn:(NSString *)searchStr withSearchBtn:(IMBSearchView *)searchView {
    _searhView = searchView;
    _isSearch = YES;
    if (searchStr != nil && ![searchStr isEqualToString:@""]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName CONTAINS[cd] %@ ",searchStr];
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

@end
