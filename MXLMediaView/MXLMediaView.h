//
//  MXLMediaView.h
//
//  Created by Kiran Panesar on 08/02/2014.
//  Copyright (c) 2014 MobileX Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXLMediaView;
@class MPMoviePlayerController;

// Create NSENUM to store possible media types
typedef NS_ENUM(NSInteger, MXLMediaViewType) {
    MXLMediaViewTypeImage,
    MXLMediaViewTypeVideo
};

@protocol MXLMediaViewDelegate <NSObject>

@optional
-(void)mediaView:(MXLMediaView *)mediaView didReceiveLongPressGesture:(id)gesture; // When the user holds finger on screen
-(void)mediaViewWillDismiss:(MXLMediaView *)mediaView;                             // When media view is about to dismiss
-(void)mediaViewDidDismiss:(MXLMediaView *)mediaView;                              // When media view dismisses

@end

@interface MXLMediaView : UIView

@property (strong, nonatomic, readonly) UIImageView             *mediaImageView;        // Used to show image to be displayed
@property (strong, nonatomic, readonly) MPMoviePlayerController *mediaPlayerController; // Used to show the video to be plaeyd
@property (strong, nonatomic, readonly) UIImageView             *backgroundImageView;   // Used to capture background image & blur

@property (strong, nonatomic) UIView  *parentView;
@property (strong, nonatomic) UIImage *mediaImage;
@property (strong, nonatomic) NSURL   *videoURL;

@property (assign, nonatomic, readonly) MXLMediaViewType mediaType;

@property (strong, nonatomic) id<MXLMediaViewDelegate> delegate;
@property (strong, nonatomic, readonly) void(^completionBlock)();

// Methods used to show media

-(void)showImage:(UIImage *)image inParentView:(UIView *)parentView completion:(void(^)(void))completion;
-(void)showVideoWithURL:(NSURL *)videoURL inParentView:(UIView *)parentView completion:(void(^)(void))completion;

@end
