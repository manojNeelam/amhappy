//
//  ModelClass.m
//  APITest
//
//  Created by Evgeny Kalashnikov on 03.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModelClass.h"
#import <CommonCrypto/CommonHMAC.h>
#import "SBJsonParser.h"



static char base64EncodingTable[64] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};
@implementation ModelClass

@synthesize delegate = _delegate;
@synthesize temp;
@synthesize success;
@synthesize returnData = _returnData;

- (id)init
{
    self = [super init];
    if (self) {
        success = NO;
        drk = [[TYMActivityIndicatorViewViewController alloc] initWithDelegate:nil andInterval:0.1 andMathod:nil];
    }
    
    return self;
}
-(NSString *)getLanguage
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    //  NSLog(@"current language is %@",language);
    
    NSString *str;
    
        if([language isEqualToString:@"es"])
        {
            str= @"S";
        }
        else if([language isEqualToString:@"ch"])
        {
            str= @"C";
        }
        else
        {
            str= @"E";
        }
    
    return str;
    

}
-(NSString *)encryptData:(NSString *)userid
{
    const char *cKey  = [EncryptionKey cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [[NSString stringWithFormat:@"%@",userid] cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256,  cKey, strlen(cKey),cData, strlen(cData), cHMAC);
    
    
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", cHMAC[i]];
        
    }
    
    return output;
}

-(void)loginUser:(NSString *)username Password:(NSString *)password Device_id:(NSString *)device_id Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    
    
    [requestDictionary setValue:username forKey:@"email"];
    [requestDictionary setValue:password forKey:@"password"];
    [requestDictionary setValue:device_id forKey:@"deviceid"];
    [requestDictionary setValue:@"I" forKey:@"device_type"];
    
    //http://192.168.1.100/apps/amhappy/web/api/user/login
    URL = [[NSString stringWithFormat:@"%@user/login",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}


-(void)MakeAdmin:(NSString *)userid eventid:(NSString *)eventid friendid:(NSString *)friendid Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    

    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:friendid forKey:@"friendid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];

    URL = [[NSString stringWithFormat:@"%@event/makeadmin",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
    
    
    
}


-(void)loginFBUser:(NSString *)facebookid Fullname:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Facebook_image:(NSString *)facebook_image Gender:(NSString *)gender Dob:(NSString *)dob Device_id:(NSString *)deviceid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];    
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (facebookid)
    {
        [requestDictionary setValue:facebookid forKey:@"facebookid"];
    }
    
    if (fullname)
    {
        [requestDictionary setValue:fullname forKey:@"fullname"];
    }
    
    if (username)
    {
        [requestDictionary setValue:username forKey:@"username"];
    }
    
    if (email)
    {
        [requestDictionary setValue:email forKey:@"email"];
    }
    
    if (deviceid)
    {
         [requestDictionary setValue:deviceid forKey:@"deviceid"];
    }
    
    
    if (facebook_image)
    {
         [requestDictionary setValue:facebook_image forKey:@"facebook_image"];
        
    }
    
    if (gender)
    {
        [requestDictionary setValue:gender forKey:@"gender"];
    }
    
    if (dob)
    {
        [requestDictionary setValue:dob forKey:@"dob"];
    }
    

    [requestDictionary setValue:@"I" forKey:@"device_type"];
   
   
    
    [requestDictionary setValue:nil forKey:@"facebook_thumb_image"];
    [requestDictionary setValue:[self getLanguage] forKey:@"language"];


    
    //http://192.168.1.100/apps/amhappy/web/api/user/facebooklogin
    URL = [[NSString stringWithFormat:@"%@user/facebooklogin",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}

-(void)loginGoogleUser:(NSString *)googleid Fullname:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Google_image:(NSString *)google_image Gender:(NSString *)gender Dob:(NSString *)dob Device_id:(NSString *)deviceid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:googleid forKey:@"googleid"];
    [requestDictionary setValue:fullname forKey:@"fullname"];
    [requestDictionary setValue:username forKey:@"username"];
    [requestDictionary setValue:email forKey:@"email"];
    [requestDictionary setValue:deviceid forKey:@"deviceid"];
    [requestDictionary setValue:@"I" forKey:@"device_type"];
    [requestDictionary setValue:google_image forKey:@"google_image"];
    [requestDictionary setValue:gender forKey:@"gender"];
    [requestDictionary setValue:dob forKey:@"dob"];
    [requestDictionary setValue:nil forKey:@"google_thumb_image"];
    [requestDictionary setValue:[self getLanguage] forKey:@"language"];


    
    //http://192.168.1.100/apps/amhappy/web/api/user/googlelogin
    URL = [[NSString stringWithFormat:@"%@user/googlelogin",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}

-(void)loginTwitterUser:(NSString *)twitterid Fullname:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Twitter_image:(NSString *)twitter_image Gender:(NSString *)gender Dob:(NSString *)dob Device_id:(NSString *)deviceid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:twitterid forKey:@"twitterid"];
    [requestDictionary setValue:fullname forKey:@"fullname"];
    [requestDictionary setValue:username forKey:@"username"];
    [requestDictionary setValue:email forKey:@"email"];
    [requestDictionary setValue:deviceid forKey:@"deviceid"];
    [requestDictionary setValue:@"I" forKey:@"device_type"];
    [requestDictionary setValue:twitter_image forKey:@"twitter_image"];
    [requestDictionary setValue:gender forKey:@"gender"];
    [requestDictionary setValue:dob forKey:@"dob"];
    [requestDictionary setValue:twitter_image forKey:@"twitter_thumb_image"];
    [requestDictionary setValue:[self getLanguage] forKey:@"language"];


    
    //http://192.168.1.100/apps/amhappy/web/api/user/twitterlogin
    URL = [[NSString stringWithFormat:@"%@user/twitterlogin",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)registerUser:(NSString *)username Fullname:(NSString *)fullname Email_id:(NSString *)email Password:(NSString *)password Device_id:(NSString *)device_id Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:username forKey:@"username"];
    [requestDictionary setValue:fullname forKey:@"fullname"];
    [requestDictionary setValue:email forKey:@"email"];
    [requestDictionary setValue:password forKey:@"password"];
    [requestDictionary setValue:username forKey:@"username"];
    [requestDictionary setValue:fullname forKey:@"fullname"];
    [requestDictionary setValue:email forKey:@"email"];
    [requestDictionary setValue:password forKey:@"password"];
    [requestDictionary setValue:device_id forKey:@"deviceid"];
    [requestDictionary setValue:@"I" forKey:@"device_type"];
    [requestDictionary setValue:[self getLanguage] forKey:@"language"];

    
    URL = [[NSString stringWithFormat:@"%@/register",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}


-(void)editUser:(NSString *)userid Fullname:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Image:(NSData *)image Gender:(NSString *)gender Dob:(NSString *)dob Hobbies:(NSString *)hobbies Relationship:(NSString *)relationship Password:(NSString *)password Device_id:(NSString *)deviceid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:gender forKey:@"gender"];
    [requestDictionary setValue:dob forKey:@"dob"];
    [requestDictionary setValue:hobbies forKey:@"hobbies"];
    [requestDictionary setValue:relationship forKey:@"relationship"];    
    //[requestDictionary setValue:username forKey:@"username"];
    [requestDictionary setValue:fullname forKey:@"fullname"];
    [requestDictionary setValue:email forKey:@"email"];
    [requestDictionary setValue:password forKey:@"password"];
    [requestDictionary setValue:deviceid forKey:@"deviceid"];
    [requestDictionary setValue:@"I" forKey:@"device_type"];
    [requestDictionary setValue:image forKey:@"image"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
   // NSLog(@"encypted data is %@",[NSString stringWithFormat:@"%@",[self encryptData:userid]]);


    //http://192.168.1.100/apps/amhappy/web/api/user/editprofile
    URL = [[NSString stringWithFormat:@"%@user/editprofile",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    if(image)
    {
        [self postImage:requestDictionary img:image img2:nil img3:nil img4:nil img5:nil];
        
    }
    else
    {

        [self postData:requestDictionary];

    }
    NSLog(@"post data is  =%@",requestDictionary);

}
-(void)guestList:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/guestlist
    URL = [[NSString stringWithFormat:@"%@event/guestlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)reportComment:(NSString *)userid Comment_id:(NSString *)comment_id Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:comment_id forKey:@"comment_id"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/reportcomment
    URL = [[NSString stringWithFormat:@"%@event/reportcomment",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)unBlockUser:(NSString *)userid Friendid:(NSString *)friendid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:friendid forKey:@"friendid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/user/unblockuser
    URL = [[NSString stringWithFormat:@"%@user/unblockuser",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)blockUser:(NSString *)userid Friendid:(NSString *)friendid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:friendid forKey:@"friendid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/user/blockuser
    URL = [[NSString stringWithFormat:@"%@user/blockuser",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)reportEvent:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/reportevent
    URL = [[NSString stringWithFormat:@"%@event/reportevent",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)findFriends:(NSString *)userid Type:(NSString *)type Friendids:(NSString *)friendids Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:type forKey:@"type"];
    [requestDictionary setValue:friendids forKey:@"friendids"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/friend/findfriend
    URL = [[NSString stringWithFormat:@"%@friend/findfriend",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)inviteFriendtoEvent:(NSString *)userid Eventid:(NSString *)eventid Friendids:(NSString *)friendids Type:(NSString *)type Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:friendids forKey:@"friendids"];
    [requestDictionary setValue:type forKey:@"type"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/invite
    URL = [[NSString stringWithFormat:@"%@event/invite",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    NSLog(@"requestDictionary =%@",requestDictionary);

    [self postData:requestDictionary];
}
-(void)vote:(NSString *)userid Eventid:(NSString *)eventid Type:(NSString *)type Voteid:(NSString *)voteid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:type forKey:@"type"];
    [requestDictionary setValue:voteid forKey:@"id"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/givevote
    URL = [[NSString stringWithFormat:@"%@event/givevote",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)sendFriendRequest:(NSString *)userid Friendid:(NSString *)friendid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:friendid forKey:@"friendid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/friend/request
    URL = [[NSString stringWithFormat:@"%@friend/request",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)acceptFriendRequest:(NSString *)userid Friendid:(NSString *)friendid Is_accept:(NSString *)is_accept Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:friendid forKey:@"friendid"];
    [requestDictionary setValue:is_accept forKey:@"is_accept"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/friend/accept
    
    URL = [[NSString stringWithFormat:@"%@friend/accept",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)listFriendRequest:(NSString *)userid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/friend/requestedlist
    
    URL = [[NSString stringWithFormat:@"%@friend/requestedlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getAppUser:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Eventid:(NSString *)eventid Keyword:(NSString *)keyword Sel:(SEL)sel;
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];


    
    //http://192.168.1.100/apps/amhappy/web/api/user/list
    
    URL = [[NSString stringWithFormat:@"%@user/list",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)searchFriends:(NSString *)userid Keyword:(NSString *)keyword Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel
{
    //[drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    
    //http://192.168.1.100/apps/amhappy/web/api/user/searchfriend
    
    URL = [[NSString stringWithFormat:@"%@user/searchfriend",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)listInvitedEvents:(NSString *)userid Json:(NSString *)json Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
   // [requestDictionary setValue:json forKey:@"json"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/grouplist
    
    //http://192.168.1.100/apps/amhappy/web/api/event/groupslist
    
    
    
    URL = [[NSString stringWithFormat:@"%@event/groupslist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getBlockedUsers:(NSString *)userid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/user/blocklist
    
    URL = [[NSString stringWithFormat:@"%@user/blocklist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getFriends:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/friend/friendlist
    
    URL = [[NSString stringWithFormat:@"%@friend/friendlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getFriendsforAddinGroup:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Groupid:(NSString *)groupid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    
    if(start)
    {
        [requestDictionary setValue:start forKey:@"start"];
    }
    
    if(limit)
    {
        [requestDictionary setValue:limit forKey:@"limit"];
    }
    
    if(groupid)
    {
        [requestDictionary setValue:groupid forKey:@"groupid"];
    }
 
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/friend/friendlist
    
    URL = [[NSString stringWithFormat:@"%@friend/friendlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)sendOfflineMessage:(NSString *)userid To_id:(NSString *)to_id Message:(NSString *)message Sel:(SEL)sel
{
   // [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:to_id forKey:@"to_id"];
    [requestDictionary setValue:message forKey:@"message"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/default/sendmessage
    
    URL = [[NSString stringWithFormat:@"%@default/sendmessage",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)sendOfflineGroupMessage:(NSString *)userid Event_id:(NSString *)event_id Message:(NSString *)message Sel:(SEL)sel
{
   // [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:event_id forKey:@"event_id"];
    [requestDictionary setValue:message forKey:@"message"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/default/sendmessage
    
    URL = [[NSString stringWithFormat:@"%@default/groupmessage",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)listEventInvitation:(NSString *)userid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/invitedlist
    
    URL = [[NSString stringWithFormat:@"%@event/invitedlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)otherUpcomingInvitation:(NSString *)userid Otherid:(NSString *)otherid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:otherid forKey:@"otherid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/invitedlist
    
    URL = [[NSString stringWithFormat:@"%@event/invitedlistupcoming",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)otherExpiredInvitation:(NSString *)userid Otherid:(NSString *)otherid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:otherid forKey:@"otherid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/invitedlist
    
    URL = [[NSString stringWithFormat:@"%@event/invitedlistexpired",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)voterList:(NSString *)userid Eventid:(NSString *)eventid Type:(NSString *)type Voteid:(NSString *)voteid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:type forKey:@"type"];
    [requestDictionary setValue:voteid forKey:@"id"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/votedetail
    URL = [[NSString stringWithFormat:@"%@event/votedetail",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}


-(void)addComment:(NSString *)userid Eventid:(NSString *)eventid Time:(NSString *)time Comment:(NSString *)comment Image:(NSData *)image is_multiple:(NSString *)is_multiple image2:(NSData *)image2 image3:(NSData *)image3 image4:(NSData *)image4 image5:(NSData *)image5 comment_tags:(NSString *)comment_tags Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
       [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (eventid)
    {
        
      [requestDictionary setValue:eventid forKey:@"eventid"];
        
    }
    
    if (time)
    {
        
         [requestDictionary setValue:time forKey:@"time"];
        
    }
    
    if (comment)
    {
        
         [requestDictionary setValue:comment forKey:@"comment"];
        
    }
    
    
    if (is_multiple)
    {
        
        [requestDictionary setValue:is_multiple forKey:@"is_multiple"];
        
    }
    
    if (image)
    {
        
        [requestDictionary setValue:image forKey:@"image"];
        
    }
    
    if (comment_tags)
    {
        [requestDictionary setValue:comment_tags forKey:@"comment_tags"];
    }
    
  
   
    //http://192.168.1.100/apps/amhappy/web/api/event/addcomment
    URL = [[NSString stringWithFormat:@"%@event/addcomment",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    if(image||image2||image3||image4||image5)
    {
 
        [self postImage:requestDictionary img:image img2:image2 img3:image3 img4:image4 img5:image5];
        
    }
    else
    {
        [self postData:requestDictionary];
        
    }

}
-(void)attendEvent:(NSString *)userid Eventid:(NSString *)eventid Is_attend:(NSString *)is_attend Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:is_attend forKey:@"is_attend"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    //http://192.168.1.100/apps/amhappy/web/api/event/goingtoattend
    URL = [[NSString stringWithFormat:@"%@event/goingtoattend",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getCommentList:(NSString *)userid Eventid:(NSString *)eventid Start:(NSString *)start Limit1:(NSString *)limit Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];

    //http://192.168.1.100/apps/amhappy/web/api/event/comments
    URL = [[NSString stringWithFormat:@"%@event/comments",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}


-(void)createUser:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Image:(NSData *)image Gender:(NSString *)gender Dob:(NSString *)dob Hobbies:(NSString *)hobbies Relationship:(NSString *)relationship Password:(NSString *)password Device_id:(NSString *)deviceid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:gender forKey:@"gender"];
    [requestDictionary setValue:dob forKey:@"dob"];
    [requestDictionary setValue:hobbies forKey:@"hobbies"];
    [requestDictionary setValue:relationship forKey:@"relationship"];
    
    //[requestDictionary setValue:username forKey:@"username"];
    [requestDictionary setValue:fullname forKey:@"fullname"];
    [requestDictionary setValue:email forKey:@"email"];
    [requestDictionary setValue:password forKey:@"password"];
    [requestDictionary setValue:deviceid forKey:@"deviceid"];
    //[requestDictionary setValue:@"123456" forKey:@"deviceid"];


    [requestDictionary setValue:@"I" forKey:@"device_type"];
    [requestDictionary setValue:image forKey:@"image"];

    //http://192.168.1.100/apps/amhappy/web/api/user/register
    URL = [[NSString stringWithFormat:@"%@user/register",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    if(image)
    {
          [self postImage:requestDictionary img:image img2:nil img3:nil img4:nil img5:nil];
    }
    else
    {
        [requestDictionary setValue:image forKey:@"image"];
        [self postData:requestDictionary];
        
    }
}
-(void)addPublicEvent:(NSString *)userid Name:(NSString *)name Description:(NSString *)description Image:(NSData *)image Category_id:(NSString *)category_id Type:(NSString *)type Location_json:(NSString *)location_json Date_json:(NSString *)date_json Voting_close_date:(NSString *)voting_close_date Price:(NSString *)price Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
 
    if (userid)
    {
        [requestDictionary setValue:userid forKey:@"userid"];
        
    }
  
    if (name)
    {
        [requestDictionary setValue:name forKey:@"name"];

    }

    if (description)
    {
         [requestDictionary setValue:description forKey:@"description"];
    }
    
   
    if (category_id)
    {
        [requestDictionary setValue:category_id forKey:@"category_id"];
    }
    
    if (type)
    {
        [requestDictionary setValue:type forKey:@"type"];
    }
    
    if (location_json)
    {
        [requestDictionary setValue:location_json forKey:@"location_json"];
    }

    
    if (date_json)
    {
        [requestDictionary setValue:date_json forKey:@"date_json"];
    }

    if (voting_close_date)
    {
         [requestDictionary setValue:voting_close_date forKey:@"voting_close_date"];
    }
    
    if (price)
    {
       
        [requestDictionary setValue:price forKey:@"price"];
    }
    
    if (image)
    {
        
        [requestDictionary setValue:image forKey:@"image"];
    }
  
    
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
   
    //http://192.168.1.100/apps/amhappy/web/api/event/create
    URL = [[NSString stringWithFormat:@"%@event/create",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    if(image)
    {

        [self postImage:requestDictionary img:image img2:nil img3:nil img4:nil img5:nil];
    }
    else
    {
        
        [self postData:requestDictionary];
        
    }
}
-(void)editPublicEvent:(NSString *)userid Name:(NSString *)name Description:(NSString *)description Image:(NSData *)image Category_id:(NSString *)category_id Type:(NSString *)type Location_json:(NSString *)location_json Date_json:(NSString *)date_json Voting_close_date:(NSString *)voting_close_date Price:(NSString *)price Eventid:(NSString *)eventid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:name forKey:@"name"];
    [requestDictionary setValue:description forKey:@"description"];
    [requestDictionary setValue:category_id forKey:@"category_id"];
    [requestDictionary setValue:type forKey:@"type"];
    [requestDictionary setValue:location_json forKey:@"location_json"];
    [requestDictionary setValue:date_json forKey:@"date_json"];    
    [requestDictionary setValue:voting_close_date forKey:@"voting_close_date"];
    [requestDictionary setValue:price forKey:@"price"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:image forKey:@"image"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];

    
    //http://192.168.1.100/apps/amhappy/web/api/event/edit
    URL = [[NSString stringWithFormat:@"%@event/edit",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    if(image)
    {
        
        [self postImage:requestDictionary img:image img2:nil img3:nil img4:nil img5:nil];
    }
    else
    {
        
        [self postData:requestDictionary];
        
    }

}
-(void)searchAllEvents:(NSString *)userid Keyword:(NSString *)keyword Category_id:(NSString *)category_id Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel
{
    
    if(keyword.length==0)
    {
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    }
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:category_id forKey:@"category_id"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    //http://192.168.1.100/apps/amhappy/web/api/event/eventlist
    URL = [[NSString stringWithFormat:@"%@event/eventlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)searchUpcomingEvents:(NSString *)userid Keyword:(NSString *)keyword Category_id:(NSString *)category_id Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel
{
    
    if(keyword.length==0)
    {
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    }
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:category_id forKey:@"category_id"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    //http://192.168.1.100/apps/amhappy/web/api/event/eventlist
    URL = [[NSString stringWithFormat:@"%@event/eventlistupcoming",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)searchExpiredEvents:(NSString *)userid Keyword:(NSString *)keyword Category_id:(NSString *)category_id Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel
{
    
    if(keyword.length==0)
    {
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    }
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:category_id forKey:@"category_id"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    //http://192.168.1.100/apps/amhappy/web/api/event/eventlist
    URL = [[NSString stringWithFormat:@"%@event/eventlistexpired",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)editSetting:(NSString *)userid Recieve_push:(NSString *)recieve_push Langauge:(NSString *)langauge search_miles:(NSString *)search_miles Event_notification:(NSString *)event_notification Comment_notification:(NSString *)comment_notification Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:recieve_push forKey:@"recieve_push"];
    [requestDictionary setValue:langauge forKey:@"langauge"];
    [requestDictionary setValue:search_miles forKey:@"search_miles"];
    [requestDictionary setValue:event_notification forKey:@"event_notification"];
    [requestDictionary setValue:comment_notification forKey:@"comment_notification"];

    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];

    //http://192.168.1.100/apps/amhappy/web/api/user/setsetting
    URL = [[NSString stringWithFormat:@"%@user/setsetting",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getHomeEvents:(NSString *)userid Latitude:(NSString *)latitude Longitude:(NSString *)longitude Category_id:(NSString *)category_id Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:latitude forKey:@"latitude"];
    [requestDictionary setValue:longitude forKey:@"longitude"];
    [requestDictionary setValue:category_id forKey:@"category_id"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
   // NSLog(@"encypted data is %@",[NSString stringWithFormat:@"%@",[self encryptData:userid]]);

    //http://192.168.1.100/apps/amhappy/web/api/event/searchevent
    URL = [[NSString stringWithFormat:@"%@event/searchevent",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    NSLog(@"post dictionary is %@",requestDictionary);

    [self postData:requestDictionary];
   
}
-(void)getMyEvents:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Keyword:(NSString *)keyword Sel:(SEL)sel
{
    if(keyword.length==0)
    {
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    }
    
    
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];

    //http://192.168.1.100/apps/amhappy/web/api/event/mylist
    URL = [[NSString stringWithFormat:@"%@event/mylist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getMyUpcomingEvents:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Keyword:(NSString *)keyword Sel:(SEL)sel
{
    if(keyword.length==0)
    {
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    }
    
    
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/mylist
    URL = [[NSString stringWithFormat:@"%@event/mylistupcoming",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getMyExpiredEvents:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Keyword:(NSString *)keyword Sel:(SEL)sel
{
    if(keyword.length==0)
    {
        [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    }
    
    
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/mylist
    URL = [[NSString stringWithFormat:@"%@event/mylistexpired",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)addFeedback:(NSString *)userid Email:(NSString *)email Description:(NSString *)description Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:email forKey:@"email"];
    [requestDictionary setValue:description forKey:@"description"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    //http://192.168.1.100/apps/amhappy/web/api/user/feedback
    URL = [[NSString stringWithFormat:@"%@user/feedback",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}


-(void)likedUserList:(NSString *)userid type:(NSString *)type Id:(NSString *)Id start:(NSString *)start limit:(NSString *)limit Sel:(SEL)sel
{
    
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
         [requestDictionary setValue:userid forKey:@"userid"];
        
    }
    
    if (type)
    {
        [requestDictionary setValue:type forKey:@"type"];
        
    }
    
    if (Id)
    {
        [requestDictionary setValue:Id forKey:@"id"];
        
    }
    
    if (start)
    {
        [requestDictionary setValue:start forKey:@"start"];
        
    }
    
    if (limit)
    {
        [requestDictionary setValue:limit forKey:@"limit"];
        
    }
  
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    URL = [[NSString stringWithFormat:@"%@event/likeduserlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
   
}



-(void)getAttendingCount:(NSString *)userid eventid:(NSString *)eventid Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        [requestDictionary setValue:userid forKey:@"userid"];
        
    }
    
    if (eventid)
    {
        [requestDictionary setValue:eventid forKey:@"eventid"];
        
    }
    
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    URL = [[NSString stringWithFormat:@"%@event/attendcount",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
 
}

-(void)getAttendList:(NSString *)userid eventid:(NSString *)eventid type:(NSString *)type Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        [requestDictionary setValue:userid forKey:@"userid"];
        
    }
    
    if (eventid)
    {
        [requestDictionary setValue:eventid forKey:@"eventid"];
        
    }
    
    if (type)
    {
        
        [requestDictionary setValue:type forKey:@"type"];
        
    }
    
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    URL = [[NSString stringWithFormat:@"%@event/attendlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
    
    
    
}


-(void)forgotPassword:(NSString *)email Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:email forKey:@"email"];
    //http://192.168.1.100/apps/amhappy/web/api/user/forgotpassword
    
    URL = [[NSString stringWithFormat:@"%@user/forgotpassword",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getUser:(NSString *)userid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]] forKey:@"userid"];
    [requestDictionary setValue:userid forKey:@"otherid"];

    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"userid"]]]] forKey:@"encrypted_data"];
    
    

    
   // [USER_DEFAULTS valueForKey:@"userid"];
    
    URL = [[NSString stringWithFormat:@"%@user/getprofile",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)logout:(NSString *)userid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    //http://192.168.1.100/apps/amhappy/web/api/user/logout
    
    URL = [[NSString stringWithFormat:@"%@user/logout",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)deleteEvent:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];

    //http://192.168.1.100/apps/amhappy/web/api/event/deleteevent
    
    URL = [[NSString stringWithFormat:@"%@event/deleteevent",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)deleteComment:(NSString *)userid Comment_id:(NSString *)comment_id Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:comment_id forKey:@"comment_id"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/deletecomment
    
    URL = [[NSString stringWithFormat:@"%@event/deletecomment",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getEventDetail:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];

    //http://192.168.1.100/apps/amhappy/web/api/event/detail
    
    URL = [[NSString stringWithFormat:@"%@event/detail",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getDropDowns:(NSString *)userid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    //http://192.168.1.100/apps/amhappy/web/api/default/masterdata
    
    URL = [[NSString stringWithFormat:@"%@default/masterdata",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if(userid)
    {
        [requestDictionary setValue:userid forKey:@"userid"];
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"localization"]] forKey:@"language"];
        
    }
    else
    {
        [requestDictionary setValue:[self getLanguage] forKey:@"language"];
    }

    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];

    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)getUserNewsfeed:(NSString *)userid Timestamp:(NSString *)timestamp Sel:(SEL)sel
{
    //[drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    newFeed = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:timestamp forKey:@"timestamp"];

    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];    
    //http://192.168.1.100/apps/amhappy/web/api/event/detail
    
    URL = [[NSString stringWithFormat:@"%@user/newfeed",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}

-(void)myGroupsForEvent:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/detail
    
    URL = [[NSString stringWithFormat:@"%@group/mygroup",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}

-(void)myGroups:(NSString *)userid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/event/detail
    
    URL = [[NSString stringWithFormat:@"%@group/mygroup",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)addGroup:(NSString *)userid Name:(NSString *)name Image:(NSData *)image Member_ids:(NSString *)member_ids Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:name forKey:@"name"];
    [requestDictionary setValue:image forKey:@"image"];
    [requestDictionary setValue:member_ids forKey:@"member_ids"];

    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    URL = [[NSString stringWithFormat:@"%@group/create",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    if(image)
    {
          [self postImage:requestDictionary img:image img2:nil img3:nil img4:nil img5:nil];
    }
    else
    {
        
        [self postData:requestDictionary];
        
    }
}
-(void)getMemberOfGroup:(NSString *)userid Groupid:(NSString *)groupid Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:groupid forKey:@"groupid"];
    
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    URL = [[NSString stringWithFormat:@"%@group/memberlist",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
        [self postData:requestDictionary];

}
-(void)getEventPhoto:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    URL = [[NSString stringWithFormat:@"%@event/images",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];

}
-(void)likeComment:(NSString *)userid Comment_id:(NSString *)comment_id Is_like:(NSString *)is_like Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:comment_id forKey:@"comment_id"];
    [requestDictionary setValue:is_like forKey:@"is_like"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    URL = [[NSString stringWithFormat:@"%@event/likecomment",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}




-(void)likeEvent:(NSString *)userid Eventid:(NSString *)eventid Is_like:(NSString *)is_like Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:eventid forKey:@"eventid"];
    [requestDictionary setValue:is_like forKey:@"is_like"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    URL = [[NSString stringWithFormat:@"%@event/likeevent",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    NSLog(@"requestDictionary is  =%@",requestDictionary);

    [self postData:requestDictionary];
}
-(void)getMyFeed:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Timestamp:(NSString *)timestamp promo_ids:(NSString *)promo_ids Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    myFeed = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:timestamp forKey:@"timestamp"];
    
    if (promo_ids)
    {
         [requestDictionary setValue:promo_ids forKey:@"promo_ids"];
    }

    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    URL = [[NSString stringWithFormat:@"%@user/myfeed",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
-(void)addMemberToGroup:(NSString *)userid Groupid:(NSString *)groupid Member_ids:(NSString *)member_ids Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:groupid forKey:@"groupid"];
    [requestDictionary setValue:member_ids forKey:@"member_ids"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    URL = [[NSString stringWithFormat:@"%@group/addmember",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}
//dax
-(void)DisplayUser:(NSString *)userid Keyword:(NSString *)keyword Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel;
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:start forKey:@"start"];
    [requestDictionary setValue:limit forKey:@"limit"];
    [requestDictionary setValue:keyword forKey:@"keyword"];
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/user/list
    
    URL = [[NSString stringWithFormat:@"%@user/alluser",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    [self postData:requestDictionary];
}



#pragma mark ---------------- Version 3 ------------------------

-(void)editGroup:(NSString *)userid groupid:(NSString *)groupid name:(NSString *)name image:(UIImage *)image member_added:(NSString *)member_added member_remove:(NSString *)member_remove Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    [requestDictionary setValue:userid forKey:@"userid"];
    [requestDictionary setValue:groupid forKey:@"groupid"];
    [requestDictionary setValue:name forKey:@"name"];
    
    
    if (member_added)
    {
         [requestDictionary setValue:member_added forKey:@"member_added"];
    }
    
    
    if (member_remove)
    {
        [requestDictionary setValue:member_remove forKey:@"member_remove"];
    }
    
   
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/user/list
    
    URL = [[NSString stringWithFormat:@"%@group/edit",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);

    if(image)
    {
        NSData *imgData= UIImageJPEGRepresentation(image,0.0);
        
        [self postImage:requestDictionary img:imgData img2:nil img3:nil img4:nil img5:nil];
    }
    else
    {
        
        [self postData:requestDictionary];
        
    }

    
}


-(void)eventInviteByMail:(NSString *)userid eventid:(NSString *)eventid email:(NSString *)email Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
    [requestDictionary setValue:userid forKey:@"userid"];
        
    }
    
    
    if (eventid)
    {
         [requestDictionary setValue:eventid forKey:@"eventid"];
    }
  
    
    if (email)
    {
        [requestDictionary setValue:email forKey:@"email"];
    }
    
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/user/list
    
    URL = [[NSString stringWithFormat:@"%@event/mailinvite",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    [self postData:requestDictionary];
   
}

-(void)deleteGroup:(NSString *)userid groupid:(NSString *)groupid Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
    }
    
    
    if (groupid)
    {
        [requestDictionary setValue:groupid forKey:@"groupid"];
    }
 
    [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
    
    //http://192.168.1.100/apps/amhappy/web/api/user/list
    
    URL = [[NSString stringWithFormat:@"%@group/delete",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    [self postData:requestDictionary];
    
   
}


#pragma mark --------- Version 4 ---------------

-(void)getPromotionTypes:(NSString *)userid Sel:(SEL)sel;
{
    
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
 
  
    
    URL = [[NSString stringWithFormat:@"%@promotion/type",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    [self postData:requestDictionary];
    
    
}

-(void)CreatePromotion:(NSString *)userid type_id:(NSString *)type_id promotion_type:(NSString *)promotion_type company_name:(NSString *)company_name description:(NSString *)description location:(NSString *)location latitude:(NSString *)latitude longitude:(NSString *)longitude website:(NSString *)website price:(NSString *)price discount:(NSString *)discount start_date:(NSString *)start_date end_date:(NSString *)end_date image:(NSData *)image Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (type_id)
    {
        
        [requestDictionary setValue:type_id forKey:@"type_id"];
      
    }
    
    if (promotion_type)
    {
        
        [requestDictionary setValue:promotion_type forKey:@"promotion_type"];
        
    }
    
    
    if (company_name)
    {
        
        [requestDictionary setValue:company_name forKey:@"company_name"];
        
    }
    
    if (description)
    {
        
        [requestDictionary setValue:description forKey:@"description"];
        
    }
    
    if (location)
    {
        
        [requestDictionary setValue:location forKey:@"location"];
        
    }
    
    if (latitude)
    {
        
        [requestDictionary setValue:latitude forKey:@"latitude"];
        
    }
    
    if (longitude)
    {
        
        [requestDictionary setValue:longitude forKey:@"longitude"];
        
    }
    
    
    if (website)
    {
        
        [requestDictionary setValue:website forKey:@"website"];
        
    }
    
    if (price)
    {
        
        [requestDictionary setValue:price forKey:@"price"];
        
    }
    
    if (discount)
    {
        
        [requestDictionary setValue:discount forKey:@"discount"];
        
    }
    
    
    if (start_date)
    {
        
        [requestDictionary setValue:start_date forKey:@"start_date"];
        
    }
    
    if (end_date)
    {
        
        [requestDictionary setValue:end_date forKey:@"end_date"];
        
    }
    
  
    URL = [[NSString stringWithFormat:@"%@promotion/create",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    
    if (image)
    {
        [self postImage:requestDictionary img:image img2:nil img3:nil img4:nil img5:nil];
    }
    else{
        
        [self postData:requestDictionary];
    }
    
    
    
}

-(void)getPromotionList:(NSString *)userid start:(NSString *)start limit:(NSString *)limit keyword:(NSString *)keyword latitude:(NSString *)latitude longitude:(NSString *)longitude type_id:(NSString *)type_id promotion_type:(NSString *)promotion_type my_promo:(NSString *)my_promo Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (start)
    {
        
        [requestDictionary setValue:start forKey:@"start"];
   
    }
    
    if (limit)
    {
        
        [requestDictionary setValue:limit forKey:@"limit"];
        
    }
    
    if (keyword)
    {
        
        [requestDictionary setValue:keyword forKey:@"keyword"];
        
    }
    
    if (latitude)
    {
        
        [requestDictionary setValue:latitude forKey:@"latitude"];
        
    }
    
    if (longitude)
    {
        
        [requestDictionary setValue:longitude forKey:@"longitude"];
        
    }
    
    if (type_id)
    {
        
        [requestDictionary setValue:type_id forKey:@"type_id"];
        
    }
    
    
    if (promotion_type)
    {
        
        [requestDictionary setValue:promotion_type forKey:@"promotion_type"];
        
    }
    
    if (my_promo)
    {
        
        [requestDictionary setValue:my_promo forKey:@"my_promo"];
        
    }
 
    URL = [[NSString stringWithFormat:@"%@promotion/list",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    [self postData:requestDictionary];
    
    
}

-(void)PromotionDetail:(NSString *)userid promo_id:(NSString *)promo_id Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (promo_id)
    {
        
        [requestDictionary setValue:promo_id forKey:@"promo_id"];
        
    }

    URL = [[NSString stringWithFormat:@"%@promotion/detail",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    [self postData:requestDictionary];
    
    
}

-(void)DeletePromotion:(NSString *)userid promo_id:(NSString *)promo_id  Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (promo_id)
    {
        
        [requestDictionary setValue:promo_id forKey:@"promo_id"];
        
    }
    
    
    URL = [[NSString stringWithFormat:@"%@promotion/delete",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    [self postData:requestDictionary];
    
}

-(void)ReplyOnComment:(NSString *)userid eventid:(NSString *)eventid comment_id:(NSString *)comment_id reply:(NSString *)reply reply_tags:(NSString *)reply_tags image:(NSData *)image Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (eventid)
    {
        
        [requestDictionary setValue:eventid forKey:@"eventid"];
        
    }
    
    if (comment_id)
    {
        
        [requestDictionary setValue:comment_id forKey:@"comment_id"];
        
    }
    
    if (reply)
    {
        
        [requestDictionary setValue:reply forKey:@"reply"];
        
    }
    
    if (reply_tags)
    {
        
        [requestDictionary setValue:reply_tags forKey:@"reply_tags"];
        
    }

    URL = [[NSString stringWithFormat:@"%@event/reply",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    if (image)
    {
       
        [self postImage:requestDictionary img:image img2:nil img3:nil img4:nil img5:nil];
        
    }
    else{
        
        [self postData:requestDictionary];
    }
    
    
    
}


-(void)ReplyLike:(NSString *)userid reply_id:(NSString *)reply_id is_like:(NSString *)is_like Sel:(SEL)sel
{
    
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (reply_id)
    {
        
        [requestDictionary setValue:reply_id forKey:@"reply_id"];
        
    }
    
    if (is_like)
    {
        
        [requestDictionary setValue:is_like forKey:@"is_like"];
        
    }
  
    
    URL = [[NSString stringWithFormat:@"%@event/likereply",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    

        
    [self postData:requestDictionary];
    
   
}


-(void)GetReplies:(NSString *)userid comment_id:(NSString *)comment_id Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (comment_id)
    {
        
        [requestDictionary setValue:comment_id forKey:@"comment_id"];
        
    }
    
    
    
    URL = [[NSString stringWithFormat:@"%@event/getreply",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    
    
    [self postData:requestDictionary];
    
}

-(void)EditPromotion:(NSString *)userid promo_id:(NSString *)promo_id type_id:(NSString *)type_id promotion_type:(NSString *)promotion_type company_name:(NSString *)company_name description:(NSString *)description location:(NSString *)location latitude:(NSString *)latitude longitude:(NSString *)longitude website:(NSString *)website price:(NSString *)price discount:(NSString *)discount start_date:(NSString *)start_date end_date:(NSString *)end_date image:(NSData *)image image_deleted:(NSString *)image_deleted Sel:(SEL)sel
{
    [drk showWithMessage:[localization localizedStringForKey:@"Please wait"] backgroundcolor:[UIColor blackColor]];
    responseselector = sel;
    NSMutableDictionary *requestDictionary = [NSMutableDictionary new];
    
    if (userid)
    {
        
        [requestDictionary setValue:userid forKey:@"userid"];
        
        [requestDictionary setValue:[NSString stringWithFormat:@"%@",[self encryptData:userid]] forKey:@"encrypted_data"];
        
    }
    
    if (promo_id)
    {
        
        [requestDictionary setValue:promo_id forKey:@"promo_id"];
        
    }
    
    if (image_deleted)
    {
        
        [requestDictionary setValue:image_deleted forKey:@"image_deleted"];
        
    }
    
    if (type_id)
    {
        
        [requestDictionary setValue:type_id forKey:@"type_id"];
        
    }
    
    if (promotion_type)
    {
        
        [requestDictionary setValue:promotion_type forKey:@"promotion_type"];
        
    }
    
    
    if (company_name)
    {
        
        [requestDictionary setValue:company_name forKey:@"company_name"];
        
    }
    
    if (description)
    {
        
        [requestDictionary setValue:description forKey:@"description"];
        
    }
    
    if (location)
    {
        
        [requestDictionary setValue:location forKey:@"location"];
        
    }
    
    if (latitude)
    {
        
        [requestDictionary setValue:latitude forKey:@"latitude"];
        
    }
    
    if (longitude)
    {
        
        [requestDictionary setValue:longitude forKey:@"longitude"];
        
    }
    
    
    if (website)
    {
        
        [requestDictionary setValue:website forKey:@"website"];
        
    }
    
    if (price)
    {
        
        [requestDictionary setValue:price forKey:@"price"];
        
    }
    
    if (discount)
    {
        
        [requestDictionary setValue:discount forKey:@"discount"];
        
    }
    
    
    if (start_date)
    {
        
        [requestDictionary setValue:start_date forKey:@"start_date"];
        
    }
    
    if (end_date)
    {
        
        [requestDictionary setValue:end_date forKey:@"end_date"];
        
    }
    
    
    URL = [[NSString stringWithFormat:@"%@promotion/update",API_PATH]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Url =%@",URL);
    
    
    if (image)
    {
        [self postImage:requestDictionary img:image img2:nil img3:nil img4:nil img5:nil];
    }
    else{
        
        [self postData:requestDictionary];
    }
    
    
    
}



//***********************************************************************

-(UIImage *)scaleAndRotateImage:(UIImage *)image
{ // here we rotate the image in its orignel
    int kMaxResolution = 640; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

-(void)postMultipleImage:(NSMutableDictionary *)postdatadictionary  image1:(UIImage *)img1 Image2:(UIImage *)img2 Image3:(UIImage *)img3 Image4:(UIImage *)img4 Image5:(UIImage *)img5

{
    
    AFHTTPRequestOperationManager *operationmanager = [AFHTTPRequestOperationManager manager];
    operationmanager.responseSerializer = [AFJSONResponseSerializer serializer];
    operationmanager.responseSerializer.acceptableContentTypes = [operationmanager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    operationmanager.responseSerializer.acceptableContentTypes = [operationmanager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];
    
    
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    // 2. Create an `NSMutableURLRequest`.
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:URL
                                    parameters:postdatadictionary
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         
                         
                      
                         
                         if(img1)
                         {
                             NSData *imageData1 = UIImagePNGRepresentation(img1);
                             [formData appendPartWithFileData:imageData1
                                                         name:@"image1"
                                                     fileName:@"myimage1.png"
                                                     mimeType:@"image/png"];
                             
                             
                         }
                         if(img2)
                         {
                             NSData *imageData2 = UIImageJPEGRepresentation(img2,1);
                             
                             [formData appendPartWithFileData:imageData2
                                                         name:@"image2"
                                                     fileName:@"myimage2.png"
                                                     mimeType:@"image/png"];
                         }
                         if(img3)
                         {
                             NSData *imageData3 = UIImageJPEGRepresentation(img3,1);
                             
                             [formData appendPartWithFileData:imageData3
                                                         name:@"image3"
                                                     fileName:@"myimage3.png"
                                                     mimeType:@"image/png"];
                         }
                         if(img4)
                         {
                             NSData *imageData4 = UIImageJPEGRepresentation(img4,1);
                             
                             [formData appendPartWithFileData:imageData4
                                                         name:@"image4"
                                                     fileName:@"myimage4.png"
                                                     mimeType:@"image/png"];
                         }
                         if(img5)
                         {
                             NSData *imageData5 = UIImageJPEGRepresentation(img5,1);
                             
                             [formData appendPartWithFileData:imageData5
                                                         name:@"image5"
                                                     fileName:@"myimage5.png"
                                                     mimeType:@"image/png"];
                             
                         }
                         
                         
                     }];
    
    
    
    AFHTTPRequestOperation *operation =
    [operationmanager HTTPRequestOperationWithRequest:request
                                              success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
        
        [drk hide];
         
         
         NSDictionary *responsedictionary = (NSDictionary *)responseObject;
         //  NSLog(@"\n\n +++++>> Response Dictionary Data : %@",responsedictionary);
         
         NSLog(@"Success %@", responseObject);
         
         [self.delegate performSelector:responseselector withObject:responsedictionary];
         //                                         [drk hide];
         //                                         [drkipad hide];
         
         
         
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
         NSLog(@"%@",[operation responseObject]);
         
         NSLog(@"%@",[operation responseString]);
         
         if([[operation responseString] length]>0)
         {
             [self.delegate performSelector:responseselector withObject:[operation responseObject]];
         }
         
       
        [drk hide];
         
         
         
         // NSMutableDictionary *responsedictionary = []
         
         //                                                  [self.delegate performSelector:responseselector withObject:responsedictionary];
         NSString *str = [operation responseString];
         NSLog(@"\n\n +++++>> Response String : %@",str);
         //
         NSLog(@"\n\n +++++>> Response Error Message : %@",[error localizedDescription]);
         //        NSLog(@"\n\n +++++>> Response error : %@",[error debugDescription]);
     }];
    
    
    [operation start];
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        //        DELEGATE.TotalFile = totalBytesExpectedToWrite;
        //        DELEGATE.RecivedFile = totalBytesWritten;
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
}


-(void)postImage:(NSMutableDictionary *)postdatadictionary img:(NSData *)img img2:(NSData *)img2 img3:(NSData *)img3 img4:(NSData *)img4 img5:(NSData *)img5
{
    
    //NSLog(@"post dictionary =%@",postdatadictionary);

   /*
    NSData *imageData = UIImagePNGRepresentation(img);
    NSData *imageData1 = UIImagePNGRepresentation(img1);
    NSData *imageData2 = UIImagePNGRepresentation(img2);
    NSData *imageData3 = UIImagePNGRepresentation(img3);*/
    
    
    AFHTTPRequestOperationManager *operationmanager = [AFHTTPRequestOperationManager manager];
    operationmanager.responseSerializer = [AFJSONResponseSerializer serializer];
    operationmanager.responseSerializer.acceptableContentTypes = [operationmanager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    operationmanager.responseSerializer.acceptableContentTypes = [operationmanager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/json"];


    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    // 2. Create an `NSMutableURLRequest`.
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:URL
                                    parameters:postdatadictionary
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         
                         
                         if(img)
                         {
                             //NSData *imageData = UIImagePNGRepresentation(img);
                             [formData appendPartWithFileData:img
                                                         name:@"image"
                                                     fileName:@"myimage.jpeg"
                                                     mimeType:@"image/png/jpeg"];
                         }
                       
                         if(img2)
                         {
                            // NSData *imageData2 = UIImageJPEGRepresentation(img2,1);

                             [formData appendPartWithFileData:img2
                                                         name:@"image2"
                                                     fileName:@"myimage2.jpeg"
                                                     mimeType:@"image/png/jpeg"];
                         }
                         if(img3)
                         {
                            // NSData *imageData3 = UIImageJPEGRepresentation(img3,1);

                             [formData appendPartWithFileData:img3
                                                         name:@"image3"
                                                     fileName:@"myimage3.jpeg"
                                                     mimeType:@"image/png/jpeg"];
                         }
                         if(img4)
                         {
                             // NSData *imageData3 = UIImageJPEGRepresentation(img3,1);
                             
                             [formData appendPartWithFileData:img4
                                                         name:@"image4"
                                                     fileName:@"myimage4.jpeg"
                                                     mimeType:@"image/png/jpeg"];
                         }
                         if(img5)
                         {
                             // NSData *imageData3 = UIImageJPEGRepresentation(img3,1);
                             
                             [formData appendPartWithFileData:img5
                                                         name:@"image5"
                                                     fileName:@"myimage5.jpeg"
                                                     mimeType:@"image/png/jpeg"];
                         }
                   
                         
                     }];
    
    
    //
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //
    //    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    AFHTTPRequestOperation *operation =
    [operationmanager HTTPRequestOperationWithRequest:request
                                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                                  
                                                  [drk hide];
                                                  NSDictionary *responsedictionary = (NSDictionary *)responseObject;
                                                  //  NSLog(@"\n\n +++++>> Response Dictionary Data : %@",responsedictionary);
                                                  [self.delegate performSelector:responseselector withObject:responsedictionary];
                                                  //                                         [drk hide];
                                                  //                                         [drkipad hide];
                                                  NSLog(@"Success %@", responseObject);
                                                  
                                                  
                                                  
                                                  
                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  //                                         [drk hide];
                                                  //                                         [drkipad hide];
                                                  [drk hide];
                                                  NSLog(@" +++++>> in post api Failer %@",error.localizedDescription);
                                                  
                                                  if([operation responseObject] != nil)
                                                  {
                                                      [self.delegate performSelector:responseselector withObject:[operation responseObject]];
                                                  }
                                                  else
                                                  {
                                                      
                                                        [DELEGATE showalert:nil Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
                                                  
                                                  }

                                              }];
     [operation start];
    
}
- (void)postPath:(NSString *)path
      parameters:(NSMutableDictionary *)params
completeNetworkBlock:(completeNetworkBlock)completeNetworkBlock
      errorBlock:(errorBlock)errorBlock
{
    
    
   // showIndicator();
    
    completeNetworkBlock_ = [completeNetworkBlock copy];
    errorBlock_ = [errorBlock copy];
    

    
 
    NSLog(@"params dictionary is :%@", params);
    NSString *BaseURLString = API_PATH;
    NSURL *baseURL = [NSURL URLWithString:BaseURLString];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    //    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    //    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:path parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        SBJsonParser *parser=[[SBJsonParser alloc] init];
      // [drk hide];
        completeNetworkBlock_([parser objectWithData:responseObject]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        SBJsonParser *parser=[[SBJsonParser alloc] init];
      // [drk hide];
        NSLog(@"error :%@", [parser objectWithData:error]);
        errorBlock_([parser objectWithData:error]);
        
    }];
}

-(void)postData:(NSMutableDictionary *)postdatadictionary{
    NSLog(@"post dictionary =%@",postdatadictionary);
    
    NSURL *baseURL = [NSURL URLWithString:URL];
    
  //  AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
 
    AFHTTPRequestOperationManager *operationmanager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];

    operationmanager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    operationmanager.responseSerializer.acceptableContentTypes = [operationmanager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [operationmanager POST:URL parameters:postdatadictionary success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [drk hide];
        
         NSLog(@" +++++>> in post api success ");
         
         
        // NSString *func = [self getFunc:[NSURL URLWithString:URL]];
         NSString *func = [self getFunc:operationmanager.baseURL];

      //   NSLog(@" +++++>> %@",func);

         if ([func isEqual:@"newfeed"])
         {
             NSLog(@" +++++>> in post api success url is %@",URL);

             NSDictionary *responsedictionary = (NSDictionary *)responseObject;
             [self.delegate performSelector:newFeed withObject:responsedictionary];
         }
        else if ([func isEqual:@"myfeed"])
         {
             NSDictionary *responsedictionary = (NSDictionary *)responseObject;
             [self.delegate performSelector:myFeed withObject:responsedictionary];
         }
         else
         {
             NSDictionary *responsedictionary = (NSDictionary *)responseObject;
             [self.delegate performSelector:responseselector withObject:responsedictionary];
         }

       
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [drk hide];
     
        NSLog(@" +++++>> in post api Failer %@",error.localizedDescription);
        
        if([operation responseObject] != nil)
        {
           // NSString *func = [self getFunc:[NSURL URLWithString:URL]];
            NSString *func = [self getFunc:operationmanager.baseURL];


            if ([func isEqual:@"newfeed"])
            {
                [self.delegate performSelector:newFeed withObject:[operation responseObject]];
            }
            else if ([func isEqual:@"myfeed"])
            {
                [self.delegate performSelector:myFeed withObject:[operation responseObject]];
            }
            else
            {
                [self.delegate performSelector:responseselector withObject:[operation responseObject]];
            }
        }
        else
        {
            NSString *func = [self getFunc:operationmanager.baseURL];

            NSMutableDictionary *dict =[[NSMutableDictionary alloc] init];
            [dict setValue:error.localizedDescription forKey:@"message"];
            [dict setValue:@"401" forKey:@"code"];
            [DELEGATE showalert:nil Message:error.localizedDescription AlertFlag:1 ButtonFlag:1];
            
            if ([func isEqual:@"newfeed"])
            {
                [self.delegate performSelector:newFeed withObject:dict];
            }
            else if ([func isEqual:@"myfeed"])
            {
                [self.delegate performSelector:myFeed withObject:dict];
            }
            else
            {
                [self.delegate performSelector:responseselector withObject:dict];
            }
        }

     
        
    }];
    

}
-(void)GetData:(NSMutableDictionary *)postdatadictionary{
    AFHTTPRequestOperationManager *operationmanager = [AFHTTPRequestOperationManager manager];
    
    operationmanager.requestSerializer = [AFJSONRequestSerializer serializer];
    [operationmanager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [operationmanager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [operationmanager GET:URL parameters: postdatadictionary    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responsedictionary = (NSDictionary *)responseObject;
        NSLog(@" +++++>> in getapi success ");
        [self.delegate performSelector:responseselector withObject:responsedictionary];
        [drk hide];
       
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" +++++>> in getapi failure %@",error.localizedDescription);

        [drk hide];
        
        
        
    }];
    
}
-(void)putData:(NSMutableDictionary *)postdatadictionary{
    AFHTTPRequestOperationManager *operationmanager = [AFHTTPRequestOperationManager manager];

    operationmanager.requestSerializer = [AFJSONRequestSerializer serializer];
    [operationmanager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [operationmanager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [operationmanager PUT:URL parameters: postdatadictionary    success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary *responsedictionary = (NSDictionary *)responseObject;
        //  NSLog(@"\n\n +++++>> Response Dictionary Data : %@",responsedictionary);
        [self.delegate performSelector:responseselector withObject:responsedictionary];
        [drk hide];



    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [drk hide];

       // NSString *str = [operation responseString];
      //  NSLog(@"\n\n +++++>> Response String : %@",str);
        //
        //        NSLog(@"\n\n +++++>> Response Error Message : %@",[error localizedDescription]);
        //        NSLog(@"\n\n +++++>> Response error : %@",[error debugDescription]);

    }];

}
- (NSString *) getFunc:(NSURL *)url
{
    NSString *str = [NSString stringWithFormat:@"%@",url];
    //seperating the url with a slash "/"
    NSArray *arr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
    
   /* NSLog(@"url object is %@",url);

    NSLog(@"arr object is %@",arr);

    NSLog(@"last object is %@",[arr lastObject]);
    NSLog(@"last object is %@",[arr objectAtIndex:arr.count-2]);*/
    
    if(arr.count>2)
    {
        return [arr objectAtIndex:arr.count-2];
    }
    else
    {
        return @"";
    }

    
}


@end