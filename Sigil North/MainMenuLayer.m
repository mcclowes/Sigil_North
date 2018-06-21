//
//  HelloWorldLayer.m
//  Sigil North
//
//  Created by M F J C Clowes on 20/01/2014.
//  Copyright M F J C Clowes 2014. All rights reserved.
//


// Import the interfaces
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"

int level;
int player1;
int player2;
//int player3;
//int player4;
int environment = 5;

// HelloWorldLayer implementation
@implementation MainMenuLayer

@synthesize mainMenu;
@synthesize coreMenu, charSelectMenu1, charSelectMenu2, levelSelectMenu;
@synthesize wins;
@synthesize logoImage, logoText, cloud1, cloud2, cloud3, hill1, hill2;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	MainMenuLayer *layer = [MainMenuLayer node];
	[scene addChild: layer];
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
        level = 1;
        player1=-1;
        player2=-1;
        
        wins = [[CCDirector sharedDirector] winSize];
    
        [self addMainMenu];
        
        [self addVisualAssets];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menuMusic.mp3" loop:YES];
	}
	return self;
}

#pragma mark Menu Handling

-(void) addMainMenu{
    //Add main menu
    
    //Logo - replace with correctly sized logo
    logoImage = [CCSprite spriteWithFile:@"SigilLogo.png"];
    [logoImage setPosition:ccp(wins.width/2, 225)];
    logoImage.scale=0.3;
    [self addChild:logoImage z:1];
    
    //logoText = [CCLabelTTF labelWithString:@"Sigil" fontName:@"London-Tube" fontSize:20];
    //[coreMenu setPosition:ccp(wins.width/2, 255)];
    //[self addChild:logoText];
    
    [CCMenuItemFont setFontName:@"London-Tube"];
    [CCMenuItemFont setFontSize:20];
    
    CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Quickplay"
                                                    target:self
                                                  selector:@selector(loadCharSelectMenu)];
    item1.color = ccBLACK;
    CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Freeplay"
                                                    target:self
                                                  selector:@selector(loadFreeplayMenu)];
    item2.color = ccBLACK;
    CCMenuItemFont *item3 = [CCMenuItemFont itemWithString:@"Multiplayer"
                                                    target:self
                                                  selector:@selector(loadMultiplayer:)];
    item3.color = ccBLACK;
    CCMenuItemFont *item4 = [CCMenuItemFont itemWithString:@"Options"
                                                    target:self
                                                  selector:@selector(showOptions:)];
    item4.color = ccBLACK;
    CCMenuItemFont *item5 = [CCMenuItemFont itemWithString:@"About"
                                                    target:self
                                                  selector:@selector(showAbout:)];
    item5.color = ccBLACK;
    
    coreMenu = [CCMenu menuWithItems:item1, item2, item3, item4, item5, nil];
    [coreMenu alignItemsVerticallyWithPadding:0 ];
    [coreMenu setPosition:ccp(wins.width/2, 85)];
    [self addChild:coreMenu z:4];
}

-(void)loadCharSelectMenu{
    [coreMenu.parent removeChild:coreMenu cleanup:YES];
    coreMenu = nil;
    [logoImage.parent removeChild:logoImage cleanup:YES];
    logoImage = nil;
    
    CCMenuItemImage *iconP1 = [CCMenuItemImage itemWithNormalImage:@"char_icon1.png" selectedImage:@"char icon.png" target:self selector:@selector(army1Selected)];
    CCMenuItemImage *iconP2 = [CCMenuItemImage itemWithNormalImage:@"char_icon2.png" selectedImage:@"char icon.png" target:self selector:@selector(army2Selected)];
    CCMenuItemImage *iconP3 = [CCMenuItemImage itemWithNormalImage:@"char_icon3.png" selectedImage:@"char icon.png" target:self selector:@selector(army3Selected)];
    CCMenuItemImage *iconP4 = [CCMenuItemImage itemWithNormalImage:@"char_icon4.png" selectedImage:@"char icon.png" target:self selector:@selector(army4Selected)];
    charSelectMenu1 = [CCMenu menuWithItems:iconP1, iconP2, iconP3, iconP4, nil];
    
    [charSelectMenu1 alignItemsVerticallyWithPadding:5];
    [charSelectMenu1 setPosition:ccp(wins.width/4-50, wins.height/2)];//change this
    [self addChild:charSelectMenu1 z:5];
    
    CCMenuItemImage *iconP5 = [CCMenuItemImage itemWithNormalImage:@"char_icon5.png" selectedImage:@"char icon.png" target:self selector:@selector(army5Selected)];
    CCMenuItemImage *iconP6 = [CCMenuItemImage itemWithNormalImage:@"char_icon3.png" selectedImage:@"char icon.png" target:self selector:@selector(loadLevelSelectMenu)];
    CCMenuItemImage *iconP7 = [CCMenuItemImage itemWithNormalImage:@"char_icon2.png" selectedImage:@"char icon.png" target:self selector:@selector(loadLevelSelectMenu)];
    CCMenuItemImage *iconP8 = [CCMenuItemImage itemWithNormalImage:@"char_icon4.png" selectedImage:@"char icon.png" target:self selector:@selector(loadLevelSelectMenu)];
    charSelectMenu2 = [CCMenu menuWithItems:iconP5, iconP6, iconP7, iconP8, nil];
    
    [charSelectMenu2 alignItemsVerticallyWithPadding:5];
    [charSelectMenu2 setPosition:ccp(wins.width/4, wins.height/2)];//change this
    
    [self addChild:charSelectMenu2 z:5];
    
    CCSprite *darkBG = [CCSprite spriteWithFile:@"bgDark.png"];
    [self addChild:darkBG z:4];
    [darkBG setPosition:ccp(wins.width/2, wins.height/2)];
}

-(void) army1Selected{
    if (player1>0) {
        player2 = 1;
        [self loadLevelSelectMenu];
    } else {
    player1=1;
    }
}

-(void) army2Selected{
    if (player1>0) {
        player2 = 2;
        [self loadLevelSelectMenu];
    } else {
        player1=2;
    }
}

-(void) army3Selected{
    if (player1>0) {
        player2 = 3;
        [self loadLevelSelectMenu];
    } else {
        player1=3;
    }
}

-(void) army4Selected{
    if (player1>0) {
        player2 = 4;
        [self loadLevelSelectMenu];
    } else {
        player1=4;
    }
}

-(void) army5Selected{
    if (player1>0) {
        player2 = 5;
        [self loadLevelSelectMenu];
    } else {
        player1=5;
    }
}


-(void)loadLevelSelectMenu{
    [charSelectMenu1.parent removeChild:charSelectMenu1 cleanup:YES];
    charSelectMenu1 = nil;
    [charSelectMenu2.parent removeChild:charSelectMenu2 cleanup:YES];
    charSelectMenu2 = nil;
    
    CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Fast Test" target:self selector:@selector(load1:)];
    item1.color = ccBLACK;
    CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Game Test" target:self selector:@selector(load2:)];
    item2.color = ccBLACK;
    CCMenuItemFont *item3 = [CCMenuItemFont itemWithString:@"Scrolling Test" target:self selector:@selector(load3:)];
    item3.color = ccBLACK;
    CCMenuItemFont *item4 = [CCMenuItemFont itemWithString:@"Scrolling Test 2" target:self selector:@selector(load4:)];
    item4.color = ccBLACK;
    CCMenuItemFont *itemBack = [CCMenuItemFont itemWithString:@"Back" target:self selector:@selector(loadMainMenu:)];
    itemBack.color = ccGRAY;
    
    levelSelectMenu = [CCMenu menuWithItems:item1, item2, item3, item4, itemBack, nil];
    
    [levelSelectMenu alignItemsVerticallyWithPadding:-3];
    [levelSelectMenu setPosition:ccp(wins.width/2, 85)];//change this
    [self addChild:levelSelectMenu z:4];
}

-(void) load1:(id)sender{
    level=1;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [MainGameLayer scene]]];
}

-(void) load2:(id)sender{
    level=2;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [MainGameLayer scene]]];
}

-(void) load3:(id)sender{
    level=3;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [MainGameLayer scene]]];
}

-(void) load4:(id)sender{
    level=4;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [MainGameLayer scene]]];
}

-(void) loadMainMenu:(id)sender{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [MainMenuLayer node]]];
}

#pragma mark Obselete Menu Handling
-(void) loadFreeplayMenu{
    [coreMenu.parent removeChild:coreMenu cleanup:YES];
    coreMenu = nil;
    [logoImage.parent removeChild:logoImage cleanup:YES];
    logoImage = nil;
    
    CCMenuItemFont *item1 = [CCMenuItemFont itemWithString:@"Small" target:self selector:@selector(load1:)];
    item1.color = ccBLACK;
    CCMenuItemFont *item2 = [CCMenuItemFont itemWithString:@"Medium" target:self selector:@selector(load2:)];
    item2.color = ccBLACK;
    CCMenuItemFont *item3 = [CCMenuItemFont itemWithString:@"Large" target:self selector:@selector(load3:)];
    item3.color = ccBLACK;
    CCMenuItemFont *item4 = [CCMenuItemFont itemWithString:@"Huge" target:self selector:@selector(load4:)];
    item4.color = ccBLACK;
    
    levelSelectMenu = [CCMenu menuWithItems:item1, item2, item3, item4, nil];
    
    [levelSelectMenu alignItemsVerticallyWithPadding:-3];
    [levelSelectMenu setPosition:ccp(wins.width/2, 85)];//change this
    [self addChild:levelSelectMenu z:4];
}
-(void) loadMultiplayer:(id)sender{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [Options node]]];
}
-(void) showAbout:(id)sender{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [About node]]];
}
-(void) showOptions:(id)sender{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene: [Options node]]];
}

#pragma mark Handling Visual Elements
-(void) addVisualAssets{
    CCSprite *bg = [CCSprite spriteWithFile:@"bgSky.png"];
    [bg setPosition:ccp([bg boundingBox].size.width/2, wins.height-[bg boundingBox].size.height/2)];
    [self addChild:bg z:0];
    
    cloud1 = [CCSprite spriteWithFile:@"Cloud1.png"];
    cloud1.position = CGPointMake(200, 70);
    [self addChild:cloud1];
    [self reorderChild:cloud1 z:2];
    
    cloud2 = [CCSprite spriteWithFile:@"Cloud2.png"];
    cloud2.position = CGPointMake(0, 100);
    [self addChild:cloud2];
    [self reorderChild:cloud2 z:0];
    
    cloud3 = [CCSprite spriteWithFile:@"Cloud3.png"];
    cloud3.position = CGPointMake(wins.width, 100);
    [self addChild:cloud3];
    [self reorderChild:cloud3 z:0];
    
    hill1 = [CCSprite spriteWithFile:@"bgHill1.png"];
    hill1.position = CGPointMake(hill1.boundingBox.size.width/2, hill1.boundingBox.size.height/2);
    [self addChild:hill1];
    [self reorderChild:hill1 z:3];
    
    hill2 = [CCSprite spriteWithFile:@"bgHill2.png"];
    hill2.position = CGPointMake( hill2.boundingBox.size.width/2, hill2.boundingBox.size.height/2);
    [self addChild:hill2];
    [self reorderChild:hill2 z:1];
    
    [self schedule:@selector(moveClouds:)];
}

-(void) moveClouds:(ccTime)delta{
    CGPoint pos1 = cloud1.position;
    pos1.x += 0.35f;
    cloud1.position = pos1;
    
    CGPoint pos2 = cloud2.position;
    pos2.x += 0.1f;
    cloud2.position = pos2;
    
    CGPoint pos3 = cloud3.position;
    pos3.x -= 0.19f;
    cloud3.position = pos3;
    
    if (hill1.scale<=1.2) {
        hill1.scale+=0.0004f;
        hill2.scale-=0.0003f;
        CGPoint pos4 = hill2.position;
        pos4.x += 0.09f;
        pos4.y -= 0.05f;
        hill2.position = pos4;
    }
}

#pragma mark Dealloc
- (void) dealloc
{
	[super dealloc];
}

@end
