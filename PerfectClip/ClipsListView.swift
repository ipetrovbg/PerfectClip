//
//  ClipsListView.swift
//  PerfectClip
//
//  Created by Petar Petrov on 20.02.22.
//

import SwiftUI

struct ClipsListView: View {
    @State private var store: Store?
    @State private var selection = Set<ClipboardItem.ID>()
    @State private var searchText = ""
    
    func filter(item: ClipboardItem) -> Bool {
        if ((store?.searchText.isEmpty) != nil) {
            return true
        }
        return (item.text?.lowercased().contains((store?.searchText.lowercased())!) ?? false)
    }
    
    var body: some View {
        Group {
            Table(store?.clipboardItems.filter(filter) ?? [], selection: $selection) {
                TableColumn("Text", value: \.text!)
                TableColumn("Created At") { clip in
                    Text(clip.createdAt!.formatDate())
                }.width(100)
            }
            .onAppear {
                lazy var persistentContainer: NSPersistentContainer = {
                    let container = NSPersistentContainer(name: "Model")
                    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                        if let error = error as NSError? {
                            fatalError("Unresolved error \(error), \(error.userInfo)")
                        }
                    })
                    return container
                }()
                store = Store(managedObjectContext: persistentContainer.viewContext)
                store?.fetchQuery(100)
            }
            .onDeleteCommand(perform: {
                store?.clipboardItems.forEach({ item in
                    if selection.contains(ObjectIdentifier(item)) {
                        store?.deleteItem(item)
                    }
                })
            })
            .padding()
        }
        .toolbar {
            Button("Clear All") {
                if (store != nil) && store?.clipboardItems != nil {
                    store!.clearHistory(store!.clipboardItems)
                }
                
            }
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            store?.searchText = searchText
            store?.fetchQuery()
        }
        .onChange(of: searchText) { _newSearchText in
            if searchText.isEmpty {
                store?.searchText = ""
                store?.fetchQuery(100)
            }
        }
        .navigationTitle("Clips")
    }
}

struct ClipsListView_Previews: PreviewProvider {
    static var previews: some View {
        ClipsListView()
    }
}
