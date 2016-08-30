//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LocationCellDelegate <NSObject>
@optional
- (void)cancelTapped:(id)sender;
- (void)locTapped:(id)sender;


@end

@interface LocationCell : UITableViewCell
@property (nonatomic, strong) id <LocationCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblCellTitle;
- (IBAction)cancelBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
- (IBAction)loocationTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;

@end
