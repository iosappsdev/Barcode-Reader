//
//  BCViewController.m
//  barcodeReader
//
//  Created by CtecTeacher on 5/20/14.
//  Copyright (c) 2014 ABC Adult School. All rights reserved.
//

#import "BCViewController.h"

@interface BCViewController ()

@end

@implementation BCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Scan for barcode
    UIBarButtonItem *scan = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(options)];
    self.navigationItem.rightBarButtonItem = scan;
    
    // Do any additional setup after loading the view.
    barCode = @"No Barcode Detected";
    
    highlightView = [[UIView alloc]init];
    highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    highlightView.layer.borderWidth = 3;
    highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:highlightView];
    
    label = [[UILabel alloc]init];
    label.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:.65];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = barCode;
    [self.view addSubview:label];
    
    session = [[AVCaptureSession alloc]init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (input) {
        [session addInput:input];
    } else {
        
        // UIAlertView
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Barcode Scanner" message:[NSString stringWithFormat:@"Error: %@ \n %@",error.localizedDescription, error.localizedRecoveryOptions] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"Error: %@\n%@", error.localizedDescription, error.localizedFailureReason);
    }
    
    output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:output];
    output.metadataObjectTypes = [output availableMetadataObjectTypes];
    
    prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    prevLayer.frame = self.view.bounds;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:prevLayer];
    
    [session startRunning];
    
    [self.view bringSubviewToFront:highlightView];
    [self.view bringSubviewToFront:label];

}
// Options
- (void)options {

    UIActionSheet *options = [[UIActionSheet alloc]initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Disable Torch" otherButtonTitles:@"Save Barcode", nil];
    [options showInView:self.view];
}
// ActionSheet Delegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0: {
            [self torch:NO];
        }
            break;
        case 1: {
            [[self delegate] readBarcode:barCode];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 2:
            NSLog(@"User Cancelled");
            break;
            
        default:
            break;
    }
}
// Enable Torch
- (void)viewWillAppear:(BOOL)animated {
 
    [self torch:YES];
}
// Torch off when we leave View
- (void)viewWillDisappear:(BOOL)animated {
    
    [self torch:NO];
}
// Torch
- (void)torch:(BOOL)isOn {
    
    AVCaptureDevice *torch = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([torch hasTorch]) {
        if (isOn == YES) {

                [torch lockForConfiguration:nil];
                // Use AVCaptureTorchModeOff to turn off
                [torch setTorchMode:AVCaptureTorchModeOn];
                [torch unlockForConfiguration];
        } else {
    
                [torch lockForConfiguration:nil];
                // Use AVCaptureTorchModeOff to turn off
                [torch setTorchMode:AVCaptureTorchModeOff];
                [torch unlockForConfiguration];
            }
        }
}
// Parse Barcode
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode,
                          AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }

        if (detectionString != nil)
        {
            barCode = detectionString;
            label.text = barCode;
            break;
        }
        else
            label.text = @"No Barcode Detected";
    }
    highlightView.frame = highlightViewRect;
}
@end
