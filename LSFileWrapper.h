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
#else
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
- (id)initFile;

/**
 *  @brief Initializes a new LSFileWrapper of type Directory.
 */
- (id)initDirectory;

/**
 *  @brief Loads and initializes LSFileWrapper with the contents of supplied url.
 *
 *  @param url The origin url from which LSFileWrapper should be loaded.
 *  @param isDir Boolean indicating whether the passed url is a Directory. When unknown NO should be passed, as the method will automatically detect the correct wrapper type based on the supplied url.
 */
- (id)initWithURL:(NSURL *)url isDirectory:(BOOL)isDir;

// MARK: - File Wrapper Methods

/**
 *  @brief Loads and returns the stored data as NSData.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as NSString.
 */
- (NSData *)data;

/**
 *  @brief Loads and returns the stored data as NSString.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as NSString.
 */
- (NSString *)string;

/**
 *  @brief Loads and returns the stored data as NSDictionary.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as NSDictionary.
 */
- (NSDictionary *)dictionary;

#if TARGET_OS_IPHONE || TARGET_OS_SIMULATOR
/**
 *  @brief Loads and returns the stored data as UIImage.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as UIImage.
 */
- (UIImage *)image;
#else
/**
 *  @brief Loads and returns the stored data as NSImage.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @return Stored data in the current LSFileWrapper as NSImage.
 */
- (NSImage *)image;
#endif

/**
 *  @brief Replaces currently stored contents with passed content.
 *
 *  @warning Should only be called on the LSFileWrapper of type File.
 *
 *  @param content New contents to store.
 */
- (void)updateContent:(id<NSObject>)content;

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
 *  @param path The path of child wrapper as NSString.
 *
 *  @return Optional stored child wrapper as LSFileWrapper.
 */
- (LSFileWrapper *)fileWrapperWithPath:(NSString *)path;

/**
 *  @brief Finds child wrapper at supplied path in the current LSFileWrapper and its children traversing by path.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *
 *  @param path The path of child wrapper as NSString.
 *  @param create Boolean indicating if LSFileWrapper should be created at specified path when none is found.
 *  @param isDir Boolean indicating if LSFileWrapper that should be created at specified path should be of type Directory.
 *
 *  @return Optional stored child wrapper as LSFileWrapper.
 */
- (LSFileWrapper *)fileWrapperWithPath:(NSString *)path create:(BOOL)create isDirectory:(BOOL)isDir;

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
- (NSString *)addFileWrapper:(LSFileWrapper *)fileWrapper withFilename:(NSString *)filename;

/**
 *  @brief Adds a new child wrapper with the supplied name to the current LSFileWrapper. If a wrapper is already present with the same name, then the new wrapper will replace it.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *  @warning This method will replace any wrappers currently stored under the supplied filename.
 *
 *  @param fileWrapper Child wrapper which should be stored in the current LSFileWrapper as LSFileWrapper.
 *  @param filename  Name of the child wrapper.
 */
- (void)setFileWrapper:(LSFileWrapper *)fileWrapper withFilename:(NSString *)filename;

/**
 *  @brief Removes the supplied child wrapper from the current LSFileWrapper.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *
 *  @param fileWrapper Child wrapper which should be added to current LSFileWrapper as LSFileWrapper.
 */
- (void)removeFileWrapper:(LSFileWrapper *)fileWrapper;

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
- (NSString *)addContent:(id<NSObject>)content_ withFilename:(NSString *)filename;

/**
 *  @brief Adds a new child wrapper of type File with the supplied name to the current LSFileWrapper.  If a wrapper is already present with the same name, then the new wrapper will replace it.
 *
 *  @warning Should only be called on the LSFileWrapper of type Directory.
 *  @warning This method will replace any wrappers currently stored under the supplied filename.
 *
 *  @param content_ Content which should be stored in the current LSFileWrapper.
 *  @param filename  Name of the child file wrapper.
 */
- (void)setContent:(id<NSObject>)content_ withFilename:(NSString *)filename;

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
- (BOOL)writeUpdatesToURL:(NSURL *)url error:(NSError *__autoreleasing *)outError;

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
- (BOOL)writeToURL:(NSURL *)url error:(NSError *__autoreleasing *)outError;

#if TARGET_OS_OSX
/**
 *  @brief Writes the contents of LSFileWrapper to passed url based on NSDocument save operation type.
 *
 *  @discussion This method is designed to be used in NSDocument's writeToURL forSaveOperation.
 *
 *  @warning Should only be called on the Main LSFileWrapper.
 *
 *  @param url NSURL where LSFileWrapper should be written to.
 *  @param saveOperation NSSaveOperationType passed from NSDcoument.
 *  @param absoluteOriginalContentsURL Optional NSURL where the current NSDocument – LSFileWrapper contents  are already present.
 *  @param backupFileURL Optional NSURL for backup of current NSDocument.
 *  @param outError Optional pointer to NSError instance  for error handling.
 *
 *  @return Boolean indicating success or failure of the write operation.
 */
- (BOOL)writeToURL:(NSURL *)url forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL backupDocumentURL:(NSURL *)backupFileURL error:(NSError *__autoreleasing *)outError;
#endif

// MARK: - Instance Properties

@property (readonly, strong, nonatomic) NSString *filename;
@property (readonly, strong, nonatomic) NSString *fileType;
@property (readonly, strong, nonatomic) NSMutableDictionary<NSString*, LSFileWrapper*> *fileWrappers;
@property (readonly, strong, nonatomic) NSURL *writtenURL;
@property (readonly, nonatomic) BOOL updated;
@property (readonly, nonatomic) BOOL isDirectory;
@property (assign, nonatomic) NSInteger reserve;
@end
