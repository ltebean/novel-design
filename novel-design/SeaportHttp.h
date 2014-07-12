//
//  SeaportHttp.h
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

@interface SeaportHttp : NSObject

- (id) initWithDomain:(NSString*) domain;

- (id) initWithDomain:(NSString*) domain operationQueue:(NSOperationQueue*) operationQueue;


-(void)sendRequestToPath:(NSString*)path method:(NSString*)method params:(NSDictionary*)params cookies:(NSDictionary*)cookies  completionHandler:(void (^)(id)) completionHandler ;

-(void)postJsonToPath:(NSString*)path body:(id)object cookies:(NSDictionary*)cookies  completionHandler:(void (^)(id)) completionHandler;

-(void)downloadFileAtPath:(NSString*)path params:(NSDictionary*)params cookies:(NSDictionary*)cookies  completionHandler:(void (^)(id)) completionHandler;

@end