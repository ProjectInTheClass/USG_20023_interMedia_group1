//
//  AllDataStruct.swift
//  USG_2023_intermediate_group1
//
//  Created by 안병욱 on 2023/02/17.
//

import Foundation
//MARK: ActorView()
struct AcotorResponse: Decodable{
    let message: String
    let actor: Actors?
    let filmography: [Filmography]?
    
    enum CodingKeys: String, CodingKey {
        case message
        
        case data
        case actor
        case filmography
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decode(String.self, forKey: .message)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.actor = try? dataContainer.decode(Actors.self, forKey: .actor)
        self.filmography = try? dataContainer.decode([Filmography].self, forKey: .filmography)
    }
}

struct Filmography: Codable {
    let _id: String
    let title: String
    let year: Int
    let image: String
}


//MARK: 영화 아이디로 받아온 데이터 디코딩(DetailView())
struct RespoMovie: Decodable {
    let _id: String
    let title: String
    let year: Int?
    let image: String?
    let genre: [String]
    let actors: [Actors]
    let comments: [Comment]
    
    enum CodingKeys :String, CodingKey {
        case _id
        case title
        case year
        case image
        case genre
        case actors
        case comments
        
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dataContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self._id = try dataContainer.decode(String.self, forKey: ._id)
        self.title = try dataContainer.decode(String.self, forKey: .title)
        self.year = try dataContainer.decode(Int.self, forKey: .year)
        self.image = try? dataContainer.decode(String.self, forKey: .image)
        self.genre = try dataContainer.decode([String].self, forKey: .genre)
        self.actors = try dataContainer.decode([Actors].self, forKey: .actors)
        self.comments = try dataContainer.decode([Comment].self, forKey: .comments)
    }
}
struct Actors: Codable {
    let _id: String
    let name: String
    let image: String
}

struct Comment: Codable {
    let _id: String
    let userId: String
    let name: String
    let text: String
    let rating: Float
}

//MARK: 장르 검색(MoviewFunction(), User(), HomeRecommandMovie())
struct Response: Decodable {
    let message: String
    let data: [Movie]
    let total: Int
    let skip: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case data
        case total
        case skip
        
        case paging
    }
    
    init(from decoder: Decoder) throws {
        let Contaniner = try decoder.container(keyedBy: CodingKeys.self)
        self.data = try Contaniner.decode([Movie].self, forKey: .data)
        self.message = try Contaniner.decode(String.self, forKey: .message)
        
        let pagingContainer = try Contaniner.nestedContainer(keyedBy: CodingKeys.self, forKey: .paging)
        self.total = try pagingContainer.decode(Int.self, forKey: .total)
        self.skip = try pagingContainer.decode(Int.self, forKey: .skip)
    }
}

struct Movie: Codable, Hashable {
    let title: String
    let _id: String
    let image: String?
    let genre: [String]
}

//MARK: User()
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

//MARK: 총장르 가져옴 MovieFunction()
struct genreRespo: Decodable {
    let message: String
    let data: [String]
}

struct savingMovie: Codable {
    let message: String
    let data: [Movie]
}
