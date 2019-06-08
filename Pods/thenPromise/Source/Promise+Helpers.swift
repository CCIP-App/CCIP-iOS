//
//  Promise+Helpers.swift
//  then
//
//  Created by Sacha Durand Saint Omer on 20/02/2017.
//  Copyright © 2017 s4cha. All rights reserved.
//

import Foundation

public extension Promise {
    class func reject(_ error: Error = PromiseError.default) -> Promise<T> {
        return Promise { _, reject in reject(error) }
    }
}

public extension Promise {
    class func resolve(_ value: T) -> Promise<T> {
        return Promise { resolve, _ in resolve(value) }
    }
}

extension Promise where T == Void {
    public class func resolve() -> Promise<Void> {
        return Promise { resolve, _ in resolve() }
    }
}

public extension Promise {
    
    var value: T? {
        return synchronize { state, _ in
            return state.value
        }
    }
    
    var error: Error? {
        return synchronize { state, _ in
            return state.error
        }
    }
}
