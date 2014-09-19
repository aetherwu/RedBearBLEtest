//
//  LTViewController.m
//  ArduinoControl
//
//  Created by Luke Tupper on 6/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "LTViewController.h"

@interface LTViewController () <BLEDelegate>
{
    NSMutableArray *tableData;
}

@property (nonatomic, strong) BLE *ble;
@property (nonatomic, strong) NSMutableString *bufferStr;

@end

@implementation LTViewController
@synthesize textArea;
@synthesize incomeText;
@synthesize bufferStr;
@synthesize outPutArea;

/*------------
 
 Actions
 
 -------------*/
- (IBAction) sendBtn:(UIButton *)sender {
    //break down the sentence to char
    //send each char with devider
    for (NSInteger charIdx=0; charIdx<textArea.text.length; charIdx++) {
        // Do something with character at index charIdx, for example:
        NSLog(@"SENT: %C", [textArea.text characterAtIndex:charIdx]);
        NSData* data = [[NSString stringWithFormat:@"%c$>", [textArea.text characterAtIndex:charIdx]] dataUsingEncoding: NSUTF8StringEncoding];
        [bleShield write:data];
    }
    NSData* data = [[NSString stringWithFormat:@"\n"] dataUsingEncoding: NSUTF8StringEncoding];
    [bleShield write:data];
    self.textArea.text = @"";
    
}

- (IBAction)BLEShieldScan:(id)sender
{
    if (bleShield.activePeripheral)
        if(bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    
    if (bleShield.peripherals)
        bleShield.peripherals = nil;
    
    [bleShield findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [activityIndicator startAnimating];
    self.navigationItem.leftBarButtonItem.enabled = NO;

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}



/*------------

 Initialize

 -------------*/

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    tableData = [NSMutableArray array];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    bleShield.delegate = self;
    
    self.navigationItem.hidesBackButton = NO;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    
    [self.textArea becomeFirstResponder];

    self.bufferStr = [[NSMutableString alloc] init];
}

- (void) tryToConnectToBLEShield {
    //Check core bluetooth state
    if (self.ble.CM.state != CBCentralManagerStatePoweredOn)
        [self waitAndTryConnectingToBLE]; 
    
    //Check if any periphrals
    if (self.ble.peripherals.count == 0)
        [self.ble findBLEPeripherals:2.0];
    else
        if (! self.ble.activePeripheral)
            [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:0]];

    [self waitAndTryConnectingToBLE];
}


- (void) waitAndTryConnectingToBLE {
    if (self.ble.CM.state != CBCentralManagerStatePoweredOn)
        [self performSelector:@selector(tryToConnectToBLEShield) withObject:nil afterDelay:0.25];
    else
        [self performSelector:@selector(tryToConnectToBLEShield) withObject:nil afterDelay:2.0];
}

- (void) bleDidDisconnect
{
    NSLog(@"bleDidDisconnect");
    
    [self.navigationItem.leftBarButtonItem setTitle:@"Connect"];
    [activityIndicator stopAnimating];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    //[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

-(void) bleDidConnect
{
    [activityIndicator stopAnimating];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [self.navigationItem.leftBarButtonItem setTitle:@"Disconnect"];
    
    NSLog(@"bleDidConnect");
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi {
    //NSLog(@"Did RSSI: %@", rssi);
}

-(void) bleDidReceiveData:(unsigned char *) data length:(int) length {

    NSString* s = [[NSString alloc] initWithBytes:data length:sizeof(data) encoding:NSUTF8StringEncoding];
    NSLog(@"Received Data: %@", s);
    
    
    [self.bufferStr appendString:s];
    if( [self.bufferStr hasSuffix:@"\n"] ) {
    
        [self appendToIncomingText:self.bufferStr];
        [self.bufferStr setString:@""];
    
    }
    
    //append the data to chat window
    
}

// updates the textarea for incoming text by appending text
- (void)appendToIncomingText: (id) text {
	// add the text to the textarea
	NSMutableString *textStorage;
	[textStorage stringByAppendingString:outPutArea.text];
    [textStorage appendString: text];
    outPutArea.text = textStorage;
	
	// scroll to the bottom
	NSRange myRange;
	myRange.length = 1;
	myRange.location = [textStorage length];
	[outPutArea scrollRangeToVisible:myRange];
}


/*------------
 
 Timer
 
 -------------*/

NSTimer *rssiTimer;

-(void) readRSSITimer:(NSTimer *)timer
{
    [bleShield readRSSI];
}

-(void) connectionTimer:(NSTimer *)timer
{
    if(bleShield.peripherals.count > 0)
    {
        [bleShield connectPeripheral:[bleShield.peripherals objectAtIndex:0]];
    }
    else
    {
        [activityIndicator stopAnimating];
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

@end
