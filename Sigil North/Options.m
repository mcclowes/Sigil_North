//
//  Options.m
//  Sigil Noughts
//
//  Created by Max Clayton Clowes on 30/10/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Options.h"
#import "MainMenuLayer.h"

@implementation Options

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	Options *layer = [Options node];
	[scene addChild: layer];
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
        
        CCSprite *bg = [CCSprite spriteWithFile:@"BG.png"];
        [bg setPosition:ccp(240, 160)];
        [self addChild:bg z:0];
        
        //Add menu
        CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Sound" target:self selector:@selector(loadMainMenu:)];
        item1.color = ccBLACK;
        CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Gamecentre" target:self selector:@selector(loadMainMenu:)];
        item2.color = ccBLACK;
        CCMenuItemFont *item3 = [CCMenuItemFont itemWithString:@"Etc" target:self selector:@selector(loadMainMenu:)];
        item3.color = ccBLACK;
        CCMenuItemFont *item4 = [CCMenuItemFont itemWithString:@"Etc" target:self selector:@selector(loadMainMenu:)];
        item4.color = ccBLACK;
        CCMenuItemFont *item5 = [CCMenuItemFont itemWithString:@"Back" target:self selector:@selector(loadMainMenu:)];
        item5.color = ccGRAY;
        CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, item4, item5, nil];
        [menu alignItemsVerticallyWithPadding:-3];
        [self addChild:menu z:2];
    }
    return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) loadMainMenu:(id)sender{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [MainMenuLayer node]]];
}

@end
