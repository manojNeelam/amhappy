//
//  ReplyCell.h
//  
//
//  Created by Peerbits MacMini9 on 28/03/16.
//
//

#import <UIKit/UIKit.h>

#import "DAAttributedLabel.h"

@interface ReplyCell : UITableViewCell
{
    
}

@property (weak, nonatomic) IBOutlet UIImageView *imgUser;

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;

@property (weak, nonatomic) IBOutlet DAAttributedLabel *lblComment;


@property (weak, nonatomic) IBOutlet UIImageView *imgClock;

@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTimeWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblCommentHeight;

@property (weak, nonatomic) IBOutlet UIImageView *imgComment;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgCommentTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgCommentHeight;

@property (weak, nonatomic) IBOutlet UIButton *btnLike;

@property (weak, nonatomic) IBOutlet UIImageView *imgLike;

@property (weak, nonatomic) IBOutlet UILabel *lblLikes;


@end
