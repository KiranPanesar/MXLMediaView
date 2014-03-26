MXLMediaView
============

This is a class designed to show a UIImage and blur & shrink the background. Similar to the Facebook app.

Compatibility
--------
MXLMediaView uses UIKit Dynamics for the gravity effect so is only compatible with iOS 7 right now.

![alt text](http://f.cl.ly/items/2M3v1X2I362H0O3s0f0O/MXLMediaViewDemo.gif "Demo gif")

Usage
-----
The only externa dependency is on Apple' [UIImage+ImageEffects](https://developer.apple.com/downloads/download.action?path=wwdc_2013/wwdc_2013_sample_code/ios_uiimageeffects.zip), which is included in this repo.

The process of showing an image in your app is dead simple. First import the class:
```objectivec
#import "MXLMediaView.h"
```
And then:
```objectivec
-(void)pushShowImageButton:(id)sender {
    MXLMediaView *mediaView = [[MXLMediaView alloc] init];
    [mediaView setDelegate:self];

    [mediaView showImage:[UIImage imageNamed:@"daft_punk@2x.jpg"] inParentView:self.view completion:^{
      NSLog(@"Done showing MXLMediaView");
    }];
}
```
or to show a video...
```objectivec
-(void)pushShowVideoButton:(id)sender {
    MXLMediaView *mediaView = [[MXLMediaView alloc] init];
    [mediaView setDelegate:self];
    
    // The best video on the Internet.
    NSURL *videoURL = [NSURL URLWithString:@"http://website.com/video.mp4"];
    
    [mediaView showVideoWithURL:videoURL inParentView:self.navigationController.view completion:^{
        NSLog(@"Complete");
    }];
}
```

Delegate methods:
```objectivec
-(void)mediaView:(MXLMediaView *)mediaView didReceiveLongPressGesture:(id)gesture {
    NSLog(@"MXLMediaViewDelgate: Long pressed received");
}

-(void)mediaViewWillDismiss:(MXLMediaView *)mediaView {
    NSLog(@"MXLMediaViewDelgate: Will dismiss");
}

-(void)mediaViewDidDismiss:(MXLMediaView *)mediaView {
    NSLog(@"MXLMediaViewDelgate: Did dismiss");
}
```

Licence
-------
MIT. See LICENCE file for more info.

If you do use this in your app, send me a [tweet](http://twitter.com/k_panesar)!

Pitch
-----
How much do *you* think this advanced open source project is worth? Wait just one minute before you answer!

Watch as MXLMediaView shows any image with just the call of a method! Now you can take any image you like and show it right in **your** app!

That's right, all these features for just... ***how*** much did you guess? *$500?* *$1000?* *Even more?!* ***No!*** It's just ***$0***. That's right! It's incredible value but it's true! Order today PO Box MXL, GitHub, Chicago - [Except in Nebraska...](http://www.youtube.com/watch?v=tGvHNNOLnCk)
