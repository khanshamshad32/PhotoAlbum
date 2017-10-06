//
//  DLImagePicker.m
//  DigitalLibrary
//
//  Created by Shamshad Khan on 22/03/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import "PAImagePicker.h"

static PAImagePicker* sSharedInstance;

@implementation PAImagePicker

#pragma mark -
+(instancetype)loadImagePicker
{
	if(sSharedInstance == nil)
		sSharedInstance = [[PAImagePicker alloc]init];
	return sSharedInstance;
}

+(void)showImagePickerType:(EImagePickerType)pickerType viewControler:(UIViewController*)vc onCompletion:(void(^)(id))callback
{
	PAImagePicker* picker = [PAImagePicker loadImagePicker];
	picker.delegate = picker;
	picker.sendData = callback;
	
	if(pickerType == EImagePickerTypeVideo)
	{
		picker.allowsEditing = YES;
		picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
	}
	else
		picker.mediaTypes = @[(NSString*)kUTTypeImage];
	
	UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil  message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		UIAlertAction* camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
			
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[vc presentViewController:picker animated:YES completion:nil];
		}];
		[actionSheet addAction:camera];
	}
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		UIAlertAction* gallery = [UIAlertAction actionWithTitle:NSLocalizedString(@"Gallery", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
			
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[vc presentViewController:picker animated:YES completion:nil];
		}];
		[actionSheet addAction:gallery];
	}
	
	UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
	[actionSheet addAction:cancel];
	[vc presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - ImagePickerDelegate Methods
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[picker dismissViewControllerAnimated:YES completion:nil];
	_sendData(nil);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSString* mediaType = info[UIImagePickerControllerMediaType];
	BOOL isMovie = UTTypeConformsTo((__bridge CFStringRef)mediaType,
									kUTTypeMovie) != 0;
	
	if(isMovie)
		_sendData(info[UIImagePickerControllerMediaURL]);
	else
		_sendData(info[UIImagePickerControllerOriginalImage]);
	[picker dismissViewControllerAnimated:YES completion:nil];
}

@end
