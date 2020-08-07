//
//  ResultHandler.h
//  RNTdlibRn
//
//  Created by Vidit Bhatia on 7/31/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDClient.h"

@class TDClient;
@interface ResultHandler  : NSObject

@property NSDictionary<NSString *,NSObject *> *dict;
@property TDClient *client;
@property NSString *appHash;
@property NSInteger appId;
@property NSNumber *isdev;
@property (copy) void(^emmiter)(NSDictionary *);

- (instancetype)initWithClient: (TDClient *)client appId:(NSInteger) appId appHash:(NSString *) appHash dev:(NSNumber *) isdev emmiter: (void(^)(NSDictionary *)) emmiter;
-(void) onResult:(NSDictionary *) object;

@end
