/*
 * libpitch - An Objective-C interface to libtar
 * Copyright (c) 2013 Michael Dippery <michael@monkey-robot.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
