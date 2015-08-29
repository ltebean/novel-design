//
//  ViewController.m
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "ViewController.h"
#import <Crashlytics/Crashlytics.h>

@interface ViewController  () <UIWebViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property BOOL loaded;
@end

@implementation ViewController

- (void)viewDidLoad
{
    self.loaded=NO;
    self.bridge = [SeaportWebViewBridge bridgeForWebView:self.webView param:self.param dataHandler:^(id data) {
        if(data[@"segue"]){
            [self performSegueWithIdentifier:@"detail" sender:data];
        }else if(data[@"title"]){
            self.title=data[@"title"];
        }
    }];
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    [super viewDidLoad];
}


-(void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
    if(!self.loaded){
        [self refresh:nil];
        self.loaded=YES;
    }
    [Answers logContentViewWithName:@"home"
                        contentType:nil
                          contentId:nil
                   customAttributes:nil];
}
- (IBAction)refresh:(id)sender {
    
    [self loadPage:@"index" inWebView:self.webView];
    self.title=@"品趣";
}



- (IBAction)check:(id)sender {
//    [self.seaport checkUpdate];
    [self.bridge sendData:@{@"action":@"category"}];
    
}

@end
