//
//  SeaportHttp.m
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "SeaportHttp.h"

@interface SeaportHttp()
@property(nonatomic,copy) NSString * domain;
@property(nonatomic,strong) NSOperationQueue * operationQueue;
@end

@implementation SeaportHttp


- (id) initWithDomain:(NSString*) domain
{
    if (self = [super init]) {
        self.domain=domain;
        self.operationQueue=[NSOperationQueue mainQueue];
    }
    return self;
}

- (id) initWithDomain:(NSString*) domain operationQueue:(NSOperationQueue*) operationQueue
{
    if (self = [super init]) {
        self.domain=domain;
        self.operationQueue=operationQueue;
    }
    return self;
}


-(void)sendRequestToPath:(NSString*)path method:(NSString*)method params:(NSDictionary*)params cookies:(NSDictionary*)cookies completionHandler:(void (^)(id)) completionHandler
{
    NSString* finalUrl=[NSString stringWithFormat:@"http://%@%@",self.domain,path];
    NSMutableURLRequest* request=[self generateRequestWithURL:finalUrl method:method params:params cookies:cookies];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse * response, NSData *data, NSError *error) {
        if(!error){
            id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            completionHandler(result);
        }else{
            completionHandler(nil);
        }
    }];
}

-(void)postJsonToPath:(NSString*)path body:(id)object cookies:(NSDictionary*)cookies  completionHandler:(void (^)(id)) completionHandler
{
    NSString* finalUrl=[NSString stringWithFormat:@"http://%@%@",self.domain,path];
    NSMutableURLRequest  *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalUrl]];
    [request setHTTPMethod:@"POST"];
    [self setCookie:cookies forRequest:request];
    NSData *body=[NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:body];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse * response, NSData *data, NSError *error) {
        if(!error){
            id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            completionHandler(result);
        }else{
            completionHandler(nil);
        }
    }];
}

-(void)downloadFileAtPath:(NSString*)path params:(NSDictionary*)params cookies:(NSDictionary*)cookies  completionHandler:(void (^)(id)) completionHandler
{
    NSString* finalUrl=[NSString stringWithFormat:@"http://%@%@",self.domain,path];
    NSMutableURLRequest* request=[self generateRequestWithURL:finalUrl method:@"GET" params:params cookies:cookies];
    
    [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse * response, NSData *data, NSError *error) {
        if(!error){
            completionHandler(data);
        }else{
            completionHandler(nil);
        }
    }];
}

-(NSMutableURLRequest*)generateRequestWithURL:(NSString*) url method:(NSString*)method params:(NSDictionary*)params cookies:(NSDictionary*)cookies
{
    if([method isEqualToString:@"GET"]){
        NSString* finalurl=[NSString stringWithFormat:@"%@?%@",url,[[self generateParamString:params]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSMutableURLRequest  *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalurl]];
        [self setCookie:cookies forRequest:request];
        [request setHTTPMethod:method];
        return request;
    }
    if([method isEqualToString:@"POST"]){
        NSMutableURLRequest  *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self setCookie:cookies forRequest:request];
        [request setHTTPMethod:method];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[self generateParamString:params]dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        return request;
    }
    return nil;
}

-(NSString*)generateParamString:(NSDictionary*)params
{
    NSString* result=@"";
    if(!params){
        return result;
    }
    for (NSString *key in [params allKeys]) {
        result=[result stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,params[key]]];
    }
    return result;
}

-(void)setCookie:(NSDictionary*)cookies forRequest:(NSMutableURLRequest*)request
{
    if(!cookies){
        return;
    }
    NSMutableArray* cookieArray=[NSMutableArray arrayWithCapacity:cookies.count];
    for (NSString *key in [cookies allKeys]) {
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    self.domain, NSHTTPCookieDomain,
                                    @"\\", NSHTTPCookiePath,  // IMPORTANT!
                                    key, NSHTTPCookieName,
                                    cookies[key], NSHTTPCookieValue,
                                    nil];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
        [cookieArray addObject:cookie];
    }
    
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
    [request setAllHTTPHeaderFields:headers];
}

@end

