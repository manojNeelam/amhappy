//
//  Zoomview.h
//  Product Listing
//
//  Created by Peerbits MacMini9 on 16/02/15.
//  Copyright (c) 2015 Peerbits MacMini9. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface Zoomview : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    
     BOOL zoom;
}

@property(nonatomic,strong)NSMutableArray *getted_images;

@property(nonatomic,assign)int selected_index;
@property (retain, nonatomic) NSString *imgUrl;
@property (retain, nonatomic) NSString *message;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;



- (IBAction)click_cancel:(id)sender;


- (IBAction)click_share:(id)sender;

- (IBAction)click_download:(id)sender;



@end
