//
//  ReactionWindow.h
//  Reaction
//
//  Created by Mokhlas Hussein on 2/4/14.
//
//

#import <UIKit/UIKit.h>
#import "BYQuickShotView.h"

#define PREVIEW_LAYER_EDGE_RADIUS 10

@interface UIWindow ()
+(id)keyWindow;
@end

@protocol ReactionWindowDelegate <NSObject>
- (void)reactionStarted;
- (void)reactionFinished;
@end

@interface ReactionWindow : UIWindow <BYQuickShotViewDelegate>
@property (nonatomic, strong) id <ReactionWindowDelegate> Reactiondelegate;
@property (nonatomic, strong) BYQuickShotView *_quickShot;
- (BOOL)hitsButton:(CGPoint)point;
@end
