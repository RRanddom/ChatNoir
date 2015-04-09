//
//  SwiftQueue.swift
//  ChatNoir
//
//  Created by apple on 15-4-8.
//  Copyright (c) 2015年 apple.com. All rights reserved.
//

import Foundation

class QNode<T> {
    var value: T
    var next: QNode?
    
    init(item:T) {
        value = item
    }
}


struct Queue<T> {
    private var top: QNode<T>!
    private var bottom: QNode<T>!
    
    init() {
        top = nil
        bottom = nil
    }
    
    mutating func enQueue(item: T) {
        
        var newNode:QNode<T> = QNode(item: item)
        
        if top == nil {
            top = newNode
            bottom = top
            return
        }
        
        bottom.next = newNode
        bottom = newNode
    }
    
    mutating func deQueue() -> T? {
        
        let topItem: T? = top?.value
        if topItem == nil {
            return nil
        }
        
        if let nextItem = top.next {
            top = nextItem
        } else {
            top = nil
            bottom = nil
        }
        
        return topItem
    }
    
    func isEmpty() -> Bool {
        
        return top == nil ? true : false
    }
    
    func peek() -> T? {
        return top?.value
    }
    
}

