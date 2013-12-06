//
//  TARFile.m
//  LibTar
//
//  Created by Michael Dippery on 12/5/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import "TARFile.h"

#import "libtar.h"


@implementation TARFile

+ (TARFile *)fileWithContentsOfFile:(NSString *)source
{
    return [[[self alloc] initWithContentsOfFile:source] autorelease];
}

- (id)initWithContentsOfFile:(NSString *)source
{
    if ((self = [super init])) {
        _source = [source copy];
    }
    return self;
}

- (void)dealloc
{
    [_source release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %@>", [self class], [self source]];
}

- (BOOL)extractToDirectory:(NSString *)directory error:(NSError **)error
{
    TAR *tar;
    int success;

    success = tar_open(&tar, (char *) [[self source] UTF8String], NULL, O_RDONLY, 0, 0);
    if (success == -1) {
        char *e = strerror(errno);
        // TODO: Create error object
        return NO;
    }

    success = tar_extract_all(tar, (char *) [directory UTF8String]);
    if (success != 0) {
        char *e = strerror(errno);
        // TODO: Create error object
        return NO;
    }

    success = tar_close(tar);
    if (success != 0) {
        char *e = strerror(errno);
        // TODO: Create error object
        return NO;
    }

    return YES;
}

@end
