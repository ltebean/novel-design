//
//  Seaport.m
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "Seaport.h"
#import "SeaportHttp.h"
#import "SSZipArchive.h"

#define CONFIG_FILE @"config.plist"
#define ERROR_DOMAIN @"io.seaport"

#define fm [NSFileManager defaultManager]

typedef enum {
    DownloadZipError = -1000,
    UnZipError,
}Error;

@interface Seaport ()
@property(nonatomic,copy) NSString* appName;
@property(nonatomic,copy) NSString* dbName;
@property(nonatomic,strong) NSString* packageDirectory;
@property(nonatomic,strong) SeaportHttp* http;
@property(nonatomic,strong) NSOperationQueue* operationQueue;
@end

@implementation Seaport

static Seaport *sharedInstance;

+(Seaport *)sharedInstance{
    @synchronized(self)
    {
        if (!sharedInstance){
            sharedInstance = [[Seaport alloc] initWithAppName:APP_NAME serverHost:SERVER_HOST sevrerPort:SERVER_PORT dbName:DB_NAME];
        }
        return sharedInstance;
    }
}

- (id) initWithAppName:(NSString*) appName serverHost:(NSString*) host sevrerPort:(NSString*) port dbName:(NSString*) dbName;{
    if (self = [super init]) {
        self.appName=appName;
        self.dbName=dbName;
        self.packageDirectory= [self createPackageFolderIfNeeded];
        if(![self loadConfig]){
            [self saveConfig:@{@"packages":@{}}];
        }
        self.operationQueue=[[NSOperationQueue alloc]init];
        [self.operationQueue setMaxConcurrentOperationCount:1];
        NSString * serverAddress =[NSString stringWithFormat:@"%@:%@",host,port];
        
        NSOperationQueue *httpQueue = [[NSOperationQueue alloc]init];
        [httpQueue setMaxConcurrentOperationCount:3];
        self.http = [[SeaportHttp alloc]initWithDomain:serverAddress operationQueue:httpQueue];
    }
    return self;
}

-(NSString *) createPackageFolderIfNeeded
{
    NSURL *documentsDirectoryURL = [fm URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString * packageDirectory = [documentsDirectoryURL URLByAppendingPathComponent:@"packages"].path;
    
    NSLog(@"%@",packageDirectory);
    
    BOOL exists=[fm fileExistsAtPath:packageDirectory];
    if (!exists) {
        [fm createDirectoryAtPath:packageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return packageDirectory;
}

-(void)checkUpdate
{
    [self updateLocal];
    [self updateRemote];
}

-(void) updateLocal
{
    @synchronized(self) {
        NSMutableDictionary * config=[self loadConfig];
        NSMutableDictionary * packages = config[@"packages"];
        for(NSString* packageName in [packages allKeys]){
            NSMutableDictionary* package = packages[packageName];
            if(![package[@"current"] isEqualToString: package[@"available"]]){
                [self removeLocalPackage:packageName version:package[@"current"]];
                NSString* oldVersion=[package[@"current"] copy];
                package[@"current"]=package[@"available"];
                [self saveConfig:config];
                // remove the old one asynchronously
                [self.operationQueue addOperationWithBlock:^{
                    [self removeLocalPackage:packageName version:oldVersion];
                }];
                [self.deletage seaport:self didFinishUpdatePackage:packageName version:package[@"current"]];
            }
        }
    }
}

-(void) updateRemote
{
    NSString *path = [NSString stringWithFormat:@"/%@/_design/app/_view/byApp",self.dbName];
    [self.http sendRequestToPath:path method:@"GET" params:@{@"key":[NSString stringWithFormat:@"\"%@\"",self.appName]} cookies:nil completionHandler:^(NSDictionary* result) {
        NSDictionary* localPackages = [self loadConfig][@"packages"];
        for(NSDictionary* row in result[@"rows"]){
            NSDictionary* package=row[@"value"];
            NSString *packageName = package[@"name"];
            NSDictionary* localPackage=localPackages[packageName];
            if(!localPackage || ![localPackage[@"available"] isEqualToString:package[@"activeVersion"]]){
                [self updatePackage:package toVersion:package[@"activeVersion"]];
            }
        }
    }];
}

-(BOOL)removeLocalPackage:(NSString*) packageName version:(NSString*) version
{
    NSString *path = [self packagePathWithName:packageName version:version];
    return [fm removeItemAtPath:path error:nil];
}

-(void) updatePackage:(NSDictionary*) package toVersion:(NSString*) version
{
    NSString *packageName = package[@"name"];
    NSString *destinationPath = [self packagePathWithName:packageName version:version];
    NSString *zipPath = [destinationPath stringByAppendingString:@".zip"];
    
    if([fm fileExistsAtPath:destinationPath]){
        return;
    }
    
    [self.deletage seaport:self didStartDownloadPackage:packageName version:version];
    
    NSString *path = [NSString stringWithFormat:@"/%@/%@",self.dbName,package[@"zip"]];
    [self.http downloadFileAtPath:path params:nil cookies:nil completionHandler:^(NSData* data) {
        if(!data){
            [self.deletage seaport:self didFailDownloadPackage:packageName version:version withError:[NSError errorWithDomain:ERROR_DOMAIN code:DownloadZipError userInfo:nil]];
            return;
        }
        // write data to zip
        if(![data writeToFile:zipPath atomically:YES]){
            [self.deletage seaport:self didFailDownloadPackage:packageName version:version withError:[NSError errorWithDomain:ERROR_DOMAIN code:DownloadZipError userInfo:nil]];
            return;
        }
        
        //unzip
        if(![SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath]){
            [fm removeItemAtPath:zipPath error:nil];
            [self.deletage seaport:self didFailDownloadPackage:packageName version:version withError:[NSError errorWithDomain:ERROR_DOMAIN code:UnZipError userInfo:nil]];
            return;
        }
        [fm removeItemAtPath:zipPath error:nil];
        
        [self.deletage seaport:self didFinishDownloadPackage:packageName version:version];
        
        // update config
        BOOL localUpdated=NO;
        @synchronized(self) {
            NSMutableDictionary * config=[self loadConfig];
            NSMutableDictionary * packages = config[@"packages"];
            NSMutableDictionary * package = packages[packageName];
            if(!package){
                package=[[NSMutableDictionary alloc]init];
                packages[packageName]=package;
                package[@"current"]=version;
                localUpdated=YES;
            }
            package[@"available"]=version;
            package[@"time"]=[NSDate date];
            [self saveConfig:config];
        }
        if(localUpdated){
            [self.deletage seaport:self didFinishUpdatePackage:packageName version:version];
        }
    }];
}

-(NSString*) packagePathWithName:(NSString*) packageName version:(NSString*)version
{
    NSString * packageRootPath = [self.packageDirectory stringByAppendingPathComponent:packageName];
    if(![fm fileExistsAtPath:packageName]){
        [fm createDirectoryAtPath:packageRootPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [packageRootPath stringByAppendingPathComponent:version];
}

-(NSMutableDictionary*) loadConfig
{
    NSString *configFilePath =[self.packageDirectory stringByAppendingPathComponent:CONFIG_FILE];
    NSMutableDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:configFilePath];
    return config;
}

-(BOOL) saveConfig:(NSDictionary*) config
{
    NSLog(@"update config to %@",config);
    NSString *configFilePath =[self.packageDirectory stringByAppendingPathComponent:CONFIG_FILE];
    return [config writeToFile:configFilePath atomically:YES];
}

- (NSString*) packagePath:(NSString*) packageName;
{
    NSDictionary* package;
    @synchronized(self){
        package =[self loadConfig][@"packages"][packageName];
    }
    if(!package){
        return nil;
    }
    NSString* path=[self packagePathWithName:packageName version:package[@"current"]];
    
    if(![fm fileExistsAtPath:path]){
        return nil;
    }
    return path;
}

@end
