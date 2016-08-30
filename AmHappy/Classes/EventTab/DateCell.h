//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateCellDelegate <NSObject>
@optional
- (void)cancelDateTapped:(id)sender;
@end

@interface DateCell : UITableViewCell

@property (nonatomic, strong) id <DateCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblCellTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UITextField *txtTime;
- (IBAction)cancelTapped:(id)sender;


@end
