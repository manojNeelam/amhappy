//
//  NSManagedObject+Utilities.m
//  TurnStone
//  utilites method for CoreData
//  Created by Tuong Hoang on 1/19/11.
//  Copyright 2011 TVD Corp. All rights reserved.
//

#import "NSManagedObject+Utilities.h"
#import "CoreDataUtils.h"

@implementation NSManagedObject(Utilities)


//
// Returns YES if this managed object is new and has not yet been saved in the persistent store.
//
- (BOOL)isNew {
    NSDictionary *vals = [self committedValuesForKeys:nil];
    return [vals count] == 0;
}

+ (id) newInsertedObject {
	NSManagedObjectContext* managedObjectContext = [CoreDataUtils defaultContext];
	
	return [NSEntityDescription insertNewObjectForEntityForName: [[self class] description] inManagedObjectContext: managedObjectContext];
}

+ (id) newInsertedObjectInContext: (NSManagedObjectContext *) ctx
{
	return [NSEntityDescription insertNewObjectForEntityForName: [[self class] description] inManagedObjectContext: ctx];
}

+ (id)newTempObject{
    NSEntityDescription *entity = [NSEntityDescription entityForName:[[self class] description]  inManagedObjectContext:[CoreDataUtils defaultContext]];
    return  [[[self class] alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
}


+(NSDictionary *) attributes
{
	return [[NSEntityDescription entityForName:[[self class] description] 
						inManagedObjectContext:[CoreDataUtils defaultContext]] attributesByName];
}

+(NSInteger) getNextID
{
	return [CoreDataUtils getNextID:[[self class] description]];
}

+(NSArray *) getAllObjects
{
	return [CoreDataUtils getObjects:[[self class] description]];
}

+(NSArray *) getObjectsBySubType:(NSString*) subType{
    NSArray *result;
//    if ([subType isEqualToString:@"all"]) {
//        result = [CoreDataUtils getObjects:[[self class] description]];
//    }else{
//        result = [CoreDataUtils getObjects:[[self class] description] 
//                         withQueryString:@"subType = %@" 
//                          queryArguments:[NSArray arrayWithObject:subType]];
//    }
//    // Sort by order
//    result = [result sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [((Advice*)obj1).order intValue] > [((Advice*)obj2).order intValue];
//    }];
    return result;
}

+(NSArray *) getAllObjectsInContext: (NSManagedObjectContext *) ctx
{
	return [CoreDataUtils getObjects:[[self class] description] inContext:ctx];
}

+(id) getObjectByID: (NSInteger) ID
{
	return [CoreDataUtils getObject:[[self class] description] 
					withQueryString:@"identifier = %d" 
					 queryArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:ID]]];

}

+(id) getObjectsByID: (NSInteger) ID
{
	return [CoreDataUtils getObjects:[[self class] description] 
					 withQueryString:@"identifier = %d" 
					  queryArguments:[NSArray arrayWithObject:[NSNumber numberWithInt:ID]]];
	
}

-(void) deleteObject
{
	[CoreDataUtils deleteObject:self];
}

-(void) deleteObjectInContext: (NSManagedObjectContext *) ctx
{
	[CoreDataUtils deleteObject:self inContext:ctx];
}

@end
