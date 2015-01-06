//
//  ReactionController.h
//  Reaction
//
//  Created by Mokhlas Hussein on 2/1/14.
//
//

#import <UIKit/UIKit.h>
#import "BYQuickShotView.h"

#define PREVIEW_LAYER_EDGE_RADIUS 10

@protocol ReactionControllerDelegate <NSObject>
- (void)reactionFinished;
@end

@interface ReactionController : UIViewController <BYQuickShotViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) id <ReactionControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *_imageView;
@property (nonatomic, strong) BYQuickShotView *_quickShot;
@end
