//
//  CYKMainViewController.m
//  Homework
//
//  Created by jon on 2019/1/3.
//  Copyright © 2019 jon. All rights reserved.
//

#import "CYKMainViewController.h"
#import "CYKZooTableViewCell.h"
#import "CYKZooSummaryHeaderView.h"
#import "PlantFetcher.h"
#import "Plant.h"
#import <QuartzCore/QuartzCore.h>

static NSString *headerViewIdentifier = @"CYKZooSummaryHeaderView";

@interface CYKMainViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *planets;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIPanGestureRecognizer *pangesture;
@property (weak, nonatomic) IBOutlet UIView *topSegmentView;

@property (weak, nonatomic) IBOutlet UILabel *zooTitleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UILabel *statisticLabel;

@property (strong, nonatomic) PlantFetcher *fetcher;
@property (strong, nonatomic) NSNumber *totalPlant;

@property (assign, nonatomic) CGFloat statusBarHeight;
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;

@property (assign, nonatomic) BOOL loadingMoreData;
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) BOOL isPanEnd;

@end

@implementation CYKMainViewController {
    CYKZooSummaryHeaderView *_header;
    NSCache *_imageCache;
    CFTimeInterval _stopTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _imageCache = [[NSCache alloc] init];
    _loadingMoreData = NO;
    _isAnimating = NO;
    _statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    _isPanEnd = YES;
    
    self.planets = [NSMutableArray new];
    
    [self.tableView registerNib:[UINib nibWithNibName:headerViewIdentifier bundle:nil] forHeaderFooterViewReuseIdentifier:headerViewIdentifier];
    self.tableView.frame = CGRectMake(0, 150, _screenWidth, _screenHeight - _statusBarHeight);
    
    self.pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragTable:)];
    self.pangesture.delegate = self;
    [self.pangesture setMinimumNumberOfTouches:1];
    [self.pangesture setMaximumNumberOfTouches:1];
    [self.tableView addGestureRecognizer:_pangesture];
    
    self.fetcher = [[PlantFetcher alloc] init];
    [self.fetcher fetchAt:0 limit:20 completedBlock:^(NSArray * _Nonnull plants, NSNumber * _Nonnull total) {
        self.totalPlant = total;
        [self.planets addObjectsFromArray:plants];
        [self.tableView reloadData];
    }];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkIfNeedCollapse:) userInfo:nil repeats:YES];
}

- (void)checkIfNeedCollapse:(NSTimer *)timer {
    if (_stopTime) {
        if (_isPanEnd) {
            if (!_isAnimating) {
                CGFloat currentY = self.tableView.frame.origin.y;
                if (currentY != 150 && currentY != _statusBarHeight) {
                    CFTimeInterval stillTime = CACurrentMediaTime() - _stopTime;
                    if (stillTime > 0.15) {
                        _isAnimating = YES;
                        if (currentY < (150 - _statusBarHeight)/2 + _statusBarHeight) { // Up
                            [self moveUp];
                        } else { // Down
                            [self moveDown];
                        }
                    }
                }
            }
        }
    }
}

- (void)moveUp {
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame = CGRectMake(0, self.statusBarHeight, self.screenWidth, self.screenHeight - self.statusBarHeight);
        self->_header.titleLabel.alpha = 1;
        self.zooTitleLabel.alpha = 0;
        self.segmentControl.alpha = 0;
        self.statisticLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

- (void)moveDown {
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame = CGRectMake(0, 150, self.screenWidth, self.screenHeight - self.statusBarHeight);
        self->_header.titleLabel.alpha = 0;
        self.zooTitleLabel.alpha = 1;
        self.segmentControl.alpha = 1;
        self.statisticLabel.alpha = 1;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
    }];
}

//MARK: - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_planets count];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CYKZooTableViewCell";
    CYKZooTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:cellIdentifier bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    Plant *p = self.planets[indexPath.row];
    
    cell.nameLabel.text = p.name;
    cell.locationLabel.text = p.location;
    cell.featureLabel.text = p.feature;
    
    UIImage *image = [_imageCache objectForKey:p.imageUrl];
    if (image) {
        cell.thumbnailImageView.image = image;
    } else {
        cell.thumbnailImageView.image = [UIImage imageNamed:@"leaf"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *imageURL = [NSURL URLWithString:p.imageUrl];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    CYKZooTableViewCell *cell = (CYKZooTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        cell.thumbnailImageView.image = image;
                    }
                });
                [self->_imageCache setObject:image forKey:p.imageUrl];
            }
       });
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerViewIdentifier];
    return _header;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.planets.count - 1 && self.planets.count >= 20) {
        if (_loadingMoreData == NO && self.planets.count < self.totalPlant.intValue) {
            _loadingMoreData = YES;
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicator.frame = CGRectMake(0, 0, _screenWidth, 44);
            [indicator startAnimating];
            tableView.tableFooterView = indicator;
            [tableView.tableFooterView setHidden:NO];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.fetcher fetchAt:(int)self.planets.count limit:20 completedBlock:^(NSArray * _Nonnull plants, NSNumber * _Nonnull total) {
                    [self.planets addObjectsFromArray:plants];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        self->_loadingMoreData = NO;
                        [self.tableView.tableFooterView removeFromSuperview];
                        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self->_screenWidth, 5)];
                        tableView.tableFooterView = view;
                        [tableView.tableFooterView setHidden:NO];
                    });
                }];
            });
        }
    }
}

//MARK: - UIPangestureRecognizer

- (void)dragTable:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    CGFloat currentY = self.tableView.frame.origin.y;
    CGFloat contentOffsetY = self.tableView.contentOffset.y;
    CGFloat adjustY = currentY + translation.y;
    
    if (adjustY <= _statusBarHeight) {
        adjustY = _statusBarHeight;
    }
    
    if (adjustY >= 150) {
        adjustY = 150;
    }
    
    if (currentY != _statusBarHeight || contentOffsetY < 5) {
        self.tableView.frame = CGRectMake(0, adjustY, _screenWidth, _screenHeight - _statusBarHeight);
        
        double ratio = (adjustY - _statusBarHeight) / (150 - _statusBarHeight);
        _header.titleLabel.alpha = 1 - ratio;
        
        _zooTitleLabel.alpha = ratio;
        _segmentControl.alpha = ratio;
        _statisticLabel.alpha = ratio;
    }
    
    [sender setTranslation:CGPointZero inView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        _isPanEnd = NO;
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        _stopTime = CACurrentMediaTime();
        _isPanEnd = YES;
    }
}

//MARK: - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    CGFloat currentY = self.tableView.frame.origin.y;
    
    if (currentY > _statusBarHeight && currentY <= 150) {
        return NO;
    } else {
        return YES;
    }
}

@end
