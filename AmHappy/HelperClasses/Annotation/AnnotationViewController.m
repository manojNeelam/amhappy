//
//  AnnotationViewController.m
//  Snap
//
//  Created by macmini6 on 15/08/13.
//  Copyright (c) 2013 macmini6. All rights reserved.
//

#import "AnnotationViewController.h"


@interface AnnotationViewController ()

@end

@implementation AnnotationViewController
@synthesize coordinate,title,subtitle,image,tagValue,catID,arrayId,eventId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
