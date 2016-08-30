//
//  SeachBymapViewController.m
//  DubaiExpats
//
//  Created by Peerbits 8 on 21/10/14.
//  Copyright (c) 2014 Peerbits 8. All rights reserved.
//

#import "SeachAddressmapViewController.h"
#import "ModelClass.h"
#import "TYMActivityIndicatorViewViewController.h"
#import "AnnotationViewController.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kGeoCodingString @"http://maps.google.com/maps/geo?q=%f,%f&output=csv"
#import "SBJson.h"
#import "Toast+UIView.h"
//#import "SBJson.h"



@interface SeachAddressmapViewController ()

@end

@implementation SeachAddressmapViewController
{
    ModelClass *mc;
    NSUserDefaults *defaults;
    NSMutableArray *postArray;
    int start;
    TYMActivityIndicatorViewViewController *drk;
    NSMutableDictionary *addressDict;
    int loadTag;
    
    float lat ;
    float lon ;
    
    BOOL isSelected;
    UIToolbar *mytoolbar1;
    NSMutableArray *autocompleteUrls;

}
@synthesize lblTitle,mapview,txtsearch,searchImage,btnDone,segmentview,locationTable,searchImage2,txtPlace,isFromAddPromotion;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        loadTag = -1;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil LoadFlag:(int)loadFlag bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        loadTag =loadFlag;
    }
    return self;
}
-(void)findCurrentLocation
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    if(DELEGATE.connectedToNetwork)
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
        [geocoder reverseGeocodeLocation:DELEGATE.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if (!(error))
             {
                 [drk hide];
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 NSLog(@"\nCurrent Location Detected\n");
                 NSLog(@"placemark %@",placemark);
                 NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                 NSString *Address = [[NSString alloc]initWithString:locatedAt];
                 NSString *Area = [[NSString alloc]initWithString:placemark.locality];
                 NSString *Country = [[NSString alloc]initWithString:placemark.country];
                 NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
                 NSLog(@"%@",CountryArea);
                 
                 if(placemark.thoroughfare )
                 {
                     Address =[placemark thoroughfare];
                     
                 }
                 else
                 {
                     Address =@"";
                 }
                 if(placemark.locality )
                 {
                     Area =[placemark locality];
                     
                 }
                 else
                 {
                     Area =@"";
                 }
                 if(placemark.administrativeArea)
                 {
                     Country =[placemark administrativeArea];
                     
                 }
                 else
                 {
                     Country =@"";
                 }
                 if(placemark.country )
                 {
                     CountryArea =[placemark country];
                     
                 }
                 else
                 {
                     CountryArea =@"";
                 }
            
                 [self.txtsearch setText:[NSString stringWithFormat:@"%@ %@ %@ %@",Address,Area,Country,CountryArea]];
             }
             else
             {
                 [drk hide];
                 NSLog(@"Geocode failed with error %@", error);
                 NSLog(@"\nCurrent Location Not Detected\n");
                 //return;
                 //  CountryArea = NULL;
                 
                 [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Could not get your location due to slow network"] AlertFlag:1 ButtonFlag:1];
                 
                 /* UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"Could not get address"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
                  [alert show];*/
             }
             /*---- For more results
              placemark.region);
              placemark.country);
              placemark.locality);
              placemark.name);
              placemark.ocean);
              placemark.postalCode);
              placemark.subLocality);
              placemark.location);
              ------*/
         }];
        
    }
    else
    {
        [drk hide];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    self.mapview.delegate =self;
    mc =[[ModelClass alloc] init];
    [mc setDelegate:self];
    defaults =[NSUserDefaults standardUserDefaults];
    postArray =[[NSMutableArray alloc] init];
    autocompleteUrls =[[NSMutableArray alloc] init];

    addressDict =[[NSMutableDictionary alloc] init];
    [self.lblTitle setFont:FONT_Regular(22)];
    [self.mapview showsUserLocation];
    [self.mapview setCenterCoordinate:self.mapview.userLocation.location.coordinate animated:YES];

    [self performSelector:@selector(callMAp) withObject:nil afterDelay:2.0];
    start =0;
    self.txtsearch.delegate =self;
    self.txtPlace.delegate =self;

    self.searchImage.layer.masksToBounds = YES;
    self.searchImage.layer.cornerRadius = 3.0;
    self.searchImage.layer.borderWidth =1.2;
    self.searchImage.layer.borderColor =[[UIColor lightGrayColor] CGColor];
    
    self.searchImage2.layer.masksToBounds = YES;
    self.searchImage2.layer.cornerRadius = 3.0;
    self.searchImage2.layer.borderWidth =1.2;
    self.searchImage2.layer.borderColor =[[UIColor lightGrayColor] CGColor];
    
    mytoolbar1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    mytoolbar1.barStyle = UIBarStyleBlackOpaque;
    if(IS_OS_7_OR_LATER)
    {
        mytoolbar1.barTintColor=[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    else
    {
        mytoolbar1.tintColor=[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/255.0 alpha:1.0];
    }
    
    
    UIBarButtonItem *done1 = [[UIBarButtonItem alloc] initWithTitle:[localization localizedStringForKey:@"Done"]
                                                              style:UIBarButtonItemStyleBordered
                                                             target:self action:@selector(donePressed)];
    [done1 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    mytoolbar1.items = [NSArray arrayWithObjects:flexibleSpace,done1, nil];
    self.txtsearch.inputAccessoryView =mytoolbar1;
    self.txtPlace.inputAccessoryView =mytoolbar1;

  
    
   UILongPressGestureRecognizer *tgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    tgr.minimumPressDuration = 1.0f;
    tgr.delegate =self;
    
    [self.mapview addGestureRecognizer:tgr];
    
    lat =DELEGATE.locationManager.location.coordinate.latitude;
    lon =DELEGATE.locationManager.location.coordinate.longitude;
  //  [self findCurrentLocation];
 
    
}
-(void)callMAp
{
    [self zoomToFitMapAnnotations:self.mapview ];

}
-(void)viewWillAppear:(BOOL)animated
{
    [self localize];
}
-(void)localize
{
   // [self.txtsearch setPlaceholder:[localization localizedStringForKey:@"Search place in your location"]];
    
    [self.txtsearch setPlaceholder:[localization localizedStringForKey:@"Country, city, street"]];
    [self.txtPlace setPlaceholder:[localization localizedStringForKey:@"Type or name of place"]];


    [self.btnDone setTitle:[localization localizedStringForKey:@"Done"] forState:UIControlStateNormal];
    [self.lblTitle setText:[localization localizedStringForKey:@"Location"]];
    
}
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    [self.mapview removeAnnotations:self.mapview.annotations];
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapview];
    coordinate = [self.mapview convertPoint:touchPoint toCoordinateFromView:self.mapview];
  //  NSLog(@"latitude  %f longitude %f",coordinate.latitude,coordinate.longitude);
    [addressDict setValue:[NSString stringWithFormat:@"%f",coordinate.latitude] forKey:@"lat"];
    [addressDict setValue:[NSString stringWithFormat:@"%f",coordinate.longitude] forKey:@"long"];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self getAddressFromLatLon:loc];
   // [self getAddressFromLatLon:coordinate.latitude withLongitude:coordinate.longitude];
  //  CLLocation *locations;
    
    
}
-(void)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude
{
    NSString *urlString = [NSString stringWithFormat:kGeoCodingString,pdblLatitude, pdblLongitude];
    NSError* error;
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSASCIIStringEncoding error:&error];
    locationString = [locationString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSLog(@"locationString is %@",locationString) ;
}
-(void)getAddressFromLatLon:(CLLocation*) location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         [self.mapview removeAnnotations:self.mapview.annotations];
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *placemark= [placemarks objectAtIndex:0];
             // address defined in .h file
             
             NSLog(@"%@",placemark);
             NSString *address = [NSString stringWithFormat:@"%@ , %@ , %@, %@", [placemark thoroughfare], [placemark locality], [placemark administrativeArea], [placemark country]];
          //   NSLog(@"New Address Is:%@", address);
             CLLocationCoordinate2D placeCoord;
             
             //Set the lat and long.
             placeCoord.latitude=location.coordinate.latitude;
             placeCoord.longitude=location.coordinate.longitude;
             
             AnnotationViewController    *ann1 = [[AnnotationViewController alloc] init];
             ann1.title = [placemark thoroughfare];
             ann1.subtitle = address;
             ann1.coordinate=placeCoord;
             region.center.latitude =ann1.coordinate.latitude;
             region.center.longitude =ann1.coordinate.longitude;
             
             lat =ann1.coordinate.latitude;
             lon =ann1.coordinate.longitude;

             // region.span.longitudeDelta = 0.01;
             // region.span.latitudeDelta = 0.01;
             
             [self.mapview addAnnotation:ann1];
             [self.mapview setRegion:region animated:YES];
             [self.mapview setCenterCoordinate:region.center animated:YES];
             
             [addressDict setValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forKey:@"lat"];
             [addressDict setValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forKey:@"long"];
             [addressDict setValue:[NSString stringWithFormat:@"%@ ",address] forKey:@"addressstr"];
             if(self.txtsearch.text.length>0)
             {
                 if(self.segmentview.selectedSegmentIndex==1)
                 {
                   //  [self searchMap2:self.txtsearch.text];
                 }
                 
             }


             
         }
     }];
    [drk hide];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[MKPinAnnotationView class]])
    {
        return NO;
    }
    return YES;
}

-(void)donePressed
{
    [self.view endEditing:YES];
    
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    }];
    
    return [super canPerformAction:action withSender:sender];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text =@"";
    if(textField==self.txtPlace)
    {
        [self.segmentview setSelectedSegmentIndex:1];
    }
    else
    {
        [self.segmentview setSelectedSegmentIndex:0];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
   // [self.view endEditing:YES];
    [self.mapview setUserInteractionEnabled:YES];

    if(textField==self.txtPlace)
    {
       
        if([self.txtsearch.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >0)
        {
            if(segmentview.selectedSegmentIndex==0)
            {
                if(DELEGATE.connectedToNetwork)
                {
                    // [self getLocationFromAddressString:textField.text];
                }
                
            }
            else
            {
                if(DELEGATE.connectedToNetwork)
                {
                    [self searchMap2:textField.text];
                    
                }
                
            }
        }
        else
        {
            [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Please select location before place"] AlertFlag:1 ButtonFlag:1];
        }
    }
    else
    {
         self.locationTable.hidden = YES;
        [self.mapview removeAnnotations:self.mapview.annotations];
        [self.mapview setUserInteractionEnabled:YES];
        [self getLocationFromAddressString:self.txtsearch.text];
    }

   
    
}
-(void) getLocationFromAddressString: (NSString*) addressStr {
    
    NSString *esc_addr =  [addressStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];

    NSURL *googleRequestURL=[NSURL URLWithString:req];
    if(DELEGATE.connectedToNetwork)
    {
       [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
        dispatch_async(kBgQueue, ^{
            NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
            [self performSelectorOnMainThread:@selector(fetchedData2:) withObject:data waitUntilDone:YES];
        });
    }
  
    
}
-(void)searchMap2:(NSString *)searchAddress
{
    
 //  https://maps.googleapis.com/maps/api/place/search/json?location=40.3324899,-3.8651444&radius=5000&name=Pub&key=AIzaSyCh7ifg1VJWh-ZpHtv-cdQ-Bfa7DUR0XSU
    
 //   NSString *url =@"https://maps.googleapis.com/maps/api/place/search/json?location=40.3324899,-3.8651444&radius=5000&name=Pub&key=AIzaSyCh7ifg1VJWh-ZpHtv-cdQ-Bfa7DUR0XSU";
    
    NSString *url = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=5000&name=%@&key=%@",lat,lon,searchAddress,PlaceApiKey]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // NSLog(@"url is %@",url);
    
    
    
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];

    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}
-(void)searchMap:(NSString *)searchAddress
{
    //https://maps.googleapis.com/maps/api/place/search/json?location=-33.8670522,151.1957362&radius=500&types=grocery_or_supermarket&sensor=true&key=AIzaSyAiFpFd85eMtfbvmVNEYuNds5TEF9FjIPI
    
    if([DELEGATE connectedToNetwork])
    {
        NSArray *array1 =[[NSArray alloc] initWithArray:self.mapview.annotations];
        if(array1.count >0)
        {
            [self.mapview removeAnnotations:array1];
            
        }
        
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
        [self queryGooglePlaces:searchAddress];
        // self.txtSearch.text = @"";
        
    }
    
    
    
    
}
-(void) queryGooglePlaces:(NSString *)addressStr {
    
    
    
   lat =DELEGATE.locationManager.location.coordinate.latitude;
    lon =DELEGATE.locationManager.location.coordinate.longitude;
    if(lat==0)
    {
        lat =23.03000;
    }
    if(lon==0)
    {
        lon =72.58;
    }
    
    
    // NSString *url = [[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&&sensor=true&key=%@&name=%@", lat, lon, kGOOGLE_API_KEY,addressStr]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = [[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", addressStr]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
   // NSLog(@"url is %@",url);
    
    
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
}
- (void)fetchedData:(NSData *)responseData {
    NSError* error;
     if(responseData)
     {
         NSDictionary* json = [NSJSONSerialization
                               JSONObjectWithData:responseData
                               
                               options:kNilOptions
                               error:&error];
         
         
         
         
         NSArray* places = [json objectForKey:@"results"];
         
         //[self plotPositions:places];
         [self plotPositions2:places];
     }
    else
    {
        [drk hide];
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
       /* UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"No result found"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
        [alert show];*/
    }
    
}
- (void)fetchedData2:(NSData *)responseData {
    NSError* error;
    if(responseData)
    {
        
        NSLog(@"%@",responseData);
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              
                              options:kNilOptions
                              error:&error];
        
        
        
        
        NSArray* places = [json objectForKey:@"results"];
        
        [self plotPositions:places];
        //[self plotPositions2:places];
    }
    else
    {
        [drk hide];
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
       /* UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"No result found"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
        [alert show];*/
    }
    
}
- (void)plotPositions2:(NSArray *)data
{
    if(data.count>0)
    {
        [self.mapview removeAnnotations:self.mapview.annotations];

        
        for (int i=0; i<[data count]; i++)
        {
            
            NSDictionary* place = [data objectAtIndex:i];
            NSDictionary *geo = [place objectForKey:@"geometry"];
            
            NSString *name;
           
                name=[place objectForKey:@"name"];
                
            
            NSString *vicinity=[place objectForKey:@"vicinity"];
            
            NSDictionary *loc = [geo objectForKey:@"location"];
            
            CLLocationCoordinate2D placeCoord;
            
            placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
            placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
            
            
            AnnotationViewController    *ann1 = [[AnnotationViewController alloc] init];
            ann1.title = name;
            ann1.subtitle = vicinity;
            ann1.coordinate=placeCoord;
            region.center.latitude =ann1.coordinate.latitude;
            region.center.longitude =ann1.coordinate.longitude;
           
            
            [self.mapview addAnnotation:ann1];
            [self.mapview setRegion:region animated:YES];
            if(i==0)
            {
                [addressDict setValue:[NSString stringWithFormat:@"%f",[[loc objectForKey:@"lat"] doubleValue]] forKey:@"lat"];
                [addressDict setValue:[NSString stringWithFormat:@"%f",[[loc objectForKey:@"lng"] doubleValue]] forKey:@"long"];
              
                
            }
            
            
            
            
        }
       
            double miles = 5.0;
            double scalingFactor = ABS( (cos(2 * M_PI * region.center.latitude / 360.0) ));
            
            MKCoordinateSpan span;
            
            span.latitudeDelta = miles/69.0;
            span.longitudeDelta = miles/(scalingFactor * 69.0);
            
            MKCoordinateRegion region1;
            region1.span = span;
            region1.center = region.center;
            
            [self.mapview setRegion:region1 animated:YES];
        
        //[self zoomToFitMapAnnotations:self.mapview ];
    }
    else
    {
        [drk hide];
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
       /* UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"No result found"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
        [alert show];*/
    }
    [drk hide];
}

- (void)plotPositions:(NSArray *)data
{
    if(data.count>0)
    {
        [self.mapview removeAnnotations:self.mapview.annotations];

      
            for (int i=0; i<[data count]; i++)
            {
                
                //Retrieve the NSDictionary object in each index of the array.
                NSDictionary* place = [data objectAtIndex:i];
             //   NSLog(@"place is %@",place);
                
                //There is a specific NSDictionary object that gives us location info.
                NSDictionary *geo = [place objectForKey:@"geometry"];
                
                
                //Get our name and address info for adding to a pin.
                NSString *name;
                if([[place objectForKey:@"address_components"] count]>0)
                {
                    name=[[[place objectForKey:@"address_components"] objectAtIndex:0] valueForKey:@"short_name"];
                    
                }
                else
                {
                    name=[place objectForKey:@"formatted_address"];
                    
                }
                NSString *vicinity=[place objectForKey:@"formatted_address"];
                
                //Get the lat and long for the location.
                NSDictionary *loc = [geo objectForKey:@"location"];
                
                //Create a special variable to hold this coordinate info.
                CLLocationCoordinate2D placeCoord;
                
                //Set the lat and long.
                placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
                placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
                
                
                
                
               
                
                lat=placeCoord.latitude;
                lon=placeCoord.longitude;
                //Create a new annotiation.
                
                AnnotationViewController *ann1 = [[AnnotationViewController alloc] init];
                ann1.title = name;
                ann1.subtitle = vicinity;
                ann1.coordinate=placeCoord;
                region.center.latitude =ann1.coordinate.latitude;
                region.center.longitude =ann1.coordinate.longitude;
                
                [self.mapview addAnnotation:ann1];
                [self.mapview setRegion:region animated:YES];
                
                
                
                [self.mapview selectAnnotation:ann1 animated:NO];
             
                break;
                
            }
       // [self zoomToFitMapAnnotations:self.mapview ];
    }
    else
    {
        [drk hide];
        
        [DELEGATE showalert:self Message:[localization localizedStringForKey:@"No result found"] AlertFlag:1 ButtonFlag:1];
        
         /*UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"AmHappy" message:[localization localizedStringForKey:@"No result found"] delegate:nil cancelButtonTitle:[localization localizedStringForKey:@"Ok"] otherButtonTitles:nil, nil];
            [alert show];*/
    }
    [drk hide];
    // [self zoomToFitMapAnnotations:self.mapview];
}
-(void)zoomToFitMapAnnotations:(MKMapView *)mapview1 {
    if ([mapview1.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapview.annotations) {
        
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region3;
    region3.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region3.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region3.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    
    // Add a little extra space on the sides
    region3.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region3 = [mapview1 regionThatFits:region3];
    if((region3.center.longitude >= -180.00000000) || (region3.center.longitude <= 180.00000000) || (region3.center.latitude >= -90.00000000) || (region.center.latitude >= 90.00000000)){
        if (region3.span.latitudeDelta >=180 || region3.span.longitudeDelta >=180) {
            region3.span.latitudeDelta = 180.0;
            region3.span.longitudeDelta =180.0;
            [mapview1 setRegion:region3 animated:YES];
        }
        else
        {
            [mapview1 setRegion:region3 animated:YES];
        }
        
    }
    else
    {
        if (region3.span.latitudeDelta >=180 || region3.span.longitudeDelta >=180) {
            region3.span.latitudeDelta = 180.0;
            region3.span.longitudeDelta =180.0;
            [mapview1 setRegion:region3 animated:YES];
        }else
        {
            [mapview1 setRegion:region3 animated:YES];
        }
        
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
   
    
    isSelected=YES;
    if (!view.rightCalloutAccessoryView)
    {
        if (view.annotation == mapView.userLocation)
        {
            [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
            if(DELEGATE.connectedToNetwork)
            {
                CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
                [geocoder reverseGeocodeLocation:mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error)
                 {
                     if (!(error))
                     {
                         [drk hide];
                         CLPlacemark *placemark = [placemarks objectAtIndex:0];
                         NSLog(@"\nCurrent Location Detected\n");
                         NSLog(@"placemark %@",placemark);
                         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                         NSString *Address = [[NSString alloc]initWithString:locatedAt];
                         NSString *Area = [[NSString alloc]initWithString:placemark.locality];
                         NSString *Country = [[NSString alloc]initWithString:placemark.country];
                         NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
                         NSLog(@"%@",CountryArea);
                         
                         if(placemark.thoroughfare )
                         {
                             Address =[placemark thoroughfare];
                             
                         }
                         else
                         {
                             Address =@"";
                         }
                         if(placemark.locality )
                         {
                             Area =[placemark locality];
                             
                         }
                         else
                         {
                             Area =@"";
                         }
                         if(placemark.administrativeArea)
                         {
                             Country =[placemark administrativeArea];
                             
                         }
                         else
                         {
                             Country =@"";
                         }
                         if(placemark.country )
                         {
                             CountryArea =[placemark country];
                             
                         }
                         else
                         {
                             CountryArea =@"";
                         }
                         
                         
                         [addressDict setValue:[NSString stringWithFormat:@"%f",view.annotation.coordinate.latitude] forKey:@"lat"];
                         [addressDict setValue:[NSString stringWithFormat:@"%f",view.annotation.coordinate.longitude] forKey:@"long"];
                         [addressDict setValue:[NSString stringWithFormat:@"%@ %@ %@ %@",Address,Area,Country,CountryArea] forKey:@"addressstr"];
                     }
                     else
                     {
                         [drk hide];
                         
                         [DELEGATE showalert:self Message:[localization localizedStringForKey:@"Could not get address"] AlertFlag:1 ButtonFlag:1];
                         
                     }
                     
                 }];

            }
            else
            {
                [drk hide];
            }
            
        }
        else
        {
            AnnotationViewController *ann=(AnnotationViewController *)view.annotation;
            
            [addressDict setValue:[NSString stringWithFormat:@"%f",view.annotation.coordinate.latitude] forKey:@"lat"];
            [addressDict setValue:[NSString stringWithFormat:@"%f",view.annotation.coordinate.longitude] forKey:@"long"];
            [addressDict setValue:[NSString stringWithFormat:@"%@,%@",ann.title,ann.subtitle] forKey:@"addressstr"];
           // [addressDict setValue:[NSString stringWithFormat:@"%@",ann.subtitle] forKey:@"addressstr"];

        }
       
        
        

    }

  //  NSLog(@"annotation is selected");
}
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:
(id <MKAnnotation>)annotation {
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] ;
    if(pinView == nil)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] ;
    }
    
    if (annotation == mV.userLocation)
    {
        self.mapview.userLocation.title = @"Current Location";
          //  [self.mapview setRegion:MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500) animated:YES];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = NO;
            pinView.canShowCallout = YES;
            [pinView setSelected:YES animated:YES];
        
    }
    else
    {
        pinView.animatesDrop = NO;
        //[pinView setImage:[UIImage imageNamed:@"annotationPin.png"]];
        pinView.pinColor = MKPinAnnotationColorPurple;

        pinView.canShowCallout = YES;
        [pinView setSelected:YES animated:YES];
        
    }
    
    return pinView;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)doneTapped:(id)sender
{
    if (isFromAddPromotion)
    {
  
        if(addressDict)
        {
            if(addressDict.count>0)
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"AddPromotionLocationUpdate" object:nil userInfo:addressDict];
                
            }
        }
  
    }
    else
    {
        
        if(isSelected)
        {
         
            [addressDict setValue:[NSString stringWithFormat:@"%d",loadTag] forKey:@"tag"];
            // [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationUpdate" object:self];
            if(loadTag>=0)
            {
                if(addressDict)
                {
                    if(addressDict.count>0)
                    {
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationChanged" object:nil userInfo:addressDict];
                    }
                }
                
                
            }
            else
            {
                if(addressDict)
                {
                    if(addressDict.count>0)
                    {
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationUpdate" object:nil userInfo:addressDict];
                        
                    }
                }
                
                
            }
            
        }
        
        
    }
 
    [self.navigationController popViewControllerAnimated:YES];


}
- (IBAction)locationvalueChanges:(id)sender
{
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

-(void)callAddressApi:(NSString *)searchAdr
{
    if(DELEGATE.connectedToNetwork)
    {
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        
        NSString *str1 =[searchAdr  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *str  = [str1 stringByReplacingOccurrencesOfString:@""
                                                            withString:@"%20"];
        
        
        //https://maps.googleapis.com/maps/api/place/autocomplete/json?key=AIzaSyADm62Ky4wwac9wDWkWRqq26Y5ydXewZWM&components=country:cr&input=yourtext
        
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",GooglePlaceApi,str]]];
        NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSDictionary *statuses = [parser objectWithString:json_string error:nil];
        
        if(statuses.count>0)
        {
            // autocompleteTableView.hidden = NO;
            [autocompleteUrls removeAllObjects];
            [autocompleteUrls addObjectsFromArray:[statuses valueForKey:@"predictions"]];
            [self.locationTable reloadData];
            
            if(autocompleteUrls.count>0)
            {
                self.locationTable.hidden = NO;
            }
            else
            {
                self.locationTable.hidden = YES;
            }
            [drk hide];
        }
        else
        {
            [drk hide];
            if(autocompleteUrls.count==0)
            {
                self.locationTable.hidden = YES;
            }
            
        }
        
    }
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    return autocompleteUrls.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier] ;
    }
    
    
    
    cell.textLabel.text = [[autocompleteUrls objectAtIndex:indexPath.row] valueForKey:@"description"];
    [cell.textLabel setTextColor:[UIColor colorWithRed:228.0/255.0 green:123.0/255.0 blue:0.0/250.0 alpha:1]];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    [self.mapview removeAnnotations:self.mapview.annotations];
    [self.mapview setUserInteractionEnabled:YES];

    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  
        self.txtsearch.text = selectedCell.textLabel.text;
      //  [self getLocationFromAddressString:self.txtsearch.text];

        
       [self.view endEditing:YES];
        self.locationTable.hidden = YES;
    
    
}

- (IBAction)searchTextChanged:(UITextField *)sender
{
    if([sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length%3==0)
    {
        if(DELEGATE.connectedToNetwork)
        {
            [self.mapview setUserInteractionEnabled:NO];
            self.locationTable.hidden = NO;
            
            NSString *substring = [NSString stringWithString:sender.text];
            [self searchAutocompleteEntriesWithSubstring:substring];
        }
        
    }
}
- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    
    [self callAddressApi:substring];
}

@end
