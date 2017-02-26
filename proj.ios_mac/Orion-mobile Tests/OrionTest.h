//
//  OrionTest.h
//  Orion
//
//  Created by Tetsushi on 2017/02/25.
//
//

#ifndef Orion_OrionTest_h
#define Orion_OrionTest_h

#include "OrionPlayer.h"
#include "OrionContext.h"

template <class Tag>
struct Accessor{
    static typename Tag::type value;
};
template <class Tag>
typename Tag::type Accessor<Tag>::value;

template <class Tag, typename Tag::type p>
struct Initializer{
    Initializer(){ Accessor<Tag>::value = p; }
    static Initializer instance;
};
template <class Tag, typename Tag::type p>
Initializer<Tag, p> Initializer<Tag, p>::instance;

#endif
