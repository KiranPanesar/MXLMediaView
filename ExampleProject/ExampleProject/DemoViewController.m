//
//  DemoViewController.m
//  ExampleProject
//
//  Created by Kiran Panesar on 09/02/2014.
//  Copyright (c) 2014 MobileX Labs. All rights reserved.
//

#import "DemoViewController.h"

// Views
#import "MXLMediaView.h"

@interface DemoViewController () <MXLMediaViewDelegate>

@property (strong, nonatomic, readwrite) UIButton *showImageButton;

-(void)setUpShowImageButton;
-(void)pushShowImageButton:(id)sender;

@end

@implementation DemoViewController

-(void)pushShowImageButton:(id)sender {
    MXLMediaView *mediaView = [[MXLMediaView alloc] init];
    [mediaView setDelegate:self];

    [mediaView showImage:[UIImage imageNamed:@"daft_punk@2x.jpg"] inParentView:self.navigationController.view completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *introAlertView = [[UIAlertView alloc] initWithTitle:@"Quick Tips"
                                                                     message:@"Tap on the image to dismiss it, hold down to show options."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"Dismiss"
                                                           otherButtonTitles:nil, nil];
            [introAlertView show];
        });
    }];
}

-(void)setUpShowImageButton {
    _showImageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_showImageButton setFrame:CGRectMake(0.0f, 0.0f, 200.0f, 60.0f)];
    [_showImageButton setCenter:CGPointMake(self.view.frame.size.width/2.0f, self.view.frame.size.height/2.0f)];
    [_showImageButton setTitle:@"Show Image" forState:UIControlStateNormal];
    [_showImageButton addTarget:self action:@selector(pushShowImageButton:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_showImageButton];
}

#pragma mark MXLMediaViewDelegate Methods

-(void)mediaView:(MXLMediaView *)mediaView didReceiveLongPressGesture:(id)gesture {
    NSLog(@"MXLMediaViewDelgate: Long pressed received");
    
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share Photo"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"Dismiss"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"Twitter", @"Facebook", @"Instagram", nil];
    [shareActionSheet showInView:self.view];
}

-(void)mediaViewWillDismiss:(MXLMediaView *)mediaView {
    NSLog(@"MXLMediaViewDelgate: Will dismiss");
}

-(void)mediaViewDidDismiss:(MXLMediaView *)mediaView {
    NSLog(@"MXLMediaViewDelgate: Did dismiss");
}

-(id)init {
    self = [super init];

    if (self) {
        [self setTitle:@"Demo"];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setUpShowImageButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
