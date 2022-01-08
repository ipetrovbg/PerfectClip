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
    
    func fetchQuery() {
        self.controller = NSFetchedResultsController(fetchRequest: ClipboardItem.fetchRequest(q: self.searchText),
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
            return count > 0
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func createItem(text: String) {
        
        do {
            if !checkIfExist(text) {
                let clipboardItem = ClipboardItem(context: self.context)
                clipboardItem.text = text
                clipboardItem.createdAt = Date()
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
}

extension Store: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    guard let items = controller.fetchedObjects as? [ClipboardItem]
      else { return }

    clipboardItems = items
  }
}
