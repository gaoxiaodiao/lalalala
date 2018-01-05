//
//  IMBFileSystemExport.m
//  AnyTrans
//
//  Created by iMobie on 8/2/16.
//  Copyright (c) 2016 imobie. All rights reserved.
//

#import "IMBFileSystemExport.h"
#import "SimpleNode.h"
#import "TempHelper.h"
#import "StringHelper.h"
#import "IMBFileSystem.h"

@implementation IMBFileSystemExport

- (void)startTransfer {
    _totalItemCount = 0;
    _currItemIndex = 0;
    [_loghandle writeInfoLog:@"FileSystemExport DoProgress enter"];
    AFCMediaDirectory *afcMedia = [_ipod.fileSystem afcMediaDirectory];
    if ([_transferDelegate respondsToSelector:@selector(transferPrepareFileStart:)]) {
        [_transferDelegate transferPrepareFileStart:CustomLocalizedString(@"MSG_COM_Prepare", nil)];
    }
    //先用递归算法算出文件的总的个数
    [self caculateTotalFileCount:_exportTracks afcMedia:afcMedia];
    if ([_transferDelegate respondsToSelector:@selector(transferPrepareFileEnd)]) {
        [_transferDelegate transferPrepareFileEnd];
    }
    for (int i=0;i<[_exportTracks count];i++) {
        if (_limitation.remainderCount == 0) {
            SimpleNode *node = [_exportTracks objectAtIndex:i];
            [[IMBTransferError singleton] addAnErrorWithErrorName:node.fileName WithErrorReson:CustomLocalizedString(@"ResultWindow_result_2", nil)];
            continue;
        }
        [_condition lock];
        if (_isPause) {
            [_condition wait];
        }
        [_condition unlock];
        if (!_isStop) {
            SimpleNode *node = [_exportTracks objectAtIndex:i];
            NSString *destinationPath = [_exportPath stringByAppendingPathComponent:node.fileName];
            if (node.container) {
                [_fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:nil];
                NSArray *arr = [self getFirstContent:node.path afcMedia:afcMedia];
                [self copyFileToMac:destinationPath withNodeArray:arr afcMedia:afcMedia];
            }else {
                _currItemIndex++;
                NSLog(@"_currItemIndex:%d  _totalItemCount:%d",_currItemIndex,_totalItemCount);
                if ([_fileManager fileExistsAtPath:destinationPath]) {
                    destinationPath = [_exportPath stringByAppendingPathComponent:[StringHelper createDifferentfileName:node.fileName]];
                }
                if (![TempHelper stringIsNilOrEmpty:node.path]) {
                    NSString *msgStr = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_Copying", nil),[node.path lastPathComponent]];
                    if ([_transferDelegate respondsToSelector:@selector(transferFile:)]) {
                        [_transferDelegate transferFile:msgStr];
                    }
                }
//                float progress = ((float)_currItemIndex / _totalItemCount) * 100;
//                if ([_transferDelegate respondsToSelector:@selector(transferProgress:)]) {
//                    [_transferDelegate transferProgress:progress];
//                }
                if ([afcMedia fileExistsAtPath:node.path]) {
                    BOOL success = [self copyRemoteFile:node.path toLocalFile:destinationPath];
                    if (success) {
                        [_limitation reduceRedmainderCount];
                        _successCount ++;
                    }else
                    {
                        [[IMBTransferError singleton] addAnErrorWithErrorName:node.fileName WithErrorReson:CustomLocalizedString(@"Ex_Op_file_copy_error", nil)];
                        _failedCount ++;
                        continue;
                    }
                }else {
                     [[IMBTransferError singleton] addAnErrorWithErrorName:node.fileName WithErrorReson:CustomLocalizedString(@"Ex_Op_file_no_exist", nil)];
                    _failedCount ++;
                }
            }
        }else {
            SimpleNode *node = [_exportTracks objectAtIndex:i];
            [[IMBTransferError singleton] addAnErrorWithErrorName:node.fileName WithErrorReson:CustomLocalizedString(@"ResultWindow_result_2", nil)];
            _skipCount ++;
        }
    }
    if ([_transferDelegate respondsToSelector:@selector(transferComplete:TotalCount:)]) {
        [_transferDelegate transferComplete:_successCount TotalCount:_totalItemCount];
    }
    
    [_loghandle writeInfoLog:@"FileSystemExport DoProgress Complete"];
}

- (void)copyFileToMac:(NSString *)FolderPath withNodeArray:(NSArray *)nodeArray afcMedia:(AFCMediaDirectory *)afcMedia {
    for (int i=0;i<[nodeArray count];i++) {
        if (_limitation.remainderCount == 0) {
            SimpleNode *node = [nodeArray objectAtIndex:i];
            [[IMBTransferError singleton] addAnErrorWithErrorName:node.fileName WithErrorReson:CustomLocalizedString(@"ResultWindow_result_2", nil)];
            continue;
        }
        [_condition lock];
        if (_isPause) {
            [_condition wait];
        }
        [_condition unlock];
        if (!_isStop) {
            SimpleNode *node = [nodeArray objectAtIndex:i];
            NSString *destinationPath = [FolderPath stringByAppendingPathComponent:node.fileName];
            if ([_fileManager fileExistsAtPath:destinationPath]) {
                destinationPath = [FolderPath stringByAppendingPathComponent:[StringHelper createDifferentfileName:node.fileName]];
            }
            if (node.container) {
                [_fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:nil];
                NSArray *arr = [self getFirstContent:node.path afcMedia:afcMedia];
                [self copyFileToMac:destinationPath withNodeArray:arr afcMedia:afcMedia];
            }else {
                _currItemIndex++;
                NSLog(@"sdfs _currItemIndex:%d  _totalItemCount:%d",_currItemIndex,_totalItemCount);
                if (![TempHelper stringIsNilOrEmpty:FolderPath]) {
                    NSString *msgStr = [NSString stringWithFormat:CustomLocalizedString(@"MSG_COM_Copying", nil),[FolderPath lastPathComponent]];
                    if ([_transferDelegate respondsToSelector:@selector(transferFile:)]) {
                        [_transferDelegate transferFile:msgStr];
                    }
                }
//                float progress = ((float)_currItemIndex / _totalItemCount) * 100;
//                if ([_transferDelegate respondsToSelector:@selector(transferProgress:)]) {
//                    [_transferDelegate transferProgress:progress];
//                }
                if ([afcMedia fileExistsAtPath:node.path]) {
                    BOOL success = [self copyRemoteFile:node.path toLocalFile:destinationPath];
                    if (success) {
                        _successCount ++;
                        [_limitation reduceRedmainderCount];
                    }else {
                        [[IMBTransferError singleton] addAnErrorWithErrorName:node.fileName WithErrorReson:CustomLocalizedString(@"Ex_Op_file_copy_error", nil)];
                        _failedCount ++;
                        continue;
                    }
                }else {
                    [[IMBTransferError singleton] addAnErrorWithErrorName:node.fileName WithErrorReson:CustomLocalizedString(@"Ex_Op_file_no_exist", nil)];
                    _failedCount ++;
                }
            }
        }else {
            SimpleNode *node = [nodeArray objectAtIndex:i];
            [[IMBTransferError singleton] addAnErrorWithErrorName:node.fileName WithErrorReson:CustomLocalizedString(@"ResultWindow_result_2", nil)];
            _skipCount ++;
        }
    }
}

- (void)caculateTotalFileCount:(NSArray *)nodeArray afcMedia:(AFCMediaDirectory *)afcMedia
{
    for (SimpleNode *node in nodeArray) {
        if (!node.container) {
            _totalItemCount ++;
            _totalSize += node.itemSize;
        }else
        {
            NSArray *arr = [self getFirstContent:node.path afcMedia:afcMedia];
            [self caculateTotalFileCount:arr afcMedia:afcMedia];
        }
    }
}

- (NSArray *)getFirstContent:(NSString *)path afcMedia:(AFCMediaDirectory *)afcMedia {
    NSMutableArray *nodeArray = [NSMutableArray array];
    NSArray *array = [afcMedia directoryContents:path];
    for (NSString *fileName in array) {
        NSString *filePath = nil;
        if ([path isEqualToString:@"/"]) {
            
            filePath = [NSString stringWithFormat:@"/%@",fileName];
        }else
        {
            
            filePath = [path stringByAppendingPathComponent:fileName];
        }
        
        SimpleNode *node = [[SimpleNode alloc] initWithName:fileName];
        node.path = filePath;
        node.parentPath = path;
        NSDictionary *fileDic = [afcMedia getFileInfo:filePath];
        NSString *fileType = [fileDic objectForKey:@"st_ifmt"];
        if ([fileType isEqualToString:@"S_IFDIR"]) {
            node.container = YES;
//            OSType code = UTGetOSTypeFromString((CFStringRef)@"fldr");
//            NSImage *picture = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(code)];
//            [picture setSize:NSMakeSize(66, 58)];
//            node.image = picture;
        }else
        {
            node.container = NO;
            node.itemSize = [[fileDic objectForKey:@"st_size"] longLongValue];
//            NSString *extension = [node.path pathExtension];
//            NSWorkspace *workSpace = [[NSWorkspace alloc] init];
//            NSImage *icon = [workSpace iconForFileType:extension];
//            [icon setSize:NSMakeSize(56, 52)];
//            node.image = icon;
//            [workSpace release];
        }
        [nodeArray addObject:node];
        [node release];
    }
    return nodeArray;
}

@end
