//
//  BLEasyConfigViewController.m
//  BroadLinkSDKDemo
//
//  Created by yzm157 on 14-5-28.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import "BLEasyConfigViewController.h"
#import "JSONKit.h"
#import "BLNetwork.h"

#import <SystemConfiguration/CaptiveNetwork.h>

@interface BLEasyConfigViewController ()

@property (nonatomic, strong) BLNetwork *network;
@property (nonatomic, strong) UITextField *ssidTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@end

@implementation BLEasyConfigViewController

- (void)dealloc
{
    [self setNetwork:nil];
    [self setSsidTextField:nil];
    [self setPasswordTextField:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self == nil)
        return nil;

    return self;
}

/*获取当前连接的wifi网络名称，如果未连接，则为nil*/
- (NSString *)getCurrentWiFiSSID
{
    CFArrayRef ifs = CNCopySupportedInterfaces();       //得到支持的网络接口 eg. "en0", "en1"
    
    if (ifs == NULL)
        return nil;
    
    CFDictionaryRef info = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(ifs, 0));
    
    CFRelease(ifs);
    
    if (info == NULL)
        return nil;
    
    NSDictionary *dic = (__bridge_transfer NSDictionary *)info;
    
    // If ssid is not exist.
    if ([dic isEqual:nil])
        return nil;
    
    NSString *ssid = [dic objectForKey:@"SSID"];
    
    return ssid;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*Set title*/
    [self.navigationItem setTitle:@"Easy Config"];
    
    /*Init network library*/
    self.network = [[BLNetwork alloc] init];
    
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = 15.0f;
    viewFrame.origin.y = 15.0f;
    viewFrame.size.width = self.view.frame.size.width - 30.0f;
    viewFrame.size.height = 32.0f;
    _ssidTextField = [[UITextField alloc] initWithFrame:viewFrame];
    [_ssidTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_ssidTextField setBackgroundColor:[UIColor clearColor]];
    [_ssidTextField setReturnKeyType:UIReturnKeyNext];
    [_ssidTextField setKeyboardType:UIKeyboardTypeASCIICapable];
    [_ssidTextField setPlaceholder:@"Input your Wi-Fi's SSID"];
    [_ssidTextField setTextColor:[UIColor blackColor]];
    [_ssidTextField setFont:[UIFont systemFontOfSize:17.0f]];
    [_ssidTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_ssidTextField setText:[self getCurrentWiFiSSID]];
    [self.view addSubview:_ssidTextField];
    
    viewFrame = _ssidTextField.frame;
    viewFrame.origin.y += viewFrame.size.height + 20.0f;
    _passwordTextField = [[UITextField alloc] initWithFrame:viewFrame];
    [_passwordTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [_passwordTextField setBackgroundColor:[UIColor clearColor]];
    [_passwordTextField setReturnKeyType:UIReturnKeyNext];
    [_passwordTextField setKeyboardType:UIKeyboardTypeASCIICapable];
    [_passwordTextField setPlaceholder:@"Input your Wi-Fi's password"];
    [_passwordTextField setTextColor:[UIColor blackColor]];
    [_passwordTextField setFont:[UIFont systemFontOfSize:17.0f]];
    [_passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.view addSubview:_passwordTextField];
    
    viewFrame = _passwordTextField.frame;
    viewFrame.origin.y += viewFrame.size.height + 50.0f;
    viewFrame.size.width = 150.0f;
    viewFrame.origin.x = (self.view.frame.size.width - 150.0f) * 0.5f;
    UIButton *configButton = [[UIButton alloc] initWithFrame:viewFrame];
    [configButton setBackgroundColor:[UIColor clearColor]];
    [configButton setTitle:@"Easy Config" forState:UIControlStateNormal];
    [configButton setTitle:@"Waiting..." forState:UIControlStateSelected];
    [configButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [configButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [configButton addTarget:self action:@selector(configButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:configButton];
}

- (void)initLibrary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@1 forKey:@"api_id"];
    [dic setObject:@"network_init" forKey:@"command"];
    [dic setObject:@"hXZiAvxNl65WX29d0rbNkiO6O/EoAC26K60zaushO2raU5ilXywBh7Jg6awMUV52iVlVZq7x/5elBh47qYMMwpRSYh5e4Txcrw9UfrrF7KZr5jRqWAw=" forKey:@"license"];
    NSData *requestData = [dic JSONData];
    
    NSData *responseData = [self.network requestDispatch:requestData];
    NSDictionary * dict = [responseData objectFromJSONData];
    NSLog(@"%@", dict);
}


#pragma mark -

/*Config button action*/
- (void)configButtonClicked:(UIButton *)button
{
    [button setSelected:![button isSelected]];
    if ([button isSelected])
    {
        [self startConfig:button];
    }
    else
    {
        [self cancelConfig:button];
    }
}

/*Start config*/
- (void)startConfig:(UIButton *)button
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:10000] forKey:@"api_id"];
        [dic setObject:@"easyconfig" forKey:@"command"];
        [dic setObject:_ssidTextField.text forKey:@"ssid"];
        [dic setObject:_passwordTextField.text forKey:@"password"];
#warning If your device is v1, this field set 0.
        [dic setObject:@0 forKey:@"broadlinkv2"];
#warning This filed is your route's gateway address.
        [dic setObject:@"192.168.1.1" forKey:@"dst"];
        
        NSData *requestData = [dic JSONData];
        
        NSData *responseData = [self.network requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);

        dispatch_async(dispatch_get_main_queue(), ^{
            [button setSelected:NO];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[responseData objectFromJSONData] objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        });
    });
}

/*Cancel config*/
- (void)cancelConfig:(UIButton *)button
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:10001] forKey:@"api_id"];
    [dic setObject:@"cancel_easyconfig" forKey:@"command"];
    
    NSData *requestData = [dic JSONData];
    
    NSData *responseData = [self.network requestDispatch:requestData];
    NSLog(@"%@", [responseData objectFromJSONData]);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[responseData objectFromJSONData] objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [button setSelected:NO];
}


#pragma mark -
#pragma mark - UITouches Delegate Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
