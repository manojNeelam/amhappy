//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FriendCellDelegate <NSObject>
@required
- (void)inviteTapped:(id)sender;
- (void)addTapped:(id)sender;
- (void)accerptTapped:(id)sender;

@end


@interface FriendCell : UITableViewCell
@property (nonatomic, strong) id <FriendCellDelegate> delegate;

- (IBAction)addBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
- (IBAction)inviteTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnInvite;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
- (IBAction)acceptBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;



@end
