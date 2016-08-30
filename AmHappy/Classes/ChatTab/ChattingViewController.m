//
//  ChattingViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 09/03/15.
//
//

#import "ChattingViewController.h"

@interface ChattingViewController ()

@end

@implementation ChattingViewController
@synthesize lblTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
