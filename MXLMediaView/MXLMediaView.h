//
//  MXLMediaView.h
//
//  Created by Kiran Panesar on 08/02/2014.
//  Copyright (c) 2014 MobileX Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXLMediaView;

@protocol MXLMediaViewDelegate <NSObject>

@optional
-(void)mediaView:(MXLMediaView *)mediaView didReceiveLongPressGesture:(id)gesture; // When the user holds finger on screen
-(void)mediaViewWillDismiss:(MXLMediaView *)mediaView;                             // When media view is about to dismiss
-(void)mediaViewDidDismiss:(MXLMediaView *)mediaView;                              // When media view dismisses

@end

@interface MXLMediaView : UIView

@property (strong, nonatomic, readonly) UIImageView *mediaImageView;      // Used to show acutal image
@property (strong, nonatomic, readonly) UIImageView *backgroundImageView; // Used to capture background image & blur

@property (strong, nonatomic) UIView  *parentView;
@property (strong, nonatomic) UIImage *mediaImage;

@property (strong, nonatomic) id<MXLMediaViewDelegate> delegate;

-(void)showImage:(UIImage *)image inParentView:(UIView *)parentView;

@end
