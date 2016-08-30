//
//  CoreDataUtils.h
//  
//  Utilites method for CoreData
//  Created by Hai Trinh on 11/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <stdlib.h>
@interface CoreDataUtils : NSObject {
    
}

@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (CoreDataUtils *) shared;


//create context
+ (NSManagedObjectContext *) defaultContext;
+ (void) closeDatabaseConnection;
//get next available id
+(NSInteger) getNextID : (NSString *) entityName;

//rollback
+(void) rollBack;

//update db
+(void)updateDatabase;
+(void)updateDatabaseWithContext: (NSManagedObjectContext *) ctx;

//delete
+(void) deleteObject: (NSManagedObject *) object;
+(void) deleteObject: (NSManagedObject *) obj inContext:(NSManagedObjectContext *) ctx;
+(void) insertObject: (NSManagedObject *) obj;
+(void) insertObject: (NSManagedObject *) obj inContext:(NSManagedObjectContext *) ctx;
//select
+(id) getObject: (NSString *) entityName;
+(id) getObject: (NSString *) entityName withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments;
+(id) getObject: (NSString *) entityName withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys;
+(id) getObject: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx;
+(id) getObject: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments;
+(id) getObject: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys;
+(NSArray *) getObjects: (NSString *) entityName;
+(NSArray *) getObjects: (NSString *) entityName withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments;
+(NSArray *) getObjects: (NSString *) entityName withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys;
+(NSArray *) getObjects: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx;
+(NSArray *) getObjects: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments;
+(NSArray *) getObjects: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys;
+(NSArray *) getObjects: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys cacheName: (NSString *) cacheName;
@end
