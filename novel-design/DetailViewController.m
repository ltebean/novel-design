//
//  ViewController.m
//  Seaport
//
//  Created by ltebean on 14-5-14.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "DetailViewController.h"
#import "WXApi.h"

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
}
- (IBAction)refresh:(id)sender {
   
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"分享给微信好友",@"分享到微信朋友圈",nil];
    
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:[self.view window]];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0){
        [self shareToWeixinIsTimeLine:NO];
    }else if(buttonIndex==1){
        [self shareToWeixinIsTimeLine:YES];
    }
}

-(void) alert:(NSString*) message
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

-(void)shareToWeixinIsTimeLine: (BOOL)isTimeLine
{
    if(![WXApi isWXAppInstalled]){
        [self alert:@"还没有安装微信"];
        return;
    }
    
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
