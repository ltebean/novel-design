//
//  SinaWeiboAuthViewController.m
//  Memories
//
//  Created by  on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SinaWeiboAuthViewController.h"
#import "SVProgressHUD.h"
#import "WeiboHTTP.h"
#import "NSURL+QueryParser.h"
#import <Crashlytics/Crashlytics.h>

#define userDefaults  [NSUserDefaults standardUserDefaults]
#define appSecret @""

@interface SinaWeiboAuthViewController ()<UIWebViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation SinaWeiboAuthViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *url = 
    @"https://api.weibo.com/oauth2/authorize?redirect_uri=https://api.weibo.com/oauth2/default.html&response_type=code&client_id=25985519&display=mobile";
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [SVProgressHUD showWithStatus:@"正在加载"];

    [self.webView setDelegate:self];
    [self.webView loadRequest:request];  
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"网络连接出错啦"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView  
{
    [SVProgressHUD dismiss];
    NSURL *url = self.webView.request.URL;
    
    NSDictionary* queries=[url queryDictionary];
    if(queries[@"code"]){
        [self getUserInfoWithCode:queries[@"code"]];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        [self dismissViewControllerAnimated:YES completion:nil];

    }else if(buttonIndex==1){
        NSDictionary* userInfo=[userDefaults objectForKey:@"userInfo"];
        [WeiboHTTP sendRequestToPath:@"/friendships/create.json" method:@"POST" params:@{@"access_token":userInfo[@"weiboToken"],@"uid":@"5237599617"} completionHandler:^(id data) {
            [self dismissViewControllerAnimated:YES completion:nil];

        }];
    }

}

-(void)getUserInfoWithCode:(NSString *)code
{
    [self refreshTokenWithCode:code completionHandler:^(id userInfo) {
        if(userInfo){
            UIAlertView* alert=[[UIAlertView alloc]initWithTitle:@"关注品趣官方微博" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"稍后",@"OK", nil];
            [alert show];
        }else{
            [SVProgressHUD showErrorWithStatus:@"网络链接出错"];
        }
    }];
    
}

-(void) refreshTokenWithCode:(NSString*) code completionHandler:(void (^)(id)) completionHandler
{
    [WeiboHTTP sendRequestToPath:@"/oauth2/access_token" method:@"post" params:@{@"client_id":@"25985519",@"client_secret":appSecret,@"grant_type":@"authorization_code",@"code":code,@"redirect_uri":@"https://api.weibo.com/oauth2/default.html"} completionHandler:^(id data) {
        NSString *access_token=data[@"access_token"];
        NSString *uid=data[@"uid"];
        [WeiboHTTP sendRequestToPath:@"/2/users/show.json" method:@"GET" params:@{@"access_token":access_token,@"uid":uid} completionHandler:^(id data) {
            
            if(!data || data[@"error_code"]){
                completionHandler(nil);
                return;
            }
                        
            NSDictionary* userInfo = @{@"code":code, @"weiboId":data[@"id"],@"weiboName":data[@"name"],@"weiboAvatar":data[@"avatar_large"],@"weiboToken":access_token};
            [userDefaults setObject:userInfo forKey:@"userInfo"];
            [userDefaults synchronize];
            [Answers logContentViewWithName:@"connect_weibo"
                                contentType:nil
                                  contentId:nil
                           customAttributes:nil];
            return completionHandler(userInfo);
        }];
    }];
}


- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
