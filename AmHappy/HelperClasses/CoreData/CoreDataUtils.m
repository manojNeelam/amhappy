//
//  CoreDataUtils.m
//
//  Utilites method for CoreData
//  Created by Hai Trinh on 11/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "CoreDataUtils.h"
#import "AppDelegate.h"

@implementation CoreDataUtils
@synthesize managedObjectModel, managedObjectContext, persistentStoreCoordinator;

+ (CoreDataUtils *) shared
{
    
    static CoreDataUtils *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataUtils alloc] init];
    });
    return instance;
}

- (void) dealloc
{
    self.managedObjectContext = nil;
    self.managedObjectModel = nil;
    self.persistentStoreCoordinator = nil;
}

#pragma mark - 
#pragma mark Core Data stack
- (NSManagedObjectContext *)managedObjectContext {	
    if (!managedObjectContext) 
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) 
        {    
            managedObjectContext = [NSManagedObjectContext new];
            [managedObjectContext setPersistentStoreCoordinator: coordinator];
        }
    }
    
    return managedObjectContext;
   
}

- (NSManagedObjectModel *)managedObjectModel {	
    if (!managedObjectModel) 
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"AmHappy" ofType:@"momd"];
        NSURL *momURL = [NSURL fileURLWithPath:path];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    }
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{	
    
    
    @try
    {
        if (!persistentStoreCoordinator)
        {
            NSURL *storeUrl = [NSURL fileURLWithPath:DATABSE_PATH];
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                     [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            NSError *error;
            persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
            if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
            {
                //we need to remove the database
#ifndef BUILD_DEBUG
                [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:nil];
#endif
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                //abort();
            }
        }
        
        return persistentStoreCoordinator;
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@", exception.reason);
        NSLog(@" in catch block");
        
    }
    @finally {
        NSLog(@" in finally block");
        
    }
}

+ (void) closeDatabaseConnection
{
    [[self shared] setManagedObjectContext:nil];
}

+(NSManagedObjectContext *) defaultContext
{
	return [[self shared] managedObjectContext];
}

+(NSInteger) getNextID : (NSString *) entityName
{
	static NSMutableDictionary *dictID;
	
	if(!dictID)
	{
		dictID	=	[[NSMutableDictionary alloc] init];
	}
	
	NSNumber *val						=	[dictID objectForKey:entityName];
	NSInteger newID	=	0;
	if(val)
	{
		newID	=	[val intValue] + 1;
		val = [NSNumber numberWithInt:newID];
		[dictID setObject:val forKey:entityName];
		return newID;
	}
	
	
	// setup request
	NSFetchRequest *request		= [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[self defaultContext]];
   [request setEntity:entity];
   
   // need to use dictionary to access values
   [request setResultType:NSDictionaryResultType];
   

   NSExpression *attributeToFetch = [NSExpression expressionForKeyPath:@"identifier"];
   NSExpression *functionToPerformOnAttribute = [NSExpression expressionForFunction:@"max:" 
																		  arguments:[NSArray arrayWithObject:attributeToFetch]];
   
   NSExpressionDescription *propertyToFetch = [[NSExpressionDescription alloc] init];
   [propertyToFetch setName:@"maxID"]; 
   [propertyToFetch setExpression:functionToPerformOnAttribute];
   [propertyToFetch setExpressionResultType:NSInteger32AttributeType];
   
   // modify request to fetch only the attribute
   [request setPropertiesToFetch:[NSArray arrayWithObject:propertyToFetch]];
   
   // execute fetch
   NSArray *results = [[self defaultContext] executeFetchRequest:request error:nil];
   
	// get value
	if ([results count] > 0)
	{
	   	newID	=	[[[results objectAtIndex:0] valueForKey:@"maxID"] intValue]+1;
	}
	   
    [dictID setObject:[NSNumber numberWithInt:newID] forKey:entityName];
	return newID;
}

+(void) rollBack
{
	[[self defaultContext] rollback];
}


#pragma mark update database
+(void) updateDatabase
{
    [self updateDatabaseWithContext:[self defaultContext]];	
}

+(void)updateDatabaseWithContext: (NSManagedObjectContext *) ctx
{
    NSError *error;
	if ([ctx hasChanges] && ![ctx save:&error]) {
		NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
		NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
		if(detailedErrors && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				NSLog(@"DetailedError: %@", [detailedError userInfo]);
			}
		}
		else {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}		
		//abort();
	} 
}

#pragma mark Select Methods

+(id) getObject: (NSString *) entityName
{
	NSArray *result	=	 [self getObjects:entityName inContext:[self defaultContext]];
	
	return	[result count] > 0 ? [result objectAtIndex:0] : nil;
}

+(id) getObject: (NSString *) entityName withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments
{
	NSArray *result	=	 [self getObjects:entityName inContext:[self defaultContext] withQueryString:queryString queryArguments:arguments];
	return	[result count] > 0 ? [result objectAtIndex:0] : nil;
}

+(id) getObject: (NSString *) entityName withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys
{
	NSArray *result	=	 [self getObjects:entityName inContext:[self defaultContext] withQueryString:queryString queryArguments:arguments sortBy:sortKeys];
	return	[result count] > 0 ? [result objectAtIndex:0] : nil;
}

+(id) getObject: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx
{
	NSArray *result	=	 [self getObjects:entityName inContext:ctx withQueryString:nil queryArguments:nil];
	return	[result count] > 0 ? [result objectAtIndex:0] : nil;
}

+(id) getObject: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments
{
	NSArray *result	=	 [self getObjects:entityName inContext:ctx withQueryString:queryString queryArguments:arguments sortBy:nil];
	return	[result count] > 0 ? [result objectAtIndex:0] : nil;
}

+(id) getObject: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys
{
	NSArray *result	=	[self getObjects:entityName inContext:ctx withQueryString:queryString queryArguments:arguments sortBy:sortKeys cacheName:entityName];
	
	return	[result count] > 0 ? [result objectAtIndex:0] : nil;
}

+(NSArray *) getObjects: (NSString *) entityName
{
	return [self getObjects:entityName inContext:[self defaultContext]];
}

+(NSArray *) getObjects: (NSString *) entityName withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments
{
	return [self getObjects:entityName inContext:[self defaultContext] withQueryString:queryString queryArguments:arguments];
}

+(NSArray *) getObjects: (NSString *) entityName withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys
{
	return [self getObjects:entityName inContext:[self defaultContext] withQueryString:queryString queryArguments:arguments sortBy:sortKeys];
}

+(NSArray *) getObjects: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx
{
	return [self getObjects:entityName inContext:ctx withQueryString:nil queryArguments:nil];
}

+(NSArray *) getObjects: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments
{
	return [self getObjects:entityName inContext:ctx withQueryString:queryString queryArguments:arguments sortBy:nil];
}

+(NSArray *) getObjects: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys
{
	return [self getObjects:entityName inContext:ctx withQueryString:queryString queryArguments:arguments sortBy:sortKeys cacheName:entityName];//should generate this cachename
}

+(NSArray *) getObjects: (NSString *) entityName inContext:(NSManagedObjectContext *) ctx withQueryString:(NSString *) queryString queryArguments:(NSArray *) arguments sortBy:(NSDictionary *) sortKeys cacheName: (NSString *) cacheName
{	
	NSFetchRequest		*request	=	[[NSFetchRequest alloc] init];
	NSEntityDescription *entity		=	[NSEntityDescription entityForName:entityName inManagedObjectContext:ctx];
	
	[request			setEntity:entity];
//    [request            setFetchBatchSize:5];
	
	if([queryString length] > 0)
	{
		NSPredicate *query	=	[NSPredicate predicateWithFormat:queryString argumentArray:arguments];
		[request setPredicate:query];
	}

	NSSortDescriptor *sortDesc;
	NSMutableArray	 *sortDescs	=	[[NSMutableArray alloc] init];
	for(NSString *sortKey in [sortKeys allKeys])
	{
		BOOL isAscending	=	[[sortKeys objectForKey:sortKey] boolValue];
		sortDesc			=	[[NSSortDescriptor alloc] initWithKey:sortKey ascending:isAscending];
		[sortDescs	addObject:sortDesc];
	}
	
	if([sortDescs count] == 0)//Default is sort by ID ascending
	{
		NSDictionary	*attributes	=	[entity attributesByName];
		NSArray			*defSorts	=	[NSArray arrayWithObjects:@"serverID", @"identifier", nil];
		
		for(NSString *sortKey in defSorts)
		{
			if([attributes valueForKey:sortKey])
			{
				sortDesc	=	[[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
				[sortDescs addObject:sortDesc];
			}
		}
	}

	[request			setSortDescriptors:sortDescs];
	
	NSError *error;
	NSArray *result;
	NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request 
																				 managedObjectContext:ctx 
																				   sectionNameKeyPath:nil 
																							cacheName:cacheName];
	
	
	if(![controller		performFetch:&error])
	{
		result	=	[NSArray array];
	}
	else 
	{
		result	=	controller.fetchedObjects  ;
	}
	
	
	return result;	
}

#pragma mark delete methods

+(void) deleteObject: (NSManagedObject *) obj
{    
	[self deleteObject:obj inContext:[self defaultContext]];
}

+(void) deleteObject: (NSManagedObject *) obj inContext:(NSManagedObjectContext *) ctx
{
    if(obj == nil)
        return;
    
	[ctx deleteObject:obj];
	//[self updateDatabaseWithContext:ctx];
}

#pragma mark insert methods
+(void) insertObject: (NSManagedObject *) obj
{
	[self insertObject:obj inContext:[self defaultContext]];
}

+(void) insertObject: (NSManagedObject *) obj inContext:(NSManagedObjectContext *) ctx
{
	[ctx insertObject:obj];
	[self updateDatabaseWithContext:ctx];
}

@end
