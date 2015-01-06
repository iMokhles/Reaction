//
//  ReactionView.m
//  Reaction
//
//  Created by Mokhlas Hussein on 2/3/14.
//
//

#import "ReactionView.h"

UIWindow *addWindow;
UIWindow *previousKeyWindow;
ReactionView *sharedInstance;

@interface ReactionView ()
- (void)dismiss;
@end

@implementation ReactionView


+ (void)eventTriggered {
	if (sharedInstance) {
		return;
	}
    
	sharedInstance = [[self alloc] init];
    [sharedInstance.view setFrame:CGRectMake(190, 380, 120, 160)];
	addWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	addWindow.windowLevel = UIWindowLevelAlert - 1.0f;
    
	//previousKeyWindow = UIWindow.keyWindow;
    addWindow.userInteractionEnabled = YES;
    addWindow.hidden                 = NO;
    addWindow.clipsToBounds          = NO;
	[addWindow addSubview:sharedInstance.view];
	[addWindow makeKeyAndVisible];
}

- (void)loadView {
	[super loadView];
    // Do any additional setup after loading the view.
    reaction = [[ReactionController alloc] init];
    [reaction._imageView setImage:nil];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self presentViewController:reaction animated:YES completion:NULL];
}

- (void)dismiss {
	[sharedInstance dismissViewControllerAnimated:YES completion:^{
		[sharedInstance performSelector:@selector(_dismissCompleted) withObject:nil afterDelay:0.35f];
	}];
}

+ (void)dismiss {
	if (!sharedInstance) {
		return;
	}
	[sharedInstance dismiss]; //Back in my day, we could call our own class methods from instance methods...
}

- (void)_dismissCompleted {
	//[previousKeyWindow makeKeyWindow];
	//previousKeyWindow = nil;
    
	addWindow = nil;
    
	sharedInstance = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(BOOL)interfaceOrientation {
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? YES : interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark ReactionControllerDelegate implementation

- (void)reactionFinished {
    //
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
