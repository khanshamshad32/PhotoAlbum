//
//  ImageCacheManager.h
//  DigitalLibrary
//
//  Created by Shamshad Khan on 02/03/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LAMCompression)
{
	LAMCompressionLZ4,
	LAMCompressionZLIB,
	LAMCompressionLZMA,
	LAMCompressionLZFSE,
};

static LAMCompression sCompressionType = LAMCompressionZLIB;

@interface CacheManager : NSObject

+(CacheManager*)loadCacheManager;

-(void)saveImage:(UIImage*)image imageName:(NSString*)imagePath;
-(NSArray*)getAllImages;

-(void)saveVideo:(NSURL*)videoUrl;
-(NSArray*)getAllVideos;

+(NSData *)lamCompressData:(NSData*)data;
+(NSData *)lamDecompressData:(NSData*)data;

@end

#define _gCache  [CacheManager loadCacheManager]
