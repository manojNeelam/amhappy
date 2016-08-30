//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FriendCellNewDelegate <NSObject>
@required
- (void)addTapped:(UIButton *)sender;

@end


@interface FriendCellNew : UITableViewCell
@property (nonatomic, strong) id <FriendCellNewDelegate> delegate;

- (IBAction)addBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;



@end
