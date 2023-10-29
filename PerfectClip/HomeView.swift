//
//  HomeView.swift
//  PerfectClip
//
//  Created by Petar Petrov on 19.02.22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Group {
            VStack {
                VStack {
                    
                    Image(systemName: "paperclip.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.bottom)
                        .foregroundColor(.secondary)
                    
                    Text("Perfect Clipboard Manager")
                        .font(.headline)
                        .padding(.bottom)
                        .foregroundColor(.secondary)
                    
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
        .navigationTitle("About")
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
