//
//  Users.swift
//  JSONRESTful
//
//  Created by Willian Kana Choquenaira on 8/11/24.
//

import Foundation
struct Users:Decodable{
    let id:Int
    let nombre:String
    let clave:String
    let email:String
}
