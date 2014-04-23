//
//  CommonMacro.h
//  SpotIt
//
//  Created by aram on 4/22/14.
//  Copyright (c) 2014 mani. All rights reserved.
//

#ifndef SpotIt_CommonMacro_h
#define SpotIt_CommonMacro_h

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define iOS7_0 @"7.0"

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#endif
