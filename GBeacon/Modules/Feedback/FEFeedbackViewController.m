//
//  FEFeedbackViewController.m
//  BLEAssistant
//
//  Created by feasycom on 2025/11/25.
//  Copyright © 2025 feasycom. All rights reserved.
//

#import "FEFeedbackViewController.h"
#import "Masonry.h"
#import "FeasyCallbackSDK.h"
#import "LogListViewController.h"

@interface FEFeedbackViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
// 反馈类型相关
@property (nonatomic, strong) UIView *typeView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) NSArray<UIButton *> *typeButtons;
@property (nonatomic, assign) FEEDBACKTYPE selectedType;

// 问题描述
@property (nonatomic, strong) UIView *descriptionView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;

// 联系邮箱
@property (nonatomic, strong) UIView *emailView;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) UITextField *emailTextField;

// 提交按钮
@property (nonatomic, strong) UIButton *submitButton;

// 类型标题数组
@property (nonatomic, strong) NSArray *typeTitles;

@end

@implementation FEFeedbackViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13.0, *)) {
        NSDictionary *dic = @{NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightMedium]};
        
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor darkGrayColor];
        appearance.titleTextAttributes = dic;
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    
    [self setupNavigationContent];
    [self setupData];
    [self setupUI];
    [self setupConstraints];
    [self setupKeyboardDismissal];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showKeyboard:)name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeKeyboard:)name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupData {
    self.typeTitles = @[LS(@"Advice"), LS(@"Function"), LS(@"UI"), LS(@"Cooperate")];
    self.selectedType = FEEDBACKTYPE_ADVICE;
}

- (void)setupUI {
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 88)];
    self.scrollView.backgroundColor = [UIColor colorWithRed:247/255.0 green:248/255.0 blue:249/255.0 alpha:0];
    
    [self.view addSubview:self.scrollView];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:248/255.0 blue:249/255.0 alpha:1.00];;
    self.title = LS(@"Feed Back");
    
    _typeView = [[UIView alloc] init];
    _typeView.backgroundColor = [UIColor whiteColor];
    _typeView.layer.cornerRadius = 8;
    [self.scrollView addSubview:_typeView];
    
    _descriptionView = [[UIView alloc] init];
    _descriptionView.backgroundColor = [UIColor whiteColor];
    _descriptionView.layer.cornerRadius = 8;
    [self.scrollView addSubview:_descriptionView];
    
    _emailView = [[UIView alloc] init];
    _emailView.backgroundColor = [UIColor whiteColor];
    _emailView.layer.cornerRadius = 8;
    [self.scrollView addSubview:_emailView];
    
    // 反馈类型标签
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.text = LS(@"Feedback Type");
    self.typeLabel.font = [UIFont boldSystemFontOfSize:16];
    self.typeLabel.textColor = [UIColor blackColor];
    [_typeView addSubview:self.typeLabel];
    
    // 创建类型按钮
    NSMutableArray *buttons = [NSMutableArray array];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:16];
    for (NSInteger i = 0; i < self.typeTitles.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        NSAttributedString *selectedTitle = [[NSAttributedString alloc]
                                             initWithString:self.typeTitles[i]
                                             attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:16],
            NSForegroundColorAttributeName: [UIColor grayColor]
        }];
        [button setAttributedTitle:selectedTitle forState:UIControlStateNormal];
        
        selectedTitle = [[NSAttributedString alloc]
                         initWithString:self.typeTitles[i]
                         attributes:@{
            NSFontAttributeName: boldFont,
            NSForegroundColorAttributeName: [UIColor colorWithRed:0/255.0 green:117/255.0 blue:201/255.0 alpha:1.00]
        }];
        [button setAttributedTitle:selectedTitle forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.cornerRadius = 6;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(typeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.typeView addSubview:button];
        [buttons addObject:button];
    }
    self.typeButtons = [buttons copy];
    
    // 问题描述标签
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text = LS(@"Description");
    self.descriptionLabel.font = [UIFont boldSystemFontOfSize:16];
    self.descriptionLabel.textColor = [UIColor blackColor];
    [self.descriptionView addSubview:self.descriptionLabel];
    
    // 问题描述输入框
    self.textView = [[UITextView alloc] init];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.04].CGColor;
    self.textView.layer.cornerRadius = 6;
    self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    self.textView.backgroundColor = [UIColor colorWithRed:247/255.0 green:248/255.0 blue:249/255.0 alpha:1.00];
    [self.descriptionView addSubview:self.textView];
    
    // 占位符
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.text = LS(@"INPUT_QUESTION_PROMPT");
    self.placeholderLabel.font = [UIFont systemFontOfSize:14];
    self.placeholderLabel.textColor = [UIColor lightGrayColor];
    [self.textView addSubview:self.placeholderLabel];
    
    // 邮箱标签（带星号）
    self.emailLabel = [[UILabel alloc] init];
    NSString *emailText = LS(@"Fb_email");
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:emailText];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(1, emailText.length - 1)];
    self.emailLabel.attributedText = attributedText;
    self.emailLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.emailView addSubview:self.emailLabel];
    
    // 邮箱输入框
    self.emailTextField = [[UITextField alloc] init];
    self.emailTextField.placeholder = LS(@"Please enter your email.");
    self.emailTextField.font = [UIFont systemFontOfSize:14];
    self.emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.backgroundColor = [UIColor colorWithRed:247/255.0 green:248/255.0 blue:249/255.0 alpha:1.00];
    [self.emailView addSubview:self.emailTextField];
    
    // 提交按钮
    self.submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.submitButton setTitle:LS(@"Submit") forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.submitButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:117/255.0 blue:201/255.0 alpha:1.00];
    self.submitButton.layer.cornerRadius = 6;
    [self.submitButton addTarget:self action:@selector(submitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.submitButton];
    
    // 设置初始选中状态
    [self updateTypeButtonSelection];
}

- (void)setupConstraints {
    // 类型约束
    CGFloat margin = 16;
    CGFloat buttonHeight = 36;
    CGFloat textViewHeight = 120;
    CGFloat fieldHeight = 44;
    __weak typeof(self) weakSelf = self;
    [self.typeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(20);
        make.right.equalTo(weakSelf.scrollView).offset(-20);
        make.width.offset(weakSelf.scrollView.frame.size.width - 40);
    }];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.typeView).offset(margin);
        make.left.equalTo(weakSelf.typeView).offset(margin);
        make.right.equalTo(weakSelf.typeView).offset(-margin);
    }];
    
    NSMutableArray *typeButtons1  = [NSMutableArray array];
    NSMutableArray *typeButtons2  = [NSMutableArray arrayWithObject:[self.typeButtons lastObject]];
    for (int i = 0; i < 3; i ++) {
        [typeButtons1 addObject:self.typeButtons[i]];
    }
    
    // 类型按钮水平等分布局
    [typeButtons1 mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:8 leadSpacing:margin tailSpacing:margin];
    [typeButtons1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.typeLabel.mas_bottom).offset(12);
        make.height.offset(buttonHeight);
    }];
    
    [typeButtons2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.typeButtons[0].mas_bottom).offset(12);
        make.leading.equalTo(weakSelf.typeButtons[0]);
        make.bottom.equalTo(weakSelf.typeView).offset(-20);
        make.width.equalTo(weakSelf.typeButtons[0]);
        make.height.offset(buttonHeight);
    }];
    
    // 问题描述
    [self.descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.typeView.mas_bottom).offset(20);
        make.left.offset(20);
        make.width.equalTo(weakSelf.scrollView).offset(-40);
    }];
    
    [self.descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.descriptionView).offset(margin);
        make.left.equalTo(weakSelf.descriptionView).offset(margin);
        make.right.equalTo(weakSelf.descriptionView).offset(-margin);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.descriptionLabel.mas_bottom).offset(8);
        make.left.equalTo(weakSelf.descriptionView).offset(margin);
        make.right.equalTo(weakSelf.descriptionView).offset(-margin);
        make.height.mas_equalTo(textViewHeight);
        make.bottom.equalTo(weakSelf.descriptionView).offset(-margin);
    }];
    
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.textView).offset(8);
        make.left.equalTo(weakSelf.textView).offset(12);
        make.right.equalTo(weakSelf.textView).offset(-8);
    }];
    
    // 邮箱
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.descriptionView.mas_bottom).offset(20);
        make.left.offset(20);
        make.width.equalTo(weakSelf.scrollView).offset(-40);
        make.bottom.offset(-20);
    }];
    [self.emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.emailView).offset(margin);
        make.left.equalTo(weakSelf.emailView).offset(margin);
        make.right.equalTo(weakSelf.emailView).offset(-margin);
    }];
    
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.emailLabel.mas_bottom).offset(8);
        make.left.equalTo(weakSelf.emailView).offset(margin);
        make.right.equalTo(weakSelf.emailView).offset(-margin);
        make.height.mas_equalTo(fieldHeight);
        make.bottom.equalTo(weakSelf.emailView).offset(-margin);
    }];
    
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(margin);
        make.right.equalTo(weakSelf.view).offset(-margin);
        make.bottom.equalTo(weakSelf.view).offset(-20);
        make.height.mas_equalTo(48);
        
    }];
}

- (void)setupNavigationContent {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:LS(@"Log Export") style:UIBarButtonItemStylePlain target:self action:@selector(toLogListAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)toLogListAction {
    LogListViewController *logListViewController = [[LogListViewController alloc] init];
    [self.navigationController pushViewController:logListViewController animated:YES];
}

#pragma mark - Button Actions
- (void)typeButtonClicked:(UIButton *)sender {
    self.selectedType = sender.tag;
    [self updateTypeButtonSelection];
}

- (void)submitButtonClicked {
    // 处理提交逻辑
    NSString *description = self.textView.text;
    NSString *email = self.emailTextField.text;
    
    if (description.length == 0) {
        [self showAlert:LS(@"INPUT_QUESTION_PROMPT")];
        return;
    }
    
    if (email.length == 0 || ![self isValidEmail:email]) {
        [self showAlert:LS(@"Please enter a valid email address")];
        return;
    }
    
    NSLog(@"反馈类型: %@", self.typeTitles[self.selectedType]);
    NSLog(@"问题描述: %@", description);
    NSLog(@"联系邮箱: %@", email);
    __weak typeof(self) weakSelf = self;
    [FeasyCallbackSDK submitFeedbackWithType:self.selectedType content:self.textView.text tel:nil phone:nil email:self.emailTextField.text wechat:nil QQ:nil completion:^(NSInteger code, NSDictionary * _Nullable data, NSString * _Nullable msg, NSError * _Nullable error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil) {
                [weakSelf showAlert:LS(@"FEEDBACK_SUCCEEDED")];
            }else{
                [weakSelf showAlert:LS(@"FEEDBACK_FAILED")];
            }
        });
    }];
}

- (void)updateTypeButtonSelection {
    for (NSInteger i = 0; i < self.typeButtons.count; i++) {
        UIButton *button = self.typeButtons[i];
        if (i == self.selectedType) {
            button.selected = YES;
            //            button.backgroundColor = [UIColor blueColor];
            button.layer.borderColor = [UIColor colorWithRed:0/255.0 green:117/255.0 blue:201/255.0 alpha:1.00].CGColor;
        } else {
            button.selected = NO;
            //            button.backgroundColor = [UIColor whiteColor];
            button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        }
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0;
}

#pragma mark - Helper Methods
- (BOOL)isValidEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LS(@"Infomation") message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LS(@"OK") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - keyboard

-(void)showKeyboard:(NSNotification*)notification{
    //读取userInfo中的动画种类
    NSInteger option = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue];
    //读取userInfo中的动画时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]floatValue];
    //获取弹起的键盘的frame中的左顶点位置的y
    //    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration   delay:0 options:option animations:^{
        weakSelf.view.frame = CGRectMake(0, -weakSelf.descriptionView.frame.origin.y, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        [ weakSelf.view layoutIfNeeded];
    }completion:nil];
}
-(void)closeKeyboard:(NSNotification*)notification{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view layoutIfNeeded];
}
//键盘收回设置
-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupKeyboardDismissal {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tapGesture];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
