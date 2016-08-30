//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBVLinkedTextView.h"
#import "DAAttributedLabel.h"

@protocol CommentCell1Delegate <NSObject>
@required

- (void)shareBtnTapped:(id)sender;
- (void)deleteBtnTapped:(id)sender;
- (void)likeBtnTapped:(id)sender;
- (void)reportBtnTapped:(id)sender;
- (void)commentTapped:(id)sender;



@end





@interface CommentList1Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewReply1;

@property (weak, nonatomic) IBOutlet UIView *viewReply2;

@property (weak, nonatomic) IBOutlet UIView *viewReply3;


@property (weak, nonatomic) IBOutlet UIView *viewReply;

@property (weak, nonatomic) IBOutlet UIButton *btnViewAllReply;

@property (weak, nonatomic) IBOutlet UIButton *btnUser1Image;

@property (weak, nonatomic) IBOutlet UIButton *btnUser1Name;

@property (weak, nonatomic) IBOutlet UILabel *lblUser1comment;

@property (weak, nonatomic) IBOutlet UIButton *btnUser2Image;

@property (weak, nonatomic) IBOutlet UIButton *btnUser2Name;

@property (weak, nonatomic) IBOutlet UILabel *lblUser2comment;

@property (weak, nonatomic) IBOutlet UIButton *btnUser3Image;

@property (weak, nonatomic) IBOutlet UIButton *btnUser3Name;

@property (weak, nonatomic) IBOutlet UILabel *lblUser3comment;







@property (weak, nonatomic) IBOutlet DAAttributedLabel *txtComment;


@property (weak, nonatomic) IBOutlet UIButton *btnComment;

@property (weak, nonatomic) IBOutlet UILabel *lblReplies;



@property (weak, nonatomic) IBOutlet UILabel *lblLike;

@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblComment;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;


- (IBAction)shareTapped:(id)sender;

- (IBAction)deleteTapped:(id)sender;

- (IBAction)reportTapped:(id)sender;

- (IBAction)likeTapped:(id)sender;

- (IBAction)commentTapped:(id)sender;

@property (nonatomic, strong) id <CommentCell1Delegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *imgBorder;


@property (weak, nonatomic) IBOutlet UIView *btnView;

@property (weak, nonatomic) IBOutlet UIButton *btnReport;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnshare;



@end
