//
//  FeedResource.h
//  RSSReader
//
//  Created by USER on 8/31/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedResource : NSObject
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSURL* url;
- (instancetype)initWithName:(NSString*) name url:(NSURL*) url;
@end
