//
//  OrionPlayer  .cpp
//  Orion
//
//  Created by RevLow on 2017/02/25.
//
//

#include "OrionPlayer.h"

using namespace Orion;

const Mat4 Orion::Player::MovieClip::COORDINATE_TRANSFORM_MAT = Mat4(1, 0, 0, 0,
                                                                    0, -1, 0, 0,
                                                                    0, 0, -1, 0,
                                                                    0, 0, 0, 1);

bool Player::SwfPlayer::init(const std::string& filename) {
    if(MovieFactory::getInstance().registeredContext(filename)){
        int movieId = MovieFactory::getInstance().getRootMovieId(filename);
        root = MovieFactory::getInstance().generate(movieId);
        addChild(root);
        schedule(schedule_selector(Player::SwfPlayer::update), 0.033);
        playFile = filename;
        return true;
    }
    
    std::string content = FileUtils::getInstance()->getStringFromFile(filename);
    rapidjson::Document document;
    document.Parse<rapidjson::ParseFlag::kParseDefaultFlags>(content.c_str());
    if(document.HasParseError()){
        return false;
    }
    
    std::unique_ptr<MovieContext::Context> context(new MovieContext::Context);
    context->name = document["name"].GetString();
    context->msPerFrame = document["msPerFrame"].GetInt();
    const rapidjson::Value& movies = document["movies"];
    for(int i = 0;i < movies.Size();i++){
        context->addFlshMovie(movies[i]);
    }
    int movieId = context->movies[context->movies.size() - 1].getId();
    MovieFactory::getInstance().registerContext(filename, std::move(context));
    MovieFactory::getInstance().switchTo(filename);
    root = MovieFactory::getInstance().generate(movieId);
    addChild(root);
    
    playFile = filename;
    
    schedule(schedule_selector(Player::SwfPlayer::update), 0.033);
    return true;
}

void Player::SwfPlayer::update(float delta){
    MovieFactory::getInstance().switchTo(playFile);
    root->traverse();
}

bool Player::MovieClip::init(const MovieContext::Movie& movie){
    _frame = 0;
    _movieId = movie.getId();
    _playing = false;
    _name = movie.getName();
    _offset = movie.getOffset();
    _type = movie.getType() == "movie" ? MCType::Movie : MCType::Image;
    
    // 子ノードに透明度反映
    setCascadeOpacityEnabled(true);
    if(_type == MCType::Image){
        long p = _name.find_last_of('/') + 1;
        std::string imgName = _name.substr(p, _name.length() - 5 - p);
        Sprite* sprite = Sprite::create(imgName);
        sprite->ignoreAnchorPointForPosition(true);
        sprite->setPosition(
                            Vec2(sprite->getTexture()->getContentSize().width / 2 + _offset.y,
                                 -sprite->getTexture()->getContentSize().height - sprite->getTexture()->getContentSize().height / 2 - _offset.y));
        addChild(sprite);
        
        //        DrawNode* node = DrawNode::create();
        //        node->drawDot(Vec2(0,0), 3, Color4F::BLUE);
        //        node->drawDot(Vec2(sprite->getTexture()->getContentSize().width, -sprite->getContentSize().height), 5, Color4F::RED);
        //        addChild(node);
    }else{
        _playing = true;
    }
    
    return true;
}

void Player::MovieClip::traverse(){
    if(_type == MCType::Image){
        return;
    }
    
    for(auto child : getChildren()){
        auto layer = dynamic_cast<MovieClip*>(child);
        if(layer != nullptr){
            layer->traverse();
        }
    }
    
    if(!_playing) return;
    const MovieContext::Frame& frame = _timeline->at(_frame);
    for (auto& instruction : frame.instructions) {
        switch (instruction.type) {
            case MovieContext::Instruction::InstructionType::NEXT_FRAME:
                switch (instruction.action) {
                    case MovieContext::Instruction::ActionType::NO_ACTION:
                        _frame++;
                        if(_frame >= _timeline->size()){
                            _playing = false;
                        }
                        break;
                    case MovieContext::Instruction::ActionType::STOP_MOVIE:
                        _playing = false;
                        _frame++;
                        break;
                    case MovieContext::Instruction::ActionType::GOTO_AND_PLAY:
                        _frame = instruction.destFrameId - 1;
                        break;
                    case MovieContext::Instruction::ActionType::GOTO_AND_STOP:
                        _frame = instruction.destFrameId - 1;
                        _playing = false;
                        break;
                    default:
                        break;
                }
                goto end_frame;
            case MovieContext::Instruction::InstructionType::PLACE_OBJECT:
            case MovieContext::Instruction::InstructionType::PLACE_CLIP_OBJECT:
            {
                MovieClip* layer;
                if (getChildByTag<MovieClip*>(instruction.layer) == nullptr)
                {
                    layer = MovieFactory::getInstance().generate(instruction.movieId);
                    layer->setTag(instruction.layer);
                    layer->setPosition(Vec2(0,0));
                    addChild(layer, instruction.layer);
                }else{
                    layer = getChildByTag<MovieClip*>(instruction.layer);
                }
                
                const Mat4 transform = instruction.transform;
                layer->setNodeToParentTransform(COORDINATE_TRANSFORM_MAT * transform * COORDINATE_TRANSFORM_MAT);
                //LOG_MAT(layer->getNodeToParentTransform());
                
                if (instruction.color.w >= 0.0) {
                    layer->setOpacity(255 * instruction.color.w);
                }
                
                break;
            }
            case MovieContext::Instruction::InstructionType::PLAY_SOUND:
                break;
            case MovieContext::Instruction::InstructionType::REMOVE_OBJECT:
                removeChildByTag(instruction.layer);
                break;
            default:
                break;
        }
    }
    
end_frame:
    return;
}

void Player::MovieFactory::registerContext(const std::string &key, std::unique_ptr<MovieContext::Context> context){
    contexts[key] = std::move(context);
}

void Player::MovieFactory::switchTo(const std::string &key){
    referenceKey = key;
}

Player::MovieClip* Player::MovieFactory::generate(int movieId){
    if(contexts.find(referenceKey) == contexts.end()){
        return nullptr;
    }
    
    const MovieContext::Context& context = *contexts[referenceKey];
    MovieClip* clip = MovieClip::create(context.movies[movieId - 1]);
    clip->setTimeline(context.movies[movieId - 1].getFramesPtr());
    return clip;
}

