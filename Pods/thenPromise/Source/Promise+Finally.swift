//
//  Promise+Finally.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    
    func finally(_ block: @escaping () -> Void) {
        tryStartInitialPromiseAndStartIfneeded()
        registerFinally(block)
    }
    
    func registerFinally(_ block: @escaping () -> Void) {
        synchronize { state, blocks in
            switch state {
            case .rejected, .fulfilled:
                block()
            case .dormant, .pending:
                blocks.finally.append(block)
            }
        }
    }
}
