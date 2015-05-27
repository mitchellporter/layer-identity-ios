//
//  ATLMPersistenceManager.h
//  Atlas Messenger
//
//  Created by Blake Watters on 6/28/14.
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
#import "ATLMUser.h"
#import "ATLMSession.h"

/**
 @abstract The `ATLMPersistenceManager` provides an interface for persisting and querying, session and user
 data related to the Atlas Messenger application.
 */
@interface ATLMPersistenceManager : NSObject

///---------------------------------------
/// @name Initializing a Manager
///---------------------------------------

/**
 @abstract Returns the default persistence manager for the application.
 @discussion When running within XCTest, returns a transient in-memory persistence manager. When running in a normal application environment, returns a persistence manager that persists objects to disk.
 */
+ (instancetype)defaultManager;

///---------------------------------------
/// @name Persisting
///---------------------------------------

/**
 @abstract Persists an `NSSet` of `ATLMUser` objects to the specified path.
 @param users The `NSSet` of `ATLMUser` objects to be persisted.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value indicating if the operation was successful.
 */
- (BOOL)persistUsers:(NSSet *)users error:(NSError **)error;

/**
 @abstract Persists an `ATLMSession` object for the currently authenticated user.
 @param session The `ATLMSession` object to be persisted.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value indicating if the operation was successful.
 */
- (BOOL)persistSession:(ATLMSession *)session error:(NSError **)error;

///---------------------------------------
/// @name Fetching
///---------------------------------------

/**
 @abstract Returns the persisted `NSSet` of all `ATLMUser` objects.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 */
- (NSSet *)persistedUsersWithError:(NSError **)error;

/**
 @abstract Returns the persisted `ATLMSession` object.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 */
- (ATLMSession *)persistedSessionWithError:(NSError **)error;

/**
 @abstract Returns an `NSSet` of `ATLMUser` objects whose `userID` properties match those supplied in an `NSSet` of identifiers.
 @param identifiers An `NSSet` of `NSString` objects representing user identifiers.
 @return An `NSSet` of `ATLMUser` objects.
 */
- (NSSet *)usersForIdentifiers:(NSSet *)identifiers;

/**
 @abstract Returns a `ATLMUser` object whose `userID` property matches the supplied identifier.
 @param identifier An `NSString` representing a user identifier.
 @return A `ATLMUser` object or nil if a user was not found with the supplied identifier.
 */
- (ATLMUser *)userForIdentifier:(NSString *)identifier;

/**
 @abstract Performs a search across the `fullName` property on all persisted `ATLMUser` objects for the supplied string.
 @param searchString The string object for which the search is performed.
 @param completion The completion block called when search completes.
 */
- (void)performUserSearchWithString:(NSString *)searchString completion:(void(^)(NSArray *users, NSError *error))completion;

///---------------------------------------
/// @name Deletion
///---------------------------------------

/**
 @abstract Deletes all objects currently persisted in the persistence manager.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A boolean value indicating if the operation was successful.
 */
- (BOOL)deleteAllObjects:(NSError **)error;

@end
