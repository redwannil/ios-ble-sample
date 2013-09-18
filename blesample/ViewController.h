//
//  ViewController.h
//  blesample
//
//  Created by mythosil on 13/09/18.
//  Copyright (c) 2013 mythosil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController
<CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, weak) IBOutlet UITextView *debugView;
@end
