//
//  DB.h
//  AmHappy
//
//  Created by Peerbits 8 on 13/03/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DB : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * delivered;
@property (nonatomic, retain) NSNumber * from;
@property (nonatomic, retain) NSString * idd;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * isClear;
@property (nonatomic, retain) NSString * isShow;
@property (nonatomic, retain) NSString * jid;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * messageType;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * unread;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * waitingType;

@end
