//
//  SeaportWebViewBridge.h
//  Seaport
//
//  Created by ltebean on 14-7-2.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SeaportWebViewBridge : NSObject
+(SeaportWebViewBridge* ) bridgeForWebView:(UIWebView*) webView param:(NSDictionary*) param dataHandler:(void (^)(id)) handler;

-(void) sendData:(id) data;
@end
