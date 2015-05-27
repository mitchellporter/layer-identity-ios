//
//  ATLAPIManager.h
//  Layer Messenger
//
//  Created by Kevin Coleman on 2/18/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "ATLMAPIManager.h"
#import "ATLMUser.h"

@interface LYRMAPIManager : ATLMAPIManager

///------------------------------------
/// @name JSON API Interface
///------------------------------------

/**
 @abstract Registers a new user with the Layer sample backend Rails application.
 @param user The model object representing the user attempting to authenticate.
 @param completion The completion block that will be called upon completion of the registration operation. Completion block cannot be `nil`.
 */
- (void)registerUser:(ATLMUser *)user completion:(void(^)(ATLMUser *user, NSError *error))completion;

/**
 @abstract Authenticates an existing user with the Layer sample backend Rails application. This method takes a nonce value that must be
 obtained from LayerKit. It returns an identity token in the completion block that can be used to authenticate LayerKit.
 @param email The email address for the user attempting to authenticate.
 @param password The password for the user attempting to authenticate.
 @param nonce The nonce obtained from LayerKit.
 @param completion The completion block that is called upon completion of the authentication operation. Upon succesful authentication,
 an identityToken will be returned. Completion block cannot be `nil`.
 */
- (void)authenticateWithEmail:(NSString *)email password:(NSString *)password nonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion;

/**
 @abstract Loads all contacts from the Layer sample backend Rails application.
 @param completion The completion block that is called upon successfully loading contacts. Completion block cannot be `nil`.
 */
- (void)loadContactsWithCompletion:(void(^)(NSSet *contacts, NSError *error))completion;

/**
 @abstract Deletes all contacts from the Layer sample backend Rails application.
 @param completion The completion block that is call upon successful deletion of all contacts. Completion block cannot be `nil`.
 */
- (void)deleteAllContactsWithCompletion:(void(^)(BOOL completion, NSError *error))completion;

///------------------------------
/// @name Authentication State
///------------------------------

/**
 @abstract Resumes a Layer sample app session.
 @param session The model object for the current session.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value that indicates if the manager has a valid session.
 @discussion Note that if the manager already has a session, the manager will continue to use the existing session (ignoring the passed session) and this method will return `YES`.
 */
- (BOOL)resumeSession:(ATLMSession *)session error:(NSError **)error;


@end
