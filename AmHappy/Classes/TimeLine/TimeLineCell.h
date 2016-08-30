//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeLineCellDelegate <NSObject>
@required

- (void)sharePostTapped:(id)sender;
- (void)deletePostTapped:(id)sender;
- (void)likePostTapped:(id)sender;
- (void)reportPostTapped:(id)sender;
- (void)commentPostTapped:(id)sender;

- (void)profilePostTapped:(id)sender;
- (void)namePostTapped:(id)sender;
- (void)eventPostTapped:(id)sender;
@end

@interface TimeLineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (nonatomic, strong) id <TimeLineCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgComment;
@property (weak, nonatomic) IBOutlet UILabel *lblEventName;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblComment;

@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
- (IBAction)likeTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblCommentCount;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
- (IBAction)commentTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
- (IBAction)reportTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
- (IBAction)shareTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnReport;
- (IBAction)deleteTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
- (IBAction)profileTapped:(id)sender;
- (IBAction)nameTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnEvent;
- (IBAction)eventTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnName;

@property (weak, nonatomic) IBOutlet UILabel *lblCellTitle;


@end
