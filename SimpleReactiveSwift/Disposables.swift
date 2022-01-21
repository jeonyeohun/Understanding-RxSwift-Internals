//
//  Disposables.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

struct Disposables {}

extension Disposables {
    static public func create() -> Disposable {
        return DefaultDisposable()
    }
}

protocol Disposable {
    func dispose()
}

class DefaultDisposable: Disposable {
    func dispose() {
        print("disposed")
    }
}

class BinaryDisposables: Cancelable {
    private var disposable1: Disposable?
    private var disposable2: Disposable?
    
    init(_ disposable1: Disposable, _ disposable2: Disposable) {
        self.disposable1 = disposable1
        self.disposable2 = disposable2
    }
    
    func dispose() {
        self.disposable1?.dispose()
        self.disposable2?.dispose()
        self.disposable1 = nil
        self.disposable2 = nil
    }
}

extension Disposables {
    public static func create(_ disposable1: Disposable, _ disposable2: Disposable) -> Cancelable {
        BinaryDisposables(disposable1, disposable2)
    }
}
