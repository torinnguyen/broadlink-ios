//
//  BLRM2ViewController.m
//  BroadLinkSDKDemo
//
//  Created by yzm157 on 14-5-28.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import "BLRM2ViewController.h"
#import "BLNetwork.h"
#import "JSONKit.h"

@interface BLRM2ViewController ()
{
    BOOL isGetData;
}

@property (nonatomic, strong) BLNetwork *network;

@property (nonatomic, strong) NSString *rmCode;

@end

@implementation BLRM2ViewController

- (void)dealloc
{
    [self setNetwork:nil];
    [self setRmCode:nil];
}

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
    
    /*Set title*/
    [self.navigationItem setTitle:_info.name];
    
    /*Init network library*/
    _network = [[BLNetwork alloc] init];
    
    /*Enter study mode button*/
    CGRect viewFrame = CGRectZero;
    viewFrame.origin.x = (self.view.frame.size.width - 180.0f) * 0.5f;
    viewFrame.origin.y = 30.0f;
    viewFrame.size = CGSizeMake(180.0f, 32.0f);
    UIButton *studyButton = [[UIButton alloc] initWithFrame:viewFrame];
    [studyButton setBackgroundColor:[UIColor clearColor]];
    [studyButton setTitle:@"Enter study mode" forState:UIControlStateNormal];
    [studyButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [studyButton addTarget:self action:@selector(studyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:studyButton];
    
    /*Check code button*/
    viewFrame = studyButton.frame;
    viewFrame.origin.y += viewFrame.size.height + 20.0f;
    UIButton *checkButton = [[UIButton alloc] initWithFrame:viewFrame];
    [checkButton setBackgroundColor:[UIColor clearColor]];
    [checkButton setTitle:@"Check code" forState:UIControlStateNormal];
    [checkButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(checkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkButton];
    
    /*Send code button*/
    viewFrame = checkButton.frame;
    viewFrame.origin.y += viewFrame.size.height + 20.0f;
    UIButton *sendButton = [[UIButton alloc] initWithFrame:viewFrame];
    [sendButton setBackgroundColor:[UIColor clearColor]];
    [sendButton setTitle:@"Send code" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*Study button action*/
- (void)studyButtonClicked:(UIButton *)button
{
    isGetData = NO;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:132] forKey:@"api_id"];
    [dic setObject:@"rm2_study" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    NSData *requestData = [dic JSONData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *responseData = [_network requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[responseData objectFromJSONData] objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        });
    });
}

/*Check button action*/
- (void)checkButtonClicked:(UIButton *)button
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:133] forKey:@"api_id"];
    [dic setObject:@"rm2_code" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    NSData *requestData = [dic JSONData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *responseData = [_network requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            isGetData = YES;
            _rmCode = [[responseData objectFromJSONData] objectForKey:@"data"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[responseData objectFromJSONData] objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        });
    });
}

/*Send button action*/
- (void)sendButtonClicked:(UIButton *)button
{
    if (!isGetData)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"No data to send!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:134] forKey:@"api_id"];
    [dic setObject:@"rm2_send" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    [dic setObject:_rmCode forKey:@"data"];
    NSData *requestData = [dic JSONData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *responseData = [_network requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[[responseData objectFromJSONData] objectForKey:@"msg"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        });
    });
}

@end
