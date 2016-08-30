//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HobbyCellDelegate <NSObject>
@optional
- (void)checkBtnTapped:(id)sender;

@end

@interface HobbyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgHobby;
@property (weak, nonatomic) IBOutlet UILabel *lblHobbyName;
@property (nonatomic, strong) id <HobbyCellDelegate> delegate;


- (IBAction)checkTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btnCheck;

@end
