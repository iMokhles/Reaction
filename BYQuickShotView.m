//
//  BYQuickShotView.m
//  QuickShotView
//
//  Created by Dario Lass on 22.03.13.
//  Copyright (c) 2013 Bytolution. All rights reserved.
//

#import "BYQuickShotView.h"
#import <CoreMedia/CoreMedia.h>
#import <QuartzCore/QuartzCore.h>

@interface BYQuickShotView ()

- (void)prepareSession;
- (AVCaptureDevice*)rearCamera;
- (void)captureImage;
- (CGRect)previewLayerFrame;
- (UIImage*)cropImage:(UIImage*)imageToCrop;
- (void)animateFlash;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) UIImageView *imagePreView;

@end

#define PREVIEW_LAYER_INSET 8
#define PREVIEW_LAYER_EDGE_RADIUS 10
#define BUTTON_SIZE 50

@implementation BYQuickShotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareSession];
        self.backgroundColor = [UIColor clearColor];
        self.draggable = NO;
        // UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
        //                                                       initWithTarget:self
        //                                                       action:@selector(handleDoubleTap:)];
        // [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        // [self addGestureRecognizer:doubleTapGestureRecognizer];
    }
    return self;
}

- (UIImageView *)imagePreView
{
    if (!_imagePreView) {
        _imagePreView = [[UIImageView alloc]init];
        _imagePreView.layer.cornerRadius = PREVIEW_LAYER_EDGE_RADIUS - 1;
        _imagePreView.layer.masksToBounds = YES;
        _imagePreView.frame = self.previewLayerFrame;
        _imagePreView.userInteractionEnabled = NO;
        _imagePreView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imagePreView];
    }
    return _imagePreView;
}

- (CGRect)previewLayerFrame
{
    CGRect layerFrame = self.bounds;
    
    layerFrame.origin.x += PREVIEW_LAYER_INSET;
    layerFrame.origin.y += PREVIEW_LAYER_INSET;
    layerFrame.size.width -= PREVIEW_LAYER_INSET * 2;
    layerFrame.size.height -= PREVIEW_LAYER_INSET * 2;
    
    return layerFrame;
}

//This method returns the AVCaptureDevice we want to use as an input for our AVCaptureSession

- (AVCaptureDevice *)rearCamera {
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
        }
    }
    return captureDevice;
}

// if we want to add a shadow without drawing out of bounds we have to slightly resize the AVCaptureVideoPreviewLayer
// and this method returns trhe frame we need to achieve this



- (void)prepareSession
{
    
    NSLog(@"%@", self.captureSession);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //capture session setup
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.rearCamera error:nil];
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey,
                                    nil];
    [newStillImageOutput setOutputSettings:outputSettings];
    
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    
    if ([newCaptureSession canAddOutput:newStillImageOutput]) {
        [newCaptureSession addOutput:newStillImageOutput];
        self.stillImageOutput = newStillImageOutput;
        self.captureSession = newCaptureSession;
    }
    // -startRunning will only return when the session started (-> the camera is then ready)
    dispatch_queue_t layerQ = dispatch_queue_create("layerQ", NULL);
    dispatch_async(layerQ, ^{
        [self.captureSession startRunning];
        AVCaptureVideoPreviewLayer *prevLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        prevLayer.frame = self.previewLayerFrame;
        prevLayer.masksToBounds = YES;
        prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        prevLayer.cornerRadius = PREVIEW_LAYER_EDGE_RADIUS;
        //to make sure were not modifying the UI on a thread other than the main thread, use dispatch_async w/ dispatch_get_main_queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.layer insertSublayer:prevLayer atIndex:0];
        });
    }); 
}

- (void)captureImage
{
    //Before we can take a snapshot, we need to determine the specific connection to be used
    
    NSArray *connections = [self.stillImageOutput connections];
    AVCaptureConnection *stillImageConnection;
    for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) {
				stillImageConnection = connection;
			}
		}
	}
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                           UIImage *capturedImage;
                                                           if (imageDataSampleBuffer != NULL) {
                                                               // as for now we only save the image to the camera roll, but for reusability we should consider implementing a protocol
                                                               // that returns the image to the object using this view
                                                               NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                               capturedImage = [UIImage imageWithData:imgData];
                                                            }
                                                           //UIImage *croppedImg = [self cropImage:capturedImage];
                                                           self.imagePreView.image = capturedImage;
                                                           [self.delegate didTakeSnapshot:capturedImage];
                                                           [self animateFlash];
                                                        }];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch = [touches anyObject];
    offset = [aTouch locationInView: self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.draggable) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.superview];
        [UIView beginAnimations:@"Dragging" context:nil];
        self.frame = CGRectMake(location.x-offset.x, location.y-offset.y, self.frame.size.width, self.frame.size.height);
        [UIView commitAnimations];
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    if (!self.imagePreView.image) {
        [self captureImage];
    } else {
        [self.delegate didDiscardLastImage];
        self.imagePreView.image = nil;
    }
}

- (void)animateFlash {
    UIView *flashView = [[UIView alloc]initWithFrame:self.previewLayerFrame];
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

- (UIImage *)cropImage:(UIImage *)imageToCrop {
    CGSize size = [imageToCrop size];
    int padding = 0;
    int pictureSize;
    int startCroppingPosition;
    if (size.height > size.width) {
        pictureSize = size.width - (2.0 * padding);
        startCroppingPosition = (size.height - pictureSize) / 2.0;
    } else {
        pictureSize = size.height - (2.0 * padding);
        startCroppingPosition = (size.width - pictureSize) / 2.0;
    }
    CGRect cropRect = CGRectMake(startCroppingPosition, padding, pictureSize, pictureSize);
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:imageToCrop.imageOrientation];
    return newImage;
}

- (void)drawRect:(CGRect)rect {
    plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.imokhles.Reaction.plist"];
    bgColor = [((NSNumber*)[plist valueForKey:@"bgColor"]) integerValue];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat minx = CGRectGetMinX(self.previewLayerFrame), midx = CGRectGetMidX(self.previewLayerFrame), maxx = CGRectGetMaxX(self.previewLayerFrame);
    CGFloat miny = CGRectGetMinY(self.previewLayerFrame), midy = CGRectGetMidY(self.previewLayerFrame), maxy = CGRectGetMaxY(self.previewLayerFrame);
    CGContextMoveToPoint(c, minx, midy);
    CGContextAddArcToPoint(c, minx, miny, midx, miny, PREVIEW_LAYER_EDGE_RADIUS);
    CGContextAddArcToPoint(c, maxx, miny, maxx, midy, PREVIEW_LAYER_EDGE_RADIUS);
    CGContextAddArcToPoint(c, maxx, maxy, midx, maxy, PREVIEW_LAYER_EDGE_RADIUS);
    CGContextAddArcToPoint(c, minx, maxy, minx, midy, PREVIEW_LAYER_EDGE_RADIUS); 
    CGContextClosePath(c);
    CGContextSetShadow(c, CGSizeMake(0, 0), 6);
    CGContextSetLineWidth(c, 4);
    CGContextSetStrokeColorWithColor(c, [[self grabPrefColor:bgColor] CGColor]);
    CGContextDrawPath(c, kCGPathFillStroke);
}

-(id)grabPrefColor:(NSInteger)colorBG {
        switch (colorBG) {
                
            case 0:
                return [UIColor whiteColor];
            case 1:
                return [UIColor blueColor];
            case 2:
                return [UIColor greenColor];
            case 3:
                return [UIColor blackColor];
            case 4:
                return [UIColor brownColor];
            case 5:
                return [UIColor purpleColor];
            case 6:
                return [UIColor redColor];
            case 7:
                return [UIColor orangeColor];
            case 8:
                return [UIColor darkGrayColor];
            case 9:
                return [UIColor lightGrayColor];
            case 10:
                return [UIColor grayColor];
            case 11:
                return [UIColor cyanColor];
            case 12:
                return [UIColor yellowColor];
            case 13:
                return [UIColor magentaColor];
            case 14:
                return [UIColor clearColor];
            default:
                return [UIColor whiteColor];
        }
}
@end
