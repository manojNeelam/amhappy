//
//  ShowImageViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 07/04/15.
//
//

#import "ShowImageViewController.h"

@interface ShowImageViewController ()

@end

@implementation ShowImageViewController
@synthesize imageview,getted_image;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect =CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    //CGRect screenRect = self.imgEvent.frame;
    UIGraphicsBeginImageContext(rect.size);
    [self.getted_image drawInRect:rect];
    // [image drawInRect:screenRect blendMode:kCGBlendModePlusDarker alpha:1];
    UIImage *tmpValue = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageview.image =tmpValue;
   // self.imageview.image =self.getted_image;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backTapped:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];

}

- (IBAction)saveTapped:(id)sender
{
    
    //************
    
    UIImage *screen=self.imageview.image;
    
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[screen CGImage] orientation:(ALAssetOrientation)[screen imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
     {
         if (error) {
             [DELEGATE showalert:self Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
             // TODO: error handling
         } else {
             
             [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Image Saved to Gallery"] AlertFlag:1 ButtonFlag:1];

             // TODO: success handling
         }
     }];
    
   /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"Download sucssesfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];*/
}

- (IBAction)shareTapped:(id)sender
{
    
    //************
    
    UIImage *screen=self.imageview.image;
    
    
    NSData *imageData = UIImageJPEGRepresentation(screen, 1.0);
    
    UIImage *simage=[UIImage imageWithData:imageData];
    
    
    NSArray *postItems;
    
    
    NSString *desc=[NSString stringWithFormat:@""];
    
    
    postItems = @[desc,simage];
    
    // NSString *level = ;
    //  postItems = @[appversion,device,osversion,local,level];
    
    
    
    
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                            initWithActivityItems:postItems
                                            applicationActivities:nil];
    
    
    
    [activityVC setValue:@"AmHappy" forKey:@"subject"];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    //if iPad
    else
    {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        [popup presentPopoverFromRect:CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
    }
}

-(void)ok1BtnTapped:(id)sender
{
    // NSLog(@"ok1BtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
-(void)ok2BtnTapped:(id)sender
{
    // NSLog(@"ok2BtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
-(void)cancelBtnTapped:(id)sender
{
    //NSLog(@"cancelBtnTapped");
    [[self.view viewWithTag:123] removeFromSuperview];
    
}
@end
