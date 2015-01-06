//
//  ReactionWindow.m
//  Reaction
//
//  Created by Mokhlas Hussein on 2/4/14.
//
//

#import "ReactionWindow.h"

OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;

@implementation ReactionWindow

@synthesize _quickShot = quickShot;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.Reactiondelegate reactionStarted];
        [self setFrame:[[UIScreen mainScreen] applicationFrame]];
        [self setWindowLevel:UIWindowLevelAlert-2];
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        //[self setBackgroundColor:[UIColor redColor]];
        [self.Reactiondelegate reactionStarted];
        [self prepareView];
        [self makeKeyAndVisible];
    }
    return self;
}

- (void)prepareView {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    quickShot = [[BYQuickShotView alloc]init];
    
    UILongPressGestureRecognizer *longPressShot = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressShot:)];
    [quickShot addGestureRecognizer:longPressShot];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            /*Do iPhone 5 stuff here.*/
            quickShot.frame = CGRectMake(190, 380, 120, 160);
            quickShot.delegate = self;
            quickShot.draggable = YES;
            [self addSubview:quickShot];
        } else {
            /*Do iPhone Classic stuff here.*/
            quickShot.frame = CGRectMake(190, 300, 120, 150);
            quickShot.delegate = self;
            quickShot.draggable = YES;
            [self addSubview:quickShot];
        }
    } else {
        /*Do iPad stuff here.*/
        quickShot.frame = CGRectMake(190, 290, 120, 160);
        quickShot.delegate = self;
        quickShot.draggable = YES;
        [self addSubview:quickShot];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return [self hitsButton:point];
}

- (BOOL)hitsButton:(CGPoint)point
{
    BOOL xMatches = (point.x >= quickShot.frame.origin.x && point.x <= quickShot.frame.origin.x + quickShot.frame.size.width ? true : false);
    BOOL yMatches = (point.y >= quickShot.frame.origin.y && point.y <= quickShot.frame.origin.y + quickShot.frame.size.height ? true : false);

    // if (isFSShowen) {
    //     return NO;
    // } else {
        return (xMatches && yMatches ? true : false);
    // }
}

- (void)longPressShot:(UILongPressGestureRecognizer*)gesture {
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        NSLog(@"Long Press");
        
        [self screenshot];
        [self animateFlash];
        UIImageWriteToSavedPhotosAlbum([self screenshot], nil, nil, nil);
        [self.Reactiondelegate reactionFinished];
        [self setHidden:YES];
        self = nil;
    }
}

- (void)animateFlash {
    UIView *flashView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    flashView.backgroundColor = [UIColor whiteColor];
    flashView.layer.masksToBounds = YES;
    flashView.layer.cornerRadius = PREVIEW_LAYER_EDGE_RADIUS;
    [self addSubview:flashView];
    [UIView animateWithDuration:0.2 delay:0.1 options:kNilOptions animations:^{
        flashView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [flashView removeFromSuperview];
    }];
}

-(UIImage *)screenshot {
    UIImage *Screenshot = _UICreateScreenUIImage();
    return Screenshot;
}

#pragma mark BYQuickShotViewDelegate implementation

- (void)didTakeSnapshot:(UIImage *)img {
    NSLog(@"BYQuickShotView took a snapshot: %@", img);
}

- (void)didDiscardLastImage {
    NSLog(@"BYQuickShotView did discard the last image taken");
}

@end
