//
//  CTKeyboardToolView.h
//  CTNumberKeyboardView
//
//  Created by Admin on 2017/5/5.
//  Copyright © 2017年 Arvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTKeyboardToolView : UIView

+ (instancetype)defaultToolView;

+ (instancetype)toolViewWithHeight:(CGFloat)height;

- (void)applyToApperence:(NSInteger)them;

@end
