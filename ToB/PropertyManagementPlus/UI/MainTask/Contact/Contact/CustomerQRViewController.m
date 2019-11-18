//
//  MyQRViewController.m
//

#import "CustomerQRViewController.h"
#import "PropertyManagementPlus-Swift.h"

#define kBtnX           [UIScreen mainScreen].bounds.size.width*1/5
#define kBtnY           (([UIScreen mainScreen].bounds.size.height-kQRY-kQRHeight-kBtnHeight)/2+kQRY+kQRHeight)
#define kBtnWidth       [UIScreen mainScreen].bounds.size.width*3/5
#define kBtnHeight      45

#define kQRX            [UIScreen mainScreen].bounds.size.width*1/10
#define kQRY            [UIScreen mainScreen].bounds.size.height/4
#define kQRWidht        [UIScreen mainScreen].bounds.size.width*4/5
#define kQRHeight       kQRWidht

@interface CustomerQRViewController ()

//二维码
@property (nonatomic, strong) UIView *qrView;
@property (nonatomic, strong) UIImageView* qrImgView;

//条形码
@property (nonatomic, strong) UIView *tView;
@property (nonatomic, strong) UIImageView *tImgView;


@end

@implementation CustomerQRViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.8f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT - kBtnHeight, SCREENWIDTH, kBtnHeight)];
    [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn1 setTitle:@"返回" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    btn1.layer.borderWidth = 0.5;
    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    
    [self.view addSubview:btn1];
   
    
    //二维码
    self.qrView = [[UIView alloc]initWithFrame:CGRectMake(kQRX, kQRY, kQRWidht, kQRHeight)];
    [self.view addSubview:_qrView];
    _qrView.backgroundColor = [UIColor whiteColor];
    _qrView.layer.shadowOffset = CGSizeMake(0, 2);
    _qrView.layer.shadowRadius = 2;
    _qrView.layer.shadowColor = [UIColor blackColor].CGColor;
    _qrView.layer.shadowOpacity = 0.5;
    
    
    self.qrImgView = [[UIImageView alloc]init];
    _qrImgView.bounds = CGRectMake(0, 0, kQRWidht-12, kQRHeight-12);
    _qrImgView.center = CGPointMake(kQRWidht/2, kQRHeight/2);
    [_qrView addSubview:_qrImgView];
//    self.qrView = view;
    
    
    //条形码
    self.tView = [[UIView alloc]initWithFrame:CGRectMake( kQRX,
                                                         kQRY*1.5,
                                                         kQRWidht,
                                                         kQRHeight*0.5)];
    [self.view addSubview:_tView];
  
    
    self.tImgView = [[UIImageView alloc]init];
    _tImgView.bounds = CGRectMake(0, 0, CGRectGetWidth(_tView.frame)-12, CGRectGetHeight(_tView.frame)-12);
    _tImgView.center = CGPointMake(CGRectGetWidth(_tView.frame)/2, CGRectGetHeight(_tView.frame)/2);
    [_tView addSubview:_tImgView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 64)];
    titleLabel.text = @"房间二维码";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    [self.view addSubview:titleLabel];
    
    [self createQR];
    
    [LocalToastView toastWithText:@"请在15分钟内使用，逾期后自动失效！"];
}

- (void)back {
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (void)createQR {
    
    _qrView.hidden = NO;
    _tView.hidden = YES;
    
    _qrImgView.image = [BaseTool createNonInterpolatedUIImageFormCIImage:[BaseTool createQRForString:_qrCodeStr] withSize:_qrImgView.bounds.size.width];
    
}
@end
