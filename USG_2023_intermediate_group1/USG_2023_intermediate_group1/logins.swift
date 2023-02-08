//
//  lorgins.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/08.
//

import SwiftUI

struct logins: View {
    
    @AppStorage("UserId") var UserId: String = UserDefaults.standard.string(forKey: "UserId") ?? ""
    
    
    @State var userId: String = ""
    @State var userPw: String = ""
    
    @StateObject var user = User()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack{
            if user.loginSuccess {
                Text("Dismiss")
                    .onAppear(){
                        user.loginSuccess = false
                        dismiss()
                    }
            }
            VStack{
                Text("로그인")
                    .foregroundColor(.white)
                    .font(.title)
                    .bold()
                VStack{
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 40)
                        //.padding(.trailing,-5)
                            .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 1)))
                        TextField("", text: $userId)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                            .modifier(PlaceholderStyle(showPlaceHolder: userId.isEmpty, placeholder: "아이디"))
                            .padding(.horizontal, 10)
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .frame(height: 40)
                            //.padding(.trailing,-5)
                            .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 1)))
                        SecureField("", text: $userPw)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                            .modifier(PlaceholderStyle(showPlaceHolder: userPw.isEmpty, placeholder: "비밀번호"))
                            .padding(.horizontal, 10)
                    }
                }.padding()
                HStack{
                    Button {
                        user.login(id: self.userId, pw: self.userPw)
                    } label: {
                        Text("로그인")
                            .frame(width: 100, height: 30)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red.opacity(0.7))
                    .padding(.horizontal)
                    NavigationLink {
                        signUps(userId: $userId, userPw: $userPw)
                    } label: {
                        Text("회원가입")
                            .frame(width: 100, height: 30)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.secondary)
                    
                }.preferredColorScheme(.dark)
                Text(user.messages)
                    .foregroundColor(.red)
                    .animation(.easeOut(duration: 0.25), value: user.messages)
            }
        }
    }
}

struct loginpage: View {
    @AppStorage("UserId") var UserId: String = UserDefaults.standard.string(forKey: "UserId") ?? ""
    var body: some View {
        if !UserId.isEmpty {
            Text("\(UserId)로 로그인 됨.")
            Button {
                UserId = ""
            } label: {
                Text("로그아웃")
                    .foregroundColor(.red)
            }

        } else {
            logins()
        }
    }
}

struct signUps: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var userId: String
    @Binding var userPw: String
    @State var name: String = ""
    
    @StateObject var user = User()
    var body: some View {
        VStack{
            if user.signupSuccess {
                Text("Dismiss")
                    .onAppear(){
                        user.signupSuccess = false
                        dismiss()
                        print(user.signupSuccess)
                    }
            }
            Text("회원가입")
                .foregroundColor(.white)
                .font(.title)
                .bold()
            VStack{
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 40)
                    //.padding(.trailing,-5)
                        .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 1)))
                    TextField("", text: $userId)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .modifier(PlaceholderStyle(showPlaceHolder: userId.isEmpty, placeholder: "아이디"))
                        .padding(.horizontal, 10)
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 40)
                    //.padding(.trailing,-5)
                        .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 1)))
                    SecureField("", text: $userPw)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .modifier(PlaceholderStyle(showPlaceHolder: userPw.isEmpty, placeholder: "비밀번호"))
                        .padding(.horizontal, 10)
                }
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 40)
                    //.padding(.trailing,-5)
                        .foregroundColor(Color(UIColor(red: 67/255, green: 66/255, blue: 66/255, alpha: 1)))
                    TextField("", text: $name)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(.white)
                        .modifier(PlaceholderStyle(showPlaceHolder: userId.isEmpty, placeholder: "이름"))
                        .padding(.horizontal, 10)
                }
            }
            //.padding()
            Button {
                user.signUp(id: self.userId, pw: self.userPw, name: self.name)
                //dismiss()
            } label: {
                Text("회원가입")
                    .frame(width: 100, height: 30)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red.opacity(0.7))
            .padding(.top, 10)
            Text(user.messages)
                .foregroundColor(.red)
                .animation(.easeOut(duration: 0.25), value: user.messages)
        }
    }
}

struct lorgins_Previews: PreviewProvider {
    static var previews: some View {
        logins()
    }
}
