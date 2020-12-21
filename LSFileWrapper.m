//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/LSFileWrapper
//  Copyright (c) 2020 Adam Kopeć
//  https://github.com/admkopec/LSFileWrapper
//  Distributed under MIT license
//

#import "LSFileWrapper.h"

@interface LSFileWrapper ()
@property (weak, nonatomic) LSFileWrapper *parent;
@property (strong, nonatomic) NSMutableDictionary<NSString*, LSFileWrapper*> *fileWrappers;
@property (strong, nonatomic) NSString *filename;
@property (strong, nonatomic) NSURL *writtenURL;
@property (strong, nonatomic) id<NSObject> content;
@property (assign, nonatomic) BOOL updated;
@property (assign, nonatomic) BOOL deleted;
@property (assign, nonatomic) BOOL cacheFile;
@end

@interface LSFileWrapper (Internal)
- (LSFileWrapper *)walkDirectoryPath:(NSString *)path create:(BOOL)create;
- (NSString *)setFileWrapper:(LSFileWrapper *)fileWrapper filename:(NSString *)filename_ replace:(BOOL)replace;
- (BOOL)getParentUpdates:(NSMutableArray *)updates withURL:(NSURL *)url;
- (void)getUpdates:(NSMutableArray *)updates withURL:(NSURL *)url;
- (void)getAll:(NSMutableArray *)updates withURL:(NSURL *)url;
- (BOOL)writeUpdates:(NSArray *)updates filemanager:(NSFileManager *)fileManager error:(NSError *__autoreleasing *)outError;
@end

@implementation LSFileWrapper
@synthesize parent;
@synthesize fileWrappers;
@synthesize filename;
@synthesize writtenURL;
@synthesize content;
@synthesize updated;
@synthesize deleted;
@synthesize cacheFile;
@synthesize isDirectory;



- (id)initFile
{
    self = [super self];
    if (self) {
        isDirectory = NO;
        _reserve = 0;
    }
    return self;
}

- (id)initDirectory
{
    self = [super init];
    if (self) {
        isDirectory = YES;
        _reserve = 0;
        fileWrappers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url isDirectory:(BOOL)isDir
{
    self = [super init];
    if (self) {
        filename = [url lastPathComponent];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDir]) {
            writtenURL = url;
        }
        isDirectory = isDir;
        _reserve = 0;
        
        if (isDirectory) {
            fileWrappers = [[NSMutableDictionary alloc] init];
            
            for (NSURL *childUrl in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                                 includingPropertiesForKeys:nil
                                                                                    options:0
                                                                                      error:nil]) {
                LSFileWrapper *fileWrapper = [[LSFileWrapper alloc] initWithURL:childUrl isDirectory:NO];
                [fileWrapper setParent:self];
                [fileWrappers setObject:fileWrapper forKey:[childUrl lastPathComponent]];
            }
        }
    }
    return self;
}

- (NSData *)data
{
    if (content == nil && writtenURL != nil) {
        content = [NSData dataWithContentsOfURL:writtenURL];
//        cacheFile = YES;
    }
    if ([content isKindOfClass:[NSData class]]) {
        NSData * contentAsData = (NSData *)content;
        if (!updated && writtenURL != nil) {
            content = nil;
        }
        return contentAsData;
    }
    return nil;
}

- (NSString *)string
{
    if (content == nil && writtenURL != nil) {
        content = [NSData dataWithContentsOfURL:writtenURL];
        cacheFile = YES;
    }
    if ([content isKindOfClass:[NSData class]]) {
        content = [[NSString alloc] initWithData:(NSData*)content encoding:NSUTF8StringEncoding];
    }
    if ([content isKindOfClass:[NSString class]]) {
        return (NSString *)content;
    }
    return nil;
}

- (NSDictionary *)dictionary
{
    if (content == nil && writtenURL != nil) {
        content = [NSData dataWithContentsOfURL:writtenURL];
        cacheFile = YES;
    }
    if ([content isKindOfClass:[NSData class]]) {
        id propList = [NSPropertyListSerialization propertyListWithData:(NSData*)content
                                                                options:NSPropertyListImmutable
                                                                 format:NULL
                                                                  error:NULL];
        
        if ([propList isKindOfClass:[NSDictionary class]])
        {
            content = (NSDictionary*)propList;
        }
    }
    if ([content isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)content;
    }
    return nil;
}

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
- (UIImage *)image
{
    if (content == nil && writtenURL != nil) {
        content = [UIImage imageWithContentsOfFile:writtenURL.path];
        cacheFile = YES;
        return (UIImage *)content;
    }
    if ([content isKindOfClass:[NSData class]]) {
        content = [UIImage imageWithData:(NSData *)content];
    }
    if ([content isKindOfClass:[UIImage class]]) {
        return (UIImage *)content;
    }
    return nil;
}
#else
- (NSImage *)image {
    if (content == nil && writtenURL != nil) {
        content = [[NSImage alloc] initWithContentsOfFile:writtenURL.path];
        cacheFile = YES;
        return (NSImage *)content;
    }
    if ([content isKindOfClass:[NSData class]]) {
        content = [[NSImage alloc] initWithData:(NSData *)content];
    }
    if ([content isKindOfClass:[NSImage class]]) {
        return (NSImage *)content;
    }
    return nil;
}
#endif

- (void)updateContent:(id<NSObject>)content_
{
    if (isDirectory) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"LSFileWrapper directory is not a file."
                                     userInfo:nil];
        return;
    }
    content = content_;
    updated = YES;
    deleted = NO;
}

- (void)deleteContent
{
    content = nil;
    updated = NO;
    deleted = YES;
}

- (void)incReserve
{
    self.reserve++;
}

- (void)decReserve
{
    self.reserve--;
}

- (void)deleteUnreserved
{
    if (isDirectory && fileWrappers.count > 0) {
        for (LSFileWrapper *fileWrapper in [fileWrappers objectEnumerator]) {
            [fileWrapper deleteUnreserved];
        }
    }
    else if (self.reserve < 1) {
        [self deleteContent];
    }
}

- (LSFileWrapper *)fileWrapperWithPath:(NSString *)path
{
    return [self fileWrapperWithPath:path create:NO isDirectory:NO];
}

- (LSFileWrapper *)fileWrapperWithPath:(NSString *)path create:(BOOL)create isDirectory:(BOOL)isDir
{
    NSString *dirpath = [path stringByDeletingLastPathComponent];
    NSString *filename_ = [path lastPathComponent];
    LSFileWrapper *dirFileWrapper = [self walkDirectoryPath:dirpath create:create];
    
    if (!dirFileWrapper) {
        return nil;
    }
    
    LSFileWrapper *fileWrapper = [dirFileWrapper.fileWrappers objectForKey:filename_];
    
    if (!fileWrapper) {
        if (!create) {
            return nil;
        }
        if (isDir) {
            fileWrapper = [[[self class] alloc] initDirectory];
        }
        else {
            fileWrapper = [[[self class] alloc] initFile];
        }
        
        [dirFileWrapper setFileWrapper:fileWrapper filename:filename_ replace:YES];
    }
    
    return fileWrapper;
}

- (NSString *)addFileWrapper:(LSFileWrapper *)fileWrapper withFilename:(NSString *)filename_;
{
    return [self setFileWrapper:fileWrapper filename:filename_ replace:NO];
}

- (void)setFileWrapper:(LSFileWrapper *)fileWrapper withFilename:(NSString *)filename_
{
    [self setFileWrapper:fileWrapper filename:filename_ replace:YES];
}

- (void)removeFileWrapper:(LSFileWrapper *)fileWrapper {
    if (!isDirectory) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"LSFileWrapper file is not a directory."
                                     userInfo:nil];
        return;
    }
    if (fileWrapper == self) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Cannot remove LSFileWrapper from itself."
                                     userInfo:nil];
        return;
    }
    LSFileWrapper *existing = [fileWrappers objectForKey:fileWrapper.filename];
    if (existing.writtenURL) {
        existing.deleted = YES;
    }
    else {
        [fileWrappers removeObjectForKey:fileWrapper.filename];
    }
    updated = YES;
}

- (NSString *)addContent:(id<NSObject>)content_ withFilename:(NSString *)filename_
{
    LSFileWrapper *fileWrapper = [[LSFileWrapper alloc] initFile];
    [fileWrapper updateContent:content_];
    return [self setFileWrapper:fileWrapper filename:filename_ replace:NO];
}

- (void)setContent:(id<NSObject>)content_ withFilename:(NSString *)filename_
{
    LSFileWrapper *fileWrapper = [fileWrappers objectForKey:filename_];
    if (!fileWrapper) {
        fileWrapper = [[LSFileWrapper alloc] initFile];
        [self setFileWrapper:fileWrapper filename:filename_ replace:YES];
    }
    [fileWrapper updateContent:content_];
}

- (BOOL)writeUpdatesToURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
    NSMutableArray *updates = [[NSMutableArray alloc] init];

    if (!updated && !isDirectory) {
        return YES;
    }
    if (parent) {
        BOOL parentOK = [self getParentUpdates:updates withURL:url];
        if (parentOK == NO) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"LSFileWrapper child cannot be written to a different directory"
                                         userInfo:nil];
        }
    }
    
    [self getUpdates:updates withURL:url];
    return [self writeUpdates:updates filemanager:[[NSFileManager alloc] init] error:outError];
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError *__autoreleasing *)outError {
    NSMutableArray *updates = [[NSMutableArray alloc] init];
    
    if (parent) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"LSFileWrapper child cannot be written to new URL"
                                     userInfo:nil];
    }
    
    [self getAll:updates withURL:url];
    return [self writeUpdates:updates filemanager:[[NSFileManager alloc] init] error:outError];
}

#if TARGET_OS_OSX
- (BOOL)writeToURL:(NSURL *)url forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(nullable NSURL *)absoluteOriginalContentsURL backupDocumentURL:(nullable NSURL *)backupFileURL error:(NSError *__autoreleasing *)outError {
    [url startAccessingSecurityScopedResource];
    switch (saveOperation) {
        case NSAutosaveInPlaceOperation:
            // Auto overwrite
        case NSSaveOperation:
            // Overwrite
            if (backupFileURL) {
                // Optional Backup propagation
                [[NSFileManager defaultManager] copyItemAtURL:url toURL:backupFileURL error:nil];
                [backupFileURL setResourceValues:@{NSURLIsHiddenKey: @YES} error:nil];
            }
            if (absoluteOriginalContentsURL) {
                if (![self writeUpdatesToURL:absoluteOriginalContentsURL error:outError]) {
                    [url stopAccessingSecurityScopedResource];
                    return NO;
                }
                if (![url isEqual:absoluteOriginalContentsURL]) {
                    if(![[NSFileManager defaultManager] copyItemAtURL:absoluteOriginalContentsURL toURL:url error:outError]) {
                        [url stopAccessingSecurityScopedResource];
                        return NO;
                    }
                }
            } else {
                if(![self writeToURL:url error:outError]) {
                    [url stopAccessingSecurityScopedResource];
                    return NO;
                }
            }
            break;
        case NSAutosaveAsOperation:
            // Auto new with switch
        case NSSaveAsOperation:
            // New with switch
            if(![self writeToURL:url error:outError]) {
                [url stopAccessingSecurityScopedResource];
                return NO;
            }
            // Switches self to new NSURL
            if (self) {
                filename = [url lastPathComponent];
                writtenURL = url;
                isDirectory = YES;
                _reserve = 0;
                fileWrappers = [[NSMutableDictionary alloc] init];
                for (NSURL *childUrl in [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                                     includingPropertiesForKeys:nil
                                                                                        options:0
                                                                                          error:nil]) {
                    LSFileWrapper *fileWrapper = [[LSFileWrapper alloc] initWithURL:childUrl isDirectory:NO];
                    [fileWrapper setParent:self];
                    [fileWrappers setObject:fileWrapper forKey:[childUrl lastPathComponent]];
                }
            }
            [url setResourceValues:@{NSURLIsHiddenKey: @YES} error:nil];
            break;
        case NSAutosaveElsewhereOperation:
            // Auto totally new
        case NSSaveToOperation:
            // Totally new
            if(![self writeToURL:url error:outError]) {
                [url stopAccessingSecurityScopedResource];
                return NO;
            }
            [url setResourceValues:@{NSURLIsHiddenKey: @YES} error:nil];
            break;
        default:
            break;
    }
    BOOL success = [url setResourceValues:@{NSURLContentModificationDateKey: [NSDate date]} error:outError];
    [url stopAccessingSecurityScopedResource];
    if (!success) {
        return NO;
    }
    return YES;
}
#endif

@end

@implementation LSFileWrapper (Internal)

- (LSFileWrapper *)walkDirectoryPath:(NSString *)path create:(BOOL)create
{
    if (!isDirectory) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"LSFileWrapper file is not a directory."
                                     userInfo:nil];
        return nil;
    }
    if ([path hasPrefix:@"/"]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"path must be relative"
                                     userInfo:nil];
        return nil;
    }
    
    NSArray *pathComponents = [path pathComponents];
    LSFileWrapper *dirFileWrapper = self;
    LSFileWrapper *parentWrapper;
    
    for (NSString *component in pathComponents) {
        parentWrapper = dirFileWrapper;
        dirFileWrapper = [dirFileWrapper.fileWrappers objectForKey:component];
        if (!dirFileWrapper) {
            if (!create) {
                return nil;
            }
            dirFileWrapper = [[[self class] alloc] initDirectory];
            [parentWrapper setFileWrapper:dirFileWrapper filename:component replace:YES];
        }
    }
    
    return dirFileWrapper;
}

- (NSString *)setFileWrapper:(LSFileWrapper *)fileWrapper filename:(NSString *)filename_ replace:(BOOL)replace
{
    if (!isDirectory) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"LSFileWrapper file is not a directory."
                                     userInfo:nil];
        return nil;
    }
    if (fileWrapper.parent) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"LSFileWrapper can only have one parent."
                                     userInfo:nil];
        return nil;
    }
    if (fileWrapper == self) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Cannot add LSFileWrapper to itself."
                                     userInfo:nil];
        return nil;
    }
    
    if (fileWrapper) {
        if (!replace) {
            NSString *basename = [filename_ stringByDeletingPathExtension];
            NSString *extension = [filename_ pathExtension];
            NSString *format;
            NSUInteger num = 0;
            if (extension.length > 0) {
                format = [NSString stringWithFormat:@"%@ %%d.%@", basename, extension];
            }
            else {
                format = [NSString stringWithFormat:@"%@ %%d", basename];
            }
            while (true) {
                LSFileWrapper *existing = [fileWrappers objectForKey:filename_];
                if (!existing || existing.deleted) {
                    break;
                }
                filename_ = [NSString stringWithFormat:format, ++num];
            }
        }
        fileWrapper.parent = self;
        fileWrapper.filename = filename_;
        fileWrapper.deleted = NO;
        [fileWrappers setObject:fileWrapper forKey:filename_];
    }
    else if (replace) {
        LSFileWrapper *existing = [fileWrappers objectForKey:filename_];
        if (existing.writtenURL) {
            existing.deleted = YES;
        }
        else {
            [fileWrappers removeObjectForKey:filename_];
        }
    }
    
    updated = YES;
    
    return filename_;
}

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
- (BOOL)writeAsset:(ALAsset *)asset_ toURL:(NSURL *)url fileManager:(NSFileManager *)fileManager error:(NSError *__autoreleasing *)outError
{
    [fileManager createFileAtPath:[url path] contents:nil attributes:nil];
    
    static const NSUInteger BufferSize = 1024*1024;
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:url error:outError];
    if (!handle) {
        return NO;
    }
    ALAssetRepresentation *rep = [asset_ defaultRepresentation];
    NSUInteger bytesSize = (NSUInteger)[rep size];
    NSUInteger bytesRead = 0;
    NSUInteger bytesOffset = 0;
    uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
    
    do {
        bytesRead = [rep getBytes:buffer fromOffset:bytesOffset length:BufferSize error:outError];
        if (!bytesRead) {
            break;
        }
        bytesOffset += bytesRead;
        
        @try {
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
        } @catch (NSException *exception) {
            //TODO: Should probably convert NSException to NSError
            break;
        }
    } while (bytesOffset < bytesSize);
    
    free(buffer);
    
    return bytesOffset >= bytesSize;
}

- (BOOL)writeImage:(UIImage *)image_ toURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
    NSData *imageData;
    NSString *extension = [url pathExtension];
    
    if ([extension isEqualToString:@"png"]) {
        imageData = UIImagePNGRepresentation(image_);
    }
    else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"]) {
        imageData = UIImageJPEGRepresentation(image_, 1);
    }
    
    return [imageData writeToURL:url options:NSDataWritingAtomic error:outError];
}

#else
- (BOOL)writeImage:(NSImage *)image_ toURL:(NSURL *)url error:(NSError *__autoreleasing *)outError
{
    NSData *imageData;
    NSString *extension = [url pathExtension];
    
    [image_ lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, image_.size.width, image_.size.height)];
    [image_ unlockFocus];
    
    if ([extension isEqualToString:@"png"]) {
        imageData = [bitmapRep representationUsingType:NSPNGFileType properties:@{}];
    }
    else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"]) {
        imageData = [bitmapRep representationUsingType:NSJPEGFileType properties:@{}];
    }
    
    return [imageData writeToURL:url options:NSDataWritingAtomic error:outError];
}
#endif

- (BOOL)getParentUpdates:(NSMutableArray *)updates withURL:(NSURL *)url
{
    if (!parent) {
        return YES;
    }
    
    NSString *parentPath = [url URLByDeletingLastPathComponent].path;
    NSString *parentWrittenPath = parent.writtenURL.path;
    
    if (parentWrittenPath) {
        return [parentPath isEqual:parentWrittenPath];
    }
    
    NSURL *parentURL = [[NSURL alloc] initFileURLWithPath:parentPath];
    
    if ([parent getParentUpdates:updates withURL:parentURL]) {
        [updates addObject:@{@"url":parentURL, @"wrapper":parent}];
        return YES;
    }
    return NO;
}

- (void)getUpdates:(NSMutableArray *)updates withURL:(NSURL *)url
{
    if (deleted) {
        [updates addObject:@{@"url": url, @"wrapper":self, @"shouldPopulateWrittenURL": @YES}];
    }
    else if (isDirectory) {
        if (!writtenURL) {
            [updates addObject:@{@"url": url, @"wrapper":self, @"shouldPopulateWrittenURL": @YES}];
        }
        for (LSFileWrapper *fileWrapper in [fileWrappers objectEnumerator]) {
            [fileWrapper getUpdates:updates withURL:[url URLByAppendingPathComponent:fileWrapper.filename]];
        }
    }
    else if (updated && content) {
        [updates addObject:@{@"url": url, @"wrapper":self, @"shouldPopulateWrittenURL": @YES}];
    }
}

- (void)getAll:(NSMutableArray *)updates withURL:(NSURL *)url {
    if (!deleted) {
        [updates addObject:@{@"url": url, @"wrapper":self, @"shouldPopulateWrittenURL": @NO}];
        if (isDirectory) {
            for (LSFileWrapper *fileWrapper in [fileWrappers objectEnumerator]) {
                [fileWrapper getAll:updates withURL:[url URLByAppendingPathComponent:fileWrapper.filename]];
            }
        }
    }
}

- (BOOL)writeUpdates:(NSArray *)updates filemanager:(NSFileManager *)fileManager error:(NSError *__autoreleasing *)outError
{
    BOOL wroteAll = YES;
    
    for (NSDictionary *updateInfo in updates) {
        NSURL *fileURL = [updateInfo objectForKey:@"url"];
        LSFileWrapper *fileWrapper = [updateInfo objectForKey:@"wrapper"];
        // MARK: Don't change writtenURL for whole file write!
        BOOL shouldPopulateWrittenURL = [(NSNumber*)[updateInfo objectForKey:@"shouldPopulateWrittenURL"] boolValue];
        if (fileWrapper.content == nil && fileWrapper.writtenURL != nil) {
            fileWrapper.content = [NSData dataWithContentsOfURL:fileWrapper.writtenURL];
        }
        NSObject *fileContent = fileWrapper.content;
        BOOL success = YES;
        
        if (fileWrapper.deleted) {
            NSLog(@"delete %@", fileURL);
            success = [fileManager removeItemAtURL:fileURL error:outError];
        }
        else if (fileWrapper.isDirectory) {
            if (fileWrapper.writtenURL == nil) {
                if ([fileManager fileExistsAtPath:[fileURL path]]) {
                    success = [fileManager removeItemAtURL:fileURL error:outError];
                }
                success = success && [fileManager createDirectoryAtURL:fileURL withIntermediateDirectories:NO attributes:nil error:outError];
            }
        }
        else if ([fileContent isKindOfClass:[NSData class]]) {
            // Create the directories if they're missing
            NSURL* directoryURL = [fileURL URLByDeletingLastPathComponent];
            if ([directoryURL checkResourceIsReachableAndReturnError:nil] == NO) {
                [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:@{NSFileExtensionHidden: @YES} error:outError];
            }
            success = [(NSData*)fileContent writeToURL:fileURL options:NSDataWritingAtomic error:outError];
        }
        else if ([fileContent isKindOfClass:[NSString class]]) {
            success = [(NSString*)fileContent writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:outError];
        }
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
        else if ([fileContent isKindOfClass:[UIImage class]]) {
            success = [self writeImage:(UIImage *)fileContent toURL:fileURL error:outError];
        }
        else if ([fileContent isKindOfClass:[ALAsset class]]) {
            success = [self writeAsset:(ALAsset *)fileContent toURL:fileURL fileManager:fileManager error:outError];
        }
#else
        else if ([fileContent isKindOfClass:[NSImage class]]) {
            success = [self writeImage:(NSImage *)fileContent toURL:fileURL error:outError];
        }
#endif
        else {
            NSData *data = [NSPropertyListSerialization dataWithPropertyList:fileContent
                                                                      format:NSPropertyListBinaryFormat_v1_0
                                                                     options:0
                                                                       error:NULL];
            success = data && [data writeToURL:fileURL atomically:YES];
        }
        
        if (success == NO) {
            wroteAll = NO;
            continue;
        }
        
        fileWrapper.filename = [fileURL lastPathComponent];
        if (shouldPopulateWrittenURL) {
            fileWrapper.writtenURL = fileURL;
            
            fileWrapper.updated = NO;
            
            if (!cacheFile) {
                fileWrapper.content = nil;
            }
        } else {
            if (!fileWrapper.updated) {
                if (!cacheFile) {
                    fileWrapper.content = nil;
                }
            }
        }
        
        if (fileWrapper.deleted) {
            [fileWrapper.parent.fileWrappers removeObjectForKey:fileWrapper.filename];
        }
    }

    return wroteAll;
}

@end
