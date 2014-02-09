//
//  MXLMediaView.m
//
//  Created by Kiran Panesar on 08/02/2014.
//  Copyright (c) 2014 MobileX Labs. All rights reserved.
//

#import "MXLMediaView.h"

// Categories
#import "UIImage+ImageEffects.h"

@interface MXLMediaView ()

@property (strong, nonatomic, readwrite) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;

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

// Main method to show the media view
-(void)showImage:(UIImage *)image inParentView:(UIView *)parentView {
    // Store the parent view and image
    _parentView = parentView;
    _mediaImage = image;

    // Set up self
    [self setFrame:CGRectMake(0.0f, 0.0f, parentView.frame.size.width, parentView.frame.size.height)];
    [self setUserInteractionEnabled:YES];
    
    // Set up background imageview
    // This is used to replace the parentView in the backgroud, allowing us to efficiently blur
    _backgroundImageView = [[UIImageView alloc] initWithFrame:parentView.frame];
    [_backgroundImageView setImage:[self blurredImageFromView:parentView]]; // Blur
    [_backgroundImageView setAlpha:0.0f];                                   // Make invisible
    [self addSubview:_backgroundImageView];
    
    // Add self to view stack
    [parentView addSubview:self];
    
    // Start showing the actualy image file provided
    [self showMediaImageView];

    // Animate the background image view opacity
    // This gives the illusion that the background is being blurred
    [UIView animateWithDuration:0.2 animations:^{
        [_backgroundImageView setAlpha:1.0f];
    } completion:^(BOOL finished) {
        
        // Once that's complete, hide all the parent view's subviews, except for self
        for (UIView *v in parentView.subviews) {
            if (v != self) {
                [v setHidden:YES];
            }
        }
        
        
        // Animate the scaling of the background image
        // Giving the illusion that the background view is shrinking a bit
        [UIView animateWithDuration:0.2 animations:^{
            // CATransform stuff
            CGAffineTransform transform = _backgroundImageView.transform;
            [_backgroundImageView setTransform:CGAffineTransformScale(transform, 0.9, 0.9)];
            [_backgroundImageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        } completion:^(BOOL finished) {
            // Once done, add a tap gesture to dismiss self
            [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)]];
        }];
    }];
 }

// Method to show the actual image provided
-(void)showMediaImageView {
    // Initialise the imageview
    _mediaImageView = [[UIImageView alloc] initWithImage:_mediaImage];
    [_mediaImageView setFrame:CGRectMake(0.0f, -_mediaImageView.frame.size.height, self.frame.size.width, self.frame.size.height)]; // Set it to be off frame
    [_mediaImageView setContentMode:UIViewContentModeScaleAspectFit];                                                               // Set the content mode
    
    [self addSubview:_mediaImageView]; // Add to view stack
    
    // Set up UIKit Dynamic animator instance
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

    // Create collision point at the bottom boundary of self
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[_mediaImageView]];
    [collisionBehaviour addBoundaryWithIdentifier:@"barrier"
                                fromPoint:CGPointMake(0.0f, self.frame.size.height)
                                  toPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    
    // Add gravity effect with 2.5 vertical velocity
    UIGravityBehavior *gravityBehaviour   = [[UIGravityBehavior alloc] initWithItems:@[_mediaImageView]];
    [gravityBehaviour setGravityDirection:CGVectorMake(0.0f, 2.5f)];
    
    // Add the collision and gravity behaviours to the main animator
    [_dynamicAnimator addBehavior:collisionBehaviour];
    [_dynamicAnimator addBehavior:gravityBehaviour];
}

// Used to dismiss the actual image provided
-(void)hideMediaImageView {
    // Animation to shrink it to nothing
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform transform = _mediaImageView.transform;
        [_mediaImageView setTransform:CGAffineTransformScale(transform, 0, 0)];
        [_mediaImageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
    }];
}

// Method to dismiss self
-(void)dismiss:(id)sender {
    // Dismiss actual image provided
    [self hideMediaImageView];
    
    // Scale background back to fullscreen
    [UIView animateWithDuration:0.2 animations:^{
        // Scale background image
        CGAffineTransform transform = _backgroundImageView.transform;
        [_backgroundImageView setTransform:CGAffineTransformScale(transform, 1/0.9, 1/0.9)];
        [_backgroundImageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
        
        // Show status bar
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    } completion:^(BOOL finished) {
        // Show all parentview subviews again
        for (UIView *v in _parentView.subviews) {
            [v setHidden:NO];
        }
        
        // Animate background image opacity to 0
        // Giving the illusion that the background image is un-blurring
        [UIView animateWithDuration:0.2 animations:^{
            [_backgroundImageView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}


#pragma mark Blur methods

-(UIImage *)blurredImageFromView:(UIView *)backgroundView {
    UIImage *backgroundImage = [self captureView:backgroundView];
    backgroundImage = [backgroundImage applyBlurWithRadius:6.0 tintColor:[UIColor colorWithWhite:0.0f alpha:0.6] saturationDeltaFactor:1.0f maskImage:nil];
    
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
