//
//  SearchField.swift
//  PerfectClip
//
//  Created by Petar Petrov on 13.12.21.
//

import AppKit
import SwiftUI
import Combine

// original code from https://developer.apple.com/library/archive/samplecode/CustomMenus

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    
    private var mutatingWrapper = MutatingWrapper()
    
    class MutatingWrapper {
        var coordinator: Coordinator? = nil
    }
    
    init(text searchText: Binding<String>) {
        _text = searchText
        makeCoordinator()
    }
    
    func makeNSView(context: Context) -> NSSearchField {
        
        let searchField = NSSearchField(frame: .zero)
        searchField.delegate = context.coordinator
        
        context.coordinator.searchField = searchField
        
        return searchField
    }
    
    func onMoveUp(delegate: @escaping () -> ()) -> Self {
        mutatingWrapper.coordinator?.onMoveUp = delegate
        return self
    }
    
    func onMoveDown(delegate: @escaping () -> ()) -> Self {
        mutatingWrapper.coordinator?.onMoveDown = delegate
        return self
    }
    
    func onSubmit(delegate: @escaping () -> ()) -> Self {
        mutatingWrapper.coordinator?.onSubmit = delegate
        return self
    }
    
    func onChange(delegate: @escaping () -> ()) -> Self {
        mutatingWrapper.coordinator?.onChange = delegate
        return self
    }
    
    func updateNSView(_ searchField: NSSearchField, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        if mutatingWrapper.coordinator == nil {
            mutatingWrapper.coordinator = Coordinator(text: $text)
        }
        return mutatingWrapper.coordinator!
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        var updatingSelectedRange: Bool = false
        var onMoveUp: (() -> ())? = nil
        var onMoveDown: (() -> ())? = nil
        var onSubmit: (() -> ())? = nil
        var onChange: (() -> ())? = nil
        
        init(text: Binding<String>) {
            _text = text
            
            super.init()
        }
        
        var searchField: NSSearchField! {
            didSet {
                searchField.stringValue = self.text
            }
        }
        
        // MARK: - NSSearchField Delegate Methods
        
        @objc func controlTextDidChange(_ notification: Notification) {
            let text = self.searchField.stringValue
            self.text = text
            if let change = onChange {
                change()
            }
        }
        
        @objc func moveUp() {
            if let move = onMoveUp {
                move()
            }
        }
        
        @objc func moveDown() {
            if let move = onMoveDown {
                move()
            }
        }
        
        
        
        @objc func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if let submit = onSubmit {
                    submit()
                    return true
                }
            }
            
            if commandSelector == #selector(NSResponder.moveUp(_:)) {
                self.moveUp()
                return true
            }
            
            if commandSelector == #selector(NSResponder.moveDown(_:)) {
                self.moveDown()
                // return true if the action is handled
                return true
            }
            
            return false
        }
    }
}
