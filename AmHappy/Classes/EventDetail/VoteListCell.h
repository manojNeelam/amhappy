//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol voteCellDelegate <NSObject>
@optional
- (void)voteBtnTapped:(id)sender;

@end

@interface VoteListCell : UITableViewCell
@property (nonatomic, strong) id <voteCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imvEvent;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblVote;

- (IBAction)voteTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnVote;

@end
