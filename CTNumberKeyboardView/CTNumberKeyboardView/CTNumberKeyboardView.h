//
//  CTNumberKeyboardView.h
//  CTNumberKeyboardView
//
//  Created by Admin on 2017/5/5.
//  Copyright © 2017年 Arvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTNumberKeyboardView;
typedef NS_ENUM(NSInteger, CTKeyboardInputType)
{
    CTKeyboardInputDelete,  // 按键类型：删除
    CTKeyboardInputDone,    // 按键类型：完成
    CTKeyboardInputNumber   // 按键类型：数字
};

typedef void(^CTKeyboardInputBlock)(CTKeyboardInputType type, NSString *text);
typedef void(^CTResponderChangeBlock)(CTNumberKeyboardView * keyboardView, UIView * responderView);


@interface CTNumberKeyboardView : UIView

// 
@property (copy, nonatomic) CTKeyboardInputBlock keyboardInputBlock;

// 响应者切换Block
@property (copy, nonatomic) CTResponderChangeBlock responderChangeBlock;

// 删除按钮图片
@property (nonatomic, strong)UIImage * bkspRegularImage;

@property (nonatomic, strong)UIImage * bkspRandomImage;


+ (instancetype)defaultKeyboard;

// 随机排布数字键位置
- (void)randomNumber;

// 按顺序排布数字键位置
- (void)regularNumber;

@end
