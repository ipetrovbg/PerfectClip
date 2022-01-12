//
//  ContentView.swift
//  PerfectClip
//
//  Created by Petar Petrov on 12.12.21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        VStack {
            
            Image(systemName: "paperclip.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.bottom)
            
            Text("Perfect Clipboard Manager")
                .font(.headline)
                .padding(.bottom)
            
        }
        .padding(.top)

        Spacer()
        
        VStack {
            
            HStack {
                Text("Shortcuts:")
                Spacer()
                
            }
            Divider()
            
            VStack {
                HStack {
                    Text("Cmd + Shift + Space")
                    Spacer()
                    Text("open the menu")
                        .font(.subheadline)
                    
                }
            }
            Divider()
            HStack {
                Text("↑↓ arrows")
                Spacer()
                Text("navigation")
                    .font(.subheadline)
            }
            Divider()
            VStack {
                HStack {
                    Text("Cmd + C")
                    Spacer()
                    Text("copy current item")
                        .font(.subheadline)
                    
                }
                
            }
        }.padding()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
