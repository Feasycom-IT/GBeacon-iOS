//
//  FWPopoverViewController.m
//  FeasyBeacon
//
//  Created by ericj on 2018/3/7.
//  Copyright © 2018年 LIDONG. All rights reserved.
//

#import "FWPopoverViewController.h"

static NSString *cellID = @"cellID";

@interface FWPopoverViewController () <UIPopoverPresentationControllerDelegate>

@property (nonatomic, strong) NSArray *titles;

@end

@implementation FWPopoverViewController

- (instancetype)initWithTitles:(NSArray *)titles sourceView:(UIView *)sourceView {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _titles = titles;
        
        // 设置大小
        self.preferredContentSize = CGSizeMake(100, titles.count * 40);
        // 设置 Sytle
        self.modalPresentationStyle = UIModalPresentationPopover;
        
        UIPopoverPresentationController *popoverPresentationController = self.popoverPresentationController;
        
        // 需要通过 sourceView 来判断位置的
        popoverPresentationController.sourceView = sourceView;
        // 指定箭头所指区域的矩形框范围（位置和尺寸）,以sourceView的左上角为坐标原点
        popoverPresentationController.sourceRect = sourceView.bounds;
        // 箭头方向
        popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionRight;
        // 设置代理
        popoverPresentationController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = self.tableView;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.rowHeight = 40;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = _titles[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (_selectionHandler) {
        _selectionHandler(_titles[indexPath.row]);
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController: (UIPresentationController *)controller {
    return UIModalPresentationNone; //不适配
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES; //点击蒙版popover消失,默认YES
}

@end
