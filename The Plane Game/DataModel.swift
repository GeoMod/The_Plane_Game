//
//  CollisionTypes.swift
//  The Plane Game
//
//  Created by Daniel O'Leary on 8/3/19.
//  Copyright © 2019 Impulse Coupled Dev. All rights reserved.
//


import SpriteKit

enum CollisionTypes: UInt32 {
    case airplane = 1
    case runwayEdge = 2
    case tower = 4 // Unused
    case runwaysurface = 8
    case liveTree = 16
    case deadTree = 32
    case wall = 64
}


struct StartingPositions {
    let level1 = CGPoint(x: 819, y: 181)
}

