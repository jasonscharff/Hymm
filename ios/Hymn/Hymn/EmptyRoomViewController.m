//
//  EmptyRoomViewController.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "EmptyRoomViewController.h"

#import "AutolayoutHelper.h"
#import "Constants.h"
#import "CurrentMusicController.h"
#import "SocketManager.h"

@interface EmptyRoomViewController ()
@property (nonatomic, strong) NSDictionary *observingNotifications;
@end

@implementation EmptyRoomViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self registerForNotifications];
  self.title = @"Empty Room";
  self.view.backgroundColor = [UIColor whiteColor];
  UILabel *nothingHereLabel = [UILabel new];
  nothingHereLabel.text = @"This room is empty.";
  nothingHereLabel.textAlignment = NSTextAlignmentCenter;
  nothingHereLabel.numberOfLines = 0;
  nothingHereLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18];
  
  [AutolayoutHelper configureView:self.view
                         subViews:VarBindings(nothingHereLabel)
                      constraints:@[@"H:|-20-[nothingHereLabel]-20-|",
                                    @"X:nothingHereLabel.centerY == superview.centerY"]];
}

- (void)registerForNotifications {
  self.observingNotifications = @{SONG_HAS_BEEN_CHOSEN : @"songHasBeenChosen:"};
  
  [self.observingNotifications enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:NSSelectorFromString(obj)
                                                 name:key
                                               object:nil];
    
  }];
}

- (void)unregisterForNotifications {
  for (NSString *key in self.observingNotifications) {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:key
                                                  object:nil];
  }
}


-(void)dealloc {
  [self unregisterForNotifications];
}

-(void)songHasBeenChosen : (NSNotification *)notification {
  self.navigationItem.hidesBackButton = YES;
  self.navigationItem.leftBarButtonItem=nil;
  if([SocketManager sharedSocket].musicVC) {
    [self.navigationController pushViewController:[SocketManager sharedSocket].musicVC animated:YES];
  }
  else {
    CurrentMusicController *musicVC = [[CurrentMusicController alloc]init];
    [SocketManager sharedSocket].musicVC = musicVC;
    [self.navigationController pushViewController:musicVC animated:YES];
  }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
