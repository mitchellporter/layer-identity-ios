//
//  ATLAPIManager.m
//  Layer Messenger
//
//  Created by Kevin Coleman on 2/18/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "LYRMAPIManager.h"

@interface LYRMAPIManager ()

@property (nonatomic) NSURLSessionConfiguration *authenticatedURLSessionConfiguration;
@property (nonatomic) BOOL isLoadingContacts;

@end

@implementation LYRMAPIManager

- (id)init
{
    self = [super init];
    if (self) {
        _isLoadingContacts = NO;
        self.URLSession = [self defaultURLSession];
    }
    return self;
}


- (NSURLSession *)defaultURLSession
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json", @"Content-Type": @"application/json", @"X_LAYER_APP_ID": self.layerClient.appID.UUIDString};
    return [NSURLSession sessionWithConfiguration:configuration];
}

- (BOOL)resumeSession:(ATLMSession *)session error:(NSError **)error
{
    return [self configureWithSession:session error:error];
}

#pragma mark - Public Authentication Methods

- (void)registerUser:(ATLMUser *)user completion:(void (^)(ATLMUser *user, NSError *error))completion
{
    NSParameterAssert(completion);
    
    NSError *error;
    if (![user validate:&error]) {
        completion(nil, error);
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:@"users.json" relativeToURL:self.baseURL];
    NSDictionary *parameters = @{@"user": @{@"first_name": user.firstName, @"last_name": user.lastName, @"email": user.email, @"password": user.password, @"password_confirmation": user.passwordConfirmation}};
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.allHTTPHeaderFields = @{ @"content-type": @"application/json" };

    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!response && error) {
            NSLog(@"Failed with error: %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSError *serializationError;
        NSDictionary *userDetails;
        BOOL success = [ATLMHTTPResponseSerializer responseObject:&userDetails withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (success) {
            user.userID = userDetails[@"id"];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(user, nil);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
        }
    }] resume];
}

- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion;
{
    NSParameterAssert(completion);
    
    if (!email.length) {
        NSError *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMInvalidEmailAddress userInfo:@{NSLocalizedDescriptionKey: @"Please enter your email address to log in"}];
        completion(nil, error);
        return;
    }
    
    if (!password.length) {
        NSError *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMInvalidPassword userInfo:@{NSLocalizedDescriptionKey: @"Please enter your password to log in"}];
        completion(nil, error);
        return;
    }
    
    if (!nonce.length) {
        NSError *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMInvalidAuthenticationNonce userInfo:@{NSLocalizedDescriptionKey: @"Application must supply authentication nonce to complete"}];
        completion(nil, error);
        return;
    }
    
    NSURL *URL = [NSURL URLWithString:@"users/sign_in.json" relativeToURL:self.baseURL];
    NSDictionary *parameters = @{@"user": @{@"email": email, @"password": password}, @"nonce": nonce};
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    request.allHTTPHeaderFields = @{ @"content-type": @"application/json" };
    
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!response && error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSError *serializationError;
        NSDictionary *loginInfo;
        BOOL success = [ATLMHTTPResponseSerializer responseObject:&loginInfo withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
            return;
        }
        NSString *authToken = loginInfo[@"authentication_token"];
        ATLMUser *user = [ATLMUser userFromDictionaryRepresentation:loginInfo[@"user"]];
        user.password = password;
        ATLMSession *session = [ATLMSession sessionWithAuthenticationToken:authToken user:user];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *sessionConfigurationError;
            BOOL success = [self configureWithSession:session error:&sessionConfigurationError];
            if (!success) {
                completion(nil, sessionConfigurationError);
                return;
            }
            completion(loginInfo[@"layer_identity_token"], nil);
        });
    }] resume];
}

- (void)loadContactsWithCompletion:(void (^)(NSSet *contacts, NSError *error))completion
{
    NSParameterAssert(completion);
    
    //Prevent multiple calls to load contacts
    if (self.isLoadingContacts) {
        NSError *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMRequestInProgress userInfo:@{NSLocalizedDescriptionKey : @"There is a load contacts operation already in progress"}];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, error);
        });
        return;
    }
    self.isLoadingContacts = YES;
    
    NSURL *URL = [NSURL URLWithString:@"users.json" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        self.isLoadingContacts = NO;
        if (!response && error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSArray *userRepresentations;
        NSError *serializationError;
        BOOL success = [ATLMHTTPResponseSerializer responseObject:&userRepresentations withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, serializationError);
            });
            return;
        }
        NSMutableSet *contacts = [NSMutableSet new];
        for (NSDictionary *representation in userRepresentations) {
            ATLMUser *user = [ATLMUser userFromDictionaryRepresentation:representation];
            [contacts addObject:user];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(contacts, nil);
        });
    }] resume];
}


- (void)deleteAllContactsWithCompletion:(void(^)(BOOL completion, NSError *error))completion
{
    NSParameterAssert(completion);
    NSURL *URL = [NSURL URLWithString:@"users/all" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"DELETE";
    [[self.URLSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!response && error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, error);
            });
            return;
        }
        
        NSError *serializationError;
        BOOL success = [ATLMHTTPResponseSerializer responseObject:&response withData:data response:(NSHTTPURLResponse *)response error:&serializationError];
        if (!success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO, serializationError);
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, nil);
        });
    }] resume];
}

#pragma mark - Private Implementation Methods

- (BOOL)configureWithSession:(ATLMSession *)session error:(NSError **)error
{
    if (self.authenticatedSession) return YES;
    if (!session) {
        if (error) *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMNoAuthenticatedSession userInfo:@{NSLocalizedDescriptionKey: @"No authenticated session"}];
        return NO;
    }
    self.authenticatedSession = session;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Accept": @"application/json",
                                                   @"Content-Type": @"application/json",
                                                   @"X_AUTH_EMAIL": session.user.email,
                                                   @"X_AUTH_TOKEN": session.authenticationToken,
                                                   @"X_LAYER_APP_ID": self.layerClient.appID.UUIDString};
    self.authenticatedURLSessionConfiguration = sessionConfiguration;
    [self.URLSession finishTasksAndInvalidate];
    self.URLSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    [[NSNotificationCenter defaultCenter] postNotificationName:ATLMUserDidAuthenticateNotification object:session.user];
    return YES;
}

@end
