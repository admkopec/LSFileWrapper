//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/LSFileWrapper
//  Copyright (c) 2020 Adam Kopeć
//  https://github.com/admkopec/LSFileWrapper
//  Distributed under MIT license
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

//! Project version number for LSFileWrapper.
FOUNDATION_EXPORT double LSFileWrapperVersionNumber;

//! Project version string for LSFileWrapper.
FOUNDATION_EXPORT const unsigned char LSFileWrapperVersionString[];

@interface LSFileWrapper : NSObject

/**
 *  @brief Initializes a new LSFileWrapper of type File.
 */
- (nonnull id)initFile;

/**
 *  @brief Initializes a new LSFileWrapper of type Directory.
 */
- (nonnull id)initDirectory;

/**
 *  @brief Loads and initializes LSFileWrapper with the contents of supplied url.
 *
 *  @param url The origin url from which LSFileWrapper should be loaded.
 *  @param isDir Boolean indicating whether the passed url is a Directory. When unknown NO should be passed, as the method will automatically detect the correct wrapper type based on the supplied url.
 */
- (nullable id)initWithURL:(nonnull NSURL *)url isDirectory:(BOOL)isDir;

// MARK: - File Wrapper Methods

/**
 *  @brief Loads and returns the stored data as NSData.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as NSString.
 */
- (nullable NSData *)data;

/**
 *  @brief Loads and returns the stored data as NSString.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as NSString.
 */
- (nullable NSString *)string;

/**
 *  @brief Loads and returns the stored data as NSDictionary.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as NSDictionary.
 */
- (nullable NSDictionary *)dictionary;

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
/**
 *  @brief Loads and returns the stored data as UIImage.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as UIImage.
 */
- (nullable UIImage *)image;
#else
/**
 *  @brief Loads and returns the stored data as NSImage.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as NSImage.
 */
- (nullable NSImage *)image;
#endif

/**
 *  @brief Replaces currently stored contents with passed content.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @param content New contents to store.
 */
- (void)updateContent:(nonnull id<NSObject>)content NS_SWIFT_NAME(update(newContent:));;

/**
 *  @brief Clears currently stored contents.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 */
- (void)deleteContent;

// MARK: -

- (void)incReserve;
- (void)decReserve;
- (void)deleteUnreserved;

// MARK: - Directory Wrapper Methods

/**
 *  @brief Finds child wrapper at supplied path in the current LSFileWrapper and its children traversing by path.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *
 *  @param path Relative path of child wrapper as NSString.
 *
 *  @return Optional stored child wrapper as LSFileWrapper.
 */
- (nullable LSFileWrapper *)fileWrapperWithPath:(nonnull NSString *)path NS_SWIFT_NAME(wrapper(with:));

/**
 *  @brief Finds child wrapper at supplied path in the current LSFileWrapper and its children traversing by path.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *
 *  @param path Relative path of child wrapper as NSString.
 *  @param create Boolean indicating if LSFileWrapper should be created at specified path when none is found.
 *  @param isDir Boolean indicating if LSFileWrapper that should be created at specified path should be of type Directory.
 *
 *  @return Optional stored child wrapper as LSFileWrapper.
 */
- (nullable LSFileWrapper *)fileWrapperWithPath:(nonnull NSString *)path create:(BOOL)create isDirectory:(BOOL)isDir NS_SWIFT_NAME(wrapper(with:shouldCreate:isDirectory:));

/**
 *  @brief Finds all first-degree child wrappers of a directory wrapper found at supplied path in the current LSFileWrapper and its children traversing by path.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *
 *  @param path Relative path of directory wrapper, whose children we want to get as NSString. "/" Can be used to get values for current wrapper.
 *
 *  @return Array of stored child wrappers, each as LSFileWrapper.
 */
- (nonnull NSArray<LSFileWrapper*> *)fileWrappersInPath:(nonnull NSString *)path NS_SWIFT_NAME(wrappers(in:));

/**
 *  @brief Adds a new child wrapper with the supplied name to the current LSFileWrapper. If a wrapper is already present with the same name, then the new wrapper will be saved under the returned named to prevent collisions.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *  @warning Actual returned wrapper name may be different than supplied filename.
 *
 *  @param fileWrapper Child wrapper which should be added to current LSFileWrapper as LSFileWrapper.
 *  @param filename Desired name of the child wrapper.
 *
 *  @return Nil on error or the name of the added child wrapper as NSString.
 */
- (nonnull NSString *)addFileWrapper:(nonnull LSFileWrapper *)fileWrapper withFilename:(nonnull NSString *)filename NS_SWIFT_NAME(add(wrapper:withFilename:));

/**
 *  @brief Adds a new child wrapper with the supplied name to the current LSFileWrapper. If a wrapper is already present with the same name, then the new wrapper will replace it.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *  @warning This method will replace any wrappers currently stored under the supplied filename.
 *
 *  @param fileWrapper Child wrapper which should be stored in the current LSFileWrapper as LSFileWrapper.
 *  @param filename  Name of the child wrapper.
 */
- (void)setFileWrapper:(nonnull LSFileWrapper *)fileWrapper withFilename:(nonnull NSString *)filename NS_SWIFT_NAME(set(wrapper:withFilename:));

/**
 *  @brief Removes the supplied child wrapper from the current LSFileWrapper.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *
 *  @param fileWrapper Child wrapper which should be removed from the current LSFileWrapper as LSFileWrapper.
 */
- (void)removeFileWrapper:(nonnull LSFileWrapper *)fileWrapper NS_SWIFT_NAME(removeFileWrapper(_:));

/**
 *  @brief Removes the  child wrapper with supplied name from the current LSFileWrapper.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *
 *  @param path Relative path to child wrapper which should be removed from the current LSFileWrapper tree.
 */
- (void)removeFileWrapperWithPath:(nonnull NSString *)path NS_SWIFT_NAME(removeFileWrapper(with:));

/**
 *  @brief Adds a new child wrapper of type File with the supplied name to the current LSFileWrapper. If a wrapper is already present with the same name, then the new wrapper will be saved under the returned named to prevent collisions.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *  @warning Actual returned wrapper name may be different than supplied filename.
 *
 *  @param content_ Content which should be added to current LSFileWrapper.
 *  @param filename Desired name of the child file wrapper.
 *
 *  @return Nil on error or the name of the added child file wrapper as NSString.
 */
- (nonnull NSString *)addContent:(nonnull id<NSObject>)content_ withFilename:(nonnull NSString *)filename NS_SWIFT_NAME(add(content:withFilename:));

/**
 *  @brief Adds a new child wrapper of type File with the supplied name to the current LSFileWrapper.  If a wrapper is already present with the same name, then the new wrapper will replace it.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *  @warning This method will replace any wrappers currently stored under the supplied filename.
 *
 *  @param content_ Content which should be stored in the current LSFileWrapper.
 *  @param filename  Name of the child file wrapper.
 */
- (void)setContent:(nonnull id<NSObject>)content_ withFilename:(nonnull NSString *)filename NS_SWIFT_NAME(set(content:withFilename:));

// MARK: - Disk Write Methods

/**
 *  @brief Writes only the modifications since last write call of the LSFileWrapper to passed url.
 *
 *  @warning Should only be called on the Main LSFileWrapper.
 *
 *  @param url NSURL where LSFileWrapper updates should be written to.
 *  @param outError Optional pointer to NSError instance  for error handling.
 *
 *  @return Boolean indicating success or failure of the write operation.
 */
- (BOOL)writeUpdatesToURL:(nonnull NSURL *)url error:(NSError *__autoreleasing _Nullable *_Nullable)outError;

/**
 *  @brief Writes all contents of LSFileWrapper to passed url.
 *
 *  @warning Should only be called on the Main LSFileWrapper.
 *
 *  @param url NSURL where LSFileWrapper should be written to.
 *  @param outError Optional pointer to NSError instance  for error handling.
 *
 *  @return Boolean indicating success or failure of the write operation.
 */
- (BOOL)writeToURL:(nonnull NSURL *)url error:(NSError *__autoreleasing _Nullable *_Nullable)outError;

#if TARGET_OS_OSX
/**
 *  @brief Writes the contents of LSFileWrapper to passed url based on NSDocument save operation type.
 *
 *  @discussion This method is designed to be used in NSDocument's writeToURL forSaveOperation.
 *
 *  @warning Should only be called on the Main LSFileWrapper.
 *
 *  @code
 *  // Example usage in NSDocument:
 *  -(BOOL)writeToURL:(NSURL *)url forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)outError {
 *      [url startAccessingSecurityScopedResource];
 *      BOOL success = [lsFileWrapper writeToURL: url forSaveOperation: saveOperation originalContentsURL: absoluteOriginalContentsURL backupDocumnetURL: [self backupFileURL] outError: outError];
 *      [url stopAccessingSecurityScopedResource];
 *      return success;
 *  }
 *  @endcode
 *
 *  @param url NSURL where LSFileWrapper should be written to.
 *  @param saveOperation NSSaveOperationType passed from NSDcoument.
 *  @param absoluteOriginalContentsURL Optional NSURL where the current NSDocument – LSFileWrapper contents  are already present.
 *  @param backupFileURL Optional NSURL for backup of current NSDocument.
 *  @param outError Optional pointer to NSError instance  for error handling.
 *
 *  @return Boolean indicating success or failure of the write operation.
 */
- (BOOL)writeToURL:(nonnull NSURL *)url forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(nullable NSURL *)absoluteOriginalContentsURL backupDocumentURL:(nullable NSURL *)backupFileURL error:(NSError *__autoreleasing _Nullable *_Nullable)outError;
#endif

// MARK: - Instance Properties

@property (readonly, strong, nonatomic, nullable) NSString *filename;
@property (readonly, strong, nonatomic, nullable) NSString *fileType;
@property (readonly, strong, nonatomic, nullable) NSURL *writtenURL;
@property (readonly, nonatomic) BOOL updated;
@property (readonly, nonatomic) BOOL isDirectory;
@property (assign, nonatomic) NSInteger reserve;
@end
