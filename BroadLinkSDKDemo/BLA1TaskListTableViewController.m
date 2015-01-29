//
//  BLA1TaskListTableViewController.m
//  BroadLinkSDKDemo
//
//  Created by yzm157 on 14-6-6.
//  Copyright (c) 2014年 BroadLink. All rights reserved.
//

#import "BLA1TaskListTableViewController.h"
#import "JSONKit.h"
#import "BLNetwork.h"

@interface A1TaskInfo : NSObject

@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *taskName;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, assign) int taskIndex;
@property (nonatomic, assign) int timeEnable;
@property (nonatomic, assign) int taskEnable;
@property (nonatomic, assign) int repeat;
@property (nonatomic, assign) int sensorType;
@property (nonatomic, assign) int sensorTrigger;
@property (nonatomic, assign) float sensorValue;

@end

@implementation A1TaskInfo

- (void)dealloc
{
    [self setMac:nil];
    [self setTaskName:nil];
    [self setStartTime:nil];
    [self setEndTime:nil];
}

@end

@interface BLA1TaskListTableViewController ()

@property (nonatomic, strong) BLNetwork *network;

@property (nonatomic, strong) NSArray *listArray;

@end

@implementation BLA1TaskListTableViewController

- (void)dealloc
{
    [self setNetwork: nil];
}

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*set Title*/
    [self.navigationItem setTitle:@"Task List"];
    
    _network = [[BLNetwork alloc] init];
    
    /*Add task button*/
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add Task" style:UIBarButtonItemStylePlain target:self action:@selector(addBarButtonItemClicked:)];
    [self.navigationItem setRightBarButtonItem:addBarButtonItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:162] forKey:@"api_id"];
    [dic setObject:@"a1_task_list" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    
    NSData *requestData = [dic JSONData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *responseData = [_network requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSArray *list = [[responseData objectFromJSONData] objectForKey:@"list"];
            for (NSDictionary *dic in list)
            {
                A1TaskInfo *taskInfo = [[A1TaskInfo alloc] init];
                [taskInfo setMac:[dic objectForKey:@"mac"]];
                [taskInfo setStartTime:[dic objectForKey:@"start_time"]];
                [taskInfo setEndTime:[dic objectForKey:@"end_time"]];
                [taskInfo setTaskName:[dic objectForKey:@"task_name"]];
                [taskInfo setTaskIndex:[[dic objectForKey:@"index"] intValue]];
                [taskInfo setTimeEnable:[[dic objectForKey:@"time_enable"] intValue]];
                [taskInfo setTaskEnable:[[dic objectForKey:@"task_enable"] intValue]];
                [taskInfo setRepeat:[[dic objectForKey:@"repeat"] intValue]];
                [taskInfo setSensorType:[[dic objectForKey:@"sensor_type"] intValue]];
                [taskInfo setSensorTrigger:[[dic objectForKey:@"sensor_trigger"] intValue]];
                [taskInfo setSensorValue:[[dic objectForKey:@"sensor_value"] floatValue]];
                [array addObject:taskInfo];
            }
            
            _listArray = [NSArray arrayWithArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else
        {
            NSLog(@"Error");
            //TODO:
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"A1TaskListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    A1TaskInfo *taskInfo = [_listArray objectAtIndex:indexPath.row];
    [cell.textLabel setText:taskInfo.taskName];
    [cell.detailTextLabel setText:taskInfo.mac];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    A1TaskInfo *taskInfo = [_listArray objectAtIndex:indexPath.row];
    NSString *title = [NSString stringWithFormat:@"time_enable:%d\ntask_enable:%d\nstart_time:%@\nend_time:%@\nrepeat:%d\nsensor_type:%d\nsensor_trigger:%d\nsensor_value:%.1f\nmac:%@\n", taskInfo.timeEnable, taskInfo.taskEnable, taskInfo.startTime, taskInfo.endTime, taskInfo.repeat, taskInfo.sensorType, taskInfo.sensorTrigger, taskInfo.sensorValue, taskInfo.mac];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:taskInfo.taskName message:title delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        A1TaskInfo *taskInfo = [_listArray objectAtIndex:indexPath.row];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:164] forKey:@"api_id"];
        [dic setObject:@"a1_del_task" forKey:@"command"];
        [dic setObject:_info.mac forKey:@"mac"];
        [dic setObject:[NSNumber numberWithInt:taskInfo.taskIndex] forKey:@"index"];
        NSData *requestData = [dic JSONData];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *responseData = [_network requestDispatch:requestData];
            NSLog(@"%@", [responseData objectFromJSONData]);
            if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
            {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                NSArray *list = [[responseData objectFromJSONData] objectForKey:@"list"];
                for (NSDictionary *dic in list)
                {
                    A1TaskInfo *taskInfo = [[A1TaskInfo alloc] init];
                    [taskInfo setMac:[dic objectForKey:@"mac"]];
                    [taskInfo setStartTime:[dic objectForKey:@"start_time"]];
                    [taskInfo setEndTime:[dic objectForKey:@"end_time"]];
                    [taskInfo setTaskName:[dic objectForKey:@"task_name"]];
                    [taskInfo setTaskIndex:[[dic objectForKey:@"index"] intValue]];
                    [taskInfo setTimeEnable:[[dic objectForKey:@"time_enable"] intValue]];
                    [taskInfo setTaskEnable:[[dic objectForKey:@"task_enable"] intValue]];
                    [taskInfo setRepeat:[[dic objectForKey:@"repeat"] intValue]];
                    [taskInfo setSensorType:[[dic objectForKey:@"sensor_type"] intValue]];
                    [taskInfo setSensorTrigger:[[dic objectForKey:@"sensor_trigger"] intValue]];
                    [taskInfo setSensorValue:[[dic objectForKey:@"sensor_value"] floatValue]];
                    [array addObject:taskInfo];
                }
                
                _listArray = [NSArray arrayWithArray:array];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView reloadData];
                });
            }
            else
            {
                NSLog(@"Error");
                //TODO:
            }
        });
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*For demo, add a invalid task*/
- (void)addBarButtonItemClicked:(UIBarButtonItem *)item
{
    if (_listArray.count >= 8)
    {
        UIAlertView *alertView = [[UIAlertView alloc ]initWithTitle:@"Error" message:@"Max task count is 8." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:163] forKey:@"api_id"];
    [dic setObject:@"a1_add_task" forKey:@"command"];
    [dic setObject:_info.mac forKey:@"mac"];
    [dic setObject:@"Demo Add Task" forKey:@"task_name"];
    [dic setObject:[NSNumber numberWithInt:1] forKey:@"time_enable"];
    [dic setObject:[NSNumber numberWithInt:1] forKey:@"task_enable"];
    [dic setObject:@"2014-06-06 17:00:00" forKey:@"start_time"];
    [dic setObject:@"2014-06-06 18:00:00" forKey:@"end_time"];
    [dic setObject:[NSNumber numberWithInt:7] forKey:@"repeat"];
    [dic setObject:[NSNumber numberWithInt:0] forKey:@"sensor_type"];
    [dic setObject:[NSNumber numberWithInt:0] forKey:@"sensor_trigger"];
    [dic setObject:[NSNumber numberWithFloat:20.0f] forKey:@"sensor_value"];
    [dic setObject:@"aa:bb:cc:dd:ee:ff" forKey:@"device_mac"];
    [dic setObject:[NSNumber numberWithInt:12] forKey:@"device_id"];
    [dic setObject:@"097628343fe99e23765c1513accf8b02" forKey:@"device_key"];
    [dic setObject:@"RM2" forKey:@"device_type"];
    [dic setObject:@"0200010000000102" forKey:@"task_data"];
    NSLog(@"dic = %@", dic);
    NSData *requestData = [dic JSONData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *responseData = [_network requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSArray *list = [[responseData objectFromJSONData] objectForKey:@"list"];
            for (NSDictionary *dic in list)
            {
                A1TaskInfo *taskInfo = [[A1TaskInfo alloc] init];
                [taskInfo setMac:[dic objectForKey:@"mac"]];
                [taskInfo setStartTime:[dic objectForKey:@"start_time"]];
                [taskInfo setEndTime:[dic objectForKey:@"end_time"]];
                [taskInfo setTaskName:[dic objectForKey:@"task_name"]];
                [taskInfo setTaskIndex:[[dic objectForKey:@"index"] intValue]];
                [taskInfo setTimeEnable:[[dic objectForKey:@"time_enable"] intValue]];
                [taskInfo setTaskEnable:[[dic objectForKey:@"task_enable"] intValue]];
                [taskInfo setRepeat:[[dic objectForKey:@"repeat"] intValue]];
                [taskInfo setSensorType:[[dic objectForKey:@"sensor_type"] intValue]];
                [taskInfo setSensorTrigger:[[dic objectForKey:@"sensor_trigger"] intValue]];
                [taskInfo setSensorValue:[[dic objectForKey:@"sensor_value"] floatValue]];
                [array addObject:taskInfo];
            }
            
            _listArray = [NSArray arrayWithArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        else
        {
            NSLog(@"Error");
            //TODO:
        }
    });
}

@end
