//
//  MapAnnotation.h
//  FishingSites
//
//  Created by Ruben Fanjul Estrada on 02/05/14.
//  Copyright (c) 2014 ___QuorraLTD___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>{
    
    NSString *title;
    CLLocationCoordinate2D coordinate;
}

// This is the title that the mark is going to has inside the map
@property (nonatomic, copy) NSString * title;

// This is the type of this item, fish, whole, waves, rock,....
@property (nonatomic, copy) NSString * type;

@property (nonatomic, assign)CLLocationCoordinate2D coordinate;


@end