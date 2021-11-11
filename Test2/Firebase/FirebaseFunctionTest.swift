//
//  FirebaseFunctionTest.swift
//  Test2
//
//  Created by maciulek on 10/11/2021.
//

import Foundation
import FirebaseFunctions
/*
func FBTestFunction(textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void) {
    FireB.shared.functions.httpsCallable("translateTextSimple").call(["text": textToTranslate, "targetLanguage": targetLanguage]) { result, error in
        if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
                let code = FunctionsErrorCode(rawValue: error.code)
                let message = error.localizedDescription
                let details = error.userInfo[FunctionsErrorDetailsKey]
            }
        }
        //if let data = result?.data as? [String: Any], let text = data["text"] as? String {
        if let data = result?.data as? [String: Any] {
            print(data)
            completionHandler(data["firstText"] as? String)
        }
    }
}
*/
