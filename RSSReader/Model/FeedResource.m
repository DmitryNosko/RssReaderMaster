//
//  FeedResource.m
//  RSSReader
//
//  Created by USER on 8/31/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FeedResource.h"

@implementation FeedResource

- (instancetype)initWithName:(NSString*) name url:(NSURL*) url
{
    self = [super init];
    if (self) {
        _name = name;
        _url = url;
    }
    return self;
}

@end
