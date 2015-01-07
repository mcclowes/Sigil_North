//
//  HelloWorldLayer.h
//  Sigil North
//
//  Created by M F J C Clowes on 20/01/2014.
//  Copyright M F J C Clowes 2014. All rights reserved.
//

#import "cocos2d.h"
#import "MainGameLayer.h"
#import "Options.h"
#import "About.h"

@interface MainMenuLayer : CCLayer
{
    //Menu Layers
    MainMenuLayer *mainMenu;
    
    //Menu Elements
    CCMenu *coreMenu;
    CCMenu *charSelectMenu1;
    CCMenu *charSelectMenu2;
    CCMenu *levelSelectMenu;
    
    //Screen Size
    CGSize wins;
    
    //Visual Assets
    CCSprite *logoImage;
    CCLabelTTF *logoText;
    CCSprite* cloud1;
    CCSprite* cloud2;
    CCSprite* cloud3;
    CCSprite* hill1;
    CCSprite* hill2;
}
#pragma mark Variables:
//Menu Layers
@property (nonatomic, retain) MainMenuLayer *mainMenu;

//Menu Elements
@property (retain, nonatomic, readwrite) CCMenu *coreMenu;
@property (retain, nonatomic, readwrite) CCMenu *charSelectMenu1;
@property (retain, nonatomic, readwrite) CCMenu *charSelectMenu2;
@property (retain, nonatomic, readwrite) CCMenu *levelSelectMenu;

//Screen Size
@property CGSize wins;

//Visual Assets
@property (retain, nonatomic, readwrite) CCSprite *logoImage;
@property (retain, nonatomic, readwrite) CCLabelTTF *logoText;
@property (retain, nonatomic, readwrite) CCSprite* cloud1;
@property (retain, nonatomic, readwrite) CCSprite* cloud2;
@property (retain, nonatomic, readwrite) CCSprite* cloud3;
@property (retain, nonatomic, readwrite) CCSprite* hill1;
@property (retain, nonatomic, readwrite) CCSprite* hill2;

#pragma mark Methods:
+(CCScene *) scene;

#pragma mark Menu Handling
-(void)loadCharSelectMenu;
-(void)loadLevelSelectMenu;
-(void)load1:(id)sender;
-(void)load2:(id)sender;
-(void)load3:(id)sender;
-(void)load4:(id)sender;

#pragma mark Obselete Menu Handling
-(void)loadFreeplayMenu;
-(void) loadMultiplayer:(id)sender;
-(void) showAbout:(id)sender;
-(void) showOptions:(id)sender;

#pragma mark Handling Visual Elements
-(void) addVisualAssets;
-(void) moveClouds:(ccTime)delta;

@end
