//
//  ATLMSession.h
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

/**
 @abstract The `ATLMSession` class models a persistent user session.
 */
@interface ATLMSession : NSObject <NSCoding>

/**
 @abstract Returns an `ATLMSession` object containing information about the current session. 
 @param authenticationToken A token required for communication with the Layer Identity provider. 
 @param user a `ATLMuser` object modeling the currently authenticated user.
 */
+ (instancetype)sessionWithAuthenticationToken:(NSString *)authenticationToken user:(ATLMUser *)user;

@property (nonatomic, readonly) NSString *authenticationToken;

@property (nonatomic, readonly) ATLMUser *user;

@end
