//
//  RCTRongCloudDiscLib.h
//  RCTRongCloudIMLib
//
//  Created by sstonehu on 2017/4/12.
//  Copyright © 2017年 lovebing.org. All rights reserved.
//


#import "RCTBridgeModule.h"
#import "RCTEventDispatcher.h"
#import "RCTBridge.h"
#import <RongIMLib/RongIMLib.h>
#import <RongIMLib/RCIMClient.h>



@interface RCTRongCloudDiscLib: NSObject <RCTBridgeModule> {
    
}
-(RCIMClient *) getClient;

@end
