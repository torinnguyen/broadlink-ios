//
//  BLA1ViewController.m
//  BroadLinkSDKDemo
//
//  Created by yzm157 on 14-6-6.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import "BLA1ViewController.h"
#import "BLNetwork.h"
#import "JSONKit.h"
#import "BLA1TaskListTableViewController.h"

@interface BLA1ViewController ()

@property (nonatomic, strong) BLNetwork *network;

@end

@implementation BLA1ViewController

- (void)dealloc
{
    [self setNetwork:nil];
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
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    /*Init network library*/
    _network = [[BLNetwork alloc] init];
    
    /*Add temperature label*/
    CGRect viewFrame = self.view.frame;
    UILabel *tempLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [tempLabel setBackgroundColor:[UIColor clearColor]];
    [tempLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [tempLabel setTextColor:[UIColor blackColor]];
    [tempLabel setText:[NSString stringWithFormat:@"temp: %.1f℃", _temperature]];
    viewFrame = [tempLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    viewFrame.origin.x = 15.0f;
    viewFrame.origin.y = 15.0f;
    [tempLabel setFrame:viewFrame];
    [self.view addSubview:tempLabel];
    
    /*Add humidity label*/
    viewFrame = tempLabel.frame;
    viewFrame.origin.y += viewFrame.size.height + 10.0f;
    viewFrame.size.width = self.view.frame.size.width;
    UILabel *humidityLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [humidityLabel setBackgroundColor:[UIColor clearColor]];
    [humidityLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [humidityLabel setTextColor:[UIColor blackColor]];
    [humidityLabel setText:[NSString stringWithFormat:@"humidity: %.1f%%", _humidity]];
    viewFrame = [humidityLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    [humidityLabel setFrame:viewFrame];
    [self.view addSubview:humidityLabel];
    
    /*Add light label*/
    viewFrame = humidityLabel.frame;
    viewFrame.origin.y += viewFrame.size.height + 10.0f;
    viewFrame.size.width = self.view.frame.size.width;
    UILabel *lightLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [lightLabel setBackgroundColor:[UIColor clearColor]];
    [lightLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [lightLabel setTextColor:[UIColor blackColor]];
    [lightLabel setText:[NSString stringWithFormat:@"light: %d", _light]];
    viewFrame = [lightLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    [lightLabel setFrame:viewFrame];
    [self.view addSubview:lightLabel];
    
    /*Add airQuality label*/
    viewFrame = lightLabel.frame;
    viewFrame.origin.y += viewFrame.size.height + 10.0f;
    viewFrame.size.width = self.view.frame.size.width;
    UILabel *airQualityLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [airQualityLabel setBackgroundColor:[UIColor clearColor]];
    [airQualityLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [airQualityLabel setTextColor:[UIColor blackColor]];
    [airQualityLabel setText:[NSString stringWithFormat:@"airQuality: %d", _airQuality]];
    viewFrame = [airQualityLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    [airQualityLabel setFrame:viewFrame];
    [self.view addSubview:airQualityLabel];
    
    /*Add noisy label*/
    viewFrame = airQualityLabel.frame;
    viewFrame.origin.y += viewFrame.size.height + 10.0f;
    viewFrame.size.width = self.view.frame.size.width;
    UILabel *noisyLabel = [[UILabel alloc] initWithFrame:viewFrame];
    [noisyLabel setBackgroundColor:[UIColor clearColor]];
    [noisyLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [noisyLabel setTextColor:[UIColor blackColor]];
    [noisyLabel setText:[NSString stringWithFormat:@"noisy: %d", _noisy]];
    viewFrame = [noisyLabel textRectForBounds:viewFrame limitedToNumberOfLines:1];
    [noisyLabel setFrame:viewFrame];
    [self.view addSubview:noisyLabel];
    
    
    /*Add task list button.*/
    UIBarButtonItem *taskListBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"TaskList" style:UIBarButtonItemStylePlain target:self action:@selector(a1TaskList:)];
    [self.navigationItem setRightBarButtonItem:taskListBarButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)a1TaskList:(UIBarButtonItem *)item
{
    BLA1TaskListTableViewController *vc = [[BLA1TaskListTableViewController alloc ]init];
    [vc setInfo:_info];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
