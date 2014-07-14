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
    self.bridge = [SeaportWebViewBridge bridgeForWebView:self.webView param:@{@"city":@"shanghai",@"name": @"ltebean"} dataHandler:^(id data) {
        NSLog(@"receive data: %@",data);
        [self performSegueWithIdentifier:@"category" sender:data];
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
    
    NSString *rootPath = [self.seaport packagePath:@"all"];
    if(rootPath){
        NSString *filePath = [rootPath stringByAppendingPathComponent:@"detail.html"];
        NSURL *localURL=[NSURL fileURLWithPath:filePath];
        
        NSURL *debugURL=[NSURL URLWithString:@"http://localhost:8080/detail.html"];
        
        NSURLRequest *request=[NSURLRequest requestWithURL:debugURL];
        [self.webView loadRequest:request];
    }
}



- (IBAction)check:(id)sender {
    [self.seaport checkUpdate];
    [self.bridge sendData:@"btn-check clicked"];
    
}

@end
