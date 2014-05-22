//
//  ViewController.m
//  barcodeReader
//
//  Created by CtecTeacher on 5/20/14.
//  Copyright (c) 2014 ABC Adult School. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController
@synthesize barcodeOutput, BCView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Set Title
    self.title = @"Barcode Scanner";
    //Set Default
    barcodeOutput.text = @"Awaiting Input...";
}

- (void)viewWillAppear:(BOOL)animated {
    
    
}

- (void)readBarcode:(NSString *)barcodeString {
    
    barcodeOutput.text = barcodeString;
    NSLog(@"Delegate Method Called");
}

- (IBAction)scanBarcode:(id)sender {
    
    BCViewController *bcVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BCViewController"];
    self.BCView = bcVC;
    [BCView setDelegate:self];
    
    [self.navigationController pushViewController:bcVC animated:YES];
}

@end
