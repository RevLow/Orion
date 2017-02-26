//
//  Orion_mobile_Tests.m
//  Orion-mobile Tests
//
//  Created by RevLow on 2017/02/25.
//
//

#import <XCTest/XCTest.h>
#include "OrionTest.h"

/*
 privateメソッドのaddFrameを呼び出すために定義
*/
struct MovieMakeFrame { typedef Orion::MovieContext::Instruction (Orion::MovieContext::Movie::* type)(const rapidjson::Value&); };

template struct Initializer<MovieMakeFrame, &Orion::MovieContext::Movie::makeFrameInstruction>;

@interface Orion_mobile_Tests : XCTestCase

@end

@implementation Orion_mobile_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - @describe Instructionの検証
#pragma mark RemoveObject
/*
   @context valueのtypeがRemoveObjectの場合
   @it      layerとtypeが入力したjsonデータに応じた結果になる
 */
- (void)testRemoveObjectInstruction
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"instruction": {"type":"RemoveObject", "layer": 1}})";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["instruction"];
    
    auto instruction = (movie.*Accessor<MovieMakeFrame>::value)(s);
    XCTAssertEqual(instruction.type, Orion::MovieContext::Instruction::InstructionType::REMOVE_OBJECT, @"Type is RemoveObject");
    XCTAssertEqual(instruction.layer, 1, @"layer is 1");
}

#pragma mark PlaceObject

/*
  @context valueのtypeがPlaceObjectの場合
  @it      layer, type, transformが入力したjsonデータに応じた結果になる
 */
- (void)testPlaceObject
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"instruction": {"type":"PlaceObject", "layer": 1, "transform":{"a": 1.063, "d": 1.063, "b": 0, "c": 0, "tx": -45.0, "ty": 30.0}}})";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["instruction"];
    auto instruction = (movie.*Accessor<MovieMakeFrame>::value)(s);
    XCTAssertEqual(instruction.type, Orion::MovieContext::Instruction::InstructionType::PLACE_OBJECT, @"Type is PlaceObject");
    XCTAssertEqual(instruction.layer, 1, @"layer is 1");

    // transform
    XCTAssertEqualWithAccuracy(instruction.transform.m[0], 1.063, 0.001, @"a is OK");
    XCTAssertEqual(instruction.transform.m[1],  0.0,   @"c is OK");
    XCTAssertEqual(instruction.transform.m[4],  0.0,   @"b is OK");
    XCTAssertEqualWithAccuracy(instruction.transform.m[5], 1.063, 0.001,  @"d is OK");
    XCTAssertEqualWithAccuracy(instruction.transform.m[12], -45.0, 0.001, @"tx is OK");
    XCTAssertEqualWithAccuracy(instruction.transform.m[13], 30.0, 0.001,  @"ty is OK");
}

/*
    @context valueのtypeがPlaceObjectでcolorのパラメータが存在する場合
    @it      layer, type, transform, colorが入力したjsonデータに応じた結果になる
 */
- (void)testPlaceObjectWithColor
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"instruction": {"type":"PlaceObject", "layer": 1, "transform":{"a": 1.063, "d": 1.063, "b": 0, "c": 0, "tx": -45.0, "ty": 30.0}, "color":[1,1,1,0.93]}})";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["instruction"];
    auto instruction = (movie.*Accessor<MovieMakeFrame>::value)(s);
    XCTAssertEqual(instruction.type, Orion::MovieContext::Instruction::InstructionType::PLACE_OBJECT, @"Type is PlaceObject");
    XCTAssertEqual(instruction.layer, 1, @"layer is 1");
    
    // transform
    XCTAssertEqualWithAccuracy(instruction.transform.m[0], 1.063, 0.001, @"a is OK");
    XCTAssertEqual(instruction.transform.m[1],  0.0,   @"c is OK");
    XCTAssertEqual(instruction.transform.m[4],  0.0,   @"b is OK");
    XCTAssertEqualWithAccuracy(instruction.transform.m[5], 1.063, 0.001,  @"d is OK");
    XCTAssertEqualWithAccuracy(instruction.transform.m[12], -45.0, 0.001, @"tx is OK");
    XCTAssertEqualWithAccuracy(instruction.transform.m[13], 30.0, 0.001,  @"ty is OK");

    //color
    XCTAssertEqual(instruction.color.x, 1, @"red is same");
    XCTAssertEqual(instruction.color.y, 1, @"green is same");
    XCTAssertEqual(instruction.color.z, 1, @"blue is same");
    XCTAssertEqualWithAccuracy(instruction.color.w, 0.93, 0.001, @"alpha is same");
}

#pragma mark NextFrame

/*
    @context valueのtypeがNextFrameの場合
    @it      typeが入力したjsonデータに応じた結果になる
 */
-(void)testNextFrame
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"instruction": {"type":"NextFrame"}})";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["instruction"];
    
    auto instruction = (movie.*Accessor<MovieMakeFrame>::value)(s);
    XCTAssertEqual(instruction.type, Orion::MovieContext::Instruction::InstructionType::NEXT_FRAME, @"Type is NextFrame");
}

/*
    @context valueのtypeがNextFrameでaction=StopMovieの場合
    @it      typeとactionが入力したjsonデータに応じた結果になる
 */
-(void)testNextFrameWithStopMovieAction
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"instruction": {"type":"NextFrame", "action":"StopMovie"}})";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["instruction"];
    
    auto instruction = (movie.*Accessor<MovieMakeFrame>::value)(s);
    XCTAssertEqual(instruction.type, Orion::MovieContext::Instruction::InstructionType::NEXT_FRAME, @"Type is NextFrame");
    XCTAssertEqual(instruction.action, Orion::MovieContext::Instruction::ActionType::STOP_MOVIE, @"Stop Movie");
}

/*
    @context valueのtypeがNextFrameでaction=gotoAndPlayの場合
    @it      type,action,destFrameIdが入力したjsonデータに応じた結果になる
 */
-(void)testNextFrameWithGotoAndPlayAction
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"instruction": {"type":"NextFrame", "action":"gotoAndPlay", "destFrameId": 1}})";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["instruction"];
    
    auto instruction = (movie.*Accessor<MovieMakeFrame>::value)(s);
    XCTAssertEqual(instruction.type, Orion::MovieContext::Instruction::InstructionType::NEXT_FRAME, @"Type is NextFrame");
    XCTAssertEqual(instruction.action, Orion::MovieContext::Instruction::ActionType::GOTO_AND_PLAY, @"gotoAndPlay Movie");
    XCTAssertEqual(instruction.destFrameId, 1, "destFrameId 1");
}

/*
    @context valueのtypeがNextFrameでaction=gotoAndStopの場合
    @it      type,action,destFrameIdが入力したjsonデータに応じた結果になる
 */
-(void)testNextFrameWithGotoAndStopAction
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"instruction": {"type":"NextFrame", "action":"gotoAndStop", "destFrameId": 1}})";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["instruction"];
    
    auto instruction = (movie.*Accessor<MovieMakeFrame>::value)(s);
    XCTAssertEqual(instruction.type, Orion::MovieContext::Instruction::InstructionType::NEXT_FRAME, @"Type is NextFrame");
    XCTAssertEqual(instruction.action, Orion::MovieContext::Instruction::ActionType::GOTO_AND_STOP, @"gotoAndStop Movie");
    XCTAssertEqual(instruction.destFrameId, 1, "destFrameId 1");
}

#pragma mark PlaySound

-(void)testPlaySound
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"instruction": {"type":"PlaySound", "soundId": 1}})";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["instruction"];

    auto instruction = (movie.*Accessor<MovieMakeFrame>::value)(s);
    XCTAssertEqual(instruction.type, Orion::MovieContext::Instruction::InstructionType::PLAY_SOUND, @"Type is PlaySound");
    XCTAssertEqual(instruction.soundId, 1, @"Sound id is 1");
}

@end
