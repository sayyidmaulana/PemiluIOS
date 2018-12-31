//
//  ProfileInfoDummyData.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import Networking


enum ProfileHeaderItem: Int {
    case editProfile
    case editPassword
    case editDataLapor
    
    var title: String {
        switch self {
        case .editProfile:
            return "Edit Profile"
        case .editPassword:
            return "Ubah Sandi"
        case .editDataLapor:
            return "Ubah Data Lapor"
        }
    }
    
    var headerView: UIView? {
        switch self {
        case .editProfile:
            return HeaderEditProfile()
        case .editDataLapor:
            return HeaderDataLapor()
        default:
            return UIView()
        }
    }
    
    var sizeHeader: CGFloat {
        switch self {
        case .editProfile:
            return 140.0
        case .editDataLapor:
            return 82.0
        case .editPassword:
            return 0.0
        }
    }
}

final class ProfileInfoDummyData {
    static func profileInfoData(data: User, type: ProfileHeaderItem) -> Observable<[SectionOfProfileInfoData]> {
        let profileInformation = generateProfileInformation(data)
        let generateUbahSandiInformation = generateUbahSandi(data)
        let generateDataLaporInformation = generateDataLapor(data)
        
        var item: [SectionOfProfileInfoData] = []
        switch type {
        case .editProfile:
            item.append(SectionOfProfileInfoData(id: data.id,
                                                 items: profileInformation,
                                                 header: .editProfile))
        case .editPassword:
            item.append(SectionOfProfileInfoData(id: data.id,
                                                 items: generateUbahSandiInformation,
                                                 header: .editPassword))
        case .editDataLapor:
            item.append(SectionOfProfileInfoData(id: data.id,
                                                 items: generateDataLaporInformation,
                                                 header: .editDataLapor))
        }
        return Observable.just(item)
    }

    private static func generateProfileInformation(_ data: User) -> [ProfileInfoField] {
        var profileInformation: [ProfileInfoField] = []

        profileInformation.append(ProfileInfoField(
            key: "Nama",
            value: data.firstName,
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Username",
            value: data.username,
            fieldType: .username
        ))
        profileInformation.append(ProfileInfoField(
            key: "Lokasi",
            value: data.location,
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Deskripsi Tentang Kamu",
            value: data.about,
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Pendidikan",
            value: data.education,
            fieldType: .text
        ))
        profileInformation.append(ProfileInfoField(
            key: "Pekerjaan",
            value: data.occupation,
            fieldType: .text
        ))
        return profileInformation
    }
    
    private static func generateUbahSandi(_ data: User) -> [ProfileInfoField] {
        var sandiInformation: [ProfileInfoField] = []
        
        sandiInformation.append(ProfileInfoField(
            key: "Masukan Kata Sandi Lama",
            value: "123123",
            fieldType: .password
        ))
        
        sandiInformation.append(ProfileInfoField(
            key: "Kata Sandi Baru",
            value: "123123",
            fieldType: .password
        ))
        
        sandiInformation.append(ProfileInfoField(
            key: "Konfirmasi Kata Sandi Baru",
            value: "123123",
            fieldType: .password
        ))
        
        return sandiInformation
    }
    
    private static func generateDataLapor(_ data: User) -> [ProfileInfoField] {
        var dataLaporInformation: [ProfileInfoField] = []
        
        dataLaporInformation.append(ProfileInfoField(
            key: "No KTP/SIM/Pasport",
            value: "231312323",
            fieldType: .number
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: "Tempat Lahir",
            value: "Yogyakarta",
            fieldType: .text
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: "Jenis Kelamin",
            value: "Laki-laki",
            fieldType: .dropdown
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: "Pekerjaan",
            value: "PNS",
            fieldType: .text
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: "Kewarganegaraan",
            value: "Indonesia",
            fieldType: .text
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: "Alamat",
            value: "Jalan Viva La",
            fieldType: .text
        ))
        
        dataLaporInformation.append(ProfileInfoField(
            key: "No Tell/HP",
            value: "0239929333",
            fieldType: .text
        ))
        
        return dataLaporInformation
    }
}
