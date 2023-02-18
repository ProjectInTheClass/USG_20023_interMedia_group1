//
//  User.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/08.
//  로그인과 회원가입에서 겹치는 부분이 많아 간단하게 정리하기 위하여 가져옴.

import Foundation
import SwiftUI

final class User: ObservableObject {
    
    @AppStorage("userToken") var userToken: String = UserDefaults.standard.string(forKey: "userToken") ?? ""
    @AppStorage("userName") var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @AppStorage("UserId") var UserId: String = UserDefaults.standard.string(forKey: "UserId") ?? ""
    
    @Published var loginSuccess: Bool = false
    @Published var signupSuccess: Bool = false
    @Published var messages = ""
    @Published var detailViewProgress = false
    
    //MARK: - 로그인과 회원가입
    func login(id: String, pw: String) {
        let loginInfo = loginInfo(id: id, password: pw)
        let loginData: Data = try! JSONEncoder().encode(loginInfo)
        let sel = "login"
        Postuserinfo(sel: sel, bodyData: loginData, userIds: id)
    }
    
    func signUp(id: String, pw: String, name: String) {
        let signupInfo = signupInfo(id: id, password: pw, name: name)
        let signupData: Data = try! JSONEncoder().encode(signupInfo)
        let sel = "signup"
        Postuserinfo(sel: sel, bodyData: signupData, userIds: id)
    }
    
    // sel 에 따라 url이 달라지기 때문에 sel을 프로퍼티로 받아오고 관련 데이터르 가져와 바디
    func Postuserinfo(sel: String, bodyData: Data, userIds: String){
        let url = URL(string: "http://mynf.codershigh.com:8080/api/auth/\(sel)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        request.httpBody = bodyData
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

                    // 로그인 메세지에 따른 유저와의 상화작용이 필요하여 대응 메세지를 작성하였다.
                    if message == "유저 없음" {
                        self.UserId = ""
                        self.messages = "아이디가 일치하지 않습니다."
                        return
                    } else if message == "로그인 실패"{
                        self.UserId = ""
                        self.messages = "비밀 번호가 없거나 일치하지 않습니다."
                        return
                        
                    // 회원 가입 대응 메세지
                    } else if message == "이미 등록된 유저가 있습니다." {
                        self.UserId = ""
                        self.messages = "이미 동록된 아이디 입니다."
                        self.signupSuccess = false
                        return
                        
                    // 로그인 성공 & 회원가입 성공
                    } else if message == "ok" {
                        self.userToken = responses.data?.token ?? "nil"
                        self.userName = responses.data?.name ?? "nil"
                        print(self.userToken)
                        self.UserId = userIds
                        self.loginSuccess = true
                        if !self.signupSuccess {
                            self.signupSuccess = true
                        }
                    } else {
                        self.messages = message
                        self.UserId = ""
                        self.signupSuccess = false
                        
                    }
                }
            }
            catch{
            }
        }
        task.resume()
    }
    
    
    //MARK: - 댓글 POST
    func commentWrite(id: String, rating: Float, text: String) {
        let comment = commentWriting(rating: rating, text: text)
        let data = try! JSONEncoder().encode(comment)
        let url = URL(string: "http://mynf.codershigh.com:8080/api/movies/\(id)/comments")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        //로그인시 받아온 토큰을 http 헤더에 보내주어야함.
        // bearer YOUR-token -> API 서버에 인증 방법이 나와 있다.
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, Response, error in
            if error != nil || data == nil {
                print("error")
                return
            }
            do {
                let responses = try JSONDecoder().decode(commentResponse.self, from: data!)
                print(responses.message) // 에러만 나지 않는 다면 메세지 외 data를 저장할 필요가 없어 보여 저장하지 않았다.
                DispatchQueue.main.async {
                    self.detailViewProgress = true
                }
            }
            catch{
                
            }
        }
        task.resume()
    }
    
    func commentRemove(movieId: String, commentId: String) {
        let url = URL(string: "http://mynf.codershigh.com:8080/api/movies/\(movieId)/comments/\(commentId)/")
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        let task = URLSession.shared.dataTask(with: request) { data, URLResponse, error in
            if error != nil || data == nil {
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(commentResponse.self, from: data!)
                print(response.message)
                DispatchQueue.main.async {
                    print(self.detailViewProgress)
                    self.detailViewProgress = true
                    print(self.detailViewProgress)
                }
            }
            catch {
                print("캐치")
            }
        }
        task.resume()
    }
    
    func moviePost(image: Data, title: String, year: Int, genre: [String], actors: [String]) {
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let url = URL(string: "http://mynf.codershigh.com:8080/api/movies/")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-type")
        request.httpBody = createBody(boundary: boundary, dataDic: ["title": title, "year": year, "genre": genre, "actors": actors], imageData: image)
        //로그인시 받아온 토큰을 http 헤더에 보내주어야함.
        // bearer YOUR-token -> API 서버에 인증 방법이 나와 있다.
        request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, Response, error in
            if error != nil || data == nil {
                print("error")
                return
            }
            do {
                let responses = try JSONDecoder().decode(commentResponse.self, from: data!)
                print(responses.message) // 에러만 나지 않는 다면 메세지 외 data를 저장할 필요가 없어 보여 저장하지 않았다.
            }
            catch{
                
            }
        }
        task.resume()
    }
    
    func createBody(boundary: String, dataDic: [String: Any], imageData: Data) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        for (key, value) in dataDic {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"poster\"\r\n\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
}

