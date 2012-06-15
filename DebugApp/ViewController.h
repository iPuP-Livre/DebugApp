//
//  ViewController.h
//  DebugApp
//
//  Created by Marian PAUL on 10/04/12.
//  Copyright (c) 2012 iPuP SARL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController
{
    BOOL _gpsEnabled;
}

@property (nonatomic, retain) NSManagedObjectContext *moc;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)startStopGPS:(id)sender;
- (IBAction)insertCoreDataObjects:(id)sender;
- (IBAction)executeFetchRequest:(id)sender;
- (IBAction)createManyObjects:(id)sender;
- (IBAction)createZombies:(id)sender;

@end
