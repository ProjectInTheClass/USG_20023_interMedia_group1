//
//  User.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/08.
//

import Foundation
import SwiftUI

class User: ObservableObject {
    
    @AppStorage("userToken") var userToken: String = UserDefaults.standard.string(forKey: "userToken") ?? ""
    @AppStorage("userName") var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @AppStorage("UserId") var UserId: String = UserDefaults.standard.string(forKey: "UserId") ?? ""
    
    @Published var loginSuccess: Bool = false
    @Published var signupSuccess: Bool = false
    @Published var messages = ""
    
    func login(id: String, pw: String) {
        let loginInfo = loginInfo(id: id, password: pw)
        let loginData: Data = try! JSONEncoder().encode(loginInfo)
        let sel = "login"
        Postuserinfo(sel: sel, loginData: loginData, uid: id)
    }
    
    func signUp(id: String, pw: String, name: String) {
        let signupInfo = signupInfo(id: id, password: pw, name: name)
        let signupData: Data = try! JSONEncoder().encode(signupInfo)
        let sel = "signup"
        Postuserinfo(sel: sel, loginData: signupData, uid: id)
    }
    
    func Postuserinfo(sel: String, loginData: Data, uid: String){
        let url = URL(string: "http://mynf.codershigh.com:8080/api/auth/\(sel)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        request.httpBody = loginData
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil || data == nil {
                print("error")
                return
            }
            do {
                let responses = try JSONDecoder().decode(loginResponse.self, from: data!)
                print(responses.message)
                let message = responses.message
                DispatchQueue.main.async {
                    if message == "유저 없음" {
                        self.UserId = ""
                        self.messages = "아이디가 일치하지 않습니다."
                        return
                    } else if message == "로그인 실패"{
                        print("로그인 실패!")
                        
                        self.UserId = ""
                        self.messages = "비밀 번호가 없거나 일치하지 않습니다."
                        
                        return
                    } else if message == "ok" {
                        print("로그인 성공!")
                        
                        self.userToken = responses.data?.token ?? "nil"
                        self.userName = responses.data?.name ?? "nil"
                        print(self.userToken)
                        self.UserId = uid
                        self.loginSuccess = true
                        
                    } else if message == "ok" {
                        print("가입 성공!")
                        
                        self.signupSuccess = true
                        
                    } else if message == "이미 등록된 유저가 있습니다." {
                        print("이미 동록된 아이디 입니다.")
                        self.UserId = ""
                        self.messages = "이미 동록된 아이디 입니다."
                        return
                    } else {
                        self.messages = message
                        self.UserId = ""
                    }
                }
            }
            catch{
                print("error1")
            }
        }
        task.resume()
    }
    
    func commentWrite(id: String, rating: Float, text: String) {
        let comment = commentWriting(rating: rating, text: text)
        let data = try! JSONEncoder().encode(comment)
        let url = URL(string: "http://mynf.codershigh.com:8080/api/Movies/\(id)/comments")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, Response, error in
            if error != nil || data == nil {
                print("error")
                return
            }
            do {
                let responses = try JSONDecoder().decode(commentResponse.self, from: data!)
                print("comment did")
                print(responses.message)
            }
            catch{
                
            }
        }
        task.resume()
        
    }
}


struct signupInfo: Codable {
    let id: String
    let password: String
    let name: String
}

struct loginInfo: Codable {
    let id: String
    let password: String
}

struct loginResponse: Decodable {
    let message: String
    let data: loginResponseData?
}

struct loginResponseData: Codable {
    let token: String?
    let name: String
    let isAdmin: Bool?
    let _id: String?
}

struct commentWriting: Codable {
    let rating: Float
    let text: String
}

struct commentResponse: Codable {
    let message: String
}
