//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InviteCellDelegate <NSObject>
@required

- (void)accerptTapped:(id)sender;
- (void)rejectTapped:(id)sender;


@end


@interface InviteCell : UITableViewCell
@property (nonatomic, strong) id <InviteCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
- (IBAction)acceptBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
- (IBAction)rejectButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnReject;


@end
