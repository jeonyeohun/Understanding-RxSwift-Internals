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

// 단순하다. 그냥 두 개의 Disposable을 저장해두고, dispose가 불리면 두 disposable의 dispose를 각각 불러준 뒤에 인스턴스를 해제한다.
// 그럼 두 개 주는건 이해됐으니까 다시 ObservableType.swift로 돌아가자.
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

/* 여행 6 */
// Disposables의 extension이 있고 여기서느 두개의 Disposable을 받아 BinaryDisposables를 만든다.
// BinaryDisposable은 위에 있으니까 올려서 어떤 녀식인지 확인해보자.
extension Disposables {
    public static func create(_ disposable1: Disposable, _ disposable2: Disposable) -> Cancelable {
        BinaryDisposables(disposable1, disposable2)
    }
}
