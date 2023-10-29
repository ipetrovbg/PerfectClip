//
//  ContentView.swift
//  PerfectClip
//
//  Created by Petar Petrov on 12.12.21.
//

import SwiftUI


struct ContentView: View {
    @State var selectedView = "clips"
    var screen = NSScreen.main!.visibleFrame
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                VStack(spacing: 0) {
                    
                    TabButton(selected: $selectedView, title: "Clips", icon: "paperclip.circle.fill", id: "clips")
//                        .border(width: 1, edges: [.bottom], color: .white)
                    

                    TabButton(selected: $selectedView, title: "About", icon: "paperclip.circle.fill", id: "about")
//                        .border(width: 1, edges: [.bottom], color: .white)
                    
                    
                }
                Spacer()
            }
            .background(Color.accentColor)
            
            ZStack {
                switch selectedView {
                case "about":
                    HomeView()
                case "clips":
                    ClipsListView()
                default: HomeView()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)

        }
        
        .frame(minWidth: 500, minHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
