//
//  ATLMUser.m
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

#import "ATLMUser.h"
#import "ATLMErrors.h"

@implementation ATLMUser

+ (instancetype)userFromDictionaryRepresentation:(NSDictionary *)representation
{
    ATLMUser *user = [ATLMUser new];
    user.userID =  representation[@"id"];
    user.firstName = representation[@"first_name"];
    if (!user.firstName) user.firstName = representation[@"name"];
    user.lastName = representation[@"last_name"];
    user.email = representation[@"email"];
    user.password = representation[@"password"];
    return user;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.userID = [decoder decodeObjectForKey:NSStringFromSelector(@selector(userID))];
    self.firstName = [decoder decodeObjectForKey:NSStringFromSelector(@selector(firstName))];
    self.lastName = [decoder decodeObjectForKey:NSStringFromSelector(@selector(lastName))];
    self.email = [decoder decodeObjectForKey:NSStringFromSelector(@selector(email))];
    self.password = [decoder decodeObjectForKey:NSStringFromSelector(@selector(password))];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.userID forKey:NSStringFromSelector(@selector(userID))];
    [encoder encodeObject:self.firstName forKey:NSStringFromSelector(@selector(firstName))];
    [encoder encodeObject:self.lastName forKey:NSStringFromSelector(@selector(lastName))];
    [encoder encodeObject:self.email forKey:NSStringFromSelector(@selector(email))];
    [encoder encodeObject:self.password forKey:NSStringFromSelector(@selector(password))];
}

#pragma mark - Accessors

- (NSString *)fullName
{
    if (self.firstName && self.lastName) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
    return [NSString stringWithFormat:@"%@%@", [[self.firstName substringToIndex:1] capitalizedString], [self.firstName substringFromIndex:1]];
}

- (NSString *)participantIdentifier
{
    return self.userID;
}

- (UIImage *)avatarImage
{
    return nil;
}

- (NSString *)avatarInitials
{
    NSMutableString *initials = [NSMutableString new];
    NSString *nameComponents = [self.fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *names = [nameComponents componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (names.count > 2) {
        NSString *firstName = names.firstObject;
        NSString *lastName = names.lastObject;
        names = @[firstName, lastName];
    }
    for (NSString *name in names) {
        [initials appendString:[name substringToIndex:1]];
    }
    return initials;
}

#pragma mark - Validation

- (BOOL)validate:(NSError *__autoreleasing *)error
{
    if (!self.email.length) {
        if (error) *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMInvalidEmailAddress userInfo:@{NSLocalizedDescriptionKey: @"Please enter an email to register"}];
        return NO;
    }
    
    if (!self.firstName.length) {
        if (error) *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMInvalidFirstName userInfo:@{NSLocalizedDescriptionKey: @"Please enter your first name to register"}];
        return NO;
    }
    
    if (!self.lastName.length) {
        if (error) *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMInvalidLastName userInfo:@{NSLocalizedDescriptionKey: @"Please enter your last name to register"}];
        return NO;
    }
    
    if (!self.password.length || !self.passwordConfirmation.length || ![self.password isEqualToString:self.passwordConfirmation]) {
        if (error) *error = [NSError errorWithDomain:ATLMErrorDomain code:ATLMInvalidPassword userInfo:@{NSLocalizedDescriptionKey: @"Please enter matching passwords to register"}];
        return NO;
    }
    
    return YES;
}

#pragma mark - NSObject

- (NSUInteger)hash
{
    return self.userID.hash;
}

- (BOOL)isEqual:(id)object
{
    if (!object) return NO;
    if (![object isKindOfClass:[ATLMUser class]]) return NO;
    ATLMUser *otherUser = (ATLMUser *)object;
    return [self.userID isEqualToString:otherUser.userID];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p userID=%@, firstName=%@, lastName=%@, email=%@, password=%@>",
            [self class], self, self.userID, self.firstName, self.lastName, self.email, self.password];
}

- (NSURL *)avatarImageURL
{
    return nil;
}

@end
