//
//  BYQuickShotView.h
//  QuickShotView
//
//  Created by Dario Lass on 22.03.13.
//  Copyright (c) 2013 Bytolution. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol BYQuickShotViewDelegate <NSObject>

- (void)didTakeSnapshot:(UIImage*)img;
- (void)didDiscardLastImage;

@end

@interface BYQuickShotView : UIView {
    CGPoint offset;
    NSMutableDictionary *plist;
    NSInteger bgColor;
}

@property (nonatomic, strong) id <BYQuickShotViewDelegate> delegate;
@property (nonatomic, assign) BOOL draggable;

-(id)grabPrefColor:(NSInteger)colorBG;
@end
