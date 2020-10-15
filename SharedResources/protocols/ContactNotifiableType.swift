//
//  ContactNotifiableType.swift
//  idiots
//
//  Created by Jason Foster on 29/01/2018.
//  Copyright © 2018 Jason Foster. All rights reserved.
//

import GameplayKit

protocol ContactNotifiableType {
    
    func contactWithEntityDidBegin(_ entity: GKEntity, contactPoint: CGPoint)
    
    func contactWithEntityDidEnd(_ entity: GKEntity, contactPoint: CGPoint)
}
