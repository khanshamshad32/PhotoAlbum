//
//  AlbumViewController.m
//  PhotoAlbum
//
//  Created by Shamshad Khan on 02/06/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import "AlbumViewController.h"
#import "CacheManager.h"
#import "AlbumCollectionCell.h"
#import "CollectionHeaderView.h"

#define kCellIdentifier @"ViewAlbumCollectionCell"
#define kHeaderIdentifier @"ViewAlbumCollectionHeader"

#define kPhotosSectionIndex 0
#define kVideosSectionIndex 1
#define kPhotosSectionName @"Photos"
#define kVideosSectionName @"Videos"

@interface AlbumViewController ()

@end

@implementation AlbumViewController

-(void)viewDidLoad
{
	[super viewDidLoad];	
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self setUpVC];
}

-(void)savePhotos
{
	NSArray* selectedIndexPaths = _collectionView.indexPathsForSelectedItems;
	
	for(NSIndexPath* indexPath in selectedIndexPaths)
	{
		NSArray* section = [_dataSource objectAtIndex:indexPath.section];
		NSString* filePath = [section objectAtIndex:indexPath.row];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			if(indexPath.section == kPhotosSectionIndex)
			{
				NSData* imageData = [NSData dataWithContentsOfFile:filePath];
				NSData* unCompressedData = [CacheManager lamDecompressData:imageData];
				UIImage* image = [UIImage imageWithData:unCompressedData];
				UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
			}
			else
				UISaveVideoAtPathToSavedPhotosAlbum(filePath,nil,nil,nil);
		});		
		[self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
	}
	self.navigationItem.rightBarButtonItem = nil;
	
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Successfull" message:@"Successfully saved to Photos " preferredStyle:UIAlertControllerStyleAlert];	
	UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil];
	[alert addAction:okAction];
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CollectionDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return _dataSource.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	NSArray* sec = [_dataSource objectAtIndex:section];
	return sec.count;
}

-(AlbumCollectionCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	AlbumCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	NSArray* section = [_dataSource objectAtIndex:indexPath.section];
	NSString* path = [section objectAtIndex:indexPath.row];
	
	if(indexPath.section == kPhotosSectionIndex)
	{
		NSData* imageData = [NSData dataWithContentsOfFile:path];
		NSData* unCompressedData = [CacheManager lamDecompressData:imageData];
		NSLog(@"Original size : %d, decompressed Size : %d",imageData.length, unCompressedData.length);
		UIImage* image = [UIImage imageWithData:unCompressedData];
		cell.posterIV.image = image;
	}
	else
	{
		NSURL* url = [NSURL fileURLWithPath:path];
		cell.posterIV.image = [self getThumbnailOfVideo:url];
	}
	return cell;
}

#pragma mark - CollectionDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray* selectedIndexs = collectionView.indexPathsForSelectedItems;
	self.navigationItem.rightBarButtonItem = selectedIndexs.count > 0 ? _saveBarButton : nil;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray* selectedIndexs = collectionView.indexPathsForSelectedItems;
	self.navigationItem.rightBarButtonItem = selectedIndexs.count > 0 ? _saveBarButton : nil;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
	CollectionHeaderView* reusableView;
	if(kind == UICollectionElementKindSectionHeader)
	{
		NSString* title = indexPath.section == kPhotosSectionIndex ? kPhotosSectionName: kVideosSectionName;
		reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderIdentifier forIndexPath:indexPath];
		reusableView.titleLabel.text = title;
	}
	return reusableView;
}

#pragma mark -
-(void)setUpVC
{
	_dataSource = [[NSMutableArray alloc]init];
	
	[_dataSource addObject:[_gCache getAllImages]];
	[_dataSource addObject:[_gCache getAllVideos]];
	
	_collectionView.allowsMultipleSelection = YES;
	[_collectionView reloadData];
	
	_saveBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePhotos)];
}

-(UIImage*)getThumbnailOfVideo:(NSURL*)videoPath
{
	AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
	AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	gen.appliesPreferredTrackTransform = YES;
	CMTime time = CMTimeMakeWithSeconds(2.0, 600);
	NSError *error = nil;
	CMTime actualTime;
	
	CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
	UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
	CGImageRelease(image);
	return thumb;
}

@end
