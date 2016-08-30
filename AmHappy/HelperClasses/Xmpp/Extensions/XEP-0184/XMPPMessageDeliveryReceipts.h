#import "XMPPModule.h"

#define _XMPP_MESSAGE_DELIVERY_RECEIPTS_H

/**
 * XMPPMessageDeliveryReceipts can be configured to automatically send delivery receipts and requests in accordance to XEP-0184
**/

@interface XMPPMessageDeliveryReceipts : XMPPModule

/**
 * Automatically add message delivery requests to outgoing messages, in all situations that are permitted in XEP-0184
 *
 * - Message MUST NOT be of type 'error' or 'groupchat'
 * - Message MUST have an id
 * - Message MUST NOT have a delivery receipt or request
 * - To must either be a bare JID or a full JID that advertises the urn:xmpp:receipts capability
 *
 * Default NO
**/
- (BOOL)activate:(XMPPStream *)aXmppStream;
@property (assign) BOOL autoSendMessageDeliveryRequests;

/**
 * Automatically send message delivery receipts when a message with a delivery request is received 
 *
 * Default NO
**/
- (void)setAutoSendMessageDeliveryRequests:(BOOL)flag;
@property (assign) BOOL autoSendMessageDeliveryReceipts;

@end