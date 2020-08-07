//
//  TDClient.m
//  RNTdlibRn
//
//  Created by Vidit Bhatia on 7/30/19.
//  Copyright © 2019 Facebook. All rights reserved.
//
#include "td_json_client.h"
#import <Foundation/Foundation.h>
#import "TDClient.h"
#import "ResultHandler.h"
#import <libkern/OSAtomic.h>

@implementation TDClient


- (instancetype)initWithAppId: (NSInteger) appId andHash: (NSString *) hash
{
    self = [super init];
    if (self) {
        [self setAppId:appId];
        [self setApiHash:hash];
        [self setClient:td_json_client_create()];
        [self setIsRunning:@YES];
        self.queryId = 0;
        _updateQueue = dispatch_queue_create("updateQueue", NULL);
        _executeQueue = dispatch_queue_create("executeQueue", NULL);
    }
    return self;
}

-(NSDictionary *)jsonToDictionary:(const char *) jsonString{
    NSError *jsonError;
    return [NSJSONSerialization JSONObjectWithData:[[NSString stringWithUTF8String:jsonString]dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
}

- (void) run : (ResultHandler *) resultHandler{
    dispatch_async(_updateQueue, ^{
        while ([self.isRunning boolValue]) {
            [self setIsProcessing:@YES];
            const char *res = td_json_client_receive(self.client, 10);
            [self setIsProcessing:@NO];
            if(res != NULL){
                NSDictionary *response = [self jsonToDictionary:res];
                if (response != NULL) {
                    dispatch_async(self->_executeQueue, ^{
                        [resultHandler onResult:response];
                    });
                }
            }
            
        }
    });
}
-(NSString *)convertDictionaryToString: (NSDictionary *) dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = @"";
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (void)execute:(NSDictionary<NSString *,NSObject *> *)query withResultHandler:(void (^)(NSDictionary *))emmiter{
    emmiter([self jsonToDictionary:td_json_client_execute([self client], [[self convertDictionaryToString:query] UTF8String])]);
}

- (void)send:(NSDictionary<NSString *,NSObject *> *)query withResultHandler:(ResultHandler *)resultHandler{
    td_json_client_send([self client], [[self convertDictionaryToString:query] UTF8String]);
}

-(void) close{
    if(self.client != nil){
        [self setIsRunning:@NO];
        dispatch_async(self->_executeQueue, ^{
            while([self.isProcessing boolValue]){
                [NSThread sleepForTimeInterval:1.0f];
            }
            td_json_client_destroy(self.client);
            [self setClient:nil];
        });
        
    }
}
@end
