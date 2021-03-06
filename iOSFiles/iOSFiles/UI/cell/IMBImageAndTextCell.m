/*
 File: ImageAndTextCell.m
 Abstract: Subclass of NSTextFieldCell which can display text and an image simultaneously.
 Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "IMBImageAndTextCell.h"
#import <AppKit/NSCell.h>
#import "StringHelper.h"
#import "TempHelper.h"
@implementation IMBImageAndTextCell
@synthesize marginX = _marginX;
@synthesize paddingX = _paddingX;
@synthesize image = _image;
@synthesize imageSize = _imageSize;
@synthesize reserveWidth = _reserveWidth;
@synthesize rightImage = _rightImage;
@synthesize rightSize = _rightSize;
@synthesize lockImg = _lockImg;
@synthesize iCloudImg = _iCloudImg;
@synthesize imageStrName = _imageStrName;
@synthesize imageName = _imageName;
@synthesize isDataImage = _isDataImage;
- (id)init {
    if ((self = [super init])) {
        //[self setLineBreakMode:NSLineBreakByTruncatingTail];
        //[self setSelectable:YES];
        _imageSize = NSMakeSize(0, 0);
        _marginX = 3;
        _paddingX = 3;
        _reserveWidth = 0;
        _imageStrName = @"";
    }
    return self;
}

- (void)dealloc {
    [_image release];
    [_rightImage release];
    [_lockImg release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    IMBImageAndTextCell *cell = (IMBImageAndTextCell *)[super copyWithZone:zone];
    // The image ivar will be directly copied; we need to retain or copy it.
    cell->_image = [_image retain];
    cell->_rightImage = [_rightImage retain];
    cell ->_lockImg = [_lockImg retain];
    return cell;
}

- (NSSize)_imageSize:(CGFloat)cellFrameHeight {
    if (_imageSize.width == 0 && _imageSize.height == 0) {
        _imageSize = NSMakeSize(cellFrameHeight - 4, cellFrameHeight - 4);
    }
    return _imageSize;
}

- (NSRect)imageRectForBounds:(NSRect)cellFrame {
    
    NSRect result;
    if (_image != nil) {
        result.size = [self _imageSize:_image.size.height];
        result.origin = cellFrame.origin;
        result.origin.x += _marginX;
        result.origin.y += ceil((cellFrame.size.height - result.size.height) / 2);
    } else {
        if (_reserveWidth > 0) {
            NSRect rect = NSZeroRect;
            rect.origin = cellFrame.origin;
            rect.size = [self _imageSize:_reserveWidth];
            rect.origin.x += _marginX;
            result = rect;
        }
        else{
            result = NSZeroRect;
        }
    }
    return result;
}

// We could manually implement expansionFrameWithFrame:inView: and drawWithExpansionFrame:inView: or just properly implement titleRectForBounds to get expansion tooltips to automatically work for us
- (NSRect)titleRectForBounds:(NSRect)cellFrame {
    NSRect result;
    /*
     if (_image != nil) {
     CGFloat imageWidth = [self _imageSize:cellFrame.size.height].width;
     result = cellFrame;
     result.origin.x += (3 + imageWidth);
     result.size.width -= (3 + imageWidth);
     } else {
     */
    result = [super titleRectForBounds:cellFrame];
    result.origin.x += self.paddingX;
    //}
    return result;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
    [super editWithFrame:[self titleRectForBounds:aRect] inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
    [super selectWithFrame:[self titleRectForBounds:aRect] inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect imageFrame;
    if (_image != nil) {
        if (self.isHighlighted && self.controlView.window.isKeyWindow) {
            NSImage *surImage = [_image retain];
            NSString *imageName = _image.name;
            if ([TempHelper stringIsNilOrEmpty:imageName]) {
                imageName = _imageName;
            }
            if(_isDataImage) {
                
            }else {
                if (_image != nil) {
                    [_image release];
                    _image = nil;
                }
                if (self.backgroundStyle == NSBackgroundStyleDark) {
                    _image = [[StringHelper imageNamed:[NSString stringWithFormat:@"%@1",imageName]] retain];
                    
                }else{
                    _image = [[StringHelper imageNamed:[NSString stringWithFormat:@"%@",imageName]] retain];
                }
            }

        
            if (_image == nil) {
                _image = [surImage retain];
            }
            [surImage release];
        }
         imageFrame = [self imageRectForBounds:cellFrame];
        [_image drawInRect:imageFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        NSInteger newX = NSMaxX(imageFrame) + _paddingX;
        cellFrame.size.width = NSMaxX(cellFrame) - newX;
        cellFrame.origin.x = newX;
    }
    else{
         imageFrame = [self imageRectForBounds:cellFrame];
        NSInteger newX = NSMaxX(imageFrame) + _paddingX;
        cellFrame.size.width = NSMaxX(cellFrame) - newX;
        cellFrame.origin.x = newX;
    }
    [super drawWithFrame:cellFrame inView:controlView];
    
    //扩展 文字右边的图
    if (_rightImage != nil) {
        
        NSRect rect;
        rect.origin.x = controlView.frame.size.width - _rightSize.width - 4;
        rect.origin.y = cellFrame.origin.y + ceilf((cellFrame.size.height - _rightSize.height)/2.0) + 1;
        rect.size = _rightImage.size;
        [_rightImage drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        
    }
    if (_lockImg != nil) {
        NSRect rect;
        rect.origin.x = cellFrame.origin.x  - 10;
        rect.origin.y = cellFrame.origin.y + ceilf((cellFrame.size.height - _rightSize.height)/2.0) ;
        rect.size = _lockImg.size;
        [_lockImg drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    }
    
    if (_iCloudImg != nil) {
        NSRect rect;
        rect.origin.x = cellFrame.origin.x - 18;
        rect.origin.y = cellFrame.origin.y + 45;
        rect.size = _iCloudImg.size;
        [_iCloudImg drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    }
}

- (NSSize)cellSize {
    NSSize cellSize = [super cellSize];
    if (_image != nil) {
        cellSize.width += _imageSize.width;
    }
    cellSize.width += _marginX;
    return cellSize;
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    NSPoint point = [controlView convertPoint:[event locationInWindow] fromView:nil];
    // If we have an image, we need to see if the user clicked on the image portion.
    if (_image != nil) {
        // This code closely mimics drawWithFrame:inView:
        NSSize imageSize = [self _imageSize:cellFrame.size.height];
        NSRect imageFrame;
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, _marginX + imageSize.width, NSMinXEdge);
        
        imageFrame.origin.x += _marginX;
        imageFrame.size = imageSize;
        // If the point is in the image rect, then it is a content hit
        if (NSMouseInRect(point, imageFrame, [controlView isFlipped])) {
            // We consider this just a content area. It is not trackable, nor it it editable text. If it was, we would or in the additional items.
            // By returning the correct parts, we allow NSTableView to correctly begin an edit when the text portion is clicked on.
            return NSCellHitContentArea;
        }
    }
    // At this point, the cellFrame has been modified to exclude the portion for the image. Let the superclass handle the hit testing at this point.
    return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
}



@end

