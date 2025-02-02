//
//  ContactFormView.swift
//  SwiftUI_ContactForm_CleanArchitecture
//
//  Created by Hiroaki-Hirabayashi on 2021/12/22.
//

import SwiftUI

struct ContactFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var needShowAlert: Bool
    @State var errorAlert = false
    @ObservedObject var viewModel = ContactFormViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.viewBackground.ignoresSafeArea()
                VStack {
                    Spacer()
                        .frame(height: 35)
                    Text("ContactFormView_GuideText".localizedString)
                        .font(Font.system(size: 16))
                        .frame(width: 327, height: 42)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    HStack {
                        Text("ContactFormView_ContentsText".localizedString)
                            .font(Font.system(size: 13))
                            .frame(width: 350, height: 18, alignment: .leading)
                            .foregroundColor(.secondary)
                        Spacer()
                            .frame(width: 5)
                    }
                    
                    Spacer()
                        .frame(height: 8)
                    
                    PlaceHolderTextEditor(
                        placeholderText: "ContactFormView_ContentsTextPlaceholder"
                            .localizedString,
                        text: $viewModel.text
                    )
                    
                        .keyboardType(.default)
                        .background(Color.white)
                    //                    var text = viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines)
                    Text("\(countText(text:viewModel.text) ) / 4,000")
                    
                    //                    if !self.viewModel.text.isEmpty || viewModel.text.count > 4000 {
                    //                        Text("\(viewModel.text.count.trimmingCharacters(in: .whitespacesAndNewlines))/4000")
                    //                            .foregroundColor(.red)
                    
                    
                }
                Spacer()
            }
            .onAppear {
                self.needShowAlert = false
            }
            .navigationBarTitle(
                Text("ContactFormView_BarTitle".localizedString),
                displayMode: .inline
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("ContactFormView_Cancel".localizedString)
                            .font(Font.system(size: 17))
                            .foregroundColor(Color.viewButtton)
                    }
                    .accessibilityIdentifier("ContactFormView_CloseButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.sendInquiry { error in
                            let isError = error != nil
                            errorAlert = isError
                            self.needShowAlert = !isError
                            
                            if !isError {
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                        }
                    }) {
                        Text("ContactFormView_SendButton".localizedString)
                            .font(Font.system(size: 17))
                            .bold()
                            .foregroundColor(viewModel.toValidation ? .gray : Color.viewButtton)
                    }
                    .disabled(viewModel.toValidation)
                    .alert(isPresented: $errorAlert) {
                        showErrorAlert()
                    }
                    .accessibilityIdentifier("ContactFormView_SendButton")
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
            )
        }
    }
}

func countText(text: String) -> Float {
    let charCount = Float(text.count)
    let halfSizeCharCount:Float = Float(text.halfSizeCharsCount())
    let lineFeedCount:Float = Float(text.lineFeedCount())
    var count: Float = charCount - halfSizeCharCount - lineFeedCount
    
    
    return count
}



func showErrorAlert() -> Alert {
    Alert(
        title: Text("ContactSendErrorAlert_Title".localizedString),
        message: Text("ContactSendErrorAlert_Message".localizedString),
        dismissButton: .default(Text("ErrorAlertButton_OK".localizedString))
    )
}


struct ContactFormView_Previews: PreviewProvider {
    static var previews: some View {
        ContactFormView(needShowAlert: Binding<Bool>.constant(false))
    }
}

extension String {
    // 半角文字が存在する場合、その文字数を返す
    func halfSizeCharsCount() -> Int {
        let pattern = "[ -~]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matches(in: self, options: [], range: NSRange(0..<self.count))
        return results.count
    }
    // 改行コードが存在する場合、その文字数を返す
    func lineFeedCount() -> Int {
        let pattern = "[\n]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matches(in: self, options: [], range: NSRange(0..<self.count))
        return results.count
    }
}
