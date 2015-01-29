//
//  LYRAuthentication.h
//  LayerAuth
//
//  Created by Kevin Coleman on 1/29/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYRIdentityManager : NSObject

+ (instancetype)managerWithLayerAppID:(NSUUID *)layerAppID;

- (void)identityTokenForUserIdentifier:(NSString *)userIdentifier
                                 nonce:(NSString *)nonce
                            completion:(void(^)(NSString *identityToken, NSError *error))completion;
@end
