//
//  AlbumViewController.h
//  PhotoAlbum
//
//  Created by Shamshad Khan on 02/06/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AlbumViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray* dataSource;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;

-(void)savePhotos;

@end
