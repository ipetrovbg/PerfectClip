//
//  PerfectClipApp.swift
//  PerfectClip
//
//  Created by Petar Petrov on 12.12.21.
//


import Cocoa
import SwiftUI
import CoreData
import HotKey


func WatchPasteboard(copied: @escaping (_ copiedString:String) -> Void) {
    let pasteboard = NSPasteboard.general
    var changeCount = NSPasteboard.general.changeCount
    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
        if let copiedString = pasteboard.string(forType: .string) {
            if pasteboard.changeCount != changeCount {
                copied(copiedString)
                changeCount = pasteboard.changeCount
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover = NSPopover.init()
    var statusItem: NSStatusItem?
    var store: Store?
    
    private var hotKey: HotKey? {
        didSet {
            guard let hotKey = hotKey else {
                return
            }

            hotKey.keyDownHandler = { [weak self] in
                if let strongSelf = self {
                    if let menuButton = strongSelf.statusItem?.button {
                        self!.store!.fetchQuery()
                        self!.store?.resetFocusIndex()
                        strongSelf.popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
                    }
                }
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        hotKey = HotKey(keyCombo: KeyCombo(key: .space, modifiers: [.shift, .command]))
        
        // Create the SwiftUI view that provides the contents
        store = Store(managedObjectContext: persistentContainer.viewContext)
        
        WatchPasteboard {
            self.store!.createItem(text: $0)
        }
        
        let contentView = MenuView(store: store!)
            .frame(height: 360)

        popover.animates = true
        popover.behavior = .transient
        
        // Set the SwiftUI's ContentView to the Popover's ContentViewController
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = NSHostingView(rootView: contentView)
        popover.contentViewController?.view.window?.makeKey()
        
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let MenuButton = statusItem?.button {
            MenuButton.image = NSImage(systemSymbolName: "icloud.and.arrow.up.fill", accessibilityDescription: nil)
            MenuButton.action = #selector(MenuToggleButton)
            
        }
    }
    
    @objc func MenuToggleButton(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let menuButton = statusItem?.button {
                self.popover.show(relativeTo: menuButton.bounds, of: menuButton, preferredEdge: NSRectEdge.minY)
            }
        }
        
    }
}

@main
struct PerfectClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 300, height: 300)
        }
    }
}
