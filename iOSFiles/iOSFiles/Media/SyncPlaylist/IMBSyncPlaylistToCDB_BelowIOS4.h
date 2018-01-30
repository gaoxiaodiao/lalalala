//
//  IMBSnycPlaylistToCDB_BelowIOS4.h
//  iMobieTrans
//
//  Created by Pallas on 1/29/13.
//  Copyright (c) 2013 iMobie Inc. All rights reserved.
//

#import "IMBSyncPlaylistFactory.h"

@interface IMBSyncPlaylistToCDB_BelowIOS4 : IMBISyncPlaylistToCDB {
@protected
    IMBiPod *iPod;
    NSMutableArray *filePaths;
}

- (id)initWithIPod:(IMBiPod*)ipod;

@end
