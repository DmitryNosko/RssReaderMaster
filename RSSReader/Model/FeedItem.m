//
//  FeedItem.m
//  RSSReader
//
//  Created by Dzmitry Noska on 8/30/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

#import "FeedItem.h"

@interface FeedItem () <NSCoding>

@end

static NSString* const ITEM_TITLE_KEY = @"ITEM_TITLE_KEY";
static NSString* const LINK_KEY = @"LINK_KEY";
static NSString* const PUBDATE_KEY = @"PUBDATE_KEY";
static NSString* const ITEM_DESCRIPTION_KEY = @"ITEM_DESCRIPTION_KEY";
static NSString* const ENCLOSURE_KEY = @"ENCLOSURE_KEY";
static NSString* const IMAGE_URL_KEY = @"IMAGE_URL_KEY";

@implementation FeedItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        _itemDescription = [[NSMutableString alloc] init];
        _link = [[NSMutableString alloc] init];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.itemTitle forKey:ITEM_TITLE_KEY];
    [aCoder encodeObject:self.link forKey:LINK_KEY];
    [aCoder encodeObject:self.pubDate forKey:PUBDATE_KEY];
    [aCoder encodeObject:self.itemDescription forKey:ITEM_DESCRIPTION_KEY];
    [aCoder encodeObject:self.enclosure forKey:ENCLOSURE_KEY];
    [aCoder encodeObject:self.imageURL forKey:IMAGE_URL_KEY];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.itemTitle = [aDecoder decodeObjectForKey:ITEM_TITLE_KEY];
        self.link = [aDecoder decodeObjectForKey:LINK_KEY];
        self.pubDate = [aDecoder decodeObjectForKey:PUBDATE_KEY];
        self.itemDescription = [aDecoder decodeObjectForKey:ITEM_DESCRIPTION_KEY];
        self.enclosure = [aDecoder decodeObjectForKey:ENCLOSURE_KEY];
        self.imageURL = [aDecoder decodeObjectForKey:IMAGE_URL_KEY];
    }
    return self;
}


@end
