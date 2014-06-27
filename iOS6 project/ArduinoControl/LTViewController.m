//
//  LTViewController.m
//  ArduinoControl
//
//  Created by Luke Tupper on 6/07/13.
//  Copyright (c) 2013 Tupps.com. All rights reserved.
//

#import "LTViewController.h"
#import "BLE.h"

@interface LTViewController () <BLEDelegate>

@property (nonatomic, strong) BLE *ble; 

@end

@implementation LTViewController
@synthesize textArea;

/*------------
 
 Actions
 
 -------------*/
- (IBAction) sendBtn:(UIButton *)sender {
    //break down the sentence to char
    //send each char with devider
    for (NSInteger charIdx=0; charIdx<textArea.text.length; charIdx++) {
        // Do something with character at index charIdx, for example:
        NSLog(@"%C", [textArea.text characterAtIndex:charIdx]);
        NSData* data = [[NSString stringWithFormat:@"%c$>", [textArea.text characterAtIndex:charIdx]] dataUsingEncoding: NSUTF8StringEncoding];
        NSLog(@"%@", data);
        [self.ble write:data];
    }
    NSData* data = [[NSString stringWithFormat:@"\n"] dataUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"%@", data);
    [self.ble write:data];
    
}


/*------------

 Initialize

 -------------*/

- (void)viewDidLoad {
    [super viewDidLoad];

    self.ble = [[BLE alloc] init];
    [self.ble controlSetup:1]; //Note the number doesn't seem to do anything!
    self.ble.delegate = self;

    [self tryToConnectToBLEShield];
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
-(void) bleDidConnect {
    NSLog(@"Did Connect");
}

-(void) bleDidDisconnect {
    NSLog(@"Did Disconnect");
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi {
    NSLog(@"Did RSSI: %@", rssi);
}

-(void) bleDidReceiveData:(unsigned char *) data length:(int) length {
    NSLog(@"Did Receive Data");
}


@end
