//
//  CategoryViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 07/02/15.
//
//

#import <UIKit/UIKit.h>

@interface CategoryViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
- (IBAction)cat1Tapped:(id)sender;
- (IBAction)cat2Tapped:(id)sender;
- (IBAction)cat3Tapped:(id)sender;
- (IBAction)cat4Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img4;
- (IBAction)selectAllCat:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;
@property (weak, nonatomic) IBOutlet UIImageView *img5;
- (IBAction)cat5Tapped:(id)sender;
- (IBAction)cat6Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img6;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectAll;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *img3;
- (IBAction)cat7Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img7;
- (IBAction)cat8Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img8;
- (IBAction)cat9Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img9;
- (IBAction)cat10Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img12;
@property (weak, nonatomic) IBOutlet UIImageView *img10;
- (IBAction)cat11Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img11;
- (IBAction)cat12Tapped:(id)sender;
- (IBAction)cat13Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img13;
- (IBAction)cat14tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img14;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
- (IBAction)cat15Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img15;
- (IBAction)cat16Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img16;
- (IBAction)cat17Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img17;
- (IBAction)cat18Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img19;
- (IBAction)cat19Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *img18;
- (IBAction)cat20Tapped:(id)sender;
- (IBAction)cat21Tapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnOther;
@property (weak, nonatomic) IBOutlet UIImageView *img21;
@property (weak, nonatomic) IBOutlet UIButton *btnFamily;
@property (weak, nonatomic) IBOutlet UIButton *btnCards;
@property (weak, nonatomic) IBOutlet UIButton *btnWine;
@property (weak, nonatomic) IBOutlet UIButton *btnPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btndance;

@property (weak, nonatomic) IBOutlet UIImageView *img20;
@property (weak, nonatomic) IBOutlet UIButton *btnTheatre;
@property (weak, nonatomic) IBOutlet UIButton *btnMuseum;
@property (weak, nonatomic) IBOutlet UIButton *btnDating;

@property (weak, nonatomic) IBOutlet UIButton *btnTrip;
@property (assign, nonatomic) BOOL isMultiSelect;
@property (weak, nonatomic) IBOutlet UIButton *btnSport;
@property (weak, nonatomic) IBOutlet UIButton *btnCinema;
@property (weak, nonatomic) IBOutlet UIButton *btnBirthday;
@property (weak, nonatomic) IBOutlet UIButton *btnGin;
@property (weak, nonatomic) IBOutlet UIButton *btnIdiom;

@property (weak, nonatomic) IBOutlet UIButton *btnParty;
@property (weak, nonatomic) IBOutlet UIButton *btnBar;
@property (weak, nonatomic) IBOutlet UIButton *btnConcert;
@property (weak, nonatomic) IBOutlet UIButton *btnRestaurant;
@property (weak, nonatomic) IBOutlet UIButton *btnSingle;
@property (weak, nonatomic) IBOutlet UIButton *btnHunt;

@end
