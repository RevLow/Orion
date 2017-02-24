//
//  OrionPlayer.h
//  Orion
//
//  Created by RevLow on 2017/02/25.
//
//

#ifndef __Orion__Orion__
#define __Orion__Orion__

#include <iostream>
#include "OrionContext.h"
#include <unordered_map>

namespace Orion{
    // 再生のためのモジュール
    namespace Player{
        /*
         cocos2d-xのcreateで引数を受け取るようにするテンプレートクラス
         @note 使い方
         class Hoge : public create_func<Hoge>{
         public:
         using create_func::create;
         // 任意引数を受け取るinit宣言
         bool init(Args...);
         }
         */
        template<class T>
        class create_func{
        public:
            template<class... Args>
            static T* create(Args&&... args){
                auto p = new T();
                if(p->init(std::forward<Args>(args)...)){
                    p->autorelease();
                    return p;
                }
                else{
                    delete p;
                    return nullptr;
                }
            }
        };
        
        /*
         シングルトンを構築するテンプレートクラス
         @note 使い方
         class Hoge : public Singleton<Hoge>{
         private:
         friend class Singleton<Hoge>;
         Hoge() { std::cout << "Hoge()" << std::endl; }
         }
         */
        template<class T>
        class Singleton{
        public:
            static T& getInstance(){
                static typename T::singleton_pointer_type s_singleton(T::createInstance());
                return getReference(s_singleton);
            }
        private:
            using singleton_pointer_type=std::unique_ptr<T>;
            inline static T* createInstance(){ return new T(); }
            inline static T& getReference(const singleton_pointer_type& ptr){ return *ptr;}
        protected:
            Singleton(){}
        private:
            Singleton(const Singleton&)=delete;
            Singleton& operator=(const Singleton&) = delete;
            Singleton(Singleton&&) = delete;
            Singleton& operator=(Singleton&&) = delete;
        };
        
        /*
         FlashのMovieClip要素
         */
        class MovieClip : public Layer, create_func<MovieClip>{
            enum MCType{
                Image = 0,
                Movie = 1
            };
        public:
            bool init(const Orion::MovieContext::Movie& movie);
            using create_func::create;
            bool isPlaying() const{
                return _playing;
            }
            CC_SYNTHESIZE_READONLY(MCType, _type, Type);
            void traverse();
            void setTimeline(const std::vector<Orion::MovieContext::Frame>* timeline){
                _timeline = timeline;
            };
        private:
            static const Mat4 COORDINATE_TRANSFORM_MAT;
            int _movieId;
            int _frame;
            bool _playing;
            std::string _name;
            Vec2 _offset;
            const std::vector<Orion::MovieContext::Frame>* _timeline;
        };
        
        
        /*
         
         */
        class SwfPlayer : public Layer, create_func<SwfPlayer>{
        public:
            bool init(const std::string& filename);
            void update(float delta);
            using create_func::create;
        private:
            std::string playFile;
            MovieClip* root;
        };
        
        // ムービーノードを作成するファクトリ
        class MovieFactory : public Singleton<MovieFactory>{
        public:
            void registerContext(const std::string& key,  std::unique_ptr<Orion::MovieContext::Context> context);
            void switchTo(const std::string& key);
            Player::MovieClip* generate(int movieId);
            bool registeredContext(const std::string& key) {
                return contexts.find(key) != contexts.end();
            }
            int getRootMovieId(const std::string& key){
                return contexts[key]->movies[contexts[key]->movies.size() - 1].getId();
            }
        private:
            friend class Singleton<MovieFactory>;
            MovieFactory(){}
            std::string referenceKey = "";
            std::unordered_map<std::string, std::unique_ptr<Orion::MovieContext::Context>> contexts;
        };
    }
}

#endif /* defined(__Orion__Orion__) */
