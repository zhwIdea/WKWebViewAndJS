//
//  ViewController.m
//  WKWebviewAndJS
//
//  Created by BJ on 2018/12/6.
//  Copyright © 2018年 face. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 150, 50)];
    btn.backgroundColor = [UIColor blackColor];
    [btn addTarget:self action:@selector(btn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"点击跳转Html" forState:UIControlStateNormal];
    [self.view addSubview:btn];

}

-(void)btn:(UIButton *)sender{
    WebViewController *webVC = [[WebViewController alloc] init];
    [self.navigationController pushViewController:webVC animated:YES];
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
