//
//  BLListTableViewController.m
//  BroadLinkSDKDemo
//
//  Created by yang on 3/31/14.
//  Copyright (c) 2014 BroadLink. All rights reserved.
//

#import "BLListTableViewController.h"
#import "BLNetwork.h"
#import "BLDeviceInfo.h"
#import "JSONKit.h"
#import "BLEasyConfigViewController.h"
#import "BLSP2ViewController.h"
#import "BLRM2ViewController.h"
#import "BLA1ViewController.h"

@interface BLListTableViewController ()
{
    dispatch_queue_t networkQueue;
}

@property (nonatomic, strong) BLNetwork *network;
@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation BLListTableViewController

- (void)dealloc
{
    [self setNetwork:nil];
    [self setDeviceArray:nil];
    dispatch_release(networkQueue);
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
    
    [self.navigationItem setTitle:@"2014/08/09"];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    /*Init network queue.*/
    networkQueue = dispatch_queue_create("BroadLinkNetworkQueue", DISPATCH_QUEUE_CONCURRENT);
    
    /*Init network library*/
    self.network = [[BLNetwork alloc] init];
    
    self.deviceArray = [[NSMutableArray alloc] init];
    
    /*Add device list refresh button.*/
    UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                       target:self
                                                                                       action:@selector(onBtnRefresh:)];
    
    /*Add SDK version button.*/
    UIBarButtonItem *versionButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                       target:self
                                                                                       action:@selector(onBtnSDKVersionInfo:)];
    /*Add easyConfig button*/
    UIBarButtonItem *easyConfigButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Config"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onBtnEasyConfig:)];
    
    [self.navigationItem setRightBarButtonItems:@[refreshButtonItem, versionButtonItem]];
    [self.navigationItem setLeftBarButtonItem:easyConfigButtonItem];
    
    [self setClearsSelectionOnViewWillAppear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self networkInit];
}


#pragma mark -

- (void)networkInit
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:1] forKey:@"api_id"];
    [dic setObject:@"network_init" forKey:@"command"];
    [dic setObject:BROADLINK_LICENSE_KEY forKey:@"license"];
    NSData *requestData = [dic JSONData];
    
    dispatch_async(networkQueue, ^{
        NSData *responseData = [_network requestDispatch:requestData];
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            NSLog(@"Init success!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onBtnRefresh:nil];
            });
        }
        else
        {
            NSLog(@"Init failed!");
        }
    });
}

- (void)deviceAdd:(BLDeviceInfo *)info
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:12] forKey:@"api_id"];
    [dic setObject:@"device_add" forKey:@"command"];
    [dic setObject:info.mac forKey:@"mac"];
    [dic setObject:info.type forKey:@"type"];
    [dic setObject:info.name forKey:@"name"];
    [dic setObject:[NSNumber numberWithInt:info.lock] forKey:@"lock"];
    [dic setObject:[NSNumber numberWithUnsignedInt:info.password] forKey:@"password"];
    [dic setObject:[NSNumber numberWithInt:info.terminal_id] forKey:@"id"];
    [dic setObject:[NSNumber numberWithInt:info.sub_device] forKey:@"subdevice"];
    [dic setObject:info.key forKey:@"key"];
    NSData *requestData = [dic JSONData];
    
    dispatch_async(networkQueue, ^{
        NSData *responseData = [_network requestDispatch:requestData];
        
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            NSLog(@"Add %@ success!", info.mac);
        }
        else
        {
            NSLog(@"Add %@ failed!", info.mac);
        }
    });
}



#pragma mark - UITableView

- (void)refreshDeviceList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
    NSString *state = @"";
    NSString *localIP = @"";
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:16] forKey:@"api_id"];
    [dic setObject:@"device_state" forKey:@"command"];
    [dic setObject:info.mac forKey:@"mac"];
    NSData *requestData = [dic JSONData];
    NSData *responseData = [_network requestDispatch:requestData];
    if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
    {
        state = [[responseData objectFromJSONData] objectForKey:@"status"];
    }
    
    [dic removeAllObjects];
    [dic setObject:[NSNumber numberWithInt:15] forKey:@"api_id"];
    [dic setObject:@"device_lan_ip" forKey:@"command"];
    [dic setObject:info.mac forKey:@"mac"];
    requestData = [dic JSONData];
    responseData = [_network requestDispatch:requestData];
    if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
    {
        localIP = [[responseData objectFromJSONData] objectForKey:@"lan_ip"];
    }
    
    [cell.textLabel setText:info.name];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@ %@ %@ %@", info.mac, info.type, state, localIP]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
        BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
        dispatch_async(networkQueue, ^{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:[NSNumber numberWithInt:14] forKey:@"api_id"];
            [dic setObject:@"device_delete" forKey:@"command"];
            [dic setObject:info.mac forKey:@"mac"];
            
            NSData *requestData = [dic JSONData];
            
            NSData *responseData = [_network requestDispatch:requestData];
            NSLog(@"%@", [responseData objectFromJSONData]);
            /*If parse success...*/
            if ([[responseData objectFromJSONData] objectForKey:@"code"] == 0)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_deviceArray removeObjectAtIndex:indexPath.row];
                    [self.tableView reloadData];
                });
            }
        });
    } 
    else if (editingStyle == UITableViewCellEditingStyleInsert) 
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLDeviceInfo *info = [_deviceArray objectAtIndex:indexPath.row];
    if (![info.type isEqualToString:@"SP2"] && ![info.type isEqualToString:@"RM2"] && ![info.type isEqualToString:@"A1"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"This Demo only control SP2/RM2/A1." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([info.type isEqualToString:@"SP2"])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:71] forKey:@"api_id"];
        [dic setObject:@"sp2_refresh" forKey:@"command"];
        [dic setObject:info.mac forKey:@"mac"];
        NSData *requestData = [dic JSONData];
        
        dispatch_async(networkQueue, ^{
            NSData *responseData = [_network requestDispatch:requestData];
            NSLog(@"%@", [responseData objectFromJSONData]);
            if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
            {
                int state = [[[responseData objectFromJSONData] objectForKey:@"status"] intValue];
                [self enterSP2ViewController:info status:state];
            }
            else
            {
                NSLog(@"Error");
                //TODO:
            }
        });
    }
    else if ([info.type isEqualToString:@"RM2"])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:131] forKey:@"api_id"];
        [dic setObject:@"rm2_refresh" forKey:@"command"];
        [dic setObject:info.mac forKey:@"mac"];
        NSData *requestData = [dic JSONData];
        
        dispatch_async(networkQueue, ^{
            NSData *responseData = [_network requestDispatch:requestData];
            NSDictionary * dict = [responseData objectFromJSONData];
            NSLog(@"%@", dict);

            if ([dict isKindOfClass:[NSDictionary class]]) {
                NSUInteger code = -1;
                if ([dict objectForKey:@"code"] != nil)
                    code = [[dict objectForKey:@"code"] intValue];
                
                //Success
                if (code == 0) {
                    if ([dict objectForKey:@"temperature"] != nil)
                        info.temperature = @([[dict objectForKey:@"temperature"] floatValue]);
                    [self enterRM2ViewController:info];
                }
            }
            else {
                NSLog(@"Error");
            }
        });
    }
    else if ([info.type isEqualToString:@"A1"])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSNumber numberWithInt:161] forKey:@"api_id"];
        [dic setObject:@"a1_refresh" forKey:@"command"];
        [dic setObject:info.mac forKey:@"mac"];
        NSData *requestData = [dic JSONData];
        
        dispatch_async(networkQueue, ^{
            NSData *responseData = [_network requestDispatch:requestData];
            NSLog(@"%@", [responseData objectFromJSONData]);
            if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
            {
                float temp = [[[responseData objectFromJSONData] objectForKey:@"temperature"] floatValue];
                float humidity = [[[responseData objectFromJSONData] objectForKey:@"humidity"] floatValue];
                int light = [[[responseData objectFromJSONData] objectForKey:@"light"] intValue];
                int air = [[[responseData objectFromJSONData] objectForKey:@"air"] intValue];
                int noisy = [[[responseData objectFromJSONData] objectForKey:@"noisy"] intValue];
                [self enterA1ViewController:info temp:temp humidity:humidity light:light air:air noisy:noisy];
            }
            else
            {
                NSLog(@"Error");
                //TODO:
            }
        });
    }
}


#pragma mark - Helpers

- (void)enterSP2ViewController:(BLDeviceInfo *)info status:(int)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BLSP2ViewController *viewController = [[BLSP2ViewController alloc] init];
        [viewController setInfo:info];
        [viewController setStatus:status];
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

- (void)enterRM2ViewController:(BLDeviceInfo *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BLRM2ViewController *viewController = [[BLRM2ViewController alloc] init];
        [viewController setInfo:info];
        [self.navigationController pushViewController:viewController animated:YES];
    });
}

- (void)enterA1ViewController:(BLDeviceInfo *)info temp:(float)temp humidity:(float)humidity light:(int)light air:(int)air noisy:(int)noisy
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BLA1ViewController *vc = [[BLA1ViewController alloc] init];
        [vc setInfo:info];
        [vc setTemperature:temp];
        [vc setHumidity:humidity];
        [vc setLight:light];
        [vc setAirQuality:air];
        [vc setNoisy:noisy];
        [self.navigationController pushViewController:vc animated:YES];
    });
}


#pragma mark - Actions

/*easyConfig action*/
- (void)onBtnEasyConfig:(UIBarButtonItem *)item
{
    BLEasyConfigViewController *vc = [[BLEasyConfigViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onBtnRefresh:(UIBarButtonItem *)item
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:11] forKey:@"api_id"];
    [dic setObject:@"probe_list" forKey:@"command"];

    NSData *requestData = [dic JSONData];
    dispatch_async(networkQueue, ^{
        /*Array must be save to database by your self, if no data change, probe_list can not response again.*/
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_deviceArray];
        
        NSData *responseData = [_network requestDispatch:requestData];
        NSLog(@"%@", [responseData objectFromJSONData]);
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            NSArray *list = [[responseData objectFromJSONData] objectForKey:@"list"];
            for (NSDictionary *item in list)
            {
                int i;
                BLDeviceInfo *info = [[BLDeviceInfo alloc] init];
                [info setMac:[item objectForKey:@"mac"]];
                [info setType:[item objectForKey:@"type"]];
                [info setName:[item objectForKey:@"name"]];
                [info setLock:[[item objectForKey:@"lock"] intValue]];
                [info setPassword:[[item objectForKey:@"password"] unsignedIntValue]];
                [info setTerminal_id:[[item objectForKey:@"id"] intValue]];
                [info setSub_device:[[item objectForKey:@"subdevice"] intValue]];
                [info setKey:[item objectForKey:@"key"]];
                
                for (i=0; i<array.count; i++)
                {
                    BLDeviceInfo *tmp = [array objectAtIndex:i];
                    if ([tmp.mac isEqualToString:info.mac])
                    {
                        [array replaceObjectAtIndex:i withObject:info];
                        break;
                    }
                }
                
                if (i >= array.count && ![info.type isEqualToString:@"Unknown"])
                {
                    [array addObject:info];
                    [self deviceAdd:info];
                }
            }
            
            [_deviceArray removeAllObjects];
            [_deviceArray addObjectsFromArray:array];
            [self refreshDeviceList];
        }
    });
}

- (void)onBtnSDKVersionInfo:(UIBarButtonItem *)item
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInt:2] forKey:@"api_id"];
    [dic setObject:@"SDK_version" forKey:@"command"];
    
    NSData *requestData = [dic JSONData];
    dispatch_async(networkQueue, ^{
        NSData *responseData = [_network requestDispatch:requestData];
        
        if ([[[responseData objectFromJSONData] objectForKey:@"code"] intValue] == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[responseData objectFromJSONData] objectForKey:@"version"] message:[[responseData objectFromJSONData] objectForKey:@"update"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
        }
    });
}

@end
