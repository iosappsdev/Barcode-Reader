//
//  ViewController.h
//  barcodeReader
//
//  Created by CtecTeacher on 5/20/14.
//  Copyright (c) 2014 ABC Adult School. All rights reserved.
//

#import <UIKit/UIKit.h>
// Import Second ViewController
#import "BCViewController.h"

@interface ViewController : UIViewController<BCViewControllerDelegate>

@property (nonatomic,strong) BCViewController *BCView;
@property (weak, nonatomic) IBOutlet UILabel *barcodeOutput;

- (IBAction)scanBarcode:(id)sender;

@end
