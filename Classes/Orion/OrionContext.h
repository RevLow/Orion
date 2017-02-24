//
//  OrionContext.h
//  Orion
//
//  Created by RevLow on 2017/02/25.
//
//

#ifndef __Orion__OrionContext__
#define __Orion__OrionContext__

#include "cocos2d.h"
#include "json/rapidjson.h"
#include "json/document.h"
#include "json/stringbuffer.h"

#define TO_STRING(value) std::string(value.GetString(), value.GetStringLength())

USING_NS_CC;

namespace Orion{
    namespace MovieContext{
        struct Instruction{
            enum InstructionType{
                NO_INSTRUCTION = -1,
                NEXT_FRAME = 0,
                PLACE_OBJECT,
                REMOVE_OBJECT,
                PLAY_SOUND,
                PLACE_CLIP_OBJECT
            };
            enum ActionType{
                STOP_MOVIE,
                GOTO_AND_PLAY,
                GOTO_AND_STOP,
                NO_ACTION
            };
            
            int soundId = -1;
            int layer = -1;
            int movieId = -1;
            InstructionType type = InstructionType::NO_INSTRUCTION;
            Mat4 transform = Mat4::IDENTITY;
            Vec4 color = Vec4(-1.0f, -1.0f, -1.0f, -1.0f);
            ActionType action = ActionType::NO_ACTION;
            int destFrameId = -1;
        };
        
        struct Frame{
            int frameId = -1;
            std::string label = "";
            std::vector<Instruction> instructions;
        };
        
        class Movie {
        public:
            CC_SYNTHESIZE(int, _id, Id);
            CC_SYNTHESIZE(std::string, _name, Name);
            CC_SYNTHESIZE(Vec2, _offset, Offset);
            CC_SYNTHESIZE(std::string, _type, Type);
            const std::vector<Frame>* getFramesPtr() const{
                return &_frames;
            };
            void addFrame(const rapidjson::Value& frames);
        private:
            Instruction makeFrameInstruction(const rapidjson::Value& instruction);
            std::vector<Frame> _frames;
        };
        
        struct Context {
            std::string name = "";
            int msPerFrame = 0;
            std::vector<Movie> movies;
            void addFlshMovie(const rapidjson::Value& movie);
        };

    }
}

#endif /* defined(__Orion__OrionContext__) */
