//
//  UITextField+Input.h
//  CTNumberKeyboardView
//
//  Created by Admin on 2017/5/5.
//  Copyright © 2017年 Arvin. All rights reserved.
//

#import <UIKit/UIKit.h>

// TextField 输入内容改变
UIKIT_EXTERN NSNotificationName const kTextFieldInputDidChangeNotification;


@interface UITextField (Input)

/*
 *  通过自定义键盘输入内容
 *
 *  @param  text  输入的内容
 *  @param  limit 限制输入长度 (0: 不限制)
 */
- (void)inputText:(NSString *)text limit:(NSInteger)limit;

@end
