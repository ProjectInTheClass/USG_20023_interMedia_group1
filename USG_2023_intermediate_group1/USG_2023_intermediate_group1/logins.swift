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
            //로그인 성공시 전 네비게이션 뷰로 넘어감(dismiss)
            if user.loginSuccess {
                Text("Dismiss")
                    .onAppear(){
                        user.loginSuccess = false
                        dismiss()
                    }
            }
            //MARK: 로그인 뷰
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
                //로그인 반응 메세지
                Text(user.messages)
                    .foregroundColor(.red)
                    .animation(.easeOut(duration: 0.25), value: user.messages)
            }
        }
    }
}
//MARK: 주희님이 만드실 프로필 임시 뷰

struct loginpage: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("UserId") var UserId: String = UserDefaults.standard.string(forKey: "UserId") ?? ""
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                if !UserId.isEmpty {
                    VStack{
                        Text("\(UserId)로 로그인 됨.")
                        Button {
                            UserId = ""
                        } label: {
                            Text("로그아웃")
                                .foregroundColor(.red)
                        }
                    }
                    
                } else {
                    logins()
                }
                VStack{
                    Button {
                        dismiss()
                    } label: {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 0){
                                Image(systemName: "chevron.backward")
                                    .foregroundColor(.white)
                                    .padding(10)
                                Text("Back")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .frame(width: geometry.size.width)
                            .bold()
                        }
                    }
                    .background(.thickMaterial)
                    Spacer()
                }
            }.toolbar(.hidden)
        }
    }
}
//MARK: 회원 가입 뷰
struct signUps: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var userId: String
    @Binding var userPw: String
    @State var name: String = ""
    
    @StateObject var user = User()
    var body: some View {
        VStack{
            //회원 가입 완료되면 전 뷰로 돌아감 Dissmiss
            if user.signupSuccess {
                Text("Dismiss")
                    .onAppear(){
                        user.signupSuccess = false
                        dismiss()
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
                        .modifier(PlaceholderStyle(showPlaceHolder: name.isEmpty, placeholder: "이름"))
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
