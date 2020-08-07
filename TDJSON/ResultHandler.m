//
//  ResultHandler.m
//  RNTdlibRn
//
//  Created by Vidit Bhatia on 8/4/19.
//  Copyright © 2019 Facebook. All rights reserved.
//
#import "ResultHandler.h"
#import <Foundation/Foundation.h>

@implementation ResultHandler

-(void) onResult:(NSDictionary *) object{
    NSLog(@"%@",object);
    if([object[@"@type"] isEqualToString:@"updateAuthorizationState"]){
        [self onAuthorizationStateUpdated:object[@"authorization_state"]];
    } else  {
        [self emitData:object withEventType:object[@"@type"]];
    }
}

- (instancetype)initWithClient:(TDClient *)client appId:(NSInteger)appId appHash:(NSString *)appHash dev:(NSNumber *)isdev emmiter:(void (^)(NSDictionary *))emmiter
{
    self = [super init];
    if (self) {
        [self setClient:client];
        [self setEmmiter:emmiter];
        [self setAppId:appId];
        [self setAppHash:appHash];
        [self setIsdev:isdev];
    }
    return self;
}

-(void) emitData: (NSDictionary *) object withEventType: (NSString *) eventType{
    self.emmiter([[NSDictionary alloc]initWithObjectsAndKeys:eventType,@"key",object,@"value",[NSString stringWithFormat:@"%@",object],@"description", nil]);
}


-(void) onAuthorizationStateUpdated: (NSDictionary *) object {
    if([object[@"@type"] isEqualToString:@"authorizationStateWaitTdlibParameters"]){
        [self.client send:[[NSDictionary alloc] initWithObjectsAndKeys:@"setTdlibParameters",@"@type",[[NSDictionary alloc] initWithObjectsAndKeys:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString: @"/tdlib"],@"database_directory",self.isdev,@"use_test_dc",@YES,@"use_message_database",@YES,@"use_secret_chats",[NSNumber numberWithLong:self.appId],@"api_id",self.appHash,@"api_hash",@"en",@"system_language_code",@"Desktop",@"device_model",@"Unknown",@"system_version", @"1.0", @"application_version",@YES,@"enable_storage_optimizer", nil],@"parameters", nil] withResultHandler:[ResultHandler new]];
        
    } else if([object[@"@type"] isEqualToString:@"authorizationStateWaitEncryptionKey"]){
        [self.client send:[[NSDictionary alloc]initWithObjectsAndKeys:@"checkDatabaseEncryptionKey",@"@type",@"cucumber",@"key", nil] withResultHandler:[ResultHandler new]];
    } else if([object[@"@type"] isEqualToString:@"authorizationStateWaitPhoneNumber"]){
        self.emmiter([[NSDictionary alloc]initWithObjectsAndKeys:@"update_phone_number",@"key",object,@"value",[NSString stringWithFormat:@"%@",object],@"description", nil]);
    }else if([object[@"@type"] isEqualToString:@"authorizationStateWaitCode"]){
        self.emmiter([[NSDictionary alloc]initWithObjectsAndKeys:@"update_code",@"key",object,@"value",[NSString stringWithFormat:@"%@",object],@"description", nil]);
    } else {
        [self emitData:object withEventType:object[@"@type"]];
    }
}

-(NSString *) getTypeOfOperation: (NSString *) operation {
    return @"";
}

-(NSString *) getFriendlyEvenType: (NSString *) operation {
    return @"";
}
@end
