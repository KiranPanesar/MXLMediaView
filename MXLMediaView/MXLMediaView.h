//
//  MXLSnapChatMediaView.h
//  SnapCatch
//
//  Created by Kiran Panesar on 08/02/2014.
//  Copyright (c) 2014 MobileX Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXLMediaView : UIView

@property (strong, nonatomic, readonly) UIImageView *mediaImageView;
@property (strong, nonatomic, readonly) UIImageView *backgroundImageView; // Used to capture background image & blur

@property (strong, nonatomic) UIView  *parentView;
@property (strong, nonatomic) UIImage *mediaImage;

-(void)showImage:(UIImage *)image inParentView:(UIView *)parentView;

@end
