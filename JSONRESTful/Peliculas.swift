//
//  Peliculas.swift
//  JSONRESTful
//
//  Created by Willian Kana Choquenaira on 8/11/24.
//

import Foundation
struct Peliculas:Decodable {
    let usuarioId:Int
    let id:Int
    let nombre:String
    let genero:String
    let duracion:String
}
