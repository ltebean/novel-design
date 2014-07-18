//
//  ViewController.m
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController  () <UIWebViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property BOOL loaded;
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    self.loaded=NO;
    self.bridge = [SeaportWebViewBridge bridgeForWebView:self.webView param:self.param dataHandler:^(id data) {
        [self performSegueWithIdentifier:data[@"segue"] sender:data[@"data"]];
    }];
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.keyboardDisplayRequiresUserAction = NO;

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
   
    [self loadPage:@"detail" inWebView:self.webView];
}


@end
