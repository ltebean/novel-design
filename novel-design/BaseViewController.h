//
//  BaseViewController.h
//  Coupon
//
//  Created by ltebean on 14-7-7.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SeaportWebViewBridge.h"
#import "Seaport.h"

@interface BaseViewController : UIViewController
@property (nonatomic,strong) Seaport* seaport ;
@property(strong,nonatomic) SeaportWebViewBridge *bridge;
@end
