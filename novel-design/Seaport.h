//
//  Seaport.h
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>

#define APP_NAME @"Coupon"
#define SERVER_HOST @"223.4.15.141"
#define SERVER_PORT @"9984"
#define DB_NAME @"seaport"

@class Seaport;
@protocol SeaportDelegate<NSObject>
-(void)seaport:(Seaport*)seaport didStartDownloadPackage:(NSString*) packageName version:(NSString*) version;
-(void)seaport:(Seaport*)seaport didFinishDownloadPackage:(NSString*) packageName version:(NSString*) version;
-(void)seaport:(Seaport*)seaport didFailDownloadPackage:(NSString*) packageName version:(NSString*) version withError:(NSError*) error;
-(void)seaport:(Seaport*)seaport didFinishUpdatePackage:(NSString*) packageName version:(NSString*) version;
@end


@interface Seaport : NSObject
@property(nonatomic,weak) id<SeaportDelegate> deletage;

+ (Seaport*) sharedInstance;

- (id) initWithAppName:(NSString*) appName serverHost:(NSString*) host sevrerPort:(NSString*) port dbName:(NSString*) dbName;

- (void) checkUpdate;

- (NSString*) packagePath:(NSString*) packageName;

@end
