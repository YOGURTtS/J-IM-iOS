//
//  EHISocketPacketHandler.h
//  J-IM-Demo
//
//  Created by yogurts on 2018/11/13.
//  Copyright © 2018 yogurts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface EHISocketManager : NSObject <GCDAsyncSocketDelegate>

+ (instancetype)sharedInstance;

/** socket */
@property (nonatomic, strong) GCDAsyncSocket *socket;

@end
