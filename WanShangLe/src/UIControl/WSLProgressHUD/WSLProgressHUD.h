//
//  MMProgressHUD.h
//  MMProgressHUD
//
//  Created by Lars Anderson on 10/7/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CancelBlock)();

@interface WSLProgressHUD : UIView

@property (nonatomic, readwrite) CGPoint *progressViewPoint;

@property (nonatomic, retain) UILabel *titleLabel;

/** The status label that displays text stored in messageText.
 
 @warning Do not manually assign text to this property.  Set the intended text with messageText and call applyLayoutFrames or updateAnimated:withCompletion:.
 */
@property (nonatomic, retain) UILabel *statusLabel;

/** The imageView that displays image content stored in either image or animationImages.
 
 @warning Do not manually assign images to this property. Set the intended image/images to image/animationImages respectively, then call applyLayoutFrames or updateAnimated:withCompletion:.
 */
@property (nonatomic, retain) UIImageView *imageView;

/** The text which will display at the top of the HUD.
 
 Setting this property will not immediately draw text on the label, as the entire layout will be flagged as dirty and will need to be recalculated, after which this string will be applied to the titleLabel.
 */
@property (nonatomic, copy) NSString *titleText;

/** The text which will display at the bottom of the HUD.
 
 Setting this property will not immediately draw text on the label, as the entire layout will be flagged as dirty and will need to be recalculated, after which this string will be applied to the messageLabel.
 */
@property (nonatomic, copy) NSString *statusText;

/** The static image which will display in the middle of the HUD. */
@property (nonatomic, retain) UIImage *image;

/** An array of animated images that will display in the middle of the HUD. This takes precedence over image.
 */
@property (nonatomic, retain) NSArray *animationImages;

@property(nonatomic, copy) void(^cancelBlock)(void);

+ (void)showWithTitle:(NSString *)title
               status:(NSString *)status
          cancelBlock:(void(^)(void))cancelBlock;

- (void)showWithTitle:(NSString *)title
               status:(NSString *)status
  confirmationMessage:(NSString *)confirmation
          cancelBlock:(void(^)(void))cancelBlock
               images:(NSArray *)images;
+ (void)dismiss;

- (void)clickCancelButton:(id)sender;

+(void)cleanCache;
@end