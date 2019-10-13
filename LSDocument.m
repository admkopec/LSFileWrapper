//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/LSFileWrapper
//  Distributed under MIT license
//

#import <TargetConditionals.h>
#if !TARGET_OS_OSX
#import "LSDocument.h"
#import "LSFileWrapper.h"

@interface LSFileWrapper ()
@property (nonatomic, strong) NSURL *url;
@end

@implementation LSDocument

- (BOOL)writeContents:(LSFileWrapper *)contents
        andAttributes:(NSDictionary *)additionalFileAttributes
          safelyToURL:(NSURL *)url
     forSaveOperation:(UIDocumentSaveOperation)saveOperation
                error:(NSError *__autoreleasing *)outError
{
    return [contents writeUpdatesToURL:self.fileURL error:outError];
}

- (void)saveWithCompletionHandler:(void (^)(BOOL success))completionHandler
{
    [self saveToURL:self.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:completionHandler];
}

- (BOOL)readFromURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
    __block LSFileWrapper *wrapper = [[LSFileWrapper alloc] initWithURL:url isDirectory:NO];
    __block BOOL result;
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        result = [self loadFromContents:wrapper
                                 ofType:self.fileType
                                  error:outError];
    });
    return result;
}

@end
#endif
