//
//  Store.swift
//  PerfectClip
//
//  Created by Petar Petrov on 13.12.21.
//

import Foundation
import Combine
import SwiftUI


class Store: NSObject, ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    @Published var searchText: String = ""
    @Published var focusedIndex = -1
    @Published var isCompact = true

    private var controller: NSFetchedResultsController<ClipboardItem>
    private var context: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        context = managedObjectContext
        controller = NSFetchedResultsController(fetchRequest: ClipboardItem.fetchRequest(q: ""),
        managedObjectContext: managedObjectContext,
        sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        controller.delegate = self

        do {
          try controller.performFetch()
            clipboardItems = controller.fetchedObjects ?? []
        } catch {
          print("failed to fetch items!")
        }
      }
    
    func resetFocusIndex() {
        focusedIndex = -1
    }
    
    func fetchQuery(_ limit: Int = 20) {
        self.controller = NSFetchedResultsController(fetchRequest: ClipboardItem.fetchRequest(q: self.searchText, limit),
                                                managedObjectContext: self.context,
        sectionNameKeyPath: nil, cacheName: nil)

        do {
          try controller.performFetch()
            clipboardItems = controller.fetchedObjects ?? []
        } catch {
          print("failed to fetch items!")
        }
    }
    
    func checkIfExist(_ item: String) -> Bool {
        let request = NSFetchRequest<ClipboardItem>(entityName: "ClipboardItem")
        request.fetchLimit =  1
        request.predicate = NSPredicate(format: "text == %@" , item)
        
        do {
            let count = try self.context.count(for: request)
            if count == 1 {
                let item = try self.context.fetch(request).first
                item?.createdAt = Date()
            }
            return count > 0
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func createItem(text: String) {
        let len = text.lengthOfBytes(using: String.Encoding.utf8)
        if len > 2000 {
            return
        }

        do {
            if !checkIfExist(text) {
                let clipboardItem = ClipboardItem(context: self.context)
                clipboardItem.text = text
                clipboardItem.createdAt = Date()
                try self.context.save()
            } else {
                try self.context.save()
            }
        } catch {
            print("Couldn't save \"\(text)\"!")
        }
    }
    
    func clearHistory(_ items: [ClipboardItem]) {
        items.forEach { item in
            self.context.delete(item)
        }
        
        do {
            try self.context.save()
        } catch {
            print("Couldn't clear the clipboard history!")
        }
    }
    
    func deleteItem(_ item: ClipboardItem) {
        do {
            if item.text != nil && checkIfExist(item.text!) {
                self.context.delete(item)
            }

            try self.context.save()
            self.fetchQuery()
        } catch {
            print("Couldn't delete the item!")
        }
    }
}

extension Store: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    guard let items = controller.fetchedObjects as? [ClipboardItem]
      else { return }

    clipboardItems = items
  }
}
