//
//  LTViewController.h
//  ArduinoControl
//
//  Created by Luke Tupper on 6/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTViewController : UIViewController

- (IBAction) sendBtn:(id)sender;

@property (strong, nonatomic) IBOutlet UITextField *textArea;


@end
