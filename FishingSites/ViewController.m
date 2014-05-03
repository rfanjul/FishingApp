//
//  ViewController.m
//  FishingSites
//
//  Created by Ruben Fanjul Estrada on 21/04/14.
//  Copyright (c) 2014 ___QuorraLTD___. All rights reserved.
//

#import "ViewController.h"
#import "MapAnnotation.h"
@interface ViewController ()

@end


@implementation ViewController
{
    CLLocationCoordinate2D touchMapCoordinate;
    UITextField *textField ;
}
@synthesize map,searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.map.delegate = self;
    self.map.mapType = MKMapTypeSatellite;
    self.map.showsUserLocation = YES;

    
    searchBar.delegate = self;
    
    
    [self addGestureRecogniserToMapView];
    [self getPoints];
}
- (void)viewDidAppear{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}


- (IBAction)setMapType:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.map.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.map.mapType = MKMapTypeSatellite;
            break;
        case 2:
            self.map.mapType = MKMapTypeHybrid;
            break;
        default:
            break;
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [theSearchBar resignFirstResponder];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:theSearchBar.text completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        MKCoordinateRegion region;
        region.center.latitude = placemark.region.center.latitude;
        region.center.longitude = placemark.region.center.longitude;
        MKCoordinateSpan span;
        double radius = placemark.region.radius / 1000; // convert to km
        
        NSLog(@"[searchBarSearchButtonClicked] Radius is %f", radius);
        span.latitudeDelta = radius / 112.0;
        
        region.span = span;
        
        [map setRegion:region animated:YES];
    }];
}

/*
 Add a Gesture Recogniser that determines when the user has pressed the map for more than 0.5 seconds
 When that action is detected, call a function to add a pin at that location
 */
- (void)addGestureRecogniserToMapView{
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(addPinToMap:)];
    lpgr.minimumPressDuration = 0.5; //
    [self.map addGestureRecognizer:lpgr];
    
}

/*
 Called from LongPress Gesture Recogniser, convert Screen X+Y to Longitude and Latitude then add a standard Pin at that Location.
 The pin has its Title and SubTitle set to Placeholder text, you can modify this as you wish, a good idea would be to run a Geocoding block and put the street address in the SubTitle.
 */
- (void)addPinToMap:(UIGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.map];
    touchMapCoordinate = [self.map convertPoint:touchPoint toCoordinateFromView:self.map];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Comparte con la comunidad" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Compartir", nil];
    
    
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    /* Display a numerical keypad for this text field */
    textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    
    [alert show];
  
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //cambiar
    NSString *type = @"roca";
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        MapAnnotation *toAdd = [[MapAnnotation alloc]init];
        toAdd.coordinate = touchMapCoordinate;
        toAdd.title = textField.text;
        
        
        NSString * url =  [NSString stringWithFormat: @"latitude=%f&longitude=%f&text=%@&type=%@" , touchMapCoordinate.latitude,touchMapCoordinate.longitude, textField.text,type];
       
        NSData *postData = [url dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://quorra.es/fishingApp/createPoint.php"]]];
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:postData];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        //NSURLRequest *theRequest = [NSURLRequest requestWithURL:createPoint];
        
        if(conn)
        {
            NSLog(@"Connection Successful");
            [self.map addAnnotation:toAdd];
        }
        else
        {
            NSLog(@"Connection could not be made");
        }
        
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data{}



- ( void ) getPoints{

    NSURL * url= [NSURL URLWithString:@"http://www.quorra.es/fishingApp/getPoints.php"];
    
    NSData * data = [NSData dataWithContentsOfURL:url];
    
   NSError * error;
    
    NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    
    NSArray * responseArr = json[@"points"];

    
    for(NSDictionary * dict in responseArr){
        MapAnnotation *temp = [[MapAnnotation alloc]init];
        [temp setTitle:[dict objectForKey:@"text"]];
        [temp setType:[dict objectForKey:@"type"]];
        [temp setCoordinate:CLLocationCoordinate2DMake([[dict valueForKey:@"latitude"]floatValue], [[dict valueForKey:@"longitude"]floatValue])];
        [self.map addAnnotation:temp];
    }

}

@end
