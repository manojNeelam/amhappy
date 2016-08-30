//
//  AppDelegate.h
//  AmHappy
//
//  Created by Peerbits 8 on 04/02/15.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import <CoreData/CoreData.h>
#import "DB.h"
#import "XMPPFramework.h"
#import "XMPPLastActivity.h"
#import "CustomAlert.h"
#import "CustomImageAlert.h"
//#import "XMPPRoomMemoryStorage.h"




//NSString *const kXMPPmyJID = @"kXMPPmyJID";
//NSString *const kXMPPmyPassword = @"kXMPPmyPassword";


#import "XMPPRoom.h"
#import "XMPPRoomMemoryStorage.h"


//XMPPRoomDelegate

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,CLLocationManagerDelegate,XMPPRosterDelegate,CustomAlertDelegate,XMPPRoomDelegate,CustomImageAlertDelegate>
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    NSString *password;
    BOOL allowSelfSignedCertificates;
    BOOL allowSSLHostNameMismatch;
    BOOL isXmppConnected;
    
    
    
     __strong XMPPRoom   * xmppRoom;
     __strong id <XMPPRoomStorage> xmppRoomStorage;
     XMPPRoomMemoryStorage *roomStorage;
  
}

@property (strong, nonatomic) UIWindow *window;
- (BOOL) connectedToNetwork;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (retain, nonatomic) NSString *tokenstring;
@property (strong, nonatomic) UITabBarController *tabBarController;
- (BOOL)validateEmail:(NSString *)email ;
@property (retain, nonatomic) CLLocationManager *locationManager;
-(void)setWindowRoot;
@property (retain, nonatomic) NSMutableArray *categoryArray;
@property (retain, nonatomic) NSMutableArray *selectedCategoryArray;
@property (retain, nonatomic) NSMutableArray *categoryDictionaryArray;

-(void)enableIQKeyboard;


-(void)DisableIQKeyboard;

- (NSString *) substituteEmoticons:(NSString *)stringToReplace;
-(NSMutableArray*)getArrayByRemovingString:(NSString*)String fromstring:(NSString *)fromstring;

////////*****XMPP*****////////


@property(nonatomic,assign)BOOL isUpdatePromotions;

@property (nonatomic) BOOL isMessage;
@property (nonatomic) BOOL isAddtoWaitlist;
@property (nonatomic) BOOL isWaitlisted;
@property (nonatomic) BOOL isRevealIdentity ;
@property (nonatomic) BOOL isAbout;
@property (nonatomic) BOOL isChat;
@property (nonatomic) BOOL isAssociateFb;
@property (nonatomic) long long TotalFile;
@property (nonatomic) long long RecivedFile;

@property (nonatomic, strong, readonly) NSString *FriendName;
@property (nonatomic, strong, readonly) NSString *FriendMessage;
@property (nonatomic, strong) NSString *FrienID;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property (nonatomic, strong, readonly)  XMPPLastActivity *xmppLastActivity;
//@property (nonatomic, strong, readonly) XMPPRoomMemoryStorage *roomStorage;

@property (nonatomic)  unsigned long lastSeconds;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;
- (void)goOnline;
- (void)goOffline;
- (BOOL)connect;
- (void)disconnect;
@property(nonatomic,strong) DB *db;
- (void)setupStream;
@property (retain, nonatomic) NSMutableDictionary *presences;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)GettingDirectryPath;
- (void)teardownStream;

-(NSString *)getTimestamp:(NSDate *)date;
- (BOOL) connectedToNetwork2;

-(BOOL)IsValidEmail:(NSString *)emailString;


-(void)showalert:(UIViewController *)containerView Message:(NSString *)msg AlertFlag:(int)alertFlag ButtonFlag:(int)buttonFlag;
-(void)showCustomImageAlert:(NSString *)url Type:(int)type;

-(void)showalertNew:(UIViewController *)containerView Message:(NSString *)msg AlertFlag:(int)alertFlag;


- (NSString *) GetUniversalTime:(NSDate *)IN_strLocalTime;

-(void)createRoom:(NSString *)fromJid;
-(void)leaveFromRoom;


@property(nonatomic,assign)int frinedReqbadgeValue;

@property(nonatomic,assign)int BoardbadgeValue;


@property (nonatomic,assign) BOOL isGroupUpdated;

@property (nonatomic) BOOL isAccepted;
@property (nonatomic) BOOL isInvited;

@property (nonatomic) BOOL isEventEdited;
@property (nonatomic) BOOL isEventEditedList;










@end

