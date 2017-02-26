//
//  OrionContext.cpp
//  Orion
//
//  Created by RevLow on 2017/02/25.
//
//

#include "OrionContext.h"

using namespace Orion::MovieContext;

void Context::addFlshMovie(const rapidjson::Value& movie){
    Movie movieClip;
    movieClip.setId(movie["id"].GetInt());
    movieClip.setType(movie["type"].GetString());
    
    if(movie.HasMember("name")){
        movieClip.setName(movie["name"].GetString());
    }
    if(movie.HasMember("offX")){
        Vec2 v(movie["offX"].GetInt(), movie["offY"].GetInt());
        movieClip.setOffset(std::move(v));
    }
    else{
        movieClip.setOffset(Vec2(0, 0));
    }
    
    if(TO_STRING(movie["type"]) == "movie"){
        movieClip.addFrame(movie["frames"]);
    }
    
    movies.emplace_back(std::move(movieClip));
}


void Movie::addFrame(const rapidjson::Value& frames){
    for (int i=0; i < frames.Size(); i++)
    {
        Frame f;
        if(frames[i].HasMember("label")){
            f.label = frames[i]["label"].GetString();
        }
        else{
            f.label = "";
        }
        
        f.frameId = frames[i]["frameId"].GetInt();
        for (int j=0; j < frames[i]["instructions"].Size(); j++) {
            Instruction inst = makeFrameInstruction(frames[i]["instructions"][j]);
            
            // movieIdの補間
            if(inst.type == Instruction::InstructionType::PLACE_OBJECT)
            {
                if (inst.movieId == -1)
                {
                    for (auto frame_it = _frames.rbegin(); frame_it != _frames.rend(); frame_it++)
                    {
                        for(auto instructions_it = frame_it->instructions.rbegin();instructions_it != frame_it->instructions.rend();instructions_it++)
                        {
                            if(instructions_it->layer == inst.layer && instructions_it->movieId != -1)
                            {
                                inst.movieId = instructions_it->movieId;
                                // 多重ループを一気に抜けるためgotoを使う
                                goto iteration_break;
                            }
                        }
                    }
                }
            }
        iteration_break:
            f.instructions.emplace_back(inst);
        }
        
        _frames.emplace_back(std::move(f));
    }
}


Instruction Movie::makeFrameInstruction(const rapidjson::Value& instruction){
    Instruction inst;
    
    if(TO_STRING(instruction["type"]) == "PlaceObject"){
        // PlaceObject
        inst.type = Instruction::InstructionType::PLACE_OBJECT;
        inst.layer = instruction["layer"].GetInt();
        inst.movieId = instruction.HasMember("movieId") ? instruction["movieId"].GetInt() : inst.movieId;
#define A 0
#define B 4
#define C 1
#define D 5
#define TX 12
#define TY 13
        if(instruction["transform"].HasMember("a"))
        {
            
            inst.transform.m[A] = instruction["transform"]["a"].GetDouble();
            inst.transform.m[B] = instruction["transform"]["b"].GetDouble();
            inst.transform.m[C] = instruction["transform"]["c"].GetDouble();
            inst.transform.m[D] = instruction["transform"]["d"].GetDouble();
        }
        if(instruction["transform"].HasMember("tx")){
            inst.transform.m[TX] = instruction["transform"]["tx"].GetDouble();
            inst.transform.m[TY] = instruction["transform"]["ty"].GetDouble();
        }
#undef A
#undef B
#undef C
#undef D
#undef TX
#undef TY
        if(instruction.HasMember("color")){
            inst.color.set(instruction["color"][0].GetDouble(),
                           instruction["color"][1].GetDouble(),
                           instruction["color"][2].GetDouble(),
                           instruction["color"][3].GetDouble());
        }
    }else if(TO_STRING(instruction["type"]) == "NextFrame"){
        // NextFrame
        inst.type = Instruction::InstructionType::NEXT_FRAME;
        if(instruction.HasMember("action")){
            if(TO_STRING(instruction["action"]) == "StopMovie"){
                inst.action = Instruction::ActionType::STOP_MOVIE;
            }else if(TO_STRING(instruction["action"]) == "gotoAndPlay"){
                inst.action = Instruction::ActionType::GOTO_AND_PLAY;
                inst.destFrameId = instruction["destFrameId"].GetInt();
            }else {
                inst.action = Instruction::ActionType::GOTO_AND_STOP;
                inst.destFrameId = instruction["destFrameId"].GetInt();
            }
        }
    }else if(TO_STRING(instruction["type"]) == "RemoveObject"){
        // RemoveObject
        inst.type = Instruction::InstructionType::REMOVE_OBJECT;
        inst.layer = instruction["layer"].GetInt();
    }else {
        // PlaySound
        inst.type = Instruction::InstructionType::PLAY_SOUND;
        inst.soundId = instruction["soundId"].GetInt();
    }
    
    return inst;
}