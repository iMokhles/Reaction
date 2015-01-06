//
//  ReactionView.h
//  Reaction
//
//  Created by Mokhlas Hussein on 2/3/14.
//
//

#import <UIKit/UIKit.h>
#import "ReactionController.h"

@interface UIWindow ()
+(id)keyWindow;
@end

@interface ReactionView : UIViewController <ReactionControllerDelegate> {
    ReactionController *reaction;
}
+ (void)eventTriggered;
+ (void)dismiss;
@end
