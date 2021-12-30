//
//  MenuView.swift
//  PerfectClip
//
//  Created by Petar Petrov on 12.12.21.
//

import SwiftUI


struct MenuView: View {
    @ObservedObject var store: Store
    @State var sheetPresented = false

    var body: some View {
        VStack {
            HStack {
                TextField(text: $store.searchText) {
                    Text("Search through your clips")
                }.onSubmit {
                    store.fetchQuery()
                }
            }
            .padding([.top, .leading, .trailing])
            .padding(.bottom, 4)
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(store.clipboardItems.filter { item in
                        if store.searchText.isEmpty {
                            return true
                        }
                        return (item.text?.lowercased().contains(store.searchText.lowercased()) ?? false)
                    }, content: { item in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.text!)
                                    .frame(maxHeight: 50)
                                    .truncationMode(.tail)
                                Spacer()
                                Button("copy") {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(item.text!, forType: .string)
                                }
                            }
                            
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            Divider()
                        }
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
                }.frame(width: 16, height: 16)
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
