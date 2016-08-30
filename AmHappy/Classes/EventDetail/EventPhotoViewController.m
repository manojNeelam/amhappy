//
//  EventPhotoViewController.m
//  AmHappy
//
//  Created by Peerbits 8 on 04/09/15.
//
//

#import "EventPhotoViewController.h"
#import "ModelClass.h"
#import "UIImageView+WebCache.h"
//#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>



#define VIEW_FOR_ZOOM_TAG (1)


@interface EventPhotoViewController ()<FBSDKSharingDelegate>
{
    
    NSMutableDictionary *shareDict;
    
    NSString *imageURL;
    
   
}

@end

@implementation EventPhotoViewController
{
    ModelClass *mc;
    NSMutableArray *imageArray;
}
@synthesize lbltitle,imgProfile,collectionview,eventID,eventName,eventUrl;

@synthesize imgShareBig,bgImage,shareImageView,shareSubview;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    mc =[[ModelClass alloc] init];
    mc.delegate=self;
    imageArray =[[NSMutableArray alloc] init];
    self.lbltitle.text =[NSString stringWithFormat:@"%@",self.eventName];
    [self.lblEventNameZoomView setText:[NSString stringWithFormat:@"%@",self.eventName]];
    
    [self.collectionview registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"GradientCell"];
    
    self.imgProfile.contentMode = UIViewContentModeScaleAspectFill;
    self.imgProfile.layer.masksToBounds =YES;
    self.imgProfile.layer.cornerRadius=18.0;
    
    if(self.eventUrl.length>0)
    {
        [self.imgProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.eventUrl ]] placeholderImage:nil];
    }

    if(DELEGATE.connectedToNetwork)
    {
        [mc getEventPhoto:[USER_DEFAULTS valueForKey:@"userid"] Eventid:[NSString stringWithFormat:@"%@",self.eventID] Sel:@selector(responseGetPhotos:)];
    }
}
-(void)responseGetPhotos:(NSDictionary *)results
{
    NSLog(@"result is %@",results);
    
    if ([[NSString stringWithFormat:@"%@",[results valueForKey:@"code"]] isEqualToString:@"200"])
    {
        
        shareDict = [[NSMutableDictionary alloc]initWithDictionary:[results valueForKey:@"Event"]];
        
        [imageArray addObjectsFromArray:[results valueForKey:@"Images"]];
        
        [self.collectionview reloadData];
    }
    else
    {
        [DELEGATE showalert:self Message:[results valueForKey:@"message"] AlertFlag:1 ButtonFlag:1];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
  
        return 1;
   }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
   return [imageArray count];
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // static NSString *identifier = @"DashBoardCell";
    
    /* DashBoardCell *cell = (DashBoardCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];*/
    
    
    UICollectionViewCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:@"GradientCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    cell.tag = indexPath.row;
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    for(UIImageView *img in [cell subviews])
    {
        if([img isKindOfClass:[UIImageView class]])
        {
            //  img.image =nil;
            [img removeFromSuperview];
        }
        
    }
    float size =(self.view.frame.size.width-40)/3;

    UIImageView *imageview =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    
    [imageview.layer setBorderColor: [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor];
    [imageview.layer setBorderWidth: 1.0];
    
    [imageview sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[imageArray objectAtIndex:indexPath.row] ]] placeholderImage:nil];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.clipsToBounds = YES;
    [cell addSubview:imageview];
    [cell setUserInteractionEnabled:YES];
    
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    float size =(self.view.frame.size.width-40)/3;
    return CGSizeMake(size, size);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
    
}


#pragma mark - UICollectionView Delegate

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.shareImageView.hidden=NO;
    
    imageURL = [imageArray objectAtIndex:indexPath.row];
    
    [self.imgShareBig sd_setImageWithURL:[NSURL URLWithString:[imageArray objectAtIndex:indexPath.row]]];
    [self.imgShareBig setHidden:YES];
    [self addZoomView:[imageArray objectAtIndex:indexPath.row] ];
}
-(void)addZoomView:(NSString *)showImageUrl
{
    BOOL zoom;
    int selected_index;
    
    float minimumScale;
    
    [[self.shareSubview viewWithTag:899] removeFromSuperview];
    
    
    NSArray *getted_images =[[NSArray alloc] initWithObjects:self.bgImage.image, nil];
    
    UIScrollView * mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,self.shareSubview.frame.size.height)];
    
    mainScrollView.pagingEnabled = YES;
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = NO;
    mainScrollView.tag=899;
    
    CGRect innerScrollFrame = CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width,self.shareSubview.frame.size.height);
    
    for (NSInteger i = 0; i < [getted_images count]; i++)
    {
        UIImageView *imageForZooming= [[UIImageView alloc] initWithImage:[getted_images objectAtIndex:i]];
        // UIImageView *imageForZooming= [[UIImageView alloc] initWithImage:showImage];
        
        // UIImageView *imageForZooming= [[UIImageView alloc] init];
        [imageForZooming sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",showImageUrl]]];
        
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
        
        
        imageForZooming.frame=CGRectMake(pageScrollView.bounds.origin.x,pageScrollView.bounds.origin.y,pageScrollView.bounds.size.width,pageScrollView.bounds.size.height);
        
        
        
        
        
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
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleDoubleTap:)];
        doubleTapGesture.view.tag=i;
        
        doubleTapGesture.delegate =self;
        
        [doubleTapGesture setNumberOfTapsRequired:2];
        [pageScrollView addGestureRecognizer:doubleTapGesture];
        
        if (i < [getted_images count]-1) {
            innerScrollFrame.origin.x += innerScrollFrame.size.width;
        }
        
        
    }
    
    mainScrollView.contentSize = CGSizeMake(self.shareSubview.frame.size.width, mainScrollView.bounds.size.height);
    
    [self.shareSubview addSubview:mainScrollView];
    
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:VIEW_FOR_ZOOM_TAG];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}


- (IBAction)back2Tapped:(id)sender
{
    self.shareImageView.hidden=YES;
    self.imgShareBig.image=nil;
}

- (IBAction)downloadTapped:(id)sender
{
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[self.imgShareBig.image CGImage] orientation:(ALAssetOrientation)[self.imgShareBig.image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error)
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


-(void)shareEvent
{
    
    
    NSMutableDictionary *properties = [@{
                                         @"og:type": @"amhappyapp:event",
                                         @"og:title": self.lbltitle.text,
                                         @"og:description": [[shareDict valueForKey:@"type"]isEqualToString:@"Private"] ? [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[shareDict valueForKey:@"location"]] : [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[shareDict valueForKey:@"location"]],
                                         
                                         @"og:url": DeepLinkUrl,
                                         
                                         
                                         }mutableCopy];
    
    
    if(imageURL.length>0)
    {
        
        FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:[[NSURL alloc]initWithString:imageURL] userGenerated:NO];
        // photo.image = self.imgEvent.image;
        [properties setObject:@[photo] forKey:@"og:image"];
        
        
        
    }
    else
    {
        
        FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImageURL:[[NSURL alloc]initWithString:Icon_PATH] userGenerated:NO];
        UIImage *img = [[UIImage alloc]init];
        img = [UIImage imageNamed:@"iconBlack"];
        //photo.image = img;
        [properties setObject:@[photo] forKey:@"og:image"];
        
    }
    
    
    
    
    FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
    
    
    
    FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
    action.actionType = @"amhappyapp:share";
    [action setObject:object forKey:@"event"];
    [action setString:@"true" forKey:@"fb:explicitly_shared"];
    //[action setObject:@"www.apple.com" forKey:@"link"];
    
    
    
    
    
    FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
    
    
    content.action = action;
    content.previewPropertyName = @"event";
    
    
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.fromViewController = self;
    shareDialog.shareContent = content;
    shareDialog.delegate = self;
    
    
    NSError * error = nil;
    BOOL validation = [shareDialog validateWithError:&error];
    if (validation)
    {
        [shareDialog show];
    }
    else
    {
        
        NSLog(@"%@",error);
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Facebook App is not installed."] AlertFlag:1 ButtonFlag:1];
    }
    
}



#pragma mark - FBSDKSharingDelegate

- (void) sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    
    NSLog(@"Facebook sharing completed: %@", results);
    
    //[[[UIAlertView alloc]initWithTitle:nil message:@"Successfully Posted!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show ];
    
    
}

- (void) sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
    NSLog(@"Facebook sharing failed: %@", error);
    
    // [[[UIAlertView alloc]initWithTitle:nil message:@"Failed posting!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show ];
}

- (void) sharerDidCancel:(id<FBSDKSharing>)sharer {
    
    NSLog(@"Facebook sharing cancelled.");
    
    //[[[UIAlertView alloc]initWithTitle:nil message:@"Cancel posting!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show ];
}


-(void)shareComom:(NSDictionary *)dict ShareFlag:(int)shareFlag
{

    if(DELEGATE.connectedToNetwork)
    {
        if(shareFlag==1)
        {
 
            
            [self shareEvent];
            
            /* id<FBGraphObject> object =
             [FBGraphObject openGraphObjectForPostWithType:@"amhappytest:event"
             title:@"Sample event"
             image:nil
             url:@"http://www.apple.com" // fb.me app links hosted url here
             description:@"desc"];*/
            
            /*   NSString *html = [self htmlWithMetaTags:@[
             @{
             @"al:ios": [NSNull null],
             @"al:ios:url":@"https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app/972366090",
             @"al:ios:app_name": @"AmHappy",
             @"al:ios:app_store_id": @"972366090"
             }
             ]];*/
            
            
            
            // NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
            
//            
//            
//            NSMutableDictionary <FBOpenGraphObject> *object =  [FBGraphObject openGraphObjectForPostWithType:@"amhappyapp:event"
//                                                                                                       title:@"testing title"
//                                                                                                       image:nil
//                                                                                                         url:DeepLinkUrl
//                                                                                                 description:@""];
//            object.provisionedForPost = YES;
//            object[@"title"] = self.lbltitle.text;
//            object[@"type"] = @"amhappyapp:event";
//            
//            //object[@"link"] = @"https://fb.me/1600227070237260";
//            
//            // object[@"link"] = @"AmHappy://";
//            
//            object[@"link"] = @"www.apple.com";
//            
//             
//            if(imageURL.length>0)
//            {
//                object[@"image"] = @[
//                                     @{@"url": imageURL, @"user_generated" : @"false" }
//                                     ];
//            }
//            else
//            {
//                object[@"image"] = @[
//                                     @{@"url": Icon_PATH, @"user_generated" : @"false" }
//                                     ];
//            }
//            
//            if([[shareDict valueForKey:@"type"]isEqualToString:@"Private"])
//            {
//                object[@"description"] = [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[shareDict valueForKey:@"location"]];
//            }
//            else
//            {
//                object[@"description"] = [NSString stringWithFormat:@"%@ on %@ at %@",[shareDict valueForKey:@"description"],[self getDate1:[shareDict valueForKey:@"date"]],[shareDict valueForKey:@"location"]];
//                
//            }
//            
//            
//            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>) [FBGraphObject graphObject];
//            [action setObject:object forKey:@"event"];
//            //[action setObject:@"AmHappy://" forKey:@"link"];
//            [action setObject:@"www.apple.com" forKey:@"link"];
//            
//            FBOpenGraphActionParams *actionParam =[[FBOpenGraphActionParams alloc] init];
//            actionParam.actionType =@"amhappyapp:share";
//            actionParam.previewPropertyName = @"event";
//            actionParam.action =action;
//            
//            if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:actionParam]) {
//                // Show the share dialog
//                [FBDialogs presentShareDialogWithOpenGraphAction:action
//                                                      actionType:@"amhappyapp:share"
//                                             previewPropertyName:@"event"
//                                                         handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                                             if(error) {
//                                                                 // An error occurred, we need to handle the error
//                                                                 // See: https://developers.facebook.com/docs/ios/errors
//                                                                 NSLog(@"Error publishing story: %@", error.localizedDescription);
//                                                                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Error occured while sharing"] AlertFlag:1 ButtonFlag:1];
//                                                             } else {
//                                                                 // Success
//                                                                 NSLog(@"result %@", results);
//                                                             }
//                                                         }];
//            }
//            else
//            {
//                NSLog(@"can not open");
//            }
            
        }
        
        
    }
    
    
}


-(NSString *)getDate1:(NSString *)str
{
    NSTimeInterval _interval=[str doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSLog(@"%@", date);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    // To parse the Date "Sun Jul 17 07:48:34 +0000 2011", you'd need a Format like so:
    
    //9 fer 2015
    //EEE MMM dd HH:mm:ss ZZZ yyyy
    
    
    //en: en English
    //es: es español
    //zh-Hant: zh-Hant 中文（繁體字）
    if([USER_DEFAULTS valueForKey:@"localization"])
    {
        if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"S"])
        {
            [localization setLanguage:@"SP"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"es"]];
            
        }
        else if([[USER_DEFAULTS valueForKey:@"localization"] isEqualToString:@"C"])
        {
            [localization setLanguage:@"CH"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hant"]];
            
        }
        else
        {
            [localization setLanguage:@"EN"];
            [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
            
        }
    }
    else
    {
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
        
    }
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"%@",formattedDate];
}

- (IBAction)shareTapped:(id)sender
{
    
     [self shareComom:shareDict ShareFlag:1];
    
    
}
@end
