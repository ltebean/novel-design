//
//  SettingViewController.m
//  novel-design
//
//  Created by Spud Hsu on 14-7-17.
//  Copyright (c) 2014年 ltebean. All rights reserved.
//

#import "SettingViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>

#define userDefaults  [NSUserDefaults standardUserDefaults]

@interface SettingViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeAccountButton;
@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSDictionary* userInfo = [userDefaults objectForKey:@"userInfo"];
    if(userInfo){
        self.usernameLabel.text=userInfo[@"weiboName"];
    }
}

#pragma mark - Table view data source


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==1 && indexPath.row==0){
        [self goRating];
    }else if(indexPath.section==1 && indexPath.row==1){
        [self sendMail];
    }
}

-(void)sendMail
{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.navigationBar.tintColor=[UIColor blackColor];
        picker.mailComposeDelegate = self;
        [picker setSubject:@"品趣意见反馈"];
        [picker setToRecipients:[NSArray arrayWithObjects:@"yucong1118@gmail.com", nil]];
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"您还没有设置邮件帐号" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    NSString* message=nil;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            message=@"已存储草稿";
            break;
        case MFMailComposeResultSent:
            message=@"邮件已发送";
            break;
        case MFMailComposeResultFailed:
            message=@"发送失败";
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    if(message){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
        [alert show];
    }
}


-(void)goRating
{
    NSString *REVIEW_URL = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=900399266&onlyLatestVersion=true&type=Purple+Software";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:REVIEW_URL]];
}

@end
