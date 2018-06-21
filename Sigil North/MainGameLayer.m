//
//  Game Screen.m
//  Sigil North
//
//  Created by M F J C Clowes on 20/01/2014.
//  Copyright M F J C Clowes 2014. All rights reserved.
//

#import "MainGameLayer.h"
#import "GameConfig.h"
#import "SimpleAudioEngine.h"
#import "HUDLayer.h"
#import "GameLayer.h"

extern int level;
extern int player1;
extern int player2;
extern int environment;

@implementation MainGameLayer

@synthesize _mainGame, _theGame, _hud;
@synthesize gameWin, playerTurn, player1Gold, player2Gold;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
    
    GameLayer *theGame = [GameLayer node];
    [scene addChild:theGame z:1];
    
    HUDLayer *hud = [HUDLayer node];
    [scene addChild:hud z:2];
    
    //Game_Screen *layer = [Game_Screen node];
    MainGameLayer *mainLayer = [[[MainGameLayer alloc] initWithGame:theGame initWithHUD:hud] autorelease];
	[scene addChild:mainLayer];
    
	return scene;
}

// on "init" you need to initialize your instance
- (id)initWithGame:(GameLayer *)theGame initWithHUD:(HUDLayer *)hud {
    if ((self = [super init])) {
        _hud = hud;
        _theGame = theGame;
        _mainGame = self;
        
        _hud._mainGame = _mainGame;
        _theGame._mainGame = _mainGame;
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"militaryGrandeur01.aiff" loop:NO];
        [self musicHandler];//need to schedule this
        
        // Set up turns
        playerTurn = 1;
        gameWin = false;
        player1Gold = 1000;
        player2Gold = 1000;
        [_theGame updateMoneyLabel];
    }
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark Music Maintainance
-(void)musicHandler {
    int rand = arc4random() % 6;
    while (gameWin==false) {
        if ([[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying] == false) {
            switch (rand) {
                case 1:
                    NSLog(@"Song 1");
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"militaryGrandeur01.aiff" loop:NO];
                    break;
                case 2:
                    NSLog(@"Song 2");
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"militaryGrandeur01.aiff" loop:NO];
                    break;
                case 3:
                    NSLog(@"Song 3");
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"militaryGrandeur01.aiff" loop:NO];
                    break;
                case 4:
                    NSLog(@"Song 4");
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"militaryGrandeur01.aiff" loop:NO];
                    break;
                case 5:
                    NSLog(@"Song 5");
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"militaryGrandeur01.aiff" loop:NO];
                    break;
                case 6:
                    NSLog(@"Song 6");
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"militaryGrandeur01.aiff" loop:NO];
                    break;
                default:
                    break;
            }
            
        }
        else {
            break;
        }
    }
}

@end
