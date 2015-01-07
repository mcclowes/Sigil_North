//
//  About.m
//  Sigil Noughts
//
//  Created by Max Clayton Clowes on 30/10/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "About.h"


@implementation About
+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	About *layer = [About node];
	[scene addChild: layer];
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
        CCSprite *bg = [CCSprite spriteWithFile:@"BG-hd.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"About This Game" fontName:@"Marker Felt" fontSize:64];
        CGSize size = [[CCDirector sharedDirector] winSize];
        label.position =  ccp( size.width /2 , size.height/2 );
        [self addChild: label];
    }
    return self;
}

- (void) dealloc
{
	[super dealloc];
}

@end
