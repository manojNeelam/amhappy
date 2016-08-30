////
////  Zoomview.m
////  Product Listing
////
////  Created by Peerbits MacMini9 on 16/02/15.
////  Copyright (c) 2015 Peerbits MacMini9. All rights reserved.
////
//
#import "Zoomview.h"
#import "UIImageView+WebCache.h"
//#import <FacebookSDK/FacebookSDK.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface Zoomview ()
{
    UIScrollView *mainScrollView;
    
   
    
    
    
    float minimumScale;
    
    float newScale;
}

@end

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

#define VIEW_FOR_ZOOM_TAG (1)

@implementation Zoomview
{UIImageView *imagelogo;
}
@synthesize getted_images,selected_index,imgUrl,message,imgLogo;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 65,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height-65)];
  
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    
    CGRect innerScrollFrame = mainScrollView.bounds;
    
    for (NSInteger i = 0; i < [getted_images count]; i++)
    {
       UIImageView *imageForZooming= [[UIImageView alloc] initWithImage:[getted_images objectAtIndex:i]];
        
       // UIImageView *imageForZooming= [[UIImageView alloc] init];
        [imageForZooming sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.imgUrl]]];
        
        zoom=YES;
        imageForZooming.tag = VIEW_FOR_ZOOM_TAG;
        
        UIScrollView *pageScrollView = [[UIScrollView alloc]
                                        initWithFrame:innerScrollFrame];
        
        
        
        pageScrollView.minimumZoomScale = 1.0f;
        pageScrollView.maximumZoomScale = 2.0f;
        pageScrollView.zoomScale = 1.0f;
        pageScrollView.contentSize = imageForZooming.bounds.size;
        pageScrollView.delegate = self;
        pageScrollView.showsHorizontalScrollIndicator = NO;
        pageScrollView.showsVerticalScrollIndicator = NO;
        
        
        imageForZooming.frame=CGRectMake(pageScrollView.bounds.origin.x,pageScrollView.bounds.origin.y-35,pageScrollView.bounds.size.width,pageScrollView.bounds.size.height);
        
        
        
        
        
        //******
        
        
 
        [pageScrollView addSubview:imageForZooming];
        
       imageForZooming.layer.masksToBounds=YES;
        imageForZooming.contentMode=UIViewContentModeScaleAspectFit;
        
        minimumScale = [UIScreen mainScreen].bounds.size.width/ imageForZooming.frame.size.width;
        [pageScrollView setMinimumZoomScale:minimumScale];
        [pageScrollView setZoomScale:minimumScale];
        
        [mainScrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width*selected_index,0) animated:YES];
        
        [mainScrollView addSubview:pageScrollView];
        pageScrollView.tag =i+10;
        
        // Add gesture,double tap zoom imageView.
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleDoubleTap:)];
        doubleTapGesture.view.tag=i;
        
        //NSLog(@"%d",doubleTapGesture.view.tag);
        doubleTapGesture.delegate =self;
        
        [doubleTapGesture setNumberOfTapsRequired:2];
        [pageScrollView addGestureRecognizer:doubleTapGesture];
        

        
        if (i < [getted_images count]-1) {
            innerScrollFrame.origin.x += innerScrollFrame.size.width;
        }
        
        
    }
    
    mainScrollView.contentSize = CGSizeMake(innerScrollFrame.origin.x +
                                            innerScrollFrame.size.width, mainScrollView.bounds.size.height);
    
    
    imagelogo= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapIconBlack.png"]];
    imagelogo.frame =CGRectMake(5, mainScrollView.frame.origin.y, 50, 50);

   // [mainScrollView addSubview:imagelogo];
    [imagelogo setHidden:YES];

    [self.view addSubview:mainScrollView];
    [self.view addSubview:imagelogo];
    
    
    // Set Tap Gesture to each image of view
//    for (UIView * view in mainScrollView) {
//       
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
//                                           initWithTarget:self
//                                           action:@selector(guessTapObject:)];
//            tap.numberOfTapsRequired = 1;
//            tap.numberOfTouchesRequired = 1;
//            [view addGestureRecognizer:tap];
//            NSLog(@"tapView: %@", tap.view);
//            NSLog(@"tap: %i", tap.enabled);
//        
//    }
    
      //[mainScrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width*selected_index,0) animated:YES];
    
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Zoom methods


- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    
    //NSLog(@"%d",gestureRecognizer.view.tag);
    UIScrollView *pageScrollView1=(UIScrollView *)[gestureRecognizer view];

    if(pageScrollView1.zoomScale > pageScrollView1.minimumZoomScale)
    {
        [pageScrollView1 setZoomScale:pageScrollView1.minimumZoomScale animated:YES];
    }
    else
    {
        [pageScrollView1 setZoomScale:pageScrollView1.maximumZoomScale animated:YES];
    }
    
}



- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:VIEW_FOR_ZOOM_TAG];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
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

-(int) currentPage
{
    CGFloat pageWidth = mainScrollView.frame.size.width;
    return floor((mainScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (IBAction)click_cancel:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
   // [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)click_share:(id)sender
{
//  // [imagelogo addSubview:self.imgLogo];
//  //  [self.imgLogo setHidden:NO];
//    [imagelogo setHidden:NO];
//
//    if([DELEGATE connectedToNetwork])
//    {
//        
//        //  [drk showWithMessage:nil];
//        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"publish_actions",@"user_friends"]
//                                           allowLoginUI:YES
//                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//                                          
//                                          switch (state) {
//                                              case FBSessionStateOpen:
//                                              {
//                                                  [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
//                                                      if (error) {
//                                                          
//                                                          NSLog(@"error:%@",error);
//                                                          
//                                                          
//                                                      }
//                                                      else
//                                                      {
//                                                          [self callFB:self.message];
//                                                          [FBSession setActiveSession:session];
//                                                          
//                                                      }
//                                                  }];
//                                                  break;
//                                              }
//                                                  
//                                              case FBSessionStateClosed:
//                                              {
//                                                  
//                                              }
//                                              case FBSessionStateClosedLoginFailed:
//                                              {
//                                                  
//                                                  [FBSession.activeSession closeAndClearTokenInformation];
//                                                  break;
//                                              }
//                                                  
//                                              default:
//                                                  break;
//                                          }
//                                          
//                                      } ];
//    }
//    
//    
//
//    
//    
//   /* int pageno=[self currentPage];
//    
//    UIImage *screen=[self.getted_images objectAtIndex:pageno];
//    
//    
//    NSData *imageData = UIImageJPEGRepresentation(screen, 1.0);
//    
//    UIImage *simage=[UIImage imageWithData:imageData];
//    
//    
//    NSArray *postItems;
//    
//    
//    NSString *desc=[NSString stringWithFormat:@"Shared via AmHappy"];
//    
//    
//    postItems = @[desc,simage];
//    
//    
//    UIActivityViewController *activityVC = [[UIActivityViewController alloc]
//                                            initWithActivityItems:postItems
//                                            applicationActivities:nil];
//    
//    
//    
//    [activityVC setValue:@"AmHappy" forKey:@"subject"];
//    
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        [self presentViewController:activityVC animated:YES completion:nil];
//    }
//    //if iPad
//    else
//    {
//        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
//        [popup presentPopoverFromRect:CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUnknown animated:YES];
//    }*/
//    
//   
//    
//

    
    
}
-(void)callFB:(NSString *)text
{
  
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:text forKey:@"message"];
    [params setObject:@"AmHappy" forKey:@"title"];
    [params setObject:UIImagePNGRepresentation([self screenshot]) forKey:@"picture"];
  
    [[[FBSDKGraphRequest alloc]
      initWithGraphPath:@"me/photos"
      parameters:params
      HTTPMethod:@"POST"]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
    {
         if (!error)
         {
             NSLog(@"Post id:%@", result[@"id"]);
         }
         
         if (error)
          {

              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"Error in sharing." delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
              [alert show];
          }
          else
          {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"shared" delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
              [alert show];
          }
     

     }];
    
    
//        [FBRequestConnection startWithGraphPath:@"me/photos"
//                                     parameters:params
//                                     HTTPMethod:@"POST"
//                              completionHandler:^(FBRequestConnection *connection,
//                                                  id result,
//                                                  NSError *error)
//         {
//             if (error)
//             {
//                 
//                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"Error in sharing." delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
//                 [alert show];
//             }
//             else
//             {
//                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AmHappy" message:@"shared" delegate:nil cancelButtonTitle:nil otherButtonTitles:[localization localizedStringForKey:@"Ok"], nil];
//                 [alert show];
//             }
//         }];

    
}
-(UIImage *) screenshot
{
    [NSThread sleepForTimeInterval:2.0];
    
    CGRect rect;
    rect=self.view.bounds;
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context=UIGraphicsGetCurrentContext();
    [mainScrollView.layer renderInContext:context];
    
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imgLogo.hidden=YES;
    
    return image;
}

- (IBAction)click_download:(id)sender
{
    
    //***** get current product index
    
    int pageno=[self currentPage];
    
    //************
    
    UIImage *screen=[self.getted_images objectAtIndex:pageno];
    
    
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
    

}
@end
