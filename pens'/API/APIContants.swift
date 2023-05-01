//
//  APIContants.swift
//  pens'
//
//  Created by 박상준 on 2023/03/31.
//

import Foundation

struct APIContants{
    //고정ip
    static let baseURL = "http://13.125.106.204:8080"
    //login 로그인
    static let loginURL = baseURL + "/login"
    //register 회원가입
    static let registerURL = baseURL + "/register"
    //group create 그룹 생성
    static let groupCreateURL = baseURL + "/group/create";
    //group delete 그룹 삭제
    static let groupDeleteURL = baseURL + "/group/delete";
    //user groups 유저 그룹 목록
    static let userGroupsURL = baseURL + "/user/groups";
    //group add-user 그룹 유저 추가
    static let groupAddUserURL = baseURL + "/group/add-user";
    //group users 그룹 유저 목록
    static let groupUsersURL = baseURL + "/group/users";
    //group delete-user 그룹 유저 삭제 (나가기)
    static let groupDeleteUserURL = baseURL + "/group/delete-user";
    //group isAdmin 그룹 방장 확인
    static let groupIsAdminURL = baseURL + "/group/isAdmin";
    //group invite 그룹 초대
    static let groupInviteURL = baseURL + "/group/invite";
}
