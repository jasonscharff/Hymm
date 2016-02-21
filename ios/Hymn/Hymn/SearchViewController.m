//
//  searchViewController.m
//  Hymn
//
//  Created by Jason Scharff on 2/20/16.
//  Copyright © 2016 Jason Scharff. All rights reserved.
//

#import "SearchViewController.h"

#import "AutolayoutHelper.h"
#import "SearchResultTableViewCell.h"
#import "Song.h"
#import "SpotifyRESTSessionManager.h"
#import "UIColor+ColorPalette.h"

@interface SearchViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonnull, strong) UILabel *noResultsLabel;

@end

static NSString *SEARCH_RESULT_TABLE_VIEW_REUSE_IDENTIFIER = @"com.jasonscharff.search_results_table_view_identifier";

@implementation SearchViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithRed:236.0f/255.0f
                                              green:240.0f/255.0f
                                               blue:241.0f/255.0f
                                              alpha:1];
  self.title = @"Search Spotify";
  self.searchField = [[UITextField alloc]init];
  self.searchField.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0);
  self.searchField.placeholder = @"Search for your favorite song.";
  self.searchField.font = [UIFont fontWithName:@"AvenirNext-Regular" size:20];
  self.searchField.layer.cornerRadius = 8.0;
  self.searchField.layer.borderWidth = 2.0;
  self.searchField.layer.borderColor = [UIColor blackColor].CGColor;
  self.searchField.returnKeyType = UIReturnKeyDone;
  self.searchField.delegate = self;
  self.searchField.textColor = [UIColor blackColor];
  
  self.tableView = [[UITableView alloc]init];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.rowHeight = 150;
  self.tableView.tableFooterView = [UIView new];
  [self.tableView registerClass:[SearchResultTableViewCell class] forCellReuseIdentifier:SEARCH_RESULT_TABLE_VIEW_REUSE_IDENTIFIER];
  
  [AutolayoutHelper configureView:self.view
                      subViews:VarBindings(_searchField, _tableView)
                      constraints:@[@"H:|[_tableView]|",
                                    @"H:|-15-[_searchField]-15-|",
                                    @"V:|-15-[_searchField]-15-[_tableView]|"]];
  
  _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _activityIndicatorView.color = [UIColor navbarColor];
  [AutolayoutHelper configureView:self.view
                      subViews:VarBindings(_activityIndicatorView)
                      constraints:@[@"X:_activityIndicatorView.centerX == superview.centerX",
                                    @"X:_activityIndicatorView.centerY == superview.centerY"]];
  _activityIndicatorView.hidden = YES;
  
  _noResultsLabel = [UILabel new];
  _noResultsLabel.text = @"No results found.";
  _noResultsLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16];
  _noResultsLabel.hidden = YES;
  
  
  [AutolayoutHelper configureView:self.view
                         subViews:VarBindings(_noResultsLabel)
                      constraints:@[@"X:_noResultsLabel.centerX == superview.centerX",
                                    @"X:_noResultsLabel.centerY == superview.centerY"]];
  
  [_searchField addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
  
}

-(void)textFieldDidChange : (UITextField *)textField {
  if(textField.text.length <=0) {
    _noResultsLabel.hidden = YES;
    _searchResults = @[];
    [_tableView reloadData];
  }
  else {
    [_activityIndicatorView startAnimating];
    _activityIndicatorView.hidden = NO;
    [[SpotifyRESTSessionManager sharedSessionManager]searchWithQuery:textField.text :^(NSArray<Song *> * results) {
      if(textField.text.length <=0) {
        _noResultsLabel.hidden = YES;
        _searchResults = @[];
        [_tableView reloadData];
      }
      else {
        _searchResults = results;
        _activityIndicatorView.hidden = YES;
        [_activityIndicatorView stopAnimating];
        if(_searchResults.count == 0) {
          _noResultsLabel.hidden = NO;
        }
        else {
          _noResultsLabel.hidden = YES;
        }
        [_tableView reloadData];
      }
      
    }];
  }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  
  [textField resignFirstResponder];
  
  return YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _searchResults.count;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self.searchField resignFirstResponder];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SEARCH_RESULT_TABLE_VIEW_REUSE_IDENTIFIER];
  [cell configureFromSong:_searchResults[indexPath.row]];
  return cell;
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
