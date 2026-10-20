//
//  FWFilterViewController.m
//  BLEAssistant
//
//  Created by ericj on 2018/6/5.
//  Copyright © 2018年 feasycom. All rights reserved.
//

#import "FWFilterViewController.h"
#import "FWFilterNameTableViewCell.h"
#import "FWMinimumRSSITableViewCell.h"

@interface FWFilterViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    FBFilter *_filter;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FWMinimumRSSITableViewCell *cell;
@property (nonatomic, strong) UISwitch *filterNameEnabledSwitch;
@property (nonatomic, strong) UISlider *rssiSlider;

@end

@implementation FWFilterViewController

- (instancetype)initWithFilter:(FBFilter *)filter {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self setHidesBottomBarWhenPushed:YES];
        
        _filter = filter;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.navigationItem.title = LS(@"Filter");
    
    [self setupUI];
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //表头
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    headView.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.tableView.tableHeaderView = headView;
    
    //表尾
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    self.tableView.tableFooterView = footView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_filter saveData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        FWFilterNameTableViewCell *filterCell = [[[NSBundle mainBundle] loadNibNamed:@"FWFilterNameTableViewCell" owner:self options:nil] firstObject];
        [filterCell.filterEnableSwitch addTarget:self action:@selector(filterNameValueChanged:) forControlEvents:UIControlEventValueChanged];
        filterCell.filterEnableSwitch.on = _filter.filterByNameEnabled;
        filterCell.nameTextField.text = _filter.filterName;
        filterCell.nameTextField.delegate = self;
        self.filterNameEnabledSwitch = filterCell.filterEnableSwitch;
        return filterCell;
    } else {
        FWMinimumRSSITableViewCell *minimumCell = [[[NSBundle mainBundle] loadNibNamed:@"FWMinimumRSSITableViewCell" owner:self options:nil] firstObject];
        [minimumCell.minimumRSSISlider addTarget:self action:@selector(RSSIValueChanged:) forControlEvents:UIControlEventValueChanged];
        minimumCell.minimumRSSILabel.text = [NSString stringWithFormat:@"%.f dB", _filter.minimumRSSI];
        self.rssiSlider = minimumCell.minimumRSSISlider;
        self.rssiSlider.value = _filter.minimumRSSI;
        self.cell = minimumCell;
        return minimumCell;
    }
}

- (void)filterNameValueChanged:(UISwitch *)sender {
    _filter.filterByNameEnabled = sender.on;
}

- (void)RSSIValueChanged:(UISlider *)slider {
    _filter.minimumRSSI = slider.value;
    
    _cell.minimumRSSILabel.text = [NSString stringWithFormat:@"%.f dB", _filter.minimumRSSI];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 88.0;
    } else {
        return 44.0;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string rangeOfString:@"\r"].location != NSNotFound || [string rangeOfString:@"\n"].location != NSNotFound || [string rangeOfString:@"\x20"].location != NSNotFound) {
        return NO;
    }
    
    _filter.filterName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return YES;
}

@end
