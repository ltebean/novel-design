//
//  SeaportWebViewBridge.m
//  Seaport
//
//  Created by ltebean on 14-7-2.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "SeaportWebViewBridge.h"
#import "WebViewJavascriptBridge.h"
#import "SeaportHttp.h"

@interface SeaportWebViewBridge()
@property(nonatomic,strong) NSDictionary* param;
@property(nonatomic,strong) WebViewJavascriptBridge* bridge;

@end

@implementation SeaportWebViewBridge


+(SeaportWebViewBridge* ) bridgeForWebView:(UIWebView*) webView param:(NSDictionary*) param dataHandler:(void (^)(id)) handler;
{
    return [[SeaportWebViewBridge alloc]initWithWebView:webView param:param handler:handler];
}

-(id) initWithWebView:(UIWebView*) webView param:(NSDictionary*) param handler:(void (^)(id)) handler

{
    if (self = [super init]) {
        self.param=param;
        self.bridge=[WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
            handler(data);
        }];
        
        //[WebViewJavascriptBridge enableLogging];
        
        [self.bridge registerHandler:@"userdefaults:set" handler:^(id data, WVJBResponseCallback responseCallback){
            [[NSUserDefaults standardUserDefaults] setObject:data[@"value"] forKey:data[@"key"]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            responseCallback(@200);
        }];
        
        [self.bridge registerHandler:@"userdefaults:get" handler:^(id data, WVJBResponseCallback responseCallback){
            responseCallback([[NSUserDefaults standardUserDefaults] objectForKey:data]);
        }];
        
        [self.bridge registerHandler:@"http:get" handler:^(id data, WVJBResponseCallback responseCallback){
            SeaportHttp* http = [[SeaportHttp alloc]initWithDomain:data[@"domain"]];
            [http sendRequestToPath:data[@"path"] method:@"GET" params:nil cookies:data[@"cookies"] completionHandler:^(id result) {
                responseCallback(result);
            }];
        }];
        
        [self.bridge registerHandler:@"http:post" handler:^(id data, WVJBResponseCallback responseCallback){
            SeaportHttp* http = [[SeaportHttp alloc]initWithDomain:data[@"domain"]];
            [http postJsonToPath:data[@"path"] body:data[@"body"] cookies:data[@"cookie"] completionHandler:^(id result) {
                responseCallback(result);
            }];
        }];
        
        [self.bridge registerHandler:@"param:get" handler:^(id data, WVJBResponseCallback responseCallback){
            responseCallback(self.param[data]);
        }];
        
        [self.bridge registerHandler:@"param:getAll" handler:^(id data, WVJBResponseCallback responseCallback){
            responseCallback(self.param);
        }];
        
    }
    return self;
}

-(void) sendData:(id) data
{
    [self.bridge send:data];
}

@end
