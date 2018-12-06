//
//  WebViewController.m
//  IntelligentControl
//
//  Created by zhw_mac on 2018/11/15.
//  Copyright © 2018 zhw_mac. All rights reserved.
//

#import "WebViewController.h"
#import "webkit/webkit.h"
#import "TZImagePickerController.h"
#import "JcMessageView.h"
#define WS(weakSelf) __weak __typeof(&*self) weakSelf = self
#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

@interface WebViewController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate,UIImagePickerControllerDelegate,TZImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)WKWebView *webView;
@property (nonatomic,strong)WKWebViewConfiguration *configuration;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  // 配置网页的配置文件
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preference = [[WKPreferences alloc]init];
    configuration.preferences = preference;
    configuration.selectionGranularity = YES; //允许与网页交互
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight) configuration:configuration];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
 
    NSString * urlStr = [[NSBundle mainBundle] pathForResource:@"wkwebview.html" ofType:nil];
    NSURL * fileURL = [NSURL fileURLWithPath:urlStr];
    [_webView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
    [self.view addSubview:self.webView];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#pragma mark ======= JS事件 ========
    //返回
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"back"];
    //JS向OC传值
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"Param"];
    //拍照
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"camera"];
    //从相册选取
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"album"];
   
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 这里要记得移除handlers
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"back"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"Param"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"camera"];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"album"];
   
  
}


//WKScriptMessageHandler协议方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    id body = message.body;
    NSLog(@"=== %@", body);
    if ([message.name isEqualToString:@"back"]) {
        //返回到首页
        [self.navigationController popViewControllerAnimated:YES];
    }if ([message.name isEqualToString:@"Param"]) {
        //显示JS向OC传的值
        [[JcMessageView sharedInstance] ShowMessage:body];
    }
    if ([message.name isEqualToString:@"camera"]) {
       //拍照
         [self takePhotos];
    }
    if ([message.name isEqualToString:@"album"]) {
       //从相册选取
            [self localPhotos];
    }

}


//webView加载完成,传值给JS
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
     //给js传值
      NSString *inputValueJS = [NSString stringWithFormat:@"getUserInfo('%@')",@"这是OC向JS传的数据，哈哈哈"];
      [webView evaluateJavaScript:inputValueJS completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                NSLog(@"value: %@ error: %@", response, error);
          }];
}




// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"什么方法==%@", message);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    
     [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       completionHandler();
    }]];
     [self presentViewController:alert animated:YES completion:NULL];
     NSLog(@"%@", message);
}

//拍照上传
- (void)takePhotos{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self.navigationController presentViewController:picker animated:YES completion:^{
            NSLog(@"OK");
        }];
    }
    else {
        NSLog(@"模拟其中无法打开照相机，请在真机中使用");
    }
}


#pragma mark TZImagePickerControllerDelegate
#pragma mark  -- 从相册中选择照片
-(void)localPhotos{
  TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
 [self.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
}


/// 用户点击了取消
- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 相册
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets{
    
    UIImage *image = photos[0];
    // 压缩一下图片再上传
    NSData *imgData = UIImageJPEGRepresentation(image, 0.001);
    
    NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *imageString = [self removeSpaceAndNewline:encodedImageStr];
    NSString *inputValue = [NSString stringWithFormat:@"rtnCamera('%@')",imageString];
    
    // 这里传值给h5界面
     [self.webView evaluateJavaScript:inputValue completionHandler:^(id _Nullable response, NSError * _Nullable error) {
               NSLog(@"value图片: %@ error1: %@", response, error);
      }];
}

// 相机
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:^{}];

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imgData = UIImageJPEGRepresentation(image, 0.001);
    
    NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *imageString = [self removeSpaceAndNewline:encodedImageStr];
    NSString *inputValue = [NSString stringWithFormat:@"rtnCamera('%@')",imageString];
    
    // 这里传值给h5界面
    [self.webView evaluateJavaScript:inputValue completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"value图片: %@ error1: %@", response, error);
    }];
 
}




//删除字符串中的空格和换行符等
- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
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
