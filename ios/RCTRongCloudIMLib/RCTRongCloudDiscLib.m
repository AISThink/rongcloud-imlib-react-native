//
//  RCTRongCloudDiscLib.m
//  RCTRongCloudIMLib
//
//  Created by sstonehu on 2017/4/12.
//  Copyright © 2017年 lovebing.org. All rights reserved.
//


#import "RCTRongCloudDiscLib.h"


@implementation RCTRongCloudDiscLib
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(RongCloudDiscLibModule)

RCT_EXPORT_METHOD(createDiscussion:(NSString *)name
                  userIdList:(NSArray *)userIdList
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"-------------get createDiscussion start name: %@, userIdList: %d--------------", name, userIdList);
    void (^successBlock)(RCDiscussion * disc);
    successBlock = ^(RCDiscussion* disc) {
        if (disc) {
            NSLog(@"disc:  %@", disc);
            NSString *discJsonString = [self getDiscJsonStr:disc];
            NSLog(@"disc:  %@", discJsonString);
            resolve(discJsonString);
        } else {
            reject(@"NO_RETURN_DISC", @"There were no return disc", nil);
        }
//
//        
//        NSArray *events = [[NSArray alloc] initWithObjects:[self getDiscJsonStr:disc],nil];
//        resolve(@[[NSNull null], events]);
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
  

    [[self getClient] createDiscussion:name userIdList:userIdList success:successBlock error:errorBlock];

}

-(RCIMClient *) getClient {
    return [RCIMClient sharedRCIMClient];
}

/*
 将RCDiscussion转化为NSMutableDictionary，以便之后转为json
 */
-(NSMutableDictionary *)convertDisc:(RCDiscussion *)disc{
    NSMutableDictionary *_disc = [self getEmptyBody];
    _disc[@"discussionId"]      = disc.discussionId;
    _disc[@"discussionName"]    = disc.discussionName;
    _disc[@"creatorId"]         = disc.creatorId;
    
    NSData  * memberData = [NSJSONSerialization dataWithJSONObject:disc.memberIdList options:NSJSONWritingPrettyPrinted error: nil ];
    NSString * memberString = [[NSString alloc] initWithData:memberData encoding:NSUTF8StringEncoding];
    
    _disc[@"memberIdList"]      = memberString;
    return _disc;
}

-(NSString *)getDiscJsonStr:(RCDiscussion *) disc{
    NSMutableDictionary * _disc = [self convertDisc:disc];
    NSData  * _discData = [NSJSONSerialization dataWithJSONObject:_disc options:NSJSONWritingPrettyPrinted error: nil ];
    NSString * _discJsonStr = [[NSString alloc] initWithData:_discData encoding:NSUTF8StringEncoding];
    return _discJsonStr;

}


-(NSMutableDictionary *)getEmptyBody {
    NSMutableDictionary *body = @{}.mutableCopy;
    return body;
}

@end
