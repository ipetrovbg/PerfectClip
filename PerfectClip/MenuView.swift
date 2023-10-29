//
//  MenuView.swift
//  PerfectClip
//
//  Created by Petar Petrov on 12.12.21.
//

import SwiftUI


struct EnumeratedForEach<ItemType, ContentView: View>: View {
    let data: [ItemType]
    let content: (Int, ItemType) -> ContentView
    
    init(_ data: [ItemType], @ViewBuilder content: @escaping (Int, ItemType) -> ContentView) {
        self.data = data
        self.content = content
    }
    
    var body: some View {
        ForEach(Array(self.data.enumerated()), id: \.offset) { idx, item in
            self.content(idx, item)
        }
    }
}

struct MenuView: View {
    @ObservedObject var store: Store
    @State var sheetPresented = false
    @State var copied = false
    @State var copyWorker: DispatchWorkItem?
    
    func filter(item: ClipboardItem) -> Bool {
        if store.searchText.isEmpty {
            return true
        }
        return (item.text?.lowercased().contains(store.searchText.lowercased()) ?? false)
    }
    
    func toggleCopyWorker() -> DispatchWorkItem {
        DispatchWorkItem(block: {
            withAnimation {
                self.copied.toggle()
            }
        })
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                HStack {
                    SearchField(text: $store.searchText)
                        .onMoveUp {
                            if store.focusedIndex > 0 {
                                store.focusedIndex = store.focusedIndex - 1
                            }
                            withAnimation {
                                scrollProxy.scrollTo(store.focusedIndex)
                            }
                            copied = false
                            copyWorker?.cancel()
                            copyWorker = nil
                        }
                        .onMoveDown {
                            let count = store.clipboardItems.filter(filter).count
                            
                            if store.focusedIndex < count - 1 {
                                store.focusedIndex = store.focusedIndex + 1
                            }
                            withAnimation {
                                scrollProxy.scrollTo(store.focusedIndex)
                            }
                            copied = false
                            copyWorker?.cancel()
                            copyWorker = nil
                        }
                        .onChange {
                            store.focusedIndex = -1
                            copied = false
                            copyWorker?.cancel()
                            copyWorker = nil
                            if store.searchText.isEmpty {
                                store.fetchQuery()
                            }
                        }
                        .onSubmit {
                            store.focusedIndex = -1
                            store.fetchQuery()
                            copied = false
                            copyWorker?.cancel()
                            copyWorker = nil
                        }
                    
                    
                }
                .padding([.top, .leading, .trailing])
                HStack {
                    Button("") {
                        store.focusedIndex = 0
                        withAnimation {
                            scrollProxy.scrollTo(store.focusedIndex)
                        }
                    }
                    .padding(0)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .keyboardShortcut(.upArrow, modifiers: [.option, .command])
                    Button("") {
                        let count = store.clipboardItems.filter(filter).count
                        store.focusedIndex = count - 1
                        withAnimation {
                            scrollProxy.scrollTo(store.focusedIndex)
                        }
                    }
                    .padding(0)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .keyboardShortcut(.downArrow, modifiers: [.option, .command])
                }
                ScrollView {
                    EnumeratedForEach(store.clipboardItems.filter(filter), content: { index, item in
                        VStack(alignment: .leading) {
                            HStack {
                                if store.isCompact {
                                    Text(item.text!)
                                        .frame(maxHeight: 20)
                                        .truncationMode(.tail)
                                } else {
                                    Text(item.text!)
                                        .frame(maxHeight: 50)
                                        .truncationMode(.tail)
                                }
                                
                                
                                Button("copy") {
                                    let item = Array(store.clipboardItems.filter(filter).enumerated()).first { inx, item in
                                        inx == store.focusedIndex
                                    }
                                    
                                    if let itm = item?.element, itm.text != nil {
                                        copyWorker = toggleCopyWorker()
                                        DispatchQueue.main.asyncAfter(deadline: .now(), execute: copyWorker!)
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(itm.text!, forType: .string)
                                        copyWorker = toggleCopyWorker()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: copyWorker!)
                                    }
                                }
                                .keyboardShortcut("c", modifiers: [.command])
                                .frame(width: 0)
                                .opacity(0)
                                
                                Spacer()
                                
                                Button(action: {
                                    store.focusedIndex = index
                                    copyWorker = toggleCopyWorker()
                                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: copyWorker!)
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(item.text!, forType: .string)
                                    copyWorker = toggleCopyWorker()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: copyWorker!)
                                }, label: {
                                    Text(index == store.focusedIndex && copied ? "Copied" : "Copy")
                                        .font(.caption)
                                        .frame(width: 35)
                                }).overlay(
                                    RoundedRectangle(cornerRadius: 4.0)
                                        .stroke(index == store.focusedIndex ? Color.accentColor : Color.primary.opacity(0),
                                                style: StrokeStyle(lineWidth: 2))
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.leading, store.isCompact ? 8 : 16)
                            .padding(.trailing, store.isCompact ? 8 : 16)
                            
                            Divider().padding(store.isCompact ? 0 : 8)
                        }.id(index)
                            .padding(.top, 4)
                    })
                }
            }

            HStack {
                VStack {
                    HStack {
                        Toggle(isOn: $store.isCompact) {
                            Text("Compact View")
                        }
                        Spacer()
                        
                        Button("Clear") {
                            sheetPresented.toggle()
                        }
                    }
                }
                .padding(.leading, 8)
                .padding(.trailing, 8)
            }

            HStack {
                ZStack {
                    Color.accentColor
                    HStack {
                        Text("v0.5")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 25, height: 25)
                .cornerRadius(16)
                
                Text("Perfect Clipboard")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.trailing, 8)
            .padding(.leading, 8)
            .padding(.bottom, 8)
            .alert(isPresented: $sheetPresented, content: {
                Alert(title: Text("History"), message: Text("Are you really sure you want to clear all copy history?"), primaryButton: .destructive(Text("Clear"), action: {
                    store.clearHistory(store.clipboardItems)
                }), secondaryButton: .default(Text("Cancel")))
            })
        }
    }
}
