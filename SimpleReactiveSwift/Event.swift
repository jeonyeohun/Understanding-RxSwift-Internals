//
//  Event.swift
//  SimpleReactiveSwift
//
//  Created by 전여훈 on 2022/01/21.
//

import Foundation

enum Event<Element> {
    case next(Element), error(Swift.Error), completed
}
