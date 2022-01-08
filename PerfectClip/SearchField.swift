//
//  SuggestionTextField.swift
//  PubChemDemo
//
//  Created by Stephan Michels on 27.08.20.
//  Copyright © 2020 Stephan Michels. All rights reserved.
//

import AppKit
import SwiftUI
import Combine
import HotKey

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
//        searchField.controlSize = .regular
//        searchField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: searchField.controlSize))
//        searchField.translatesAutoresizingMaskIntoConstraints = false
//        searchField.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
//        searchField.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
        searchField.delegate = context.coordinator
        
//        let searchFieldCell = searchField.cell!
//        searchFieldCell.lineBreakMode = .byWordWrapping
        
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
//        let text = self.text
//
////        mutatingWrapper.coordinator = context.coordinator
//
//        mutatingWrapper.coordinator!.updatingSelectedRange = true
//        defer {
//            mutatingWrapper.coordinator!.updatingSelectedRange = false
//        }
//        searchField.stringValue = text
//        if let selectedSuggestion = model.selectedSuggestion {
//            let suggestionText = selectedSuggestion.text
//
//            if searchField.stringValue != suggestionText {
//                searchField.stringValue = suggestionText
//            }
//
//            if let fieldEditor = searchField.window?.fieldEditor(false, for: searchField) {
//                if model.suggestionConfirmed {
//                    let range = NSRange(suggestionText.startIndex..<suggestionText.endIndex, in: fieldEditor.string)
//                    if fieldEditor.selectedRange != range {
//                        fieldEditor.selectedRange = range
//                    }
//                } else if suggestionText.hasPrefix(text) {
//                    let range = NSRange(suggestionText.index(suggestionText.startIndex, offsetBy: text.count)..<suggestionText.index(suggestionText.startIndex, offsetBy: suggestionText.count), in: fieldEditor.string)
//                    if fieldEditor.selectedRange != range {
//                        fieldEditor.selectedRange = range
//                    }
//                }
//            }
//        } else {
//            if searchField.stringValue != self.text {
//                searchField.stringValue = self.text
//            }
//        }
    }
    
    func makeCoordinator() -> Coordinator {
        if mutatingWrapper.coordinator == nil {
            mutatingWrapper.coordinator = Coordinator(text: $text)
        }
        return mutatingWrapper.coordinator!
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
//        var didChangeSelectionSubscription: AnyCancellable?
//        var frameDidChangeSubscription: AnyCancellable?
        var updatingSelectedRange: Bool = false
        var onMoveUp: (() -> ())? = nil
        var onMoveDown: (() -> ())? = nil
        var onSubmit: (() -> ())? = nil
        var onChange: (() -> ())? = nil
        
        init(text: Binding<String>) {
            _text = text
            
            super.init()
            
//            self.didChangeSelectionSubscription = NotificationCenter.default.publisher(for: NSTextView.didChangeSelectionNotification)
//                .sink(receiveValue: { notification in
//                    guard !self.updatingSelectedRange,
//                          let fieldEditor = self.searchField.window?.fieldEditor(false, for: self.searchField),
//                          let textView = notification.object as? NSTextView,
//                          fieldEditor === textView else {
//                        return
//                    }
//                })
        }
        
        var searchField: NSSearchField! {
            didSet {
//                if let searchField = self.searchField {
                    searchField.stringValue = self.text
////                    searchField.postsFrameChangedNotifications = true
////                    self.frameDidChangeSubscription = NotificationCenter.default.publisher(for: NSView.frameDidChangeNotification, object: searchField)
////                        .sink(receiveValue: { (_) in
////
////                        })
//                } else {
////                    self.frameDidChangeSubscription = nil
//                }
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
        
        @objc func controlTextDidEndEditing(_ obj: Notification) {
            if let submit = onSubmit {
                submit()
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
