//
//  RecipeViewCell.h
//  CollectionViewDemo
//
//  Created by Simon on 9/1/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationCellDelegate <NSObject>
@optional
- (void)cancelTapped:(id)sender;
- (void)locTapped:(id)sender;


@end
@interface LocationCell2 : UITableViewCell

@property (nonatomic, strong) id <LocationCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblCellTitle;
- (IBAction)cancelBtnTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
- (IBAction)loocationTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;


@end
