//
//  FEFunctionButton.m
//  BLEAssistant
//
//  Created by feasycom on 2025/11/24.
//  Copyright © 2025 feasycom. All rights reserved.
//

#import "FEFunctionButton.h"

@implementation FEFunctionButton


- (instancetype)initWithIconName:(NSString *)iconName title:(NSString *)title {
    self = [super init];
    if (self) {
        [self setupUIWithIconName:iconName title:title];
    }
    return self;
}

- (void)setupUIWithIconName:(NSString *)iconName title:(NSString *)title {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    // 添加点击效果
    self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 1;
    
    // 图标
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.image = [UIImage imageNamed:iconName];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconImageView];
    
    // 标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = title;
    _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];
    
    // 使用Masonry设置约束
    [self setupConstraints];
}

- (void)setupConstraints {
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(30);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconImageView.mas_bottom).offset(10);
        make.leading.equalTo(self).offset(8);
        make.trailing.equalTo(self).offset(-8);
        make.bottom.equalTo(self).offset(-15);
    }];
}


@end
