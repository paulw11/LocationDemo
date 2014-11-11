//
//  AppDelegate.m
//  LocationDemo
//
//  Created by Paul Wilkinson on 3/09/2014.
//  Copyright (c) 2014 Paul Wilkinson. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (strong,nonatomic) CLLocationManager *locationManager;
@property (strong,nonatomic) NSDate *notificationDate;
@property (weak,nonatomic) ViewController *vc;

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.locationManager=[[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate=self;
    self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    self.locationManager.distanceFilter=10;
    //   [self.locationManager startUpdatingLocation];
    if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
        NSLog(@"Using significant location monitoring");
     [self.locationManager startMonitoringSignificantLocationChanges];
    }
    else {
        [self.locationManager startUpdatingLocation];
    }
    
    self.vc=(ViewController *)self.window.rootViewController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ( [CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        [self.locationManager stopUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
        
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    
    NSMutableArray *values=[NSMutableArray new];
    UITableView *tableView;
    
    [tableView beginUpdates];
    
    for (int i=0;i<values.count;i++) {
        NSNumber *number=[values objectAtIndex:i];
        NSInteger val=[number integerValue]-1;
        
        if (val > 0) {
            values[i]=[NSNumber numberWithInteger:val];
            [values setObject:[NSNumber numberWithInteger:val] atIndexedSubscript:i ];
            NSTimer *e;
            [e invalidate];
        }
        else {
            [values removeObjectAtIndex:i];
            [tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - CLLocationManagerDelegate

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc=[locations lastObject];
    self.vc.latLabel.text=[NSString stringWithFormat:@"Latitude: %f",loc.coordinate.latitude];
    self.vc.lonLabel.text=[NSString stringWithFormat:@"Longitude: %f",loc.coordinate.longitude];
    NSLog(@"Location updated");
    UIApplication *app=[UIApplication sharedApplication];
    if (app.applicationState == UIApplicationStateBackground) {
        NSLog(@"We are in the background");
        if (self.notificationDate == nil || [   self.notificationDate timeIntervalSinceNow] < -299) {
            UILocalNotification *notification=[UILocalNotification new];
            notification.alertBody=[NSString stringWithFormat:@"Location updated to %f %f",loc.coordinate.latitude,loc.coordinate.longitude ];
            [app presentLocalNotificationNow:notification];
            self.notificationDate=[NSDate new];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Authorization status is now %d",status);
    NSLog(@"When in use=%d",kCLAuthorizationStatusAuthorizedWhenInUse);
}

-(void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    NSLog(@"Finished deferred updates");
    if (error != nil) {
        NSLog(@"Error = %@",error.localizedDescription);
    }
}


@end
