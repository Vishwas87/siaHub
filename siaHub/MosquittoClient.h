//
//  MosquittoClient.h
//
//  Copyright 2012 Nicholas Humfrey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mosquitto_message.h"

@protocol MosquittoClientDelegate<NSObject>

- (void) didConnect: (NSUInteger)code;
- (void) didDisconnect;
- (void) didPublish: (NSUInteger)messageId;

- (void) didReceiveMessage: (mosquitto_message*)mosq_msg;
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos;
- (void) didUnsubscribe: (NSUInteger)messageId;

@end


@interface MosquittoClient : NSObject {
    struct mosquitto *mosq;
    NSString *host;
    unsigned short port;
    NSString *username;
    NSString *password;
    unsigned short keepAlive;
    BOOL cleanSession;
    
    id<MosquittoClientDelegate> delegate;
    NSTimer *timer;
}

@property (readwrite,retain) NSString *host;
@property (readwrite,assign) unsigned short port;
@property (readwrite,retain) NSString *username;
@property (readwrite,retain) NSString *password;
@property (readwrite,assign) unsigned short keepAlive;
@property (readwrite,assign) BOOL cleanSession;
@property (readwrite,assign) id<MosquittoClientDelegate> delegate;

+ (void) initialize;
+ (NSString*) version;


- (MosquittoClient*) initWithClientId: (NSString *)clientId;
- (void) setMessageRetry: (NSUInteger)seconds;
- (int) connect;
- (void) connectToHost: (NSString*)host;
- (void) reconnect;
- (void) disconnect;

- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain;
- (void)clearWill;

- (int)publishString: (NSString *)payload toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain;

- (int)subscribe: (NSString *)topic;
- (int)subscribe: (NSString *)topic withQos:(NSUInteger)qos;
- (void)unsubscribe: (NSString *)topic;

+(NSString*)createMessageForId:(NSString*)ident responseTo:(NSString*)responseTo
                     name:(NSString*)name command:(NSDictionary*)command
                        header:(NSDictionary*)header body:(NSDictionary*)body andSender:(NSString*)sender;



// This is called automatically when connected
- (void) loop: (NSTimer *)timer;

@end
