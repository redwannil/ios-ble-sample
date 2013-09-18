//
//  ViewController.m
//  blesample
//
//  Created by Akito Tabira on 13/09/18.
//  Copyright (c) 2013 mythosil. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CBCentralManager *centralManager;
@end

@implementation ViewController
@synthesize centralManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    [self startScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startScan
{
    /*
     * Note: If you specify nil for the first parameter, the central manager returns all discovered peripherals, regardless of their supported services. In a real app, you will likely specify an array of CBUUID objects, each of which represents the universally unique identifier (UUID) of a service that a peripheral is advertising. When you specify an array of service UUIDs, the central manager returns only peripherals that advertise those services, allowing you to scan only for devices that you may be interested in.
     */
    NSArray *services = nil;
    NSDictionary *options = nil;
    [centralManager scanForPeripheralsWithServices:services options:options];
}

- (void)stopScan
{
    [centralManager stopScan];
}

#pragma mark - CBCentralManagerDelegate (required)

/*!
 *  @method centralManagerDidUpdateState:
 *
 *  @param central  The central manager whose state has changed.
 *
 *  @discussion     Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
 *                  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code>
 *                  implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
 *                  <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
 *                  manager become invalid and must be retrieved or discovered again.
 *
 *  @see            state
 *
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    CBCentralManagerState state = central.state;
    switch (state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"The current state of the central manager is unknown; an update is imminent.");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"The connection with the system service was momentarily lost; an update is imminent.");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"The platform does not support Bluetooth low energy.");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"The app is not authorized to use Bluetooth low energy.");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"Bluetooth is currently powered off.");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Bluetooth is currently powered on and available to use.");
            break;
        default:
            // non-reach
            break;
    }
}

#pragma mark - CBCentralManagerDelegate (optional)

/*!
 *  @method centralManager:didRetrievePeripherals:
 *
 *  @param central      The central manager providing this information.
 *  @param peripherals  A list of <code>CBPeripheral</code> objects.
 *
 *  @discussion         This method returns the result of a @link retrievePeripherals @/link call, with the peripheral(s) that the central manager was
 *                      able to match to the provided UUID(s).
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    for (CBPeripheral *peripheral in peripherals) {
        NSLog(@"Retrieved Peripheral %@", peripheral.name);
    }
}

/*!
 *  @method centralManager:didRetrieveConnectedPeripherals:
 *
 *  @param central      The central manager providing this information.
 *  @param peripherals  A list of <code>CBPeripheral</code> objects representing all peripherals currently connected to the system.
 *
 *  @discussion         This method returns the result of a @link retrieveConnectedPeripherals @/link call.
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    for (CBPeripheral *peripheral in peripherals) {
        NSLog(@"Retrieved Connected Peripheral %@", peripheral.name);
    }
}

/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @param central              The central manager providing this update.
 *  @param peripheral           A <code>CBPeripheral</code> object.
 *  @param advertisementData    A dictionary containing any advertisement and scan response data.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in decibels.
 *
 *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. Any advertisement/scan response
 *                              data stored in <i>advertisementData</i> can be accessed via the <code>CBAdvertisementData</code> keys. A discovered peripheral must
 *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager.
 *
 *  @seealso                    CBAdvertisementData.h
 *
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@", peripheral.name);
    
    NSDictionary *options = nil;
    [central connectPeripheral:peripheral options:options];
}

/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @discussion         This method is invoked when a connection initiated by @link connectPeripheral:options: @/link has succeeded.
 *
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected %@", peripheral.name);
    
    peripheral.delegate = self;
    
    /*
     * Note: In a real app, you will not likely pass in nil as the parameter, since doing so returns all the services available on a peripheral device. Because a peripheral may contain many more services than you are interested in, discovering all of them may waste battery life and be an unnecessary use of time. More likely, you will specify the UUIDs of the services that you already know you are interested in discovering, as shown in “Explore a Peripheral’s Data Wisely.”
     */
    NSArray *services = nil;
    [peripheral discoverServices:services];
}

/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
 *  @param error        The cause of the failure.
 *
 *  @discussion         This method is invoked when a connection initiated by @link connectPeripheral:options: @/link has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
 *
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect %@", peripheral.name);
}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by @link connectPeripheral:options: @/link. If the disconnection
 *                      was not initiated by @link cancelPeripheralConnection @/link, the cause will be detailed in the <i>error</i> parameter. Once this method has been
 *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Disconnected %@", peripheral.name);
}

#pragma mark - CBPeripheralDelegate (optional)

/*!
 *  @method peripheralDidUpdateName:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link name @/link of <i>peripheral</i> changes.
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0)
{
    /* since iOS6 */
}

/*!
 *  @method peripheralDidInvalidateServices:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed. At this point,
 *						all existing <code>CBService</code> objects are invalidated. Services can be re-discovered via @link discoverServices: @/link.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0)
{
    /* since iOS6 */
}

/*!
 *  @method peripheralDidUpdateRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    
}

/*!
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral	The peripheral providing this information.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *						<i>peripheral</i>'s @link services @/link property.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        
        /*
         * Note: In a real app, you will not likely pass in nil as the first parameter, since doing so returns all the characteristics of a peripheral’s service. Because a peripheral’s service may contain many more characteristics than you are interested in, discovering all of them may waste battery life and be an unnecessary use of time. More likely, you will specify the UUIDs of the characteristics that you already know you are interested in discovering.
         */
        NSArray *characteristics = nil;
        [peripheral discoverCharacteristics:characteristics forService:service];
    }
}

/*!
 *  @method peripheral:didDiscoverIncludedServicesForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the included services.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    
}

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic %@", characteristic);
        
        /*
         * Note: Not all characteristics are guaranteed to have a value that is readable. You can determine whether a characteristic’s value is readable by accessing the CBCharacteristicPropertyRead constant, detailed in CBCharacteristic Class Reference. If you try to read a value that is not readable, the peripheral:didUpdateValueForCharacteristic:error: delegate method returns a suitable error.
         * 
         * Note: Not all characteristics are configured to allow you to subscribe to their values. You can determine whether a characteristic is so configured by accessing the relevant constants in the Characteristic Properties enumeration, detailed in CBCharacteristic Class Reference.
         */
        if (characteristic.isNotifying) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        } else {
            CBCharacteristicProperties properties = characteristic.properties;
            if (properties & CBCharacteristicPropertyRead) {
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
    
    }
}

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData *data = characteristic.value;
    NSLog(@"Value updated %@", data);
}

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Wrote value for %@", characteristic);
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    }
}

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* not using descriptors */
}

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    /* not using descriptors */
}

/*!
 *  @method peripheral:didWriteValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    /* not using descriptors */
}

@end
