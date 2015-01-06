#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BYQuickShotView.h"
#import "ReactionController.h"
#import <objc/runtime.h>

#define PREVIEW_LAYER_EDGE_RADIUS 10
OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

/* Photos Library Interfaces */
@interface PLPhotoBrowserController : UIViewController
- (void)beginEditingPhoto:(id)arg1;
@end

@interface PLPhotoScrollerViewController : PLPhotoBrowserController
@end

@interface PLPhotoScrollerViewController (Reaction) <BYQuickShotViewDelegate>
-(void)rectionController;
- (void)animateFlash;
-(UIImage *)screenshot;
@end

/* Camer View Interfaces */
@interface PLCameraViewController : UIViewController
- (void)viewDidAppear:(BOOL)arg1;
- (void)viewWillDisappear:(BOOL)arg1;
@end

@interface PLApplicationCameraViewController : PLCameraViewController
- (void)cameraViewFinishedTakingPicture:(id)arg1;
- (void)stopCameraPreviewAnimated:(BOOL)arg1;
- (void)startCameraPreview:(id)arg1;
- (void)_startCameraPreviewWithPreviewStartedBlock:(id)arg1;
@end

@interface PLApplicationCameraViewController (Reaction) <ReactionControllerDelegate>
- (void)presentReaction;
- (void)checkImageData;
@end

@interface CAMApplicationViewController : UIViewController
- (void)cameraViewFinishedTakingPicture:(id)arg1;
- (void)stopCameraPreviewAnimated:(BOOL)arg1;
- (void)startCameraPreview;
- (void)_startCameraPreviewWithPreviewStartedBlock:(id)arg1;
@end

@interface CAMApplicationViewController (Reaction) <ReactionControllerDelegate>
- (void)presentReaction;
- (void)checkImageData;
@end

static id animate;

static NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.imokhles.Reaction.plist"];
static BOOL value;

#define kPreferencesPath @"/User/Library/Preferences/com.imokhles.Reaction.plist"
#define kPreferencesChanged "com.imokhles.Reaction-preferencesChanged"

static void ReactionInitPrefs() {
    NSDictionary *ReactionSettings = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
    NSNumber *enableTweakNU = ReactionSettings[@"enable"];
    value = enableTweakNU ? [enableTweakNU boolValue] : 0;

}

%group REiOS67
%hook PLCameraPageController
- (void)_resetStatusBarPosition {
    
}
- (void)_updateStatusBarPositionForView:(id)arg1 {
    
}
%end

%hook PLApplicationCameraViewController

- (void)cameraViewFinishedTakingPicture:(id)arg1 {
    %log;
    %orig;
    if (value) {
        [self checkImageData];
    } else {
        %orig;
    }
}

%new(v@:@@)
- (void)presentReaction {
    /////////**//////////
}

%new(v@:@@)
- (void)checkImageData {
    [self stopCameraPreviewAnimated:0];
    ReactionController *reactionControl = [[ReactionController alloc] init];
    reactionControl.delegate = self;
    [self presentViewController:reactionControl animated:YES completion:NULL];
}

#pragma mark ReactionControllerDelegate implementation
%new(v@:@@)
- (void)reactionFinished {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [self startCameraPreview:animate];
    } else {
        [self _startCameraPreviewWithPreviewStartedBlock:animate];
    }
}
%end
%end

%group REiOS8
%hook CAMApplicationViewController

- (void)cameraViewFinishedTakingPicture:(id)arg1 {
    %log;
    %orig;    
    if (value) {
        [self checkImageData];
    } else {
        %orig;
    }
}

%new(v@:@@)
- (void)presentReaction {
    /////////**//////////
}

%new(v@:@@)
- (void)checkImageData {
    [self stopCameraPreviewAnimated:0];
    ReactionController *reactionControl = [[ReactionController alloc] init];
    reactionControl.delegate = self;
    [self presentViewController:reactionControl animated:YES completion:NULL];
}

#pragma mark ReactionControllerDelegate implementation
%new(v@:@@)
- (void)reactionFinished {
    [self startCameraPreview];
}
%end
%end
/*
 Playing with PLPhotoBrowserController To Add My Reaction Functions ;)
 */
%hook PLPhotoScrollerViewController

- (void)viewDidAppear:(BOOL)arg1 {
    %log;
    %orig;
    //NSLog(@"********iMOKHLES********* %@", self);
    //NSLog(@"********iMOKHLES********* %@", self.view);    
    if (value) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.view addGestureRecognizer:longPress];
    } else {
        %orig;
    }
}

%new(v@:@@)
- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        NSLog(@"Long Press");
        [self rectionController];
    }
}


%new(v@:@@)
-(void)rectionController {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    BYQuickShotView *quickShotView = [[BYQuickShotView alloc]init];
    UILongPressGestureRecognizer *longPressShot = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressShot:)];
    [quickShotView addGestureRecognizer:longPressShot];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            /*Do iPhone 5 stuff here.*/
            quickShotView.frame = CGRectMake(190, 380, 120, 160);
            quickShotView.delegate = self;
            quickShotView.draggable = YES;
            [self.view addSubview:quickShotView];
        } else {
            /*Do iPhone Classic stuff here.*/
            quickShotView.frame = CGRectMake(190, 300, 120, 150);;
            quickShotView.delegate = self;
            quickShotView.draggable = YES;
            [self.view addSubview:quickShotView];
        }
    } else {
        /*Do iPad stuff here.*/
        quickShotView.frame = CGRectMake(190, 290, 120, 160);
        quickShotView.delegate = self;
        quickShotView.draggable = YES;
        [self.view addSubview:quickShotView];
    }
}

%new(v@:@@)
- (void)longPressShot:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        NSLog(@"Long Press");
        
        [self screenshot];
        [self animateFlash];
        UIImageWriteToSavedPhotosAlbum([self screenshot], nil, nil, nil);
        
    }
}

%new(v@:@@)
-(UIImage *)screenshot {
    UIImage *Screenshot = _UICreateScreenUIImage();
    return Screenshot;
}

%new(v@:@@)
- (void)animateFlash {
    UIView *flashView = [[UIView alloc]initWithFrame:self.view.frame];
    flashView.backgroundColor = [UIColor whiteColor];
    flashView.layer.masksToBounds = YES;
    flashView.layer.cornerRadius = PREVIEW_LAYER_EDGE_RADIUS;
    [self.view addSubview:flashView];
    [UIView animateWithDuration:0.2 delay:0.1 options:kNilOptions animations:^{
        flashView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [flashView removeFromSuperview];
    }];
}

#pragma mark BYQuickShotViewDelegate implementation

%new(v@:@@)
- (void)didTakeSnapshot:(UIImage *)img {
    NSLog(@"BYQuickShotView took a snapshot: %@", img);
}

%new(v@:@@)
- (void)didDiscardLastImage {
    NSLog(@"BYQuickShotView did discard the last image taken");
}

%end

%ctor {
    if (IS_OS_8_OR_LATER) {
        %init(REiOS8);
    } else {
        %init(REiOS67);
    }
    %init();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReactionInitPrefs, CFSTR(kPreferencesChanged), NULL, CFNotificationSuspensionBehaviorCoalesce);
    ReactionInitPrefs();
}