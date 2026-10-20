//
//  FBAtEngineVC.m
//  FeasyBeacon
//
//  Created by chenchanghua on 2024/3/13.
//  Copyright © 2024 Feasycom. All rights reserved.
//

#import "FBAtEngineVC.h"

@interface FBAtEngineVC () <FBSessionDelegate>

@property (nonatomic, strong) FBSession *session;
@property (nonatomic, weak) id<FBSessionDelegate> sessionOriginDelegate;

@property (nonatomic, strong) UITextView *receiveTextView;// 接收框
@property (nonatomic, strong) UITextView *sendoutTextView;// 发送框
@property (nonatomic, strong) UIButton *sendoutBtn;// 发送按钮

@end

@implementation FBAtEngineVC

- (instancetype)initWithSession:(FBSession *)session {
    if (self = [super init]) {
        self.session = session;
        self.sessionOriginDelegate = session.delegate;
        [self.session setDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [self.session setDelegate:self.sessionOriginDelegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setupViewContent];
}

- (void)setupViewContent {
    // 接收数据框
    self.receiveTextView = [[UITextView alloc] init];
    self.receiveTextView.editable = NO;
    self.receiveTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.receiveTextView];
    [self.receiveTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(100);
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
        make.height.mas_equalTo(200);
    }];
    
    // 发送输入框
    self.sendoutTextView = [[UITextView alloc] init];
    self.sendoutTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.sendoutTextView];
    [self.sendoutTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.receiveTextView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.receiveTextView.mas_left);
        make.right.mas_equalTo(self.receiveTextView.mas_right);
        make.height.mas_equalTo(90);
    }];
    
    // 发送（输入框内容）按钮
    self.sendoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendoutBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.sendoutBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.sendoutBtn setTitle:LS(@"communication_send") forState:UIControlStateNormal];
    [self.sendoutBtn setBackgroundColor:[UIColor grayColor]];
    [self.sendoutBtn addTarget:self action:@selector(sendoutBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendoutBtn];
    [self.sendoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 40));
        make.top.mas_equalTo(self.sendoutTextView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.receiveTextView.mas_left);
        make.right.mas_equalTo(self.receiveTextView.mas_right);
    }];
}

- (void)sendoutBtnAction {
    [self.session openSession];
    [self.session writeDataInSession:[[NSString stringWithFormat:@"%@\r\n", self.sendoutTextView.text] dataUsingEncoding:NSUTF8StringEncoding]];
}

// 通话写入数据成功
- (void)sessionDidWrite:(FBSession *)session {
    NSLog(@"通话写入数据成功");
}

// 通话接受数据成功
- (void)session:(FBSession *)session didReceiveData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (string == nil) {
        string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    NSLog(@"string = %@", string);
    
    self.receiveTextView.text = [self.receiveTextView.text stringByAppendingString:string];
}

@end
