//
//  ViewController.m
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "DetailViewController.h"
#import "WXApi.h"
#import "WeiboHTTP.h"
#import "SVProgressHUD.h"
#import <Crashlytics/Crashlytics.h>

@interface DetailViewController  () <UIWebViewDelegate,UISearchBarDelegate,UIActionSheetDelegate>
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
        [self loadPage:@"detail" inWebView:self.webView];
        self.loaded=YES;
    }
    [Answers logContentViewWithName:@"detail"
                        contentType:nil
                          contentId:nil
                   customAttributes:nil];
}
- (IBAction)share:(id)sender {
   
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"分享到微博",@"分享给微信好友",@"分享到微信朋友圈",nil];
    
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:[self.view window]];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1){
        [self shareToWeixinIsTimeLine:NO];
    }else if(buttonIndex==2){
        [self shareToWeixinIsTimeLine:YES];
    }else if(buttonIndex==0){
        [self shareToWeibo];
    }
}

-(void) alert:(NSString*) message
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

-(void) shareToWeibo
{
    NSDictionary* userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
    if(!userInfo){
        [self alert:@"请在设置界面登陆微博"];
        return;
    }
    [Answers logCustomEventWithName:@"share_weibo"
                   customAttributes:@{}];
    NSDictionary* design=self.param[@"data"];
    NSString* status=[NSString stringWithFormat:@"%@ 分享自#品趣#",design[@"title"]];
    [WeiboHTTP sendRequestToPath:@"/2/statuses/upload_url_text.json"  method:@"POST" params:@{@"access_token":userInfo[@"weiboToken"],@"status":status,@"url":design[@"thumb"]} completionHandler:^(id data) {
        if(!data){
            [self alert:@"网络连接出错"];
            return;
            
        }else if(data[@"error_code"]){
            [self alert:@"授权过期，请重新授权"];
            return;
        }else{
            [self alert:@"分享成功^_^"];
        }
    }];
    
}

-(void)shareToWeixinIsTimeLine: (BOOL)isTimeLine
{
    if(![WXApi isWXAppInstalled]){
        [self alert:@"还没有安装微信"];
        return;
    }
    [Answers logCustomEventWithName:@"share_weixin"
                   customAttributes:@{@"time_line": @(isTimeLine)}];

    NSURLRequest* request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.param[@"data"][@"thumb"]]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * response, NSData *data, NSError *error) {
        if(error){
            [self alert:@"网络连接错误"];
            return;
        }
        UIImage *image= [[UIImage alloc] initWithData:data];
        
        WXMediaMessage *message = [WXMediaMessage message];
        [message setThumbImage:image];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = UIImagePNGRepresentation(image);
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        if(isTimeLine){
            req.scene=WXSceneTimeline;
        }
        req.message = message;
        [WXApi sendReq:req];
    }];
}


@end
