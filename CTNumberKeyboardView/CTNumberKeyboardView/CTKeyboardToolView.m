//
//  CTKeyboardToolView.m
//  CTNumberKeyboardView
//
//  Created by Admin on 2017/5/5.
//  Copyright © 2017年 Arvin. All rights reserved.
//

#import "CTKeyboardToolView.h"

@interface CTKeyboardToolView ()
{
    UIView * _textFieldView;
}

@property (nonatomic, strong)NSArray * responderAry;
@end

@implementation CTKeyboardToolView

+ (instancetype)defaultToolView
{
    return [[self class] toolViewWithHeight:44];
}

+ (instancetype)toolViewWithHeight:(CGFloat)height
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CTKeyboardToolView * toolView = [[CTKeyboardToolView alloc] initWithFrame:CGRectMake(0, 0, size.width, height)];
    return toolView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];

        [self initToolBar];
    }
    return self;
}

- (void)initToolBar
{
    CGFloat height = self.frame.size.height;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    UIButton * (^buttonBlock)(UIImage * img, NSString * title, NSInteger tag, CGFloat orgX) = ^(UIImage * img,NSString * title, NSInteger tag, CGFloat orgX) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (img)
        {
            [button setImage:img forState:UIControlStateNormal];
        }
        else
        {
            [button setTitle:title forState:UIControlStateNormal];
        }
        button.tag = tag;
        [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.2] forState:UIControlStateHighlighted];
        button.frame = CGRectMake(orgX, 0, 40, height);
        [button addTarget:self action:@selector(changeResponderAction:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    };
    UIButton * lastBtn = buttonBlock([UIImage imageNamed:@"up"],nil, 100, 10);
    UIButton * nextBtn = buttonBlock([UIImage imageNamed:@"down"],nil, 101, 50);
    
    [self addSubview:lastBtn];
    [self addSubview:nextBtn];
    
    UILabel * textLb = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, screenSize.width-200, height)];
    textLb.text = @"安全键盘已开启";
    textLb.tag = 103;
    textLb.textAlignment = NSTextAlignmentCenter;
    textLb.font = [UIFont systemFontOfSize:17];
    textLb.textColor = [UIColor whiteColor];
    [self addSubview:textLb];
    
    UIButton * doneBtn = buttonBlock(nil,@"完成", 102,  screenSize.width- 50);
    [self addSubview:doneBtn];
}

- (void)changeResponderAction:(UIButton *)btn
{
    if (btn.tag == 100) {
        [self goPrevious];
    }else if (btn.tag == 101) {
        [self goNext];
    }else if (btn.tag == 102) {
        BOOL success = [_textFieldView resignFirstResponder];
        if (!success) {
            [_textFieldView becomeFirstResponder];
            [_textFieldView resignFirstResponder];
        }
        _textFieldView = nil;
        self.responderAry = nil;
    }
}

- (void)applyToApperence:(NSInteger)them
{
    UIButton * lastBtn = [self viewWithTag:100];
    UIButton * nextBtn = [self viewWithTag:101];
    UIButton * doneBtn = [self viewWithTag:102];
    UILabel * lab = [self viewWithTag:103];
    if (them == 0) {
        [lastBtn setImage:[UIImage imageNamed:@"up_regular"] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"down_regular"] forState:UIControlStateNormal];
        [doneBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        lab.text = @"";
    }else {
        [lastBtn setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        lab.text = @"安全键盘已开启";
    }
}

- (void)textFieldViewDidBeginEditing:(NSNotification *)notification
{
    _textFieldView = notification.object;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"keyboard.firstResponderChangeNotification" object:notification.object];
}

- (NSArray *)responderViewsAryWithView:(UIView *)supView
{
    NSMutableArray * respondersViewAry = [NSMutableArray arrayWithCapacity:1];
    for (UIView * subView in supView.subviews) {
        if ([subView canBecomeFirstResponder]) {
            [respondersViewAry addObject:subView]; continue;
        }else if (subView.subviews != 0)
        {
            [respondersViewAry addObjectsFromArray:[self responderViewsAryWithView:subView]];
        }
    }
    return [self sortResponderViewByPosition:respondersViewAry];
}

- (NSArray *)sortResponderViewByPosition:(NSArray *)ary
{
    return [ary sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        
        CGRect view1Frame = view1.frame;
        if (view1.superview) {
            view1Frame = [view1.superview convertRect:view1Frame toView:[self viewController].view];
        }
        
        CGRect view2Frame = view2.frame;
        if (view2.superview) {
            view2Frame = [view2.superview convertRect:view2Frame toView:[self viewController].view];
        }
        
        CGFloat x1 = CGRectGetMinX(view1Frame);
        CGFloat y1 = CGRectGetMinY(view1Frame);
        CGFloat x2 = CGRectGetMinX(view2Frame);
        CGFloat y2 = CGRectGetMinY(view2Frame);
        
        if (y1 < y2)  return NSOrderedAscending;
        
        else if (y1 > y2) return NSOrderedDescending;
        
        //Else both y are same so checking for x positions
        else if (x1 < x2)  return NSOrderedAscending;
        
        else if (x1 > x2) return NSOrderedDescending;
        
        else return NSOrderedSame;
    }];
}

- (void)goPrevious
{
    //Getting all responder view's.
    NSArray *textFields = self.responderAry;
    if (!textFields) {
        self.responderAry = [self responderViewsAryWithView:[self viewController].view];
        textFields = self.responderAry;
    }
    if ([textFields containsObject:_textFieldView])
    {
        NSUInteger index = [textFields indexOfObject:_textFieldView];
        if (index > 0)
        {
            UITextField *nextTextField = [textFields objectAtIndex:index-1];
            [self switchFirstResponderTo:nextTextField];
        }
        else
        {
            UITextField *nextTextField = [textFields objectAtIndex:textFields.count-1];
            [self switchFirstResponderTo:nextTextField];
        }
    }
}

- (void)goNext
{
    NSArray *textFields = self.responderAry;
    if (!textFields) {
        self.responderAry = [self responderViewsAryWithView:[self viewController].view];
        textFields = self.responderAry;
    }
    if ([textFields containsObject:_textFieldView])
    {
        //Getting index of current textField.
        NSUInteger index = [textFields indexOfObject:_textFieldView];
        
        //If it is not last textField. then it's next object becomeFirstResponder.
        if (index < textFields.count-1)
        {
            UITextField *nextTextField = [textFields objectAtIndex:index+1];
            [self switchFirstResponderTo:nextTextField];
        }
        else
        {
            UITextField *nextTextField = [textFields objectAtIndex:0];
            [self switchFirstResponderTo:nextTextField];
        }
    }
}

- (void)switchFirstResponderTo:(UIView *)responder
{
    UIView * textFieldRetain = _textFieldView;
    BOOL isAcceptAsFirstResponder = [responder becomeFirstResponder];
    if (isAcceptAsFirstResponder == NO)
    {
        [textFieldRetain becomeFirstResponder];
    }
    else
    {
        _textFieldView = responder;
    }
}

- (UIViewController*)viewController
{
    UIResponder *nextResponder = self;
    do
    {
        nextResponder = [nextResponder nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;
        
    } while (nextResponder != nil);
    return nil;
}

@end
