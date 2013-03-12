//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/LSFileWrapper
//  Distributed under MIT license
//

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

- (BOOL)writePathFirst:(LSFileWrapper *)file
     andAttributes:(NSDictionary *)additionalFileAttributes
       safelyToURL:(NSURL *)url
  forSaveOperation:(UIDocumentSaveOperation)saveOperation
             error:(NSError *__autoreleasing *)outError
{
    return [file writeUpdatesToURL:url error:outError];
}

- (void)savePathFirst:(NSString *)path
         firstHandler:(void (^)(BOOL success))firstHandler
    completionHandler:(void (^)(BOOL success))completionHandler
{
    NSError *contentError;
    NSURL *url = [self.fileURL copy];
    LSFileWrapper *contents = [self contentsForType:self.fileType error:&contentError];
    if(!contents) {
        return;
    }
    
    LSFileWrapper *file = [contents fileWrapperWithPath:path];
    NSURL *firstURL = [url URLByAppendingPathComponent:path];
    
    [self performAsynchronousFileAccessUsingBlock:^{
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
        
        [fileCoordinator coordinateWritingItemAtURL:url
                                            options:NSFileCoordinatorWritingForMerging
                                              error:nil
                                         byAccessor:
         ^(NSURL *newURL) {
             NSError *writeError;
             BOOL wroteFirst, wroteAll;
             
             wroteFirst = [self writePathFirst:file
                                 andAttributes:nil
                                   safelyToURL:firstURL
                              forSaveOperation:UIDocumentSaveForOverwriting
                                         error:&writeError];
             
             if(firstHandler) {
                 dispatch_async(dispatch_get_main_queue(), ^(void) {
                     firstHandler(wroteFirst);
                 });
             }
             
             if(wroteFirst) {
                wroteAll = [self writeContents:contents
                                 andAttributes:nil
                                   safelyToURL:url
                              forSaveOperation:UIDocumentSaveForOverwriting
                                         error:&writeError];
             }
             
             if(completionHandler) {
                 dispatch_async(dispatch_get_main_queue(), ^(void) {
                     completionHandler(wroteAll);
                 });
             }
         }];
    }];
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
    [wrapper loadCache];
    return result;
}

@end
