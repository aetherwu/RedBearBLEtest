//
//  LTViewController.h
//  ArduinoControl
//
//  Created by Luke Tupper on 6/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@interface LTViewController : UIViewController
{
    BLE *bleShield;
    UIActivityIndicatorView *activityIndicator;
	NSTextStorage *storage;
}

@property (strong, nonatomic) IBOutlet UITextField *textArea;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *incomeText;
@property (strong, nonatomic) IBOutlet UITextView *outPutArea;



@end
