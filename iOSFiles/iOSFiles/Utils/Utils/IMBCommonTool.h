//
//  IMBCommonTool.h
//  iOSFiles
//
//  Created by iMobie on 2018/3/14.
//  Copyright © 2018年 iMobie. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface IMBCommonTool : NSObject
/**
 *  设置view的背景颜色
 *
 *  @param view      view
 *  @param bgColor   背景颜色值
 *  @param delta     差值
 *  @param radius    弧度
 *  @param dirtyRect frame
 */
+ (void)setViewBgWithView:(NSView *)view color:(NSColor *)bgColor delta:(CGFloat)delta radius:(CGFloat)radius dirtyRect:(NSRect)dirtyRect;

/**
 *  显示单个ok按钮的下拉提示框
 *
 *  @param isMainWindow    是否显示在mainwindow上
 *  @param btnTitle        btn的title
 *  @param msgText         显示的提示信息
 *  @param btnClickedBlock 按钮点击响应事件
 */
+ (void)showSingleBtnAlertInMainWindow:(BOOL)isMainWindow btnTitle:(NSString *)btnTitle msgText:(NSString *)msgText btnClickedBlock:(void(^)(void))btnClickedBlock;
+ (void)showSingleBtnAlertInMainWindow:(BOOL)isMainWindow alertTitle:(NSString *)alertTitle btnTitle:(NSString *)btnTitle msgText:(NSString *)msgText btnClickedBlock:(void(^)(void))btnClickedBlock;

/**
 *  显示单个两个按钮的下拉提示框
 *
 *  @param isMainWindow          是否显示在mainwindow上
 *  @param firstTitle            第一个btn的title
 *  @param secondTitle           第二个btn的title
 *  @param msgText               显示的提示信息
 *  @param firstBtnClickedBlock  第一个按钮点击响应事件
 *  @param secondBtnClickedBlock 第二个按钮点击响应事件
 */
+ (void)showTwoBtnsAlertInMainWindow:(BOOL)isMainWindow firstBtnTitle:(NSString *)firstTitle secondBtnTitle:(NSString *)secondTitle msgText:(NSString *)msgText firstBtnClickedBlock:(void(^)(void))firstBtnClickedBlock secondBtnClickedBlock:(void(^)(void))secondBtnClickedBlock;
+ (void)showTwoBtnsAlertInMainWindow:(BOOL)isMainWindow alertTitle:(NSString *)alertTitle firstBtnTitle:(NSString *)firstTitle secondBtnTitle:(NSString *)secondTitle msgText:(NSString *)msgText firstBtnClickedBlock:(void(^)(void))firstBtnClickedBlock secondBtnClickedBlock:(void(^)(void))secondBtnClickedBlock;

@end