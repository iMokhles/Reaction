#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>
#import "ReactionWindow.h"

@interface ReactionAtor : NSObject <LAListener, UIAlertViewDelegate, ReactionWindowDelegate> {
@private
	UIAlertView *av;
    ReactionWindow *reactionWindow;
}
@end

@implementation ReactionAtor

- (BOOL)dismiss {
	// Ensures alert view is dismissed
	// Returns YES if alert was visible previously
	if (reactionWindow) {
		[reactionWindow setHidden:YES];
        reactionWindow = nil;
		return YES;
	}
	return NO;
}

- (void)reactionStarted {
    // start
}
- (void)reactionFinished {
    // delete
    
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	// Called when we recieve event
	if (![self dismiss]) {
        
		reactionWindow = [[ReactionWindow alloc] init];
        [reactionWindow setReactiondelegate:self];
        reactionWindow.userInteractionEnabled = YES;
        //[reactionWindow resignKeyWindow];
        [reactionWindow.Reactiondelegate reactionStarted];
		[event setHandled:YES];
	}
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	// Called when event is escalated to a higher event
	// (short-hold sleep button becomes long-hold shutdown menu, etc)
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
	// Called when some other listener received an event; we should cleanup
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	// Called when the home button is pressed.
	// If (and only if) we are showing UI, we should dismiss it and call setHandled:
	if ([self dismiss])
		[event setHandled:YES];
}

+ (void)load {
	// Register our listener
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.imokhles.ReactionAtor"];
}
/*
- (BOOL)setupWindow {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    if (!self.window) {
        return NO;
    }
    
    [self.window setWindowLevel:UIWindowLevelAlert-2];
    [self.window setAutoresizesSubviews:YES];
    [self.window setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    return YES;
}

- (BOOL)removeWindow {
    if (!self.window) {
        return NO;
    }
    
    if (![self removeBackgroundView]) {
        return NO;
    }
    if (![self removeContentView]) {
        return NO;
    }
    
    [self.window setHidden:YES];
    [self.window release];
    self.window = nil;
    return YES;
}*/
@end
