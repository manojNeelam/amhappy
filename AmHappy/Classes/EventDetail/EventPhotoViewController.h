//
//  EventPhotoViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/09/15.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface EventPhotoViewController : UIViewController<CustomAlertDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbltitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionview;
@property(strong,nonatomic) NSString *eventID;
@property(strong,nonatomic) NSString *eventName;
@property(strong,nonatomic) NSString *eventUrl;
@property (strong, nonatomic) IBOutlet UILabel *lblEventNameZoomView;





@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@property (weak, nonatomic) IBOutlet UIView *shareSubview;
@property (strong, nonatomic) IBOutlet UIView *shareImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imgShareBig;

- (IBAction)back2Tapped:(id)sender;

- (IBAction)downloadTapped:(id)sender;
- (IBAction)shareTapped:(id)sender;

@end
