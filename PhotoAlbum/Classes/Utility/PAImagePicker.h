//
//  DLImagePicker.h
//  DigitalLibrary
//
//  Created by Shamshad Khan on 22/03/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

typedef NS_ENUM(NSInteger, EImagePickerType)
{
	EImagePickerTypePhoto = 1,
	EImagePickerTypeVideo
};

@interface PAImagePicker : UIImagePickerController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) void(^sendData)(id data);

+(void)showImagePickerType:(EImagePickerType)pickerType viewControler:(UIViewController*)vc onCompletion:(void(^)(id))callback;

@end
