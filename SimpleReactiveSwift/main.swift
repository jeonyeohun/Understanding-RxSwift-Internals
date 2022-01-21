//
//  main.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

let observable = Observable<Int>.create { observer in
    observer.onNext(1)
    observer.onNext(2)
    observer.onCompleted()
    return Disposables.create()
}

let disposable = observable.subscribe(
    onNext: { data in print(data) },
    onError: { error in print(error) },
    onCompleted: { print("completed") },
    onDisposed: { print("dispose done") }
)
