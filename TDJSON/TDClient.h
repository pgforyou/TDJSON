//
//  TDClient.h
//  RNTdlibRn
//
//  Created by Vidit Bhatia on 7/30/19.
//  Copyright © 2019 Facebook. All rights reserved.
//
#include "td_json_client.h"
#ifndef TDClient_h
#define TDClient_h
#import "ResultHandler.h"
#import <Foundation/Foundation.h>

@class ResultHandler;
@interface TDClient : NSObject

@property void *client;
@property NSInteger appId;
@property NSString *apiHash;
@property NSNumber *isRunning;
@property NSNumber *isProcessing;
@property (readonly) dispatch_queue_t updateQueue;
@property (readonly) dispatch_queue_t executeQueue;
@property (atomic) int64_t queryId;
-(void) run: (ResultHandler *) resultHandler;
-(void) send: (NSDictionary<NSString *,NSObject *> *) query withResultHandler: (ResultHandler *) resultHandler;
-(void) execute: (NSDictionary<NSString *,NSObject *> *) query withResultHandler: (void (^)(NSDictionary *))emmiter;
-(void) close;
- (instancetype)initWithAppId: (NSInteger) appId andHash: (NSString *) hash;
@end
#endif /* TDClient_h */
