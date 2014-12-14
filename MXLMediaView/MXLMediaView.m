//
//  MXLMediaView.m
//
//  Created by Kiran Panesar on 08/02/2014.
//  Copyright (c) 2014 MobileX Labs. All rights reserved.
//

#import "MXLMediaView.h"

// Frameworks
@import MediaPlayer;

// Categories
#import "UIImage+ImageEffects.h"

#define IS_DEVICE_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface MXLMediaView () <UIDynamicAnimatorDelegate>

// Background image view (used for blurring the background)
@property (strong, nonatomic, readwrite) UIImageView       *backgroundImageView;

// UIKit Dynamics manager
@property (strong, nonatomic, readwrite) UIDynamicAnimator *dynamicAnimator;

// Gesture recognizers
@property (strong, nonatomic, readwrite) UITapGestureRecognizer       *tapGestureRecognizer;
@property (strong, nonatomic, readwrite) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (assign, nonatomic, readwrite) MXLMediaViewType mediaType;

-(void)dropDownView:(UIView *)view withGravityVelocity:(float)velocity;

-(void)showMediaImageView;
-(void)showMoviePlayerView;

-(void)dismiss:(id)sender;

-(void)pushLongPress:(id)sender;

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

// Method to show an image
-(void)showImage:(UIImage *)image inParentView:(UIView *)parentView completion:(void(^)(void))completion {
    _mediaType = MXLMediaViewTypeImage;
    [self showMediaFile:image ofType:_mediaType inParentView:parentView completion:completion];
}

// Method to show a video
-(void)showVideoWithURL:(NSURL *)videoURL inParentView:(UIView *)parentView completion:(void(^)(void))completion {
    _mediaType = MXLMediaViewTypeVideo;
    [self showMediaFile:videoURL ofType:_mediaType inParentView:parentView completion:completion];
}

// Main method to show a media file
-(void)showMediaFile:(id)mediaFile ofType:(MXLMediaViewType)mediaType inParentView:(UIView *)parentView completion:(void(^)(void))completion {
    // Set up the completion block
    _completionBlock = completion;
    
    // Store the parent view and video URL
    _parentView = parentView;
    
    // Set up self
    [self setFrame:CGRectMake(0.0f, 0.0f, parentView.frame.size.width, parentView.frame.size.height)];
    [self setUserInteractionEnabled:YES];
    
    // Set up background imageview
    // This is used to replace the parentView in the backgroud, allowing us to efficiently blur
    // We're setting this to be 1.2x the size of the parentView so the parent view will be smaller than the bounds
    // of _backgroundImageView, so when we blur the view it will blur around the bounds, rather than clipping.
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, parentView.frame.size.width * 1.2, parentView.frame.size.height * 1.2)];
    [_backgroundImageView setContentMode:UIViewContentModeCenter];
    [_backgroundImageView setImage:[self captureView:parentView]];
    [_backgroundImageView setImage:[self blurredImageFromView:_backgroundImageView]]; // Blur
    [_backgroundImageView setAlpha:0.0f]; // Make invisible
    [_backgroundImageView setCenter:parentView.center];
    
    [self addSubview:_backgroundImageView];
    
    // Add self to view stack
    [parentView addSubview:self];
    
    // Check the file type, show the appropriate view
    if (mediaType == MXLMediaViewTypeImage) {
        _mediaImage = (UIImage *)mediaFile;
        [self showMediaImageView];
    } else if (mediaType == MXLMediaViewTypeVideo) {
        _videoURL   = (NSURL *)mediaFile;
        [self showMoviePlayerView];
    }
    
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
            [_backgroundImageView setTransform:CGAffineTransformScale(transform, 0.8, 0.8)];
            [_backgroundImageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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
    
    [self dropDownView:_mediaImageView withGravityVelocity:(IS_DEVICE_IPAD ? 9.0f : 2.5f)];
}

// Method to show the video player
-(void)showMoviePlayerView {
    _mediaPlayerController = [[MPMoviePlayerController alloc] initWithContentURL:_videoURL];
    [_mediaPlayerController.view setFrame:CGRectMake(0.0f, -180.0f, self.frame.size.width, 180.0f)];
    [_mediaPlayerController.view setContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:_mediaPlayerController.view];
    
    [self dropDownView:_mediaPlayerController.view withGravityVelocity:(IS_DEVICE_IPAD ? 10.0f : 3.5f)];
}

// Method to drop down an arbitrary UIView into the centre of the screen with a given velocity
-(void)dropDownView:(UIView *)view withGravityVelocity:(float)velocity {
    // Set up UIKit Dynamic animator instance
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    [_dynamicAnimator setDelegate:self];
    
    // Create collision point at the bottom boundary of self
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[view]];
    [collisionBehaviour addBoundaryWithIdentifier:@"barrier"
                                        fromPoint:CGPointMake(0.0f, (self.frame.size.height + view.frame.size.height)/2.0f)
                                          toPoint:CGPointMake(self.frame.size.width, (self.frame.size.height + view.frame.size.height)/2.0f)];
    
    // Add gravity effect with 2.5 vertical velocity
    UIGravityBehavior *gravityBehaviour   = [[UIGravityBehavior alloc] initWithItems:@[view]];
    [gravityBehaviour setGravityDirection:CGVectorMake(0.0f, velocity)];
    
    // Add the collision and gravity behaviours to the main animator
    [_dynamicAnimator addBehavior:collisionBehaviour];
    [_dynamicAnimator addBehavior:gravityBehaviour];
}

// Used to hide the image/video being displayed
-(void)hideMediaView {

    // Pause the video, this keeps the thumbnail visible while the view is dismissing.
    // if you call -stop on the player, the background of the player cuts to black. Not very smooth.
    [_mediaPlayerController pause];
    
    // Animation to shrink it to nothing
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform imageViewTransform = _mediaImageView.transform;
        [_mediaImageView setTransform:CGAffineTransformScale(imageViewTransform, 0.001f, 0.001f)];
        [_mediaImageView setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
        
        CGAffineTransform movieViewTransform = _mediaPlayerController.view.transform;
        [_mediaPlayerController.view setTransform:CGAffineTransformScale(movieViewTransform, 0.001f, 0.001f)];
        [_mediaPlayerController.view setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.height/2.0f)];
    } completion:^(BOOL finished) {
        [_mediaPlayerController stop]; // Now it's hidden, stop playback completely
        [_mediaPlayerController.view removeFromSuperview];
        [_mediaImageView removeFromSuperview];
    }];
}

// Method to dismiss self
-(void)dismiss:(id)sender {
    // Remove gesture recognizers, prevents users from 'double exiting' by tapping twice
    [self removeGestureRecognizer:_tapGestureRecognizer];
    [self removeGestureRecognizer:_longPressGestureRecognizer];
    
    // Trigger mediaViewWillDismiss: delegate method
    if ([_delegate respondsToSelector:@selector(mediaViewWillDismiss:)]) {
        [_delegate mediaViewWillDismiss:self];
    }
    
    // Dismiss the image/video being displayed
    [self hideMediaView];
    
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
            
            // Trigger delegate method
            if ([_delegate respondsToSelector:@selector(mediaViewDidDismiss:)]) {
                [_delegate mediaViewDidDismiss:self];
            }
            
            [self removeFromSuperview];
        }];
    }];
}

-(void)pushLongPress:(id)sender {
    if ([(UIGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(mediaView:didReceiveLongPressGesture:)]) {
            [_delegate mediaView:self didReceiveLongPressGesture:sender];
        }
    }
}

#pragma mark Blur methods

-(UIImage *)blurredImageFromView:(UIView *)backgroundView {
    UIImage *backgroundImage = [self captureView:backgroundView];
    backgroundImage = [backgroundImage applyBlurWithRadius:6.0 tintColor:[UIColor colorWithWhite:0.0f alpha:0.6] saturationDeltaFactor:1.0f maskImage:nil];
    
    return backgroundImage;
}

- (UIImage *)captureView:(UIView *)view {
    CGRect captureRect = view.bounds;
    UIGraphicsBeginImageContext(captureRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, captureRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    // Set up and add gesture recognizers
    // We set this in the UIDynamicAnimator completion delegete so the
    // user can't dismiss the view while the media image is dropping down
    _tapGestureRecognizer       = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pushLongPress:)];
    
    [_mediaPlayerController prepareToPlay];
    [_mediaPlayerController play];
    
    [self addGestureRecognizer:_tapGestureRecognizer];
    [self addGestureRecognizer:_longPressGestureRecognizer];
    
    if (_completionBlock) {
        _completionBlock();
    }
}

@end
