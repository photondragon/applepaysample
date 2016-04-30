//
//  ViewController.m
//  applepaysample
//
//  Created by photondragon on 16/4/30.
//  Copyright © 2016年 mahu. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()
<PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];


}

- (IBAction)checkOut:(id)sender {
	[self createPayment];
}

- (void)createPayment
{
	if([PKPaymentAuthorizationViewController canMakePayments]==FALSE) {
		NSLog(@"不支持Apple Pay");
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的设备不支持 Apple Pay" preferredStyle:UIAlertControllerStyleAlert];
		__weak UIAlertController* walert = alert;
		[alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
			[walert dismissViewControllerAnimated:YES completion:nil];
		}]];
		[self presentViewController:alert animated:YES completion:nil];
		return;
	}

	NSArray* supportedNetworks = nil;
	double ver = [[[UIDevice currentDevice] systemVersion] doubleValue];
	if(ver>=9.2){
		supportedNetworks = @[PKPaymentNetworkAmex,
							  PKPaymentNetworkChinaUnionPay,
							  PKPaymentNetworkDiscover,
							  PKPaymentNetworkInterac,
							  PKPaymentNetworkMasterCard,
							  PKPaymentNetworkPrivateLabel,
							  PKPaymentNetworkVisa];
	}
	else if(ver>=9.0){
		supportedNetworks = @[PKPaymentNetworkAmex,
							  PKPaymentNetworkDiscover,
							  PKPaymentNetworkMasterCard,
							  PKPaymentNetworkPrivateLabel,
							  PKPaymentNetworkVisa];
	}
	else if(ver>=8.0){
		supportedNetworks = @[PKPaymentNetworkAmex,
							  PKPaymentNetworkMasterCard,
							  PKPaymentNetworkVisa];
	}
	else
		NSLog(@"手机不支持Apple Pay");

	PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
	request.countryCode = @"US";
	request.currencyCode = @"USD";
	request.supportedNetworks = supportedNetworks;
	request.merchantCapabilities = PKMerchantCapabilityEMV;
	request.merchantIdentifier = @"merchant.me.mahu.applepaysample";

	PKPaymentSummaryItem *widget1 = [PKPaymentSummaryItem summaryItemWithLabel:@"商品1" amount:[NSDecimalNumber decimalNumberWithString:@"0.99"]];

	PKPaymentSummaryItem *widget2 = [PKPaymentSummaryItem summaryItemWithLabel:@"商品2" amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]];

	PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"总计" amount:[NSDecimalNumber decimalNumberWithString:@"1.99"]];

	request.paymentSummaryItems = @[widget1, widget2, total];

	PKPaymentAuthorizationViewController *paymentPane = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
	paymentPane.delegate = self;
	if(paymentPane)
		[self presentViewController:paymentPane animated:TRUE completion:nil];
}

- (void)simulateTellYourServerWithData:(NSDictionary*)data callback:(void (^)(NSError*error))callback
{
	//模拟网络请求方法
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
					   didAuthorizePayment:(PKPayment *)payment
								completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
	NSLog(@"用户已完成认证（手机刷卡或指纹支付）");
	NSMutableDictionary* params = [NSMutableDictionary new];
	params[@"transactionId"] = payment.token.transactionIdentifier;

	[self simulateTellYourServerWithData:params callback:^(NSError *error) {
		if(error)
			completion(PKPaymentAuthorizationStatusFailure); // 通知Apple交易失败，不会扣款
		else
			completion(PKPaymentAuthorizationStatusSuccess); // 通知Apple交易成功，Apple会完成扣款
	}];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
	NSLog(@"支付流程结束");
	[controller dismissViewControllerAnimated:TRUE completion:nil];
}

@end
