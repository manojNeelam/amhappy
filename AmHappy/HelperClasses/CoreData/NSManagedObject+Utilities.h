//
//  NSManagedObject+Utilities.h
//  TurnStone
//  utilites method for CoreData
//  Created by Tuong Hoang on 1/19/11.
//  Copyright 2011 TVD Corp. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface NSManagedObject(Uitilites)

- (BOOL) isNew;
+ (id) newInsertedObject;
+ (id) newInsertedObjectInContext: (NSManagedObjectContext *) ctx;
+(NSDictionary *) attributes;
+(NSInteger) getNextID;
+(NSArray *) getAllObjects;
+(NSArray *) getObjectsBySubType:(NSString*) subType;
+(NSArray *) getAllObjectsInContext: (NSManagedObjectContext *) ctx;
+(id) getObjectByID: (NSInteger) ID;
+(NSArray *) getObjectsByID: (NSInteger) ID;
-(void) deleteObject;
-(void) deleteObjectInContext: (NSManagedObjectContext *) ctx;
+ (id)newTempObject;
@end
