# 📁 LSFileWrapper
Replacement for NSFileWrapper that loads / saves content on-demand. Understands how to save / serialize objects like NSData, UIImage, NSImage, NSDictionary, etc...
## 💻 Requirements
LSFileWrapper works on Mac OS X 10.7+ and iOS 8.0 or newer. The Xcode project contains two framework targets for:
* 💻 macOS (10.7 or greater)
* 📱 iOS (8.0 or greater)
## 📖 Usage
1. To create a new LSFileWrapper use `-initDirectory` for directory wrappers or `-initFile` for regular file wrappers.
2. To load an existing wrapper from disk use `-initWithURL`.
3. To add a file wrapper to existing wrapper use `-addFileWrapper` or `-setFileWrapper`, the difference between the two being that add will suffix a filename with a 2, 3, 4, etc… if the file exists already and return the final filename, set will overwrite an existing one. `-addContent` and `-setContent` work the same way, but create the file wrapper for you.
4. To remove a file wrapper from existing wrapper use `-removeFileWrapper`.
5. To retrieve contents of a regular file wrapper use one of various convenience methods: `-data`, `-string`, `-dictionary`, `-image`.
6. To get wrappers from a directory wrapper use `@property fileWrappers` or call `-fileWrapperWithPath`, the latter will also traverse all children based on path.
7. To write the wrapper to disk call `-writeToURL` or `-writeUpdatesToURL`, the difference between the two being that updates will update the wrapper location, so use this only in situations like autosave for duplicate operations use `-writeToURL`. If the write is issued as part of NSDocument's save routine there's a convenience method `-writeToURL forSaveOperation` that automatically calls `-writeToURL` or `-writeUpdatesToURL` based on save operation and also handles document backups (versioning) and url switches on save as.
8. To update the contents of a regular file wrapper use `-updateContent`.
