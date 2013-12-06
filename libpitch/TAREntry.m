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

#import "TAREntry.h"
#import "libtar.h"
#import <grp.h>
#import <pwd.h>
#import <sys/stat.h>


@implementation TAREntry

+ (id)entryWithContentsOfTAR:(TAR *)tar
{
    return [[[self alloc] initWithContentsOfTAR:tar] autorelease];
}

- (id)initWithContentsOfTAR:(TAR *)tar
{
    if ((self = [super init])) {
        char *n = th_get_pathname(tar);
        _name = [[NSString alloc] initWithCString:n encoding:NSUTF8StringEncoding];

        _raw_mode = th_get_mode(tar);

        uid_t o = th_get_uid(tar);
        struct passwd *pw = getpwuid(o);
        _owner = [[NSString alloc] initWithCString:pw->pw_name encoding:NSUTF8StringEncoding];

        gid_t g = th_get_gid(tar);
        struct group *grp = getgrgid(g);
        _group = [[NSString alloc] initWithCString:grp->gr_name encoding:NSUTF8StringEncoding];

        _size = th_get_size(tar);

        NSInteger t = th_get_mtime(tar);
        _mtime = [[NSDate alloc] initWithTimeIntervalSince1970:t];

        _checksum = th_get_crc(tar);
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_owner release];
    [_group release];
    [_mtime release];
    [super dealloc];
}

- (NSString *)description
{
    NSString *fmt = @"<%@> (\n"
                    @"  name = %@\n"
                    @"  mode = %@\n"
                    @"  owner = %@\n"
                    @"  group = %@\n"
                    @"  size = %ld\n"
                    @"  mtime = %@\n"
                    @"  checksum = %ld\n"
                    @")";
    return [NSString stringWithFormat:fmt,
             [self class], [self name], [self mode], [self owner], [self group],
             [self size], [self mtime], [self checksum]];
}

- (NSString *)mode
{
    char u[4] = {'-', '-', '-', '\0'};
    char g[4] = {'-', '-', '-', '\0'};
    char o[4] = {'-', '-', '-', '\0'};
    char t = '?';

    if      (S_ISREG(_raw_mode))  t = '-';
    else if (S_ISDIR(_raw_mode))  t = 'd';
    else if (S_ISBLK(_raw_mode))  t = 'b';
    else if (S_ISCHR(_raw_mode))  t = 'c';
    else if (S_ISFIFO(_raw_mode)) t = 'p';
    else if (S_ISLNK(_raw_mode))  t = 'l';
    else if (S_ISSOCK(_raw_mode)) t = 's';

    if ((_raw_mode & S_IRUSR)) u[0] = 'r';
    if ((_raw_mode & S_IWUSR)) u[1] = 'w';
    if ((_raw_mode & S_IXUSR)) u[2] = 'x';

    if ((_raw_mode & S_IRGRP)) g[0] = 'r';
    if ((_raw_mode & S_IWGRP)) g[1] = 'w';
    if ((_raw_mode & S_IXGRP)) g[2] = 'x';

    if ((_raw_mode & S_IROTH)) o[0] = 'r';
    if ((_raw_mode & S_IWOTH)) o[1] = 'w';
    if ((_raw_mode & S_IXOTH)) o[2] = 'x';

    return [NSString stringWithFormat:@"%c%s%s%s", t, u, g, o];
}

@end
