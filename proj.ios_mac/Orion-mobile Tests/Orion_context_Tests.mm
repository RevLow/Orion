//
//  Orion_context_Tests.mm
//  Orion-context Tests
//
//  Created by RevLow on 2017/02/25.
//
//

#import <XCTest/XCTest.h>
#include "OrionTest.h"

/*
    privateの要素を呼び出すための定義
*/
struct MovieMakeFrame { typedef Orion::MovieContext::Instruction (Orion::MovieContext::Movie::* type)(const rapidjson::Value&); };
struct MovieFrames { typedef std::vector<Orion::MovieContext::Frame> Orion::MovieContext::Movie::* type; };

template struct Initializer<MovieMakeFrame, &Orion::MovieContext::Movie::makeFrameInstruction>;
template struct Initializer<MovieFrames, &Orion::MovieContext::Movie::_frames>;

/*
    @brief Orion::MovieContext内のメソッド群のテスト
 */
@interface Orion_context_Tests : XCTestCase

@end

@implementation Orion_context_Tests

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

#pragma mark - @describe Movie#makeFrameInstructionの検証
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

/*
    @context valueのtypeがPlaySoundの場合
    @it      type, soundIdが入力したjsonデータに応じた結果になる
 */
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

#pragma mark - @describe Movie#addFrameの検証

/*
    @context movieIdが存在するinstructionを含んでいる場合
    @it      frameIdとinstructionsがjsonに応じた結果になる
*/
-(void)testAddFrame
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"frames":
      [
        {"frameId":1, "instructions":[
            {"type":"PlaceObject", "layer":1, "movieId":3,"transform":{"a":1,"b":0,"c":0,"d":1,"tx":0,"ty":0}},
            {"type":"NextFrame"}]
        }
      ]
    })";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["frames"];

    movie.addFrame(s);
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[0].frameId, 1, @"frameId is 1");
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[0].instructions[0].type, Orion::MovieContext::Instruction::InstructionType::PLACE_OBJECT, @"0 instruction type is PlaceObject");
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[0].instructions[1].type, Orion::MovieContext::Instruction::InstructionType::NEXT_FRAME, @"1 instruction type is NextFrame");
}

/*
    @context movieIdが存在しないinstructionを含んでいる場合
    @it      instructionのmovieIdが既に存在するmovieIdで埋められている
 */
-(void)testAddFrameNonMovieId
{
    Orion::MovieContext::Movie movie;
    Orion::MovieContext::Frame frame;
    frame.frameId = 1;
    Orion::MovieContext::Instruction instruction;
    instruction.type = Orion::MovieContext::Instruction::InstructionType::PLACE_OBJECT;
    instruction.layer = 1;
    instruction.movieId = 3;
    frame.instructions.emplace_back(instruction);
    (movie.*Accessor<MovieFrames>::value).emplace_back(frame);

    const char* json = R"({"frames":
    [
     {"frameId":2, "instructions":[
                                   {"type":"PlaceObject", "layer":1, "transform":{"a":1,"b":0,"c":0,"d":1,"tx":0,"ty":0}},
                                   {"type":"NextFrame"}]
     }
    ]
    })";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["frames"];

    movie.addFrame(s);
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[1].frameId, 2, @"frameId is 2");
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[1].instructions[0].type, Orion::MovieContext::Instruction::InstructionType::PLACE_OBJECT, @"0 instruction type is PlaceObject");
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[1].instructions[0].movieId, 3, @"instruction movieId interpolated");
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[1].instructions[1].type, Orion::MovieContext::Instruction::InstructionType::NEXT_FRAME, @"1 instruction type is NextFrame");

}

/*
    @context labelが存在するFrameの場合
    @it      Frameのラベルがjsonで指定したラベルになっている
 */
-(void)testAddFrameWithLabel
{
    Orion::MovieContext::Movie movie;
    const char* json = R"({"frames":
    [
     {"frameId":1, "label": "label", "instructions":[
                                                     {"type":"PlaceObject", "layer":1, "movieId":3,"transform":{"a":1,"b":0,"c":0,"d":1,"tx":0,"ty":0}},
                                                     {"type":"NextFrame"}]
     }
    ]
    })";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["frames"];

    movie.addFrame(s);
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[0].frameId, 1, @"frameId is 1");
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[0].instructions[0].type, Orion::MovieContext::Instruction::InstructionType::PLACE_OBJECT, @"0 instruction type is PlaceObject");
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[0].instructions[1].type, Orion::MovieContext::Instruction::InstructionType::   NEXT_FRAME, @"1 instruction type is NextFrame");
    XCTAssertEqual((movie.*Accessor<MovieFrames>::value)[0].label, "label", @"label is label");
}

#pragma mark - @describe Context#addFlshMovieの検証
/*
    @context typeがmovieのjsonを指定したとき
    @it      moviesの最初の要素にtypeがmovieのMovieが追加されている
 */
-(void)testAddFlshMovie
{
    Orion::MovieContext::Context context;
    const char* json = R"({"movie":
        {
            "id": 2,
            "type":"movie",
            "frames":[
                      {"frameId":1,"instructions":[{"type":"NextFrame"}]},
                      {"frameId":2,"instructions":[{"type":"NextFrame"}]}
            ]
        }
    })";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["movie"];

    context.addFlshMovie(s);
    XCTAssertEqual(context.movies[0].getId(), 2, @"Movie Id");
    XCTAssertEqual(context.movies[0].getType(), "movie", @"Movie type");
}

/*
    @context typeがimageのjsonを指定したとき
    @it      moviesの最初の要素にtypeがimageのMovieが追加されている
 */
-(void)testAddFlshMovieOfImage
{
    Orion::MovieContext::Context context;
    const char* json = R"({"movie":
        {
            "id": 2,
            "type":"image",
            "name":"assets/flash/ui/live/img/img.png.imag",
            "offX":80,
            "offY":50
        }
    })";
    rapidjson::Document d;
    d.Parse(json);
    rapidjson::Value& s = d["movie"];

    context.addFlshMovie(s);
    XCTAssertEqual(context.movies[0].getId(), 2, @"Movie Id");
    XCTAssertEqual(context.movies[0].getType(), "image", @"Image type");
    XCTAssertEqual(context.movies[0].getOffset().x, 80, @"Offset X");
    XCTAssertEqual(context.movies[0].getOffset().y, 50, @"Offset Y");
    XCTAssertEqual(context.movies[0].getName(), "assets/flash/ui/live/img/img.png.imag", @"Image name");
}



@end
