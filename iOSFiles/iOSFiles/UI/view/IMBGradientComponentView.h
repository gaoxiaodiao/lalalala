//
//  IMBGradientComponentView.h
//  iOSFiles
//
//  Created by JGehry on 3/7/18.
//  Copyright © 2018 iMobie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMBGradientComponentView : NSView
{
    NSColor *_leftNormalBgColor;
    NSColor *_rightNormalBgColor;
    BOOL _isleftRightGridient;
    
    BOOL _isOriginalFrame;
    NSSize _shadowSize;
}


/**
 *          渐变颜色设置
 *  @param isLeftRightGridient --> 是否左右渐变，否则为上下渐变
 *  @param leftNormalBgColor    左边或者上面的颜色
 * @param  rightNormalBgColor    右边或者下面的颜色
 */
- (void)setIsLeftRightGridient:(BOOL)isLeftRightGridient withLeftNormalBgColor:(NSColor *)leftNormalBgColor withRightNormalBgColor:(NSColor *)rightNormalBgColor;
- (void)setViewShadow:(CGFloat)bottom;

@property(nonatomic, copy)void(^mouseClicked)(void);
@property(nonatomic, assign)BOOL isOriginalFrame;

@property(nonatomic, copy)void(^mouseEntered)(void);
@property(nonatomic, copy)void(^mouseExited)(void);

@end