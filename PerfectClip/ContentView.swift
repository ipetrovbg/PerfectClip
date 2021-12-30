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
        
            Text("Perfect Clipboard Manager")
                .font(.headline)
                .padding(.bottom)
            HStack {
            Text("Shortcut:")
                    .font(.caption)
                Text("Cmd + Shift + Space")
                    .font(.subheadline)
                
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
