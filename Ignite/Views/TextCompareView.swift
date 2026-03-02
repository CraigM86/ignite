//
//  TextCompareView.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import SwiftUI

struct TextCompareView: View {
    let header: String
    @Binding var storedArray: [String]
    @Binding var selectedIndex: Int
    @Binding var bedrockField: String
    let height: CGFloat
    
    
    var body: some View {
        GeometryReader { reader in
            VStack {
                HStack {
                    Text(header)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.igniteWhite)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                
                HStack(spacing: 32) {
                    TextEditor(text: $bedrockField)
                        .font(.body)
                        .foregroundStyle(.ignitePink)
                        .scrollContentBackground(.hidden)
                        .padding(6) // Adds internal spacing (the "box" feel)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .frame(height: height)
                        .background(.ignitePink.opacity(0.3))
                        .cornerRadius(8)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                storedArray.append(bedrockField)
                                selectedIndex = storedArray.count - 1
                                bedrockField = ""
                            } label: {
                                Image(systemName: "arrow.right")
                                    .font(.callout)
                                    .foregroundStyle(.white)
                                    .padding(8)
                            }
                        }
                    
                    Text(storedArray.isEmpty ? "" : storedArray[selectedIndex])
                        .font(.body)
                        .foregroundStyle(.igniteGreen)
                        .padding() // Adds internal spacing (the "box" feel)
                        .frame(maxWidth: .infinity, minHeight: height, alignment: .topLeading) // Sets the box size
                        .background(.igniteGreen.opacity(0.3))
                        .cornerRadius(8) // Rounded corners for a modern look
                        .textSelection(.enabled) // Optional: Allows users to copy the text
                        .overlay(alignment: .topTrailing) {
                            Menu {
                                ForEach(Array(storedArray.enumerated()), id: \.offset) { index, text in
                                    Button {
                                        selectedIndex = index
                                    } label: {
                                        HStack {
                                            Text("\(index + 1)")
                                            if selectedIndex == index {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                    
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .font(.callout)
                                    .foregroundStyle(.white)
                                    .padding(8)
                                    .padding(.top, 8)
                                
                            }
                        }
                }
                .frame(width: reader.size.width * 0.9)
            }
            
        }
        .padding()
    }
}
