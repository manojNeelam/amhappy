//
//  ModelClass.h
//  APITest
//
//  Created by Evgeny Kalashnikov on 03.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SBJson.h"
#import "DarckWaitView.h"
#import "AFHTTPRequestOperation.h"
#import "AFNetworking.h"

#import "TYMActivityIndicatorViewViewController.h"



typedef void (^completeNetworkBlock)(NSMutableDictionary *data);
typedef void (^errorBlock)(NSMutableDictionary *error);


@class DarckWaitView;
@class DarckWaitView_pad;
@interface ModelClass : NSObject {
  
    
    
    SEL responseselector;
    NSString *temp;
    TYMActivityIndicatorViewViewController *drk;
    NSString *URL;
    
    SEL myFeed;
    SEL newFeed;
    
    NSMutableData *data_;
    completeNetworkBlock completeNetworkBlock_;
    errorBlock errorBlock_;
}
@property (nonatomic, retain)  NSString *temp;
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) id returnData;
@property (nonatomic, readwrite) BOOL success;

/*
-(void)getDropDown:(NSString *)language Sel:(SEL)sel;
-(void)registerUser:(NSString *)userid Personality:(NSString *)personality Birthdate:(NSString *)birthdate Language:(NSString *)language Mobile:(NSString *)mobile Gender:(NSString *)gender Flexible_age:(NSString *)flexible_age Min_age:(NSString *)min_age Max_age:(NSString *)max_age Want_gender:(NSString *)want_gender Sel:(SEL)sel;

-(void)varifyUser:(NSString *)userid Code:(NSString *)code Sel:(SEL)sel;

 */

- (void)postPath:(NSString *)path
      parameters:(NSMutableDictionary *)params
completeNetworkBlock:(completeNetworkBlock)completeNetworkBlock
      errorBlock:(errorBlock)errorBlock;

-(void)loginUser:(NSString *)username Password:(NSString *)password Device_id:(NSString *)device_id Sel:(SEL)sel;

-(void)MakeAdmin:(NSString *)userid eventid:(NSString *)eventid friendid:(NSString *)friendid Sel:(SEL)sel;


-(void)registerUser:(NSString *)username Fullname:(NSString *)fullname Email_id:(NSString *)email Password:(NSString *)password Device_id:(NSString *)device_id Sel:(SEL)sel;

-(void)forgotPassword:(NSString *)email Sel:(SEL)sel;

-(void)loginFBUser:(NSString *)facebookid Fullname:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Facebook_image:(NSString *)facebook_image Gender:(NSString *)gender Dob:(NSString *)dob Device_id:(NSString *)deviceid Sel:(SEL)sel;


-(void)loginGoogleUser:(NSString *)googleid Fullname:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Google_image:(NSString *)google_image Gender:(NSString *)gender Dob:(NSString *)dob Device_id:(NSString *)deviceid Sel:(SEL)sel;


-(void)loginTwitterUser:(NSString *)twitterid Fullname:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Twitter_image:(NSString *)twitter_image Gender:(NSString *)gender Dob:(NSString *)dob Device_id:(NSString *)deviceid Sel:(SEL)sel;


-(void)getDropDowns:(NSString *)userid Sel:(SEL)sel;


-(void)editUser:(NSString *)userid Fullname:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Image:(NSData *)image Gender:(NSString *)gender Dob:(NSString *)dob Hobbies:(NSString *)hobbies Relationship:(NSString *)relationship Password:(NSString *)password Device_id:(NSString *)deviceid Sel:(SEL)sel;


-(void)createUser:(NSString *)fullname Username:(NSString *)username Email_id:(NSString *)email Image:(NSData *)image Gender:(NSString *)gender Dob:(NSString *)dob Hobbies:(NSString *)hobbies Relationship:(NSString *)relationship Password:(NSString *)password Device_id:(NSString *)deviceid Sel:(SEL)sel;

-(void)addPublicEvent:(NSString *)userid Name:(NSString *)name Description:(NSString *)description Image:(NSData *)image Category_id:(NSString *)category_id Type:(NSString *)type Location_json:(NSString *)location_json Date_json:(NSString *)date_json Voting_close_date:(NSString *)voting_close_date Price:(NSString *)price Sel:(SEL)sel;

-(void)getHomeEvents:(NSString *)userid Latitude:(NSString *)latitude Longitude:(NSString *)longitude Category_id:(NSString *)category_id Sel:(SEL)sel;

-(void)getMyEvents:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Keyword:(NSString *)keyword Sel:(SEL)sel;
-(void)logout:(NSString *)userid Sel:(SEL)sel;

-(void)addFeedback:(NSString *)userid Email:(NSString *)email Description:(NSString *)description Sel:(SEL)sel;

-(void)likedUserList:(NSString *)userid type:(NSString *)type Id:(NSString *)Id start:(NSString *)start limit:(NSString *)limit Sel:(SEL)sel;


-(void)getAttendingCount:(NSString *)userid eventid:(NSString *)eventid Sel:(SEL)sel;


-(void)getAttendList:(NSString *)userid eventid:(NSString *)eventid type:(NSString *)type Sel:(SEL)sel;


-(void)getUser:(NSString *)userid Sel:(SEL)sel;

-(void)editSetting:(NSString *)userid Recieve_push:(NSString *)recieve_push Langauge:(NSString *)langauge search_miles:(NSString *)search_miles Event_notification:(NSString *)event_notification Comment_notification:(NSString *)comment_notification Sel:(SEL)sel;

-(void)getEventDetail:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel;

-(void)addComment:(NSString *)userid Eventid:(NSString *)eventid Time:(NSString *)time Comment:(NSString *)comment Image:(NSData *)image is_multiple:(NSString *)is_multiple image2:(NSData *)image2 image3:(NSData *)image3 image4:(NSData *)image4 image5:(NSData *)image5 comment_tags:(NSString *)comment_tags Sel:(SEL)sel;

-(void)attendEvent:(NSString *)userid Eventid:(NSString *)eventid Is_attend:(NSString *)is_attend Sel:(SEL)sel;

-(void)getCommentList:(NSString *)userid Eventid:(NSString *)eventid Start:(NSString *)start Limit1:(NSString *)limit Sel:(SEL)sel;

-(void)vote:(NSString *)userid Eventid:(NSString *)eventid Type:(NSString *)type Voteid:(NSString *)voteid Sel:(SEL)sel;
-(void)voterList:(NSString *)userid Eventid:(NSString *)eventid Type:(NSString *)type Voteid:(NSString *)voteid Sel:(SEL)sel;

-(void)guestList:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel;

-(void)findFriends:(NSString *)userid Type:(NSString *)type Friendids:(NSString *)friendids Sel:(SEL)sel;

-(void)searchAllEvents:(NSString *)userid Keyword:(NSString *)keyword Category_id:(NSString *)category_id Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel;

-(void)editPublicEvent:(NSString *)userid Name:(NSString *)name Description:(NSString *)description Image:(NSData *)image Category_id:(NSString *)category_id Type:(NSString *)type Location_json:(NSString *)location_json Date_json:(NSString *)date_json Voting_close_date:(NSString *)voting_close_date Price:(NSString *)price Eventid:(NSString *)eventid Sel:(SEL)sel;

-(void)inviteFriendtoEvent:(NSString *)userid Eventid:(NSString *)eventid Friendids:(NSString *)friendids Type:(NSString *)type Sel:(SEL)sel;

-(void)sendFriendRequest:(NSString *)userid Friendid:(NSString *)friendid Sel:(SEL)sel;

-(void)acceptFriendRequest:(NSString *)userid Friendid:(NSString *)friendid Is_accept:(NSString *)is_accept Sel:(SEL)sel;


-(void)listFriendRequest:(NSString *)userid Sel:(SEL)sel;
-(void)listEventInvitation:(NSString *)userid Sel:(SEL)sel;

-(void)getAppUser:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Eventid:(NSString *)eventid Keyword:(NSString *)keyword Sel:(SEL)sel;
-(void)getFriends:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel;

-(void)listInvitedEvents:(NSString *)userid Json:(NSString *)json Sel:(SEL)sel;


-(void)sendOfflineMessage:(NSString *)userid To_id:(NSString *)to_id Message:(NSString *)message Sel:(SEL)sel;
-(void)sendOfflineGroupMessage:(NSString *)userid Event_id:(NSString *)event_id Message:(NSString *)message Sel:(SEL)sel;

-(void)deleteEvent:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel;

-(void)deleteComment:(NSString *)userid Comment_id:(NSString *)comment_id Sel:(SEL)sel;

-(void)searchFriends:(NSString *)userid Keyword:(NSString *)keyword Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel;

-(void)reportEvent:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel;

-(void)blockUser:(NSString *)userid Friendid:(NSString *)friendid Sel:(SEL)sel;

-(void)getBlockedUsers:(NSString *)userid Sel:(SEL)sel;

-(void)unBlockUser:(NSString *)userid Friendid:(NSString *)friendid Sel:(SEL)sel;

-(void)reportComment:(NSString *)userid Comment_id:(NSString *)comment_id Sel:(SEL)sel;

-(NSString *)encryptData:(NSString *)userid;


-(void)myGroups:(NSString *)userid Sel:(SEL)sel;
-(void)myGroupsForEvent:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel;



-(void)addGroup:(NSString *)userid Name:(NSString *)name Image:(NSData *)image Member_ids:(NSString *)member_ids Sel:(SEL)sel;

-(void)getMemberOfGroup:(NSString *)userid Groupid:(NSString *)groupid Sel:(SEL)sel;

-(void)getEventPhoto:(NSString *)userid Eventid:(NSString *)eventid Sel:(SEL)sel;

-(void)getMyFeed:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Timestamp:(NSString *)timestamp promo_ids:(NSString *)promo_ids Sel:(SEL)sel;

-(void)likeComment:(NSString *)userid Comment_id:(NSString *)comment_id Is_like:(NSString *)is_like Sel:(SEL)sel;

-(void)likeEvent:(NSString *)userid Eventid:(NSString *)eventid Is_like:(NSString *)is_like Sel:(SEL)sel;

-(void)addMemberToGroup:(NSString *)userid Groupid:(NSString *)groupid Member_ids:(NSString *)member_ids Sel:(SEL)sel;
-(void)getFriendsforAddinGroup:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Groupid:(NSString *)groupid Sel:(SEL)sel;



-(void)otherUpcomingInvitation:(NSString *)userid Otherid:(NSString *)otherid Sel:(SEL)sel;
-(void)otherExpiredInvitation:(NSString *)userid Otherid:(NSString *)otherid Sel:(SEL)sel;




-(void)getMyUpcomingEvents:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Keyword:(NSString *)keyword Sel:(SEL)sel;
-(void)getMyExpiredEvents:(NSString *)userid Start:(NSString *)start Limit:(NSString *)limit Keyword:(NSString *)keyword Sel:(SEL)sel;

-(void)searchUpcomingEvents:(NSString *)userid Keyword:(NSString *)keyword Category_id:(NSString *)category_id Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel;

-(void)searchExpiredEvents:(NSString *)userid Keyword:(NSString *)keyword Category_id:(NSString *)category_id Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel;

-(void)getUserNewsfeed:(NSString *)userid Timestamp:(NSString *)timestamp Sel:(SEL)sel;

#pragma mark ------------ version 3 -----------

-(void)editGroup:(NSString *)userid groupid:(NSString *)groupid name:(NSString *)name image:(UIImage *)image member_added:(NSString *)member_added member_remove:(NSString *)member_remove Sel:(SEL)sel;


-(void)eventInviteByMail:(NSString *)userid eventid:(NSString *)eventid email:(NSString *)email Sel:(SEL)sel;

-(void)deleteGroup:(NSString *)userid groupid:(NSString *)groupid Sel:(SEL)sel;

-(UIImage *)scaleAndRotateImage:(UIImage *)image;

#pragma mark ------------ Version 4 -------------

-(void)getPromotionTypes:(NSString *)userid Sel:(SEL)sel;

-(void)CreatePromotion:(NSString *)userid type_id:(NSString *)type_id promotion_type:(NSString *)promotion_type company_name:(NSString *)company_name description:(NSString *)description location:(NSString *)location latitude:(NSString *)latitude longitude:(NSString *)longitude website:(NSString *)website price:(NSString *)price discount:(NSString *)discount start_date:(NSString *)start_date end_date:(NSString *)end_date image:(NSData *)image Sel:(SEL)sel;


-(void)getPromotionList:(NSString *)userid start:(NSString *)start limit:(NSString *)limit keyword:(NSString *)keyword latitude:(NSString *)latitude longitude:(NSString *)longitude type_id:(NSString *)type_id promotion_type:(NSString *)promotion_type my_promo:(NSString *)my_promo Sel:(SEL)sel;

-(void)PromotionDetail:(NSString *)userid promo_id:(NSString *)promo_id Sel:(SEL)sel;

-(void)DeletePromotion:(NSString *)userid promo_id:(NSString *)promo_id  Sel:(SEL)sel;

-(void)EditPromotion:(NSString *)userid promo_id:(NSString *)promo_id type_id:(NSString *)type_id promotion_type:(NSString *)promotion_type company_name:(NSString *)company_name description:(NSString *)description location:(NSString *)location latitude:(NSString *)latitude longitude:(NSString *)longitude website:(NSString *)website price:(NSString *)price discount:(NSString *)discount start_date:(NSString *)start_date end_date:(NSString *)end_date image:(NSData *)image image_deleted:(NSString *)image_deleted Sel:(SEL)sel;


-(void)ReplyOnComment:(NSString *)userid eventid:(NSString *)eventid comment_id:(NSString *)comment_id reply:(NSString *)reply reply_tags:(NSString *)reply_tags image:(NSData *)image Sel:(SEL)sel;

-(void)ReplyLike:(NSString *)userid reply_id:(NSString *)reply_id is_like:(NSString *)is_like Sel:(SEL)sel;

-(void)GetReplies:(NSString *)userid comment_id:(NSString *)comment_id Sel:(SEL)sel;


#pragma mark -----------------------------------
//dax
-(void)DisplayUser:(NSString *)userid Keyword:(NSString *)keyword Start:(NSString *)start Limit:(NSString *)limit Sel:(SEL)sel;


















































@end
