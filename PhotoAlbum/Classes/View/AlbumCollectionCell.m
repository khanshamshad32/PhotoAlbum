//
//  AlbumCollectionCell.m
//  PhotoAlbum
//
//  Created by Shamshad Khan on 02/06/17.
//  Copyright © 2017 Shamshad Khan. All rights reserved.
//

#import "AlbumCollectionCell.h"

@implementation AlbumCollectionCell

-(void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	
	if(selected)
		self.backgroundColor = [UIColor blueColor];
	else
		self.backgroundColor = [UIColor clearColor];		
}

@end
