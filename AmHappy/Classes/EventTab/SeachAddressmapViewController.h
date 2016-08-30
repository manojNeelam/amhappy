//
//  SeachBymapViewController.h
//  DubaiExpats
//
//  Created by Peerbits 8 on 21/10/14.
//  Copyright (c) 2014 Peerbits 8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SeachAddressmapViewController : UIViewController<UITextFieldDelegate,MKMapViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate,CustomAlertDelegate,UITableViewDataSource,UITableViewDelegate>
{
      MKCoordinateRegion region;
    CLLocationCoordinate2D coordinate;
}

@property(nonatomic,assign)BOOL isFromAddPromotion;

@property (weak, nonatomic) IBOutlet UIImageView *searchImage2;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtsearch;
@property (weak, nonatomic) IBOutlet UITextField *txtPlace;
@property (weak, nonatomic) IBOutlet MKMapView *mapview;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;
@property (weak, nonatomic) IBOutlet UITableView *locationTable;
- (IBAction)doneTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnDone;
- (id)initWithNibName:(NSString *)nibNameOrNil LoadFlag:(int)loadFlag bundle:(NSBundle *)nibBundleOrNil;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentview;
- (IBAction)locationvalueChanges:(id)sender;

- (IBAction)searchTextChanged:(id)sender;

@end
