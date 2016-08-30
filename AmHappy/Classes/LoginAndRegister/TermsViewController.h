//
//  TermsViewController.h
//  AmHappy
//
//  Created by Peerbits 8 on 07/02/15.
//
//

#import <UIKit/UIKit.h>

@interface TermsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
- (IBAction)backTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end
