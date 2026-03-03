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
        let first: Bool

        init(
            header: String,
            storedArray: Binding<[String]>,
            selectedIndex: Binding<Int>,
            bedrockField: Binding<String>,
            height: CGFloat,
            first: Bool = false
        ) {
            self.header = header
            self._storedArray = storedArray
            self._selectedIndex = selectedIndex
            self._bedrockField = bedrockField
            self.height = height
            self.first = first
        }
    
    
    var body: some View {
        VStack {
            HStack {
                Text(header)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.igniteWhite)
                    .padding(.horizontal)
                
                if first {
                    Image(systemName: "wand.and.stars")
                        .font(.title)
                        .foregroundStyle(.ignitePink)
                        .padding(.leading, 150)
                    
                    Text("AI Enabled")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.ignitePink)
                    
                }
                Spacer()
            }
            
            HStack(spacing: 48) {
                TextEditor(text: $bedrockField)
                    .font(.title3)
                    .foregroundStyle(.ignitePink)
                    .scrollContentBackground(.hidden)
                    .padding(6)
                    .padding(.trailing, 48)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(height: height)
                    .background(.ignitePink.opacity(0.4))
                    .cornerRadius(8)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            storedArray.append(bedrockField)
                            selectedIndex = storedArray.count - 1
                            bedrockField = ""
                        } label: {
                            Image(systemName: "arrow.right")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(8)
                        }
                    }
                
                Text(storedArray.isEmpty ? "" : storedArray[selectedIndex])
                    .font(.title2)
                    .foregroundStyle(.igniteWhite)
                    .padding()
                    .padding(.trailing, 48)
                    .frame(maxWidth: .infinity, minHeight: height, alignment: .topLeading)
                    .background(.igniteGreen.opacity(0.4))
                    .cornerRadius(8)
                    .textSelection(.enabled)
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
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(8)
                                .padding(.top, 8)
                            
                        }
                    }
            }
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 24)
    }
}
