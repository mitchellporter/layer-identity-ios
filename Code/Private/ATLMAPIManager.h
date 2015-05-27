//
//  ATLMAPIManager.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "ATLMPersistenceManager.h"
#import "ATLMUser.h"
#import "ATLMHTTPResponseSerializer.h"
#import "ATLMErrors.h"

extern NSString *const ATLMUserDidAuthenticateNotification;
extern NSString *const ATLMUserDidDeauthenticateNotification;
extern NSString *const ATLMApplicationDidSynchronizeParticipants;

/**
 @abstract The `ATLMAPIManager` class provides an interface for interacting with the Layer Identity Provider JSON API and managing
 the Atlas authentication state.
 */
@interface ATLMAPIManager : NSObject

///--------------------------------
/// @name Initializing a Manager
///--------------------------------

+ (instancetype)managerWithBaseURL:(NSURL *)baseURL layerClient:(LYRClient *)layerClient;

/**
 @abstract
 */
@property (nonatomic) NSURL *baseURL;

/**
 @abstract The `LYRClient` object used to initialize the receiver.
 */
@property (nonatomic, readonly) LYRClient *layerClient;

/**
 @abstract The persistence manager responsible for persisting user information.
 */
@property (nonatomic) ATLMPersistenceManager *persistenceManager;

/**
 @abstract The current authenticated session or `nil` if not yet authenticated.
 */
@property (nonatomic) ATLMSession *authenticatedSession;

/**
 @abstract The baseURL used to initialize the receiver.
 */

/**
 @abstract The currently configured URL session.
 */
@property (nonatomic) NSURLSession *URLSession;

/**
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value that indicates if the manager has a valid session.
 */
- (BOOL)resumeSession:(ATLMSession *)session error:(NSError **)error;

/**
 @abstract Registers and authenticates an Atlas Messenger user.
 @param name An `NSString` object representing the name of the user attempting to register.
 @param nonce A nonce value obtained via a call to `requestAuthenticationNonceWithCompletion:` on `LYRClient`.
 @param completion completion The block to execute upon completion of the asynchronous user registration operation. The block has no return value and accepts two arguments: An identity token that was obtained upon successful registration (or nil in the event of a failure) and an `NSError` object that describes why the operation failed (or nil if the operation was successful).
 */
- (void)registerUserWithName:(NSString*)name nonce:(NSString *)nonce completion:(void (^)(NSString *identityToken, NSError *error))completion;

/**
 @abstract Synchronizes the local participant store with the Layer identity provider.
 */
- (void)loadContacts;

/**
 @abstract Deauthenticates the Atlas Messenger app by discarding its `ATLMSession` object.
 */
- (void)deauthenticate;

@end
