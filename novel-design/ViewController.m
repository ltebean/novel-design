//
//  ViewController.m
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "ViewController.h"

@interface ViewController  () <UIWebViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property BOOL loaded;
@end

@implementation ViewController

- (void)viewDidLoad
{
    self.loaded=NO;
    self.bridge = [SeaportWebViewBridge bridgeForWebView:self.webView param:self.param dataHandler:^(id data) {
        NSLog(@"receive data: %@",data);
        [self performSegueWithIdentifier:@"detail" sender:data];
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
}
- (IBAction)refresh:(id)sender {
    
    [self loadPage:@"index" inWebView:self.webView];
}



- (IBAction)check:(id)sender {
    [self.seaport checkUpdate];
    [self.bridge sendData:@"btn-check clicked"];
    
}

@end
