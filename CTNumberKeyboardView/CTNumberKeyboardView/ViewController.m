//
//  ViewController.m
//  CTNumberKeyboardView
//
//  Created by Admin on 2017/5/5.
//  Copyright © 2017年 Arvin. All rights reserved.
//

#import "ViewController.h"
#import "CTNumberKeyboardView.h"    
#import "UITextField+Input.h"

@interface ViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputTF;
@property (weak, nonatomic) IBOutlet UITextField *input2TF;
@property (weak, nonatomic) IBOutlet UITextField *input3TF;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inputTF.delegate = self;
    CTNumberKeyboardView * keyboard = [CTNumberKeyboardView defaultKeyboard];
    __weak typeof (self) weakSelf = self;
    keyboard.bkspRegularImage = [UIImage imageNamed:@"delete_regular"];
    keyboard.bkspRandomImage = [UIImage imageNamed:@"delete"];
    [keyboard setKeyboardInputBlock:^(CTKeyboardInputType type, NSString * inputText){
        NSLog(@"-- %@\n", inputText);
        if ([self.inputTF isFirstResponder]) {
            [weakSelf.inputTF inputInsetBlankText:inputText limit:20];
        }else if ([self.input2TF isFirstResponder]) {
            [weakSelf.input2TF inputText:inputText limit:0];
        }else {
            [weakSelf.input3TF inputText:inputText limit:10];
        }
    }];
    
    [keyboard setResponderChangeBlock:^(CTNumberKeyboardView * keyboardView, UIView * responderView) {
        if ([responderView isEqual:self.inputTF]) {
            [keyboardView regularNumber];
        }else if ([responderView isEqual:self.input2TF]) {
            [keyboardView randomNumber];
        }else {
            [keyboardView regularNumber];
        }
    }];
    self.inputTF.inputView = keyboard;
    self.input2TF.inputView = keyboard;
    self.input3TF.inputView = keyboard;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:kTextFieldInputDidChangeNotification object:nil];
}

- (void)textDidChange:(NSNotification *)notification
{
    UITextField * tf = notification.object;
    NSLog(@"%s %@", __func__, tf.text);
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"userInfo = %@", notification.userInfo);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
