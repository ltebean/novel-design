//
//  BaseViewController.m
//  Coupon
//
//  Created by ltebean on 14-7-7.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<UISearchBarDelegate,SeaportDelegate>
@property(nonatomic,strong) UIToolbar* overlay;
@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.seaport = [Seaport sharedInstance];
    self.seaport.deletage=self;
}

-(void) loadPage:(NSString*) page inWebView :(UIWebView*) webView
{
    NSString *rootPath = [self.seaport packagePath:@"all"];
    NSString *fileName=[page stringByAppendingString:@".html"];
    if(rootPath){
        NSString *filePath = [rootPath stringByAppendingPathComponent:fileName];
        NSURL *localURL=[NSURL fileURLWithPath:filePath];
        
        NSURL *debugURL=[NSURL URLWithString:[@"http://localhost:8080/" stringByAppendingString:fileName]];
        
        NSURLRequest *request=[NSURLRequest requestWithURL:debugURL];
        [webView loadRequest:request];
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BaseViewController* vc= segue.destinationViewController;
    vc.param=sender;
}


-(void)seaport:(Seaport*)seaport didStartDownloadPackage:(NSString*) packageName version:(NSString*) version
{
    NSLog(@"start download package: %@@%@",packageName,version);
}

-(void)seaport:(Seaport*)seaport didFinishDownloadPackage:(NSString*) packageName version:(NSString*) version
{
    NSLog(@"finish download package: %@@%@",packageName,version);
}

-(void)seaport:(Seaport*)seaport didFailDownloadPackage:(NSString*) packageName version:(NSString*) version withError:(NSError*) error
{
    NSLog(@"faild download package: %@@%@",packageName,version);
}

-(void)seaport:(Seaport*)seaport didFinishUpdatePackage:(NSString*) packageName version:(NSString*) version
{
    NSLog(@"update local package: %@@%@",packageName,version);
}



@end
