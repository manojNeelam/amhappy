//
//  ShowImageViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 07/04/15.
//
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface ShowImageViewController : UIViewController<CustomAlertDelegate>
- (IBAction)backTapped:(id)sender;
- (IBAction)saveTapped:(id)sender;
- (IBAction)shareTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property(nonatomic,strong)UIImage *getted_image;


@end
