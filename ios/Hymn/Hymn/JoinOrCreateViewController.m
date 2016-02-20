//
//  JoinOrCreateViewController.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "JoinOrCreateViewController.h"

#import "AutolayoutHelper.h"

#import "JoinViewController.h"

@interface JoinOrCreateViewController ()

@end

@implementation JoinOrCreateViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  UIFont *font = [UIFont fontWithName:@"AvenirNext-Regular" size:32];
  
  UIButton *joinButton = [[UIButton alloc]init];
  [joinButton setTitle:@"Join" forState:UIControlStateNormal];
  [joinButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  joinButton.titleLabel.font = font;
  [joinButton addTarget:self action:@selector(joinSpace:) forControlEvents:UIControlEventTouchUpInside];
  
  UIButton *createButton = [[UIButton alloc]init];
  [createButton setTitle:@"Create" forState:UIControlStateNormal];
  [createButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  createButton.titleLabel.font = font;
  [createButton addTarget:self action:@selector(createSpace:) forControlEvents:UIControlEventTouchUpInside];
  
  UIView *separator = [UIView new];
  separator.backgroundColor = [UIColor lightGrayColor];
  
  
  NSNumber *onePixel = @(1/[UIScreen mainScreen].scale);
  
  [AutolayoutHelper configureView:self.view
                        subViews:VarBindings(joinButton, createButton, separator)
                        metrics:VarBindings(onePixel)
                        constraints:@[@"H:|[separator]|",
                                      @"H:|[joinButton]|",
                                      @"H:|[createButton]|",
                                      @"V:|[joinButton][separator(onePixel)][createButton(==joinButton)]|"]];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)createSpace:(id)sender {
  
}

-(IBAction)joinSpace:(id)sender {
  JoinViewController *joinVC = [[JoinViewController alloc]init];
  [self.navigationController pushViewController:joinVC animated:YES];
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
