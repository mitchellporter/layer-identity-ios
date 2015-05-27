//
//  ATLMUser.h
//  Atlas Messenger
//
//  Created by Kevin Coleman on 6/4/14.
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
/**
 @abstract The `ATLMUser` object models a user within Atlas Messenger. The object also conforms the `ATLParticipant` protocol, enabling `ATLMUser` objects to be used with Atlas UI components.
 */
@interface ATLMUser : NSObject <NSCoding>

+ (instancetype)userFromDictionaryRepresentation:(NSDictionary *)representation;

@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *fullName;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *passwordConfirmation;
@property (nonatomic, readonly) NSString *participantIdentifier;

- (BOOL)validate:(NSError **)error;

- (NSURL *)avatarImageURL;


@end
