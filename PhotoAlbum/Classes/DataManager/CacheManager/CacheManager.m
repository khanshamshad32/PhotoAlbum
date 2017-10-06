//
//  ImageCacheManager.m
//  DigitalLibrary
//
//  Created by Shamshad Khan on 02/03/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import "CacheManager.h"
#import <compression.h>

#define kImage @"Image"
#define kVideo @"Video"

static CacheManager* sSharedInstance;

typedef NS_ENUM(NSUInteger, LAMCompressionOperation)
{
	LAMCompressionEncode,
	LAMCompressionDecode,
};

@implementation CacheManager

#pragma mark -
+(CacheManager*)loadCacheManager
{
	if(!sSharedInstance){
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			sSharedInstance = [[CacheManager alloc]init];
		});
	}
	return sSharedInstance;
}

#pragma mark - Video
-(void)saveVideo:(NSURL*)videoUrl
{
	NSString* videoName = [videoUrl lastPathComponent];
	
	NSString* docDir = [self documentDirectoryFor:kVideo];
	NSString* savePath = [docDir stringByAppendingPathComponent:videoName];
	NSData* data = [NSData dataWithContentsOfURL:videoUrl];
	[data writeToFile:savePath atomically:NO];
}

-(NSArray*)getAllVideos
{
	return [self getAllFiles:kVideo];
}

#pragma mark - Image
-(void) saveImage:(UIImage*)image imageName:(NSString*)imageName
{
	NSString* docDirectory = [self documentDirectoryFor:kImage];
	NSString* savedPath = [docDirectory stringByAppendingPathComponent:imageName];
	
	NSData *imageData = UIImageJPEGRepresentation(image, 1);
	NSData* compressedData = [CacheManager lamCompressData:imageData];
	NSLog(@"Original size : %d, Compressed Size : %d",imageData.length, compressedData.length);
	[compressedData  writeToFile:savedPath atomically:NO];
}

-(NSArray*)getAllImages
{
	return [self getAllFiles:kImage];
}

#pragma mark - Document directory
-(NSString*)documentDirectoryFor:(NSString*)type
{
	NSArray*	paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString*	docDirectory = [paths    objectAtIndex:0];
	docDirectory = [docDirectory stringByAppendingPathComponent:type];
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:docDirectory])
		[fileManager createDirectoryAtPath:docDirectory withIntermediateDirectories:NO attributes:nil error:nil];
	return docDirectory;
}

-(NSArray*)getAllFiles:(NSString*)fileType
{
	NSString*	docDirectory = [self documentDirectoryFor:fileType];
	NSArray*	files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:docDirectory error:nil];
	
	if(!files)
		return nil;
	
	NSMutableArray* result = [[NSMutableArray alloc]init];
	
	for(NSString* fileName in files)
	{
		NSString* filePath = [docDirectory stringByAppendingPathComponent:fileName];
		[result addObject:filePath];
	}
	return result;
}

#pragma mark - Compression

+(NSData *)lamCompressData:(NSData*)data
{
	return [CacheManager lamCompressData:data operation:LAMCompressionEncode];
}

+(NSData *)lamDecompressData:(NSData*)data
{
	return [CacheManager lamCompressData:data operation:LAMCompressionDecode];
}

+(NSData *)lamCompressData:(NSData*)data operation:(NSUInteger)operation
{
	if(data.length == 0)
		return nil;
	
	compression_stream stream;
	compression_status status;
	compression_stream_operation op;
	compression_stream_flags flags;
	compression_algorithm algorithm;
	
	switch (sCompressionType)
	{
		case LAMCompressionLZ4:
			algorithm = COMPRESSION_LZ4;
			break;
		case LAMCompressionLZFSE:
			algorithm = COMPRESSION_LZFSE;
			break;
		case LAMCompressionLZMA:
			algorithm = COMPRESSION_LZMA;
			break;
		case LAMCompressionZLIB:
			algorithm = COMPRESSION_ZLIB;
			break;
		default:
			return nil;
	}
	
	switch (operation)
	{
		case LAMCompressionEncode:
			op = COMPRESSION_STREAM_ENCODE;
			flags = COMPRESSION_STREAM_FINALIZE;
			break;
		case LAMCompressionDecode:
			op = COMPRESSION_STREAM_DECODE;
			flags = 0;
			break;
		default:
			return nil;
	}
	
	status = compression_stream_init(&stream, op, algorithm);
	if (status == COMPRESSION_STATUS_ERROR)
		return nil;
	
	// setup the stream's source
	stream.src_ptr	= data.bytes;
	stream.src_size	= data.length;
	
	size_t dstBufferSize = 4096;
	uint8_t*dstBuffer	= malloc(dstBufferSize);
	stream.dst_ptr		= dstBuffer;
	stream.dst_size		= dstBufferSize;
	
	NSMutableData *outputData = [NSMutableData new];
	
	do
	{
		status = compression_stream_process(&stream, flags);
		
		switch (status)
		{
			case COMPRESSION_STATUS_OK:
				if (stream.dst_size == 0)
				{
					[outputData appendBytes:dstBuffer length:dstBufferSize];
					stream.dst_ptr = dstBuffer;
					stream.dst_size = dstBufferSize;
				}
				break;
				
			case COMPRESSION_STATUS_END:
				if (stream.dst_ptr > dstBuffer)
					[outputData appendBytes:dstBuffer length:stream.dst_ptr - dstBuffer];
				break;
				
			case COMPRESSION_STATUS_ERROR:
				return nil;
				
			default:
				break;
		}
	}while(status == COMPRESSION_STATUS_OK);
	
	compression_stream_destroy(&stream);
	free(dstBuffer);
	
	return [outputData copy];
}

@end
