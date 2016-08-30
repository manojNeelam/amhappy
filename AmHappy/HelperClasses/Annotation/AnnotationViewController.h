//
//  AnnotationViewController.h
//  Snap
//
//  Created by macmini6 on 15/08/13.
//  Copyright (c) 2013 macmini6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface AnnotationViewController : UIViewController<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    UIImage *image;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain)  UIImage *image;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) int tagValue;
@property (nonatomic, assign) int catID;
@property (nonatomic, assign) int arrayId;
@property (nonatomic, assign) int eventId;





@end
