/* Copyright (c) 2011 Robert Blackwood
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

//V8.0

#import "cocos2d.h"

@class GameLayer;

@interface CCPanZoomController : NSObject<CCTouchOneByOneDelegate>
{	
    //properties
    CCNode  *_node;
    GameLayer *_theGame;

    //bounding rect
    CGPoint _tr;
    CGPoint _bl;
    
    //window rect
    CGPoint _winTr;
    CGPoint _winBl;
    
    float   _swipeVelocityMultiplier;
    float   _scrollDuration;
    float   _scrollRate;
    float   _scrollDamping;
    float   _pinchDamping;
    float   _pinchDistanceThreshold;
    	
	//touches
	CGPoint _firstTouch;
	float   _firstLength;
	float   _oldScale;
	
    //keep track of touches in order
	NSMutableArray *_touches;
    
    //momentum
    CGPoint _momentum;
}

#pragma mark Variables:
@property (readwrite, assign) CGRect    boundingRect;   /*!< The max bounds you want to scroll */
@property (readwrite, assign) CGRect    windowRect;     /*!< The boundary of your window, by default uses winSize of CCDirector */

@property (readwrite, assign) float     scrollRate;     /*!< Rate of the easing part of the scroll action after a swipe */
@property (readwrite, assign) float     scrollDamping;  /*!< When scrolling around, this will dampen the movement */
@property (readwrite, assign) float     pinchDamping;   /*!< When zooming, this will dampen the zoom */
@property (readwrite, assign) float     pinchDistanceThreshold; /*!< The distance moved before a pinch is recognized */

#pragma mark Methods:
//Init
+ (id) controllerWithNode:(CCNode*)node;/*! Create a new control with the node you want to scroll/zoom */
- (id) initWithNode:(CCNode*)node; /*! Initialize a new control with the node you want to scroll/zoom */

//Touch handling
- (void) enableWithTouchPriority:(int)priority swallowsTouches:(BOOL)swallowsTouches; /*! Enable touches, convenience method really */
- (void) disable;

- (void) updatePosition:(CGPoint)pos; /*! Scroll to position */

@end
