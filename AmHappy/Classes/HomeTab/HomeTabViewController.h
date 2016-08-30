//
//  HomeTabViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HomeTabViewController : UIViewController<UITextFieldDelegate,MKMapViewDelegate,CLLocationManagerDelegate,CustomAlertDelegate, UIGestureRecognizerDelegate>
{
    MKCoordinateRegion region;
    CLLocationCoordinate2D coordinate;
}

@property (weak, nonatomic) IBOutlet UIView *viewFilter;

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

- (IBAction)clickClose:(id)sender;




@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)clickAdd:(id)sender;


@property (weak, nonatomic) IBOutlet UILabel *lblInvitation;
- (IBAction)invitationTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblRequest;
- (IBAction)requestTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
- (IBAction)searchTapped:(id)sender;
- (IBAction)filterTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)filter2Tapped:(id)sender;
- (IBAction)myEventTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblFilter;
@property (weak, nonatomic) IBOutlet UILabel *lblNotificationEvent;
- (IBAction)myLocationTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnFilter;
@property (weak, nonatomic) IBOutlet UILabel *lblMyEvent;
//@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UILabel *lblSearchEvent;
@property (weak, nonatomic) IBOutlet UILabel *lblNotificationFriend;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalNotification;


//Menu
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblUserEmailAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
- (IBAction)toggleMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
- (IBAction)onClickSearchButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *baseMenuView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_BaseMenuView_Horizontal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *const_BaseMenuView_Left;
@property (weak, nonatomic) IBOutlet UIImageView *imgBG;
@property (weak, nonatomic) IBOutlet UIView *leftMenuView;

@property (weak, nonatomic) IBOutlet UIView *leftMenuHolderView;



@end
