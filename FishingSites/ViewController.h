//
//  ViewController.h
//  FishingSites
//
//  Created by Ruben Fanjul Estrada on 21/04/14.
//  Copyright (c) 2014 ___QuorraLTD___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>
{
    
    CLLocationManager *locationManager;
    CLLocation *location;
    float latitude, longitude;
}


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet MKMapView *map;

- (IBAction)setMapType:(id)sender;

@end
