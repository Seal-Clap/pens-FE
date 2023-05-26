//
//  APIContants.swift
//  pens'
//
//  Created by 박상준 on 2023/03/31.
//

import Foundation

struct APIContants{
    //basic IP
    static let baseURL = "http://13.209.120.19:8080"
    //login
    static let loginURL = baseURL + "/users/login"
    //register
    static let registerURL = baseURL + "/users/register"
    //login token
    static let tokenURL = baseURL + "/users/identity"
    //group create 그룹 생성
    static let groupCreateURL = baseURL + "/group/create";
    //group delete 그룹 삭제
    static let groupDeleteURL = baseURL + "/group/delete";
    //user groups 유저 그룹 목록
    static let usersGroupsURL = baseURL + "/users/groups";
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
    // file upload
    static let fileUploadURL = baseURL + "/file/upload"
    //file 목록 확인
    static let fileListURL = baseURL + "/file"
    //file 다운로드
    static let fileDownloadURl = baseURL + "/file/download"
    // signaling server
    static let signalingServerURL = "ws://13.209.120.19:8080/ws/signal"
    // drawing server
    static let drawingServerURL = "ws://13.209.120.19:8080/ws/draw"
    // get channels by groupId
    static let channelURL = baseURL + "/channels"
    //
    static let enterChannelURL = baseURL + "/channels/enter"
    //
    static let leaveChannelURL = baseURL + "/channels/leave"
}
