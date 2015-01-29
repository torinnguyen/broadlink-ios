//
//  BLSP2ViewController.m
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLSP2ViewController.h"
#import "BLNetwork.h"
#import "JSONKit.h"

@interface BLSP2ViewController ()
{
    dispatch_queue_t networkQueue;
}

@property (nonatomic, strong) BLNetwork *network;

@end

@implementation BLSP2ViewController

- (void)dealloc
{
    [self setNetwork:nil];
    dispatch_release(networkQueue);
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
    
    [self.navigationItem setTitle:_info.name];
    
    networkQueue = dispatch_queue_create("BroadLinkSP2NetworkQueue", DISPATCH_QUEUE_SERIAL);
    _network = [[BLNetwork alloc] init];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200.0f) * 0.5f, (self.view.frame.size.height - 200.0f) * 0.5f, 200.0f, 200.0f)];
    [button.layer setCornerRadius:100.0f];
    [button.layer setMasksToBounds:YES];
    [button setSelected:_status];
    [button setTitle:(_status) ? @"on" : @"off" forState:UIControlStateNormal];
    if (_status)
        [button setBackgroundColor:[UIColor greenColor]];
    else
        [button setBackgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(stateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)stateButtonClicked:(UIButton *)button
{
    int status = !button.isSelected;
    
    dispatch_async(networkQueue, ^{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:72] forKey:@"api_id"];
        [dic setObject:@"sp2_control" forKey:@"command"];
        [dic setObject:_info.mac forKey:@"mac"];
        [dic setObject:[NSNumber numberWithInt:status] forKey:@"status"];

        NSData *requestData = [dic JSONData];
        
        NSData *responseData = [_network requestDispatch:requestData];
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [button setSelected:status];
                [button setTitle:(status) ? @"on" : @"off" forState:UIControlStateNormal];
                if (status)
                    [button setBackgroundColor:[UIColor greenColor]];
                else
                    [button setBackgroundColor:[UIColor redColor]];
            });
        }
        else if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == -106)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Your operation is too fast" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
        }
        else
        {
            NSLog(@"Set status failed!");
            //TODO;
        }
    });
}

@end
