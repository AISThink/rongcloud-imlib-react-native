//
//  RCTRongCloudIMLib.m
//  RCTRongCloudIMLib
//
//  Created by lovebing on 3/21/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTRongCloudIMLib.h"


@implementation RCTRongCloudIMLib
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(RongCloudIMLibModule)

RCT_EXPORT_METHOD(initWithAppKey:(NSString *) appkey) {
    NSLog(@"initWithAppKey %@", appkey);
    [[self getClient] initWithAppKey:appkey];
    
    [[self getClient] setReceiveMessageDelegate:self object:nil];
}

RCT_EXPORT_METHOD(setDeviceToken:(NSString *) deviceToken) {
    [[self getClient] setDeviceToken:deviceToken];
}

RCT_EXPORT_METHOD(connectWithToken:(NSString *) token
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"connectWithToken %@", token);
    //NSLog(@"connect_status %ld", (long)[[self getClient] getConnectionStatus]);
    
    void (^successBlock)(NSString *userId);
    successBlock = ^(NSString* userId) {
        NSArray *events = [[NSArray alloc] initWithObjects:userId,nil];
        resolve(@[[NSNull null], events]);
    };
    
    void (^errorBlock)(RCConnectErrorCode status);
    errorBlock = ^(RCConnectErrorCode status) {
        NSString *errcode;
        switch (status) {
            case RC_CONN_ID_REJECT:
                errcode = @"RC_CONN_ID_REJECT";
                break;
            case RC_CONN_TOKEN_INCORRECT:
                errcode = @"RC_CONN_TOKEN_INCORRECT";
                break;
            case RC_CONN_NOT_AUTHRORIZED:
                errcode = @"RC_CONN_NOT_AUTHRORIZED";
                break;
            case RC_CONN_PACKAGE_NAME_INVALID:
                errcode = @"RC_CONN_PACKAGE_NAME_INVALID";
                break;
            case RC_CONN_APP_BLOCKED_OR_DELETED:
                errcode = @"RC_CONN_APP_BLOCKED_OR_DELETED";
                break;
            case RC_DISCONN_KICK:
                errcode = @"RC_DISCONN_KICK";
                break;
            case RC_CLIENT_NOT_INIT:
                errcode = @"RC_CLIENT_NOT_INIT";
                break;
            case RC_INVALID_PARAMETER:
                errcode = @"RC_INVALID_PARAMETER";
                break;
            case RC_INVALID_ARGUMENT:
                errcode = @"RC_INVALID_ARGUMENT";
                break;
                
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    void (^tokenIncorrectBlock)();
    tokenIncorrectBlock = ^() {
        reject(@"TOKEN_INCORRECT", @"tokenIncorrect", nil);
    };
    
    NSInteger connectStatus = [[self getClient] getConnectionStatus];
    
    if(connectStatus != ConnectionStatus_Connected
       && connectStatus != ConnectionStatus_Connecting){
        [[self getClient] connectWithToken:token success:successBlock error:errorBlock tokenIncorrect:tokenIncorrectBlock];
    }    

    //NSLog(@"connect_status %ld", (long)[[self getClient] getConnectionStatus]);
    
}

RCT_EXPORT_METHOD(sendTextMessage:(NSString *)type
                  targetId:(NSString *)targetId
                  content:(NSString *)content
                  pushContent:(NSString *) pushContent
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    RCTextMessage *messageContent = [RCTextMessage messageWithContent:content];
    [self sendMessage:type targetId:targetId content:messageContent pushContent:pushContent resolve:resolve reject:reject];
    
    
}

RCT_EXPORT_METHOD(getSDKVersion:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSString* version = [[self getClient] getSDKVersion];
    resolve(version);
}

RCT_EXPORT_METHOD(disconnect:(BOOL)isReceivePush
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject
                                            ) {
    [[self getClient] disconnect:isReceivePush];
}

RCT_EXPORT_METHOD(getConversationList:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

        NSArray *conversationList = [[self getClient]
                          getConversationList:@[@(ConversationType_PRIVATE),
                                                @(ConversationType_DISCUSSION),
                                                @(ConversationType_GROUP),
                                                @(ConversationType_SYSTEM),
                                                @(ConversationType_APPSERVICE),
                                                @(ConversationType_PUBLICSERVICE)]];
    
        NSMutableArray * arr = [[NSMutableArray alloc] init];
    

        for (RCConversation *conversation in conversationList) {
          
            //最后一条消息的发送日期
//            NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:conversation.receivedTime];
            NSNumber * receivedTime     =   [NSNumber numberWithLongLong: conversation.receivedTime];
            NSNumber * converstationType=   [NSNumber numberWithUnsignedInteger:conversation.conversationType];
            NSNumber * unreadMsgCount   =   [NSNumber numberWithLongLong: conversation.unreadMessageCount];
            NSString * isTop            =   conversation.isTop?@"1":@"0";
            
            //组织会话json对象
            [arr addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            conversation.targetId ,         @"targetId",
                            converstationType,              @"conversationType",
                            conversation.conversationTitle, @"conversationTitle",
                            receivedTime,                   @"lastMessageTime",
                            unreadMsgCount,                 @"unreadMsgCount",
                            isTop,                          @"isTop",
                           [(RCTextMessage*)conversation.lastestMessage content] , @"lastestMessage",

                            nil]];
        }
        //格式化会话json对象
        NSError * parseError = nil;
        NSData  * jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error: &parseError ];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
       
        resolve(jsonString);

}

//获得远程的消息
RCT_EXPORT_METHOD(getRemoteHistoryMessages:(int)conversationType
                  targetId:(NSString *)targetId
                  recordTime:(NSUInteger *)recordTime
                  count:(int)count
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"-------------1--------------");
    
    void (^successBlock)(NSArray *messages);
    successBlock = ^(NSArray *messages) {
        NSArray *events = [[NSArray alloc] initWithObjects:messages,nil];
        resolve(@[[NSNull null], events]);
    };
    
    void (^errorBlock)(RCErrorCode status);
    errorBlock = ^(RCErrorCode status) {
        NSString *errcode;
        switch (status) {
            case ERRORCODE_UNKNOWN:
                errcode = @"ERRORCODE_UNKNOWN";
                break;
            case REJECTED_BY_BLACKLIST:
                errcode = @"REJECTED_BY_BLACKLIST";
                break;
            case ERRORCODE_TIMEOUT:
                errcode = @"ERRORCODE_TIMEOUT";
                break;
            case SEND_MSG_FREQUENCY_OVERRUN:
                errcode = @"SEND_MSG_FREQUENCY_OVERRUN";
                break;
            case NOT_IN_DISCUSSION:
                errcode = @"NOT_IN_DISCUSSION";
                break;
            case NOT_IN_GROUP:
                errcode = @"NOT_IN_GROUP";
                break;
            case FORBIDDEN_IN_GROUP:
                errcode = @"FORBIDDEN_IN_GROUP";
                break;
            case NOT_IN_CHATROOM:
                errcode = @"NOT_IN_CHATROOM";
                break;
            case FORBIDDEN_IN_CHATROOM:
                errcode = @"FORBIDDEN_IN_CHATROOM";
                break;
            case KICKED_FROM_CHATROOM:
                errcode = @"KICKED_FROM_CHATROOM";
                break;
            case RC_CHATROOM_NOT_EXIST:
                errcode = @"RC_CHATROOM_NOT_EXIST";
                break;
            case RC_CHATROOM_IS_FULL:
                errcode = @"RC_CHATROOM_IS_FULL";
                break;
            case RC_CHANNEL_INVALID:
                errcode = @"RC_CHANNEL_INVALID";
                break;
            case RC_NETWORK_UNAVAILABLE:
                errcode = @"RC_NETWORK_UNAVAILABLE";
                break;
            case CLIENT_NOT_INIT:
                errcode = @"CLIENT_NOT_INIT";
                break;
            case DATABASE_ERROR:
                errcode = @"DATABASE_ERROR";
                break;
            case INVALID_PARAMETER:
                errcode = @"INVALID_PARAMETER";
                break;
            case MSG_ROAMING_SERVICE_UNAVAILABLE:
                errcode = @"MSG_ROAMING_SERVICE_UNAVAILABLE";
                break;
            case INVALID_PUBLIC_NUMBER:
                errcode = @"INVALID_PUBLIC_NUMBER";
                break;
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    
    NSLog(@"-------------1。2--------------");
    [[self getClient] getRemoteHistoryMessages: conversationType targetId:targetId recordTime:recordTime count:count success:successBlock error:errorBlock];
}

-(RCIMClient *) getClient {
    return [RCIMClient sharedRCIMClient];
}

-(void)sendMessage:(NSString *)type
          targetId:(NSString *)targetId
           content:(RCMessageContent *)content
       pushContent:(NSString *) pushContent
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    
    RCConversationType conversationType;
    if([type isEqualToString:@"PRIVATE"]) {
        conversationType = ConversationType_PRIVATE;
    }
    else if([type isEqualToString:@"DISCUSSION"]) {
        conversationType = ConversationType_DISCUSSION;
    }
    else {
        conversationType = ConversationType_SYSTEM;
    }
    
    void (^successBlock)(long messageId);
    successBlock = ^(long messageId) {
        NSString* id = [NSString stringWithFormat:@"%ld",messageId];
        resolve(id);
    };
    
    void (^errorBlock)(RCErrorCode nErrorCode , long messageId);
    errorBlock = ^(RCErrorCode nErrorCode , long messageId) {
        reject(nil, nil, nil);
    };
    
    
    [[self getClient] sendMessage:conversationType targetId:targetId content:content pushContent:pushContent success:successBlock error:errorBlock];
    
}

-(void)onReceived:(RCMessage *)message
             left:(int)nLeft
           object:(id)object {
    
    NSLog(@"onRongCloudMessageReceived");
    
    NSMutableDictionary *body = [self getEmptyBody];
    NSMutableDictionary *_message = [self getEmptyBody];
    _message[@"targetId"] = message.targetId;
    _message[@"senderUserId"] = message.senderUserId;
    _message[@"messageId"] = [NSString stringWithFormat:@"%ld",message.messageId];
    _message[@"sentTime"] = [NSString stringWithFormat:@"%lld",message.sentTime];
    
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        _message[@"content"] = testMessage.content;
    }
    else if([message.content isMemberOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)message.content;
        _message[@"imageUrl"] = imageMessage.imageUrl;
        _message[@"thumbnailImage"] = imageMessage.thumbnailImage;
    }
    else if([message.content isMemberOfClass:[RCRichContentMessage class]]) {
        RCRichContentMessage *richMessage = (RCRichContentMessage *)message.content;
    }
    
    
    body[@"left"] = [NSString stringWithFormat:@"%d",nLeft];
    body[@"message"] = _message;
    body[@"errcode"] = @"0";
    
    [self sendEvent:@"onRongCloudMessageReceived" body:body];
}

-(NSMutableDictionary *)getEmptyBody {
    NSMutableDictionary *body = @{}.mutableCopy;
    return body;
}

-(void)sendEvent:(NSString *)name body:(NSMutableDictionary *)body {
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:name body:body];
}

@end
