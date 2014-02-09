//
//  AppDelegate.h
//  ExampleProject
//
//  Created by Kiran Panesar on 09/02/2014.
//  Copyright (c) 2014 MobileX Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemoViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) DemoViewController *demoViewController;
@end
