// UIImage+Resize.h
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Extends the UIImage class to support resizing/cropping
#import <UIKit/UIKit.h>

@interface UIImage (Resize)
- (UIImage *)croppedImage:(CGRect)bounds;
@end

@interface UIView (ReturnImage)
- (UIImage *)imageWithView:(UIView *)view;
- (UIImage*)mergeBackgroundImage:(UIImage*)bgImg 
                          bgSize:(CGSize)bgsize
                         QRImage:(UIImage*)qrImg 
                          qrSize:(CGRect)qrSize
                       logoImage:(UIImage*)logoImg 
                        logoSize:(CGSize)logoSize;

- (UIImage *)mergeBackgroundImage:(UIImage *)backgroundImg 
                   withFrontImage:(UIImage *)frontImg;
@end
