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
    
    func filter(item: ClipboardItem) -> Bool {
        if store.searchText.isEmpty {
            return true
        }
        return (item.text?.lowercased().contains(store.searchText.lowercased()) ?? false)
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
                        }
                        .onMoveDown {
                            if store.focusedIndex < store.clipboardItems.filter(filter).count - 1 {
                                store.focusedIndex = store.focusedIndex + 1
                            }
                            withAnimation {
                                scrollProxy.scrollTo(store.focusedIndex)
                            }
                        }
                        .onChange {
                            store.focusedIndex = -1
                        }
                        .onSubmit {
                            store.focusedIndex = -1
                            store.fetchQuery()
                        }
                    
                }
                .padding([.top, .leading, .trailing])
                .padding(.bottom, 4)
                ScrollView {
                    EnumeratedForEach(store.clipboardItems.filter(filter), content: { index, item in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.text!)
                                    .frame(maxHeight: 50)
                                    .truncationMode(.tail)
                                Spacer()
                                Button("") {
                                    let item = Array(store.clipboardItems.enumerated()).first { inx, item in
                                        inx == store.focusedIndex
                                    }
                                    if let itm = item?.element, itm.text != nil {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(itm.text!, forType: .string)
                                    }
                                }
                                .frame(width: 0)
                                .hidden()
                                    .keyboardShortcut("c", modifiers: [.command])
                                Button("copy") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(item.text!, forType: .string)
                                }
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(index == store.focusedIndex ? Color.accentColor : Color.primary.opacity(0), style: StrokeStyle(lineWidth: 2))
                                )
                            }
                            
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            Divider()
                        }.id(index)
                    })
                }
            }
            HStack {
                ZStack {
                    Color.gray
                    HStack {
                        Text("v0.2")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }.frame(width: 20, height: 20)
                    .cornerRadius(16)
                Text("Perfect Clipboard")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                Button("Clear") {
                    sheetPresented.toggle()
                }
            }.padding(8)
                .alert(isPresented: $sheetPresented, content: {
                    Alert(title: Text("History"), message: Text("Are you really sure you want to clear all copy history?"), primaryButton: .destructive(Text("Clear"), action: {
                        store.clearHistory(store.clipboardItems)
                    }), secondaryButton: .default(Text("Cancel")))
                })
        }
    }
}
