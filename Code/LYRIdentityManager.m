//
//  LYRAuthentication.m
//  LayerAuth
//
//  Created by Kevin Coleman on 1/29/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "LYRIdentityManager.h"

@interface LYRIdentityManager ()

@property (nonatomic) NSUUID *layerAppID;
@property (nonatomic) NSURLSession *URLSession;

@end

@implementation LYRIdentityManager

NSString *const LYRIdentityProviderBaseURL = @"https://layer-identity-provider.herokuapp.com/identity_tokens";

+ (instancetype)managerWithLayerAppID:(NSUUID *)layerAppID
{
    return [[self alloc] initWithLayerAppID:layerAppID];
}

- (id)initWithLayerAppID:(NSUUID *)layerAppID
{
    self = [super init];
    if (self) {
        _layerAppID = layerAppID;
        _URLSession = [self defaultURLSession];
        
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (NSURLSession *)defaultURLSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json", @"Content-Type": @"application/json", @"X_LAYER_APP_ID": self.layerAppID};
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (void)identityTokenForUserIdentifier:(NSString *)userIdentifier nonce:(NSString *)nonce completion:(void (^)(NSString *, NSError *))completion
{
    NSURL *identityTokenURL = [NSURL URLWithString:LYRIdentityProviderBaseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:identityTokenURL];
    request.HTTPMethod = @"POST";

    NSDictionary *parameters = @{ @"app_id": self.layerAppID, @"user_id": userIdentifier, @"nonce": nonce };
    NSData *requestBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.HTTPBody = requestBody;
    
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if([responseObject valueForKey:@"error"]) {
            NSString *domain = @"Layer Authentication";
            NSInteger code = [responseObject[@"status"] integerValue];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Layer Identity Provider Returned an Error."};
            NSError *error = [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
            completion(nil, error);
        } else {
            NSString *identityToken = responseObject[@"identity_token"];
            completion(identityToken, nil);
        }
    }] resume];
}
@end
