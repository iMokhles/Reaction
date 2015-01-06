//
//  ReactionController.m
//  Reaction
//
//  Created by Mokhlas Hussein on 2/1/14.
//
//

#import "ReactionController.h"
#import <AssetsLibrary/AssetsLibrary.h>

OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;

@interface ReactionController ()

@end


@implementation ReactionController
@synthesize _imageView = imageView;
@synthesize _quickShot = quickShot;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      UIActionSheet *actionSheet = [[UIActionSheet alloc]
                              initWithTitle:@"Attach Image"                            
                              delegate:self
                              cancelButtonTitle:@"Cancel"                                        
                              destructiveButtonTitle:nil                                               
                              otherButtonTitles:@"attach last image", nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    });
  });
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  //Get the name of the current pressed button
  NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
  if  ([buttonTitle isEqualToString:@"attach last image"]) {
    [self checkImage];
  }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self prepareView];
    //[self checkImage];
}

- (void)prepareView {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    quickShot = [[BYQuickShotView alloc]init];
    
    UILongPressGestureRecognizer *longPressShot = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressShot:)];
    [quickShot addGestureRecognizer:longPressShot];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(handleDoubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTapGestureRecognizer];
    
    imageView = [[UIImageView alloc]init];
    imageView.frame = self.view.frame;//[[UIScreen mainScreen] bounds];
    imageView.userInteractionEnabled = NO;
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            /*Do iPhone 5 stuff here.*/
            quickShot.frame = CGRectMake(190, 380, 120, 160);
            quickShot.delegate = self;
            quickShot.draggable = YES;
            [self.view addSubview:quickShot];
        } else {
            /*Do iPhone Classic stuff here.*/
            quickShot.frame = CGRectMake(190, 300, 120, 150);
            quickShot.delegate = self;
            quickShot.draggable = YES;
            [self.view addSubview:quickShot];
        }
    } else {
        /*Do iPad stuff here.*/
        quickShot.frame = CGRectMake(190, 290, 120, 160);
        quickShot.delegate = self;
        quickShot.draggable = YES;
        [self.view addSubview:quickShot];
    }
}

- (void)longPressShot:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        NSLog(@"Long Press");
        
        [self screenshot];
        [self animateFlash];
        UIImageWriteToSavedPhotosAlbum([self screenshot], nil, nil, nil);
        [self.delegate reactionFinished];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

-(UIImage *)screenshot {
    UIImage *Screenshot = _UICreateScreenUIImage();
    return Screenshot;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    // Insert your own code to handle doubletap
    [self.delegate reactionFinished];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

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

- (void)checkImage {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (nil != group) {
            // be sure to filter the group so you only get photos
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:group.numberOfAssets - 1]
                                    options:0
                                 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                     if (nil != result) {
                                         ALAssetRepresentation *repr = [result defaultRepresentation];
                                         // this is the most recent saved photo
                                         NSDictionary *imgMeta = [repr metadata];
                                         NSDictionary *gpsdata = [imgMeta objectForKey:@"{TIFF}"];
                                         NSDate *timeImage = [gpsdata valueForKey:@"DateTime"];
                                         //NSDate *nwDate = [NSDate date];
                                         NSDate *lastDate = [NSDate dateWithTimeIntervalSinceNow:-1];
                                         UIImage *img = [UIImage imageWithCGImage:[repr fullScreenImage]];
                                         [imageView setImage:img];
                                         // if (timeImage == lastDate) {
                                         //     [imageView setImage:img];
                                         // } else {
                                         //     [imageView setImage:img];
                                         // }
                                         // we only need the first (most recent) photo -- stop the enumeration
                                         *stop = YES;
                                     }
                                 }];
        }
        *stop = NO;
    }
        failureBlock:^(NSError *error) {
            NSLog(@"error: %@", error);
    }];
}
#pragma mark BYQuickShotViewDelegate implementation

- (void)didTakeSnapshot:(UIImage *)img {
    NSLog(@"BYQuickShotView took a snapshot: %@", img);
}

- (void)didDiscardLastImage {
    NSLog(@"BYQuickShotView did discard the last image taken");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
