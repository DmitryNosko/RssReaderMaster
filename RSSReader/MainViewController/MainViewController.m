//
//  MainViewController.m
//  RSSReader
//
//  Created by Dzmitry Noska on 8/26/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "MainViewController.h"
#import "WebViewController.h"
#import "MainTableViewCell.h"
#import "DetailsViewController.h"
#import "FeedItem.h"
#import "RSSParser.h"
#import "MenuViewController.h"
#import "FeedResource.h"
#import "FileManager.h"

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, MainTableViewCellListener>
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray<FeedItem *>* feeds;
@property (strong, nonatomic) RSSParser* rssParser;
@property (strong, nonatomic) FeedItem* feedItem;
@property (strong, nonatomic) FeedResource* feedResource;
@end

static NSString* CELL_IDENTIFIER = @"Cell";
static NSString* PATTERN_FOR_VALIDATION = @"<\/?[A-Za-z]+[^>]*>";
static NSString* URL_TO_PARSE = @"https://news.tut.by/rss/index.rss";
//static NSString* URL_TO_PARSE = @"http://developer.apple.com/news/rss/news.rss";

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureNavigationBar];
    [self tableViewSetUp];
    self.feeds = [[NSMutableArray alloc] init];
    
    self.rssParser = [[RSSParser alloc] init];
    
    __weak MainViewController* weakSelf = self;
    self.rssParser.feedItemDownloadedHandler = ^(FeedItem *item) {
        [weakSelf performSelectorOnMainThread:@selector(addFeedItemToFeeds:) withObject:item waitUntilDone:NO];
    };
    
    [self.rssParser rssParseWithURL:[NSURL URLWithString:URL_TO_PARSE]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedResourceWasAddedNotification:)
                                                 name:MenuViewControllerFeedResourceWasAddedNotification
                                               object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) feedResourceWasAddedNotification:(NSNotification*) notification {
    [self.feeds removeAllObjects];
    self.feedItem = nil;
    self.rssParser = [[RSSParser alloc] init];
    FeedResource* resource = [notification.userInfo objectForKey:@"resource"];
    __weak MainViewController* weakSelf = self;
    self.rssParser.feedItemDownloadedHandler = ^(FeedItem *item) {
        [weakSelf performSelectorOnMainThread:@selector(addFeedItemToFeeds:) withObject:item waitUntilDone:NO];
    };
    
    [self.rssParser rssParseWithURL:resource.url];
}

- (void) configureNavigationBar {
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationItem.title = @"RSS Reader";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(handlemenuToggle)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void) handlemenuToggle {
    [self.delegate handleMenuToggle];
}

- (void) addFeedItemToFeeds:(FeedItem* ) item {
    if (item) {
        [self.feeds addObject:item];
        [self.tableView reloadData];
        //[[FileManager shared] save:item toFileWithName:@"TUTBY.txt"];
    }
}

- (void) resourseWasSavedLoadNotification:(NSNotification*) notification {
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feeds count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.listener = self;
    cell.titleLabel.text = [self.feeds objectAtIndex:indexPath.row].itemTitle;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WebViewController* dvc = [[WebViewController alloc] init];
    NSString* string = [self.feeds objectAtIndex:indexPath.row].link;
    NSString *stringForURL = [string substringWithRange:NSMakeRange(0, [string length]-6)];
    NSURL* url = [NSURL URLWithString:stringForURL];
    dvc.newsURL = url;
    [self.navigationController pushViewController:dvc animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}

- (NSString*) correctDescription:(NSString *) string { // vinesti v const rex
    NSRegularExpression* regularExpression = [NSRegularExpression regularExpressionWithPattern:PATTERN_FOR_VALIDATION
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    string = [regularExpression stringByReplacingMatchesInString:string
                                                         options:0
                                                           range:NSMakeRange(0, [string length])
                                                    withTemplate:@""];
    return string;
}

- (BOOL) hasRSSLink:(NSString*) link {
    return [[link substringWithRange:NSMakeRange(link.length - 4, 4)] isEqualToString:@".rss"];
}

#pragma mark - MainTableViewCellListener

- (void)didTapOnInfoButton:(MainTableViewCell *)infoButton {
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:infoButton];
    FeedItem* item = [self.feeds objectAtIndex:indexPath.row];
    
    DetailsViewController* dvc = [[DetailsViewController alloc] init];
    dvc.itemTitleString = item.itemTitle;
    dvc.itemDateString = item.pubDate;
    dvc.itemURLString = item.imageURL;
    dvc.itemDescriptionString = [self correctDescription:item.itemDescription];
    
    [self.navigationController pushViewController:dvc animated:YES];
}

#pragma mark - TableViewSetUp

- (void) tableViewSetUp {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.tableView registerClass:[MainTableViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
                                              [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
                                              [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
                                              [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
                                              [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
                                              ]];
}

#pragma mark - Shake gesture

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSThread* thread = [[NSThread alloc] initWithBlock:^{
        [self.rssParser rssParseWithURL:[NSURL URLWithString:URL_TO_PARSE]];
    }];
    [thread start];
    
}

@end
