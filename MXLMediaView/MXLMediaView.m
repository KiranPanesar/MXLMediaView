//
//  MXLSnapChatMediaView.m
//  SnapCatch
//
//  Created by Kiran Panesar on 08/02/2014.
//  Copyright (c) 2014 MobileX Labs. All rights reserved.
//

#import "MXLMediaView.h"

// Categories
#import "UIImage+ImageEffects.h"

@interface MXLMediaView ()

@property (strong, nonatomic, readwrite) UIImageView *backgroundImageView;

-(void)showMediaImageView;
-(void)dismiss:(id)sender;

@end

@implementation MXLMediaView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)showImage:(UIImage *)image inParentView:(UIView *)parentView {
    _parentView = parentView;
    _mediaImage = image;
    
    [self setFrame:CGRectMake(0.0f, 0.0f, parentView.frame.size.width, parentView.frame.size.height)];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)]];
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:parentView.frame];
    [[_backgroundImageView layer] setMasksToBounds:NO];
    [_backgroundImageView setImage:[self blurredImageFromView:parentView]];
    [_backgroundImageView setAlpha:0.0f];
    
    [self addSubview:_backgroundImageView];
    [parentView addSubview:self];

    [UIView animateWithDuration:0.2 animations:^{
        [_backgroundImageView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        
        for (UIView *v in parentView.subviews) {
            if (v != self) {
                [v setHidden:YES];
            }
        }
        
        [self showMediaImageView];
        
        [UIView animateWithDuration:0.2 animations:^{
            CGAffineTransform transform = _backgroundImageView.transform;
            [_backgroundImageView setTransform:CGAffineTransformScale(transform, 0.9, 0.9)];
            [_backgroundImageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }];
    }];
}

-(void)showMediaImageView {
    _mediaImageView = [[UIImageView alloc] initWithImage:_mediaImage];
    [_mediaImageView setFrame:CGRectZero];
    [_mediaImageView setCenter:CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f)];
    [_mediaImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:_mediaImageView];
    
    [UIView animateWithDuration:0.2 animations:^{
        [_mediaImageView setFrame:CGRectMake(0.0f, 0.0f,
                                             self.frame.size.width, self.frame.size.height)];
    }];
}

-(void)hideMediaImageView {
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform transform = _mediaImageView.transform;
        [_mediaImageView setTransform:CGAffineTransformScale(transform, 0, 0)];
        [_mediaImageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
    }];
}

-(void)dismiss:(id)sender {
    [self hideMediaImageView];
    
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform transform = _backgroundImageView.transform;
        [_backgroundImageView setTransform:CGAffineTransformScale(transform, 1/0.9, 1/0.9)];
        [_backgroundImageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    } completion:^(BOOL finished) {

        for (UIView *v in _parentView.subviews) {
            [v setHidden:NO];
        }
        
        [UIView animateWithDuration:0.2 animations:^{
            [_backgroundImageView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

-(UIImage *)blurredImageFromView:(UIView *)backgroundView {
    UIImage *backgroundImage = [self captureView:backgroundView];
    backgroundImage = [backgroundImage applyBlurWithRadius:10.0 tintColor:[UIColor colorWithWhite:0.0f alpha:0.6] saturationDeltaFactor:1.0f maskImage:nil];
    
    return backgroundImage;
}

- (UIImage *)captureView:(UIView *)view {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
