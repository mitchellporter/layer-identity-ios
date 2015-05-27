//
//  LayerIdentityTest.m
//  LayerIdentity
//
//  Created by Kevin Coleman on 5/26/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <LayerKit/LayerKit.h>
#import "LYRIdentityManager.h"

@interface LayerIdentityTest : XCTestCase

@end

@implementation LayerIdentityTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testToVerifyIdentityManagerReturnsAnIdentityToken
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Plaid Upgrade Customer Expectation"];
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"b816989e-040f-11e5-8d83-84d0be0060b5"];
    LYRIdentityManager *manager = [LYRIdentityManager managerWithLayerAppID:appID];

    [manager identityTokenForUserIdentifier:@"test" nonce:@"testnonce" completion:^(NSString *identityToken, NSError *error) {
        if (identityToken) {
            [expectation fulfill];
        } else {
            NSLog(@"Failed to acquire identity token with error: %@", error);
        }
    }];
   
    [self waitForCompletionWithTimeOut:5];
}
- (void)waitForCompletionWithTimeOut:(NSUInteger)timeout
{
    [self waitForExpectationsWithTimeout:timeout handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
@end
