//
//  CTNumberKeyboardView.m
//  CTNumberKeyboardView
//
//  Created by Admin on 2017/5/5.
//  Copyright © 2017年 Arvin. All rights reserved.
//

#import "CTNumberKeyboardView.h"
#import "CTKeyboardToolView.h"

#define K_SCREEN_W   ([[UIScreen mainScreen] bounds].size.width)
#define K_SCREEN_H   ([[UIScreen mainScreen] bounds].size.height)

#define UIColorFromRGBA(rgbValue, __alpha__) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:__alpha__]



static NSInteger const CTKeyboardNumberKeyCount  = 12;
static NSInteger const CTKeyboardNumberDelIndex  = 11;
static NSInteger const CTKeyboardNumberDoneIndex = 9;


const static CGFloat K_KEYBOARD_TOOLBAR_HEIGHT = 44.0f;
const static CGFloat K_KEYBOARD_NUMBER_HEIGHT = 215.0f;



@interface CTKeyBoardButton : UIButton

@property (assign, nonatomic) CTKeyboardInputType type;

+ (instancetype)boardButtonWithFrame:(CGRect)frame;
- (instancetype)initKeyButtonWithFrame:(CGRect)frame;

@end


@interface CTKeyBoardButton ()

@property (copy, nonatomic) CTKeyboardInputBlock block;

@end

@implementation CTKeyBoardButton

+ (instancetype)boardButtonWithFrame:(CGRect)frame
{
    return [[self alloc] initKeyButtonWithFrame:frame];
}

- (instancetype)initKeyButtonWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:30];
        [self setBackgroundImage:ct_imageWithColor([[UIColor blackColor] colorWithAlphaComponent:0.1])
                        forState:UIControlStateHighlighted];
        [self addTarget:self
                 action:@selector(keyClicked:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)keyClicked:(CTKeyBoardButton *)button
{
    NSString * text = @"";
    if (self.type == CTKeyboardInputNumber)
    {
        text = button.titleLabel.text;
    }
    self.block(self.type, text);
}

UIImage * ct_imageWithColor(UIColor * color)
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}



@end



@interface CTNumberKeyboardView ()

@property (nonatomic, strong)CTKeyboardToolView * toolView;
@property (nonatomic, strong)NSArray * numberKeyAry;
@property (nonatomic, strong)NSArray * lineHViewAry;
@property (nonatomic, strong)NSArray * lineVViewAry;

@end


@implementation CTNumberKeyboardView

+ (instancetype)defaultKeyboard
{
    CTNumberKeyboardView * keyboard = [[CTNumberKeyboardView alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_W, (K_KEYBOARD_NUMBER_HEIGHT+K_KEYBOARD_TOOLBAR_HEIGHT))];
    return keyboard;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self initToolBar];
        [self initKeyboardNumberButton];
        [self regularNumber];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responderChange:) name:@"keyboard.firstResponderChangeNotification" object:nil];
    }
    return self;
}

- (void)responderChange:(NSNotification *)notification
{
    if (self.responderChangeBlock) {
        self.responderChangeBlock(self,notification.object);
    }
}

- (void)initToolBar
{
    self.toolView = [CTKeyboardToolView toolViewWithHeight:K_KEYBOARD_TOOLBAR_HEIGHT];
    self.toolView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.toolView];
}

- (void)initKeyboardNumberButton
{
    CGRect frame = self.frame;
    int row = 4;
    int column = 3;
    
    CGFloat keyWidth = frame.size.width / column;
    CGFloat keyHeight = (frame.size.height-K_KEYBOARD_TOOLBAR_HEIGHT) / row;
    CGFloat keyX = 0;
    CGFloat keyY = K_KEYBOARD_TOOLBAR_HEIGHT;
    
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *lineVArray = [NSMutableArray array];
    NSMutableArray *lineHArray = [NSMutableArray array];

    for (int i = 0; i < CTKeyboardNumberKeyCount; i++)
    {
        CTKeyBoardButton *button = [CTKeyBoardButton boardButtonWithFrame:CGRectMake(keyX, keyY, keyWidth, keyHeight)];
        [self addSubview:button];
        __weak typeof(self) weakSelf = self;
        [button setBlock:^(CTKeyboardInputType buttonType, NSString *text) {
            if (weakSelf.keyboardInputBlock) {
                weakSelf.keyboardInputBlock(buttonType, text);
            }
        }];
        [array addObject:button];
        if (i == CTKeyboardNumberDelIndex) {
            button.titleLabel.font = [UIFont systemFontOfSize:20];
            button.type = CTKeyboardInputDelete;
        } else if (i == CTKeyboardNumberDoneIndex) {
            button.type = CTKeyboardInputDone;
        } else {
            button.type = CTKeyboardInputNumber;
        }

        keyX += keyWidth;
        
        if ((i + 1) % column == 0) {
            keyX = 0;
            keyY += keyHeight;
        }
    }
    self.numberKeyAry = array;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_W, 0.5)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    [lineHArray addObject:view];

    // 水平分隔线
    CGFloat viewY = K_KEYBOARD_TOOLBAR_HEIGHT;
    for (int i = 0; i < row; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, K_SCREEN_W, 0.5)];
        view.backgroundColor = [UIColor whiteColor];
        [self addSubview:view];
        [lineHArray addObject:view];
        viewY += keyHeight;
    }
    
    // 垂直分隔线
    CGFloat viewX = keyWidth;
    for (int i = 0; i < column - 1; i++) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(viewX, K_KEYBOARD_TOOLBAR_HEIGHT, 0.5, K_KEYBOARD_NUMBER_HEIGHT)];
        view.backgroundColor = [UIColor whiteColor];
        [self addSubview:view];
        [lineVArray addObject:view];
        viewX += keyWidth;
    }
    
    self.lineHViewAry = lineHArray;
    self.lineVViewAry = lineVArray;

}


// 随机排布数字键位置
- (void)randomNumber
{
    [self adjustApperence:1];
    NSMutableArray *numbers = [NSMutableArray array];
    for (int i = 0; i < 10; i++)
    {
        [numbers addObject:[NSString stringWithFormat:@"%d", i]];
    }
    for (int i = 0; i < self.numberKeyAry.count; i++)
    {
        CTKeyBoardButton * button = self.numberKeyAry[i];
        button.backgroundColor = UIColorFromRGBA(0x8E969B,1);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (i == CTKeyboardNumberDelIndex) {
            if (self.bkspRandomImage) {
                [button setImage:self.bkspRandomImage forState:UIControlStateNormal];
                [button setTitle:nil forState:UIControlStateNormal];
            }else {
                [button setImage:nil forState:UIControlStateNormal];
                [button setTitle:@"删除" forState:UIControlStateNormal];
            }
            continue;
        } else if (i == CTKeyboardNumberDoneIndex) {
            continue;
        }
        int index = arc4random() % numbers.count;
        [button setTitle:numbers[index] forState:UIControlStateNormal];
        [numbers removeObjectAtIndex:index];
    }
}

// 按顺序排布数字键位置
- (void)regularNumber
{
    [self adjustApperence:0];
    for (int i = 0; i < self.numberKeyAry.count; i++)
    {
        CTKeyBoardButton * button = self.numberKeyAry[i];
        [button  setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:UIColorFromRGBA(0x161616, 1) forState:UIControlStateNormal];
        if (i == CTKeyboardNumberDelIndex) {
            if (self.bkspRegularImage) {
                [button setImage:self.bkspRegularImage forState:UIControlStateNormal];
                [button setTitle:nil forState:UIControlStateNormal];
            }else {
                [button setImage:nil forState:UIControlStateNormal];
                [button setTitle:@"删除" forState:UIControlStateNormal];
            }
            continue;
        } else if (i == CTKeyboardNumberDoneIndex) {
            continue;
        }
        [button setTitle:[NSString stringWithFormat:@"%d", (i+1)%11] forState:UIControlStateNormal];
    }
}

- (void)adjustApperence:(NSInteger)them
{
    if (them == 1)
    {
        self.toolView.backgroundColor = UIColorFromRGBA(0x8E969B,1);
        [self.toolView applyToApperence:them];
        [self.lineHViewAry enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = [UIColor whiteColor];
        }];
        
        [self.lineVViewAry enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = [UIColor whiteColor];
        }];
    }
    else
    {
        self.toolView.backgroundColor = [UIColor whiteColor];
        [self.toolView applyToApperence:them];
        [self.lineHViewAry enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = UIColorFromRGBA(0xD1D5DB, 1);
        }];
        
        [self.lineVViewAry enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = UIColorFromRGBA(0xD1D5DB, 1);
        }];
    }
}

@end
