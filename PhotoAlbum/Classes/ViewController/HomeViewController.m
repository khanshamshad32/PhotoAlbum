//
//  HomeViewController.m
//  PhotoAlbum
//
//  Created by Shamshad Khan on 02/06/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import "HomeViewController.h"
#import "PAImagePicker.h"
#import "CacheManager.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
}

-(IBAction)onPickPhotoClick
{
	[PAImagePicker showImagePickerType:EImagePickerTypePhoto viewControler:self onCompletion:^(UIImage* image) {
		
		if(image)
			[_gCache saveImage:image imageName:[[NSDate date] description]];
	}];
}

-(IBAction)onPickVideoClick
{
	[PAImagePicker showImagePickerType:EImagePickerTypeVideo viewControler:self onCompletion:^(NSURL* url) {
		
		if(url)
			[_gCache saveVideo:url];
	}];
}

@end
