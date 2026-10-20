//
//  FEFunctionButton.h
//  BLEAssistant
//
//  Created by feasycom on 2025/11/24.
//  Copyright © 2025 feasycom. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FEFunctionButton : UIControl

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithIconName:(NSString *)iconName title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
