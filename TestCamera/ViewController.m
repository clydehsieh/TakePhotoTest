//
//  ViewController.m
//  TestCamera
//
//  Created by Chin-Hui Hsieh  on 5/7/15.
//  Copyright (c) 2015 Chin-Hui Hsieh. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ViewController2.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *framForCapture;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


AVCaptureStillImageOutput *stillImageOutput;
UIImage *image;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void) viewWillAppear:(BOOL)animated
{

    ///!!!: 建立session
    //建立session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session setSessionPreset:AVCaptureSessionPresetPhoto];
    //建立輸入裝置物件
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //建立儲存錯誤物件
    NSError *error;
    //建立輸入源
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    //將輸入源加入session
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    
    ///!!!: 建立sessionPreview
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    /*  
     AVLayerVideoGravityResize           不考慮畫面比例來fit frame (畫面變形）
     AVLayerVideoGravityResizeAspect     實際畫面,無縮放
     AVLayerVideoGravityResizeAspectFill 實際畫面,同縮放長寬比例來fit fream
     */
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    CGRect frame = self.framForCapture.frame;
    [previewLayer setFrame:frame];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    
    
    ///!!!: Output 建立 AVCaptureStillImageOutput
    stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    //開始影像
    [session startRunning];
    
    
}

- (IBAction)takePhoto:(id)sender
{
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL)
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//            UIImage *image = [UIImage imageWithData:imageData];
            image = [UIImage imageWithData:imageData];
            self.imageView.image = image;
        }
    }];
    
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewController2 *view2 = [segue destinationViewController];
    view2.view2Image = image;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end





