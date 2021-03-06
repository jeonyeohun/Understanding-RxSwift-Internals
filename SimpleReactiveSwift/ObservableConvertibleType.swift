//
//  ObservableConvertibleType.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

protocol ObservableConvertibleType {
    associatedtype Element
    func asObservable() -> Observable<Element>
}
