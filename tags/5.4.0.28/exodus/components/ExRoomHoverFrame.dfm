inherited ExRoomHoverFrame: TExRoomHoverFrame
  Width = 238
  Height = 190
  OnMouseEnter = TntFrameMouseEnter
  OnMouseLeave = TntFrameMouseLeave
  ExplicitWidth = 238
  ExplicitHeight = 190
  object imgRoom: TImage
    Left = 10
    Top = 10
    Width = 32
    Height = 32
    Picture.Data = {
      07544269746D617036040000424D360400000000000036000000280000001000
      0000100000000100200000000000000400000000000000000000000000000000
      0000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF009FACB9004C6279004C6279004C6279004C62
      79004C6279004C6279004C6279004C6279004C6279007E8C9B00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A8006DBBE6006ABAE6006ABAE6006ABA
      E6006ABAE6006ABAE6006ABAE6006ABAE6006ABAE6004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A80067B8E40067B8E40067B8E40067B8
      E40067B8E40067B8E40067B8E40067B8E40067B8E4004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A8005EAED70061B1DD0061B1DD0061B1
      DD0061B1DD0061B1DD0061B1DD0061B1DD0061B1DD004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A80058A6D5005EACD7005EACD7005EAC
      D7005EACD7005EACD7005EACD7005EACD7005EACD7004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A80057A2D1006A81B7007C5C9C006A81
      B70059A7D20059A7D20059A7D20059A7D20059A7D2004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A80065A9D2008567A3008B5E9C008567
      A30065A8D10065A8D10065A8D10065A8D10065A8D1004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A8006BABD0007C8EBC008D71A7007C8E
      BC006BABD0006BABD0006BABD0006BABD0006BABD0004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A80073AED10073AED10073AED10073AE
      D10073AED10073AED10073AED10073AED10073AED1004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A8007CB0D0007CB0D0007CB0D0007CB0
      D0007CB0D0007CB0D0007CB0D0007CB0D0007CB0D0004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A80086B5D20086B5D20086B5D20086B5
      D20086B5D20086B5D20086B5D20086B5D20086B5D2004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A8008EB8D3008DB8D3008DB8D3008DB8
      D3008DB8D3008DB8D3008DB8D3008DB8D3008DB8D3004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF008395A80095BBD40093BBD40093BBD40093BB
      D40093BBD40093BBD40093BBD40093BBD40095BCD4004A607700FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00899AAD007D90A4007D90A4007D90A4007D90
      A4007D90A4007D90A4007D90A4007D90A4007D90A400A6B2BF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00}
    Stretch = True
    Transparent = True
    OnMouseEnter = imgRoomMouseEnter
    OnMouseLeave = imgRoomMouseLeave
  end
  object RoomDisplayName: TTntLabel
    Left = 96
    Top = 10
    Width = 139
    Height = 16
    AutoSize = False
    Caption = 'Room name'
    EllipsisPosition = epWordEllipsis
    OnMouseEnter = RoomDisplayNameMouseEnter
    OnMouseLeave = RoomDisplayNameMouseLeave
  end
  object lblSubject: TTntLabel
    Left = 52
    Top = 32
    Width = 48
    Height = 16
    Caption = 'Subject:'
    OnMouseEnter = lblSubjectMouseEnter
    OnMouseLeave = lblSubjectMouseLeave
  end
  object lblAffiliation: TTntLabel
    Left = 52
    Top = 54
    Width = 58
    Height = 16
    Caption = 'Affiliation:'
    OnMouseMove = lblAffiliationMouseMove
    OnMouseLeave = lblAffiliationMouseLeave
  end
  object lblParticipants: TTntLabel
    Left = 52
    Top = 76
    Width = 71
    Height = 16
    Caption = 'Participants:'
    OnMouseEnter = lblParticipantsMouseEnter
    OnMouseLeave = lblParticipantsMouseLeave
  end
  object lblName: TTntLabel
    Left = 52
    Top = 10
    Width = 38
    Height = 16
    Caption = 'Name:'
    OnMouseEnter = lblSubjectMouseEnter
    OnMouseLeave = lblSubjectMouseLeave
  end
  object Subject: TTntLabel
    Left = 106
    Top = 32
    Width = 129
    Height = 16
    AutoSize = False
    Caption = 'Subject'
    EllipsisPosition = epWordEllipsis
    OnMouseEnter = lblSubjectMouseEnter
    OnMouseLeave = lblSubjectMouseLeave
  end
  object Affiliation: TTntLabel
    Left = 116
    Top = 54
    Width = 53
    Height = 16
    Caption = 'Affiliation'
    OnMouseEnter = lblSubjectMouseEnter
    OnMouseLeave = lblSubjectMouseLeave
  end
  object Participants: TTntLabel
    Left = 129
    Top = 76
    Width = 66
    Height = 16
    Caption = 'Participants'
    OnMouseEnter = lblSubjectMouseEnter
    OnMouseLeave = lblSubjectMouseLeave
  end
  object Separator1: TExGroupBox
    Left = 0
    Top = 88
    Width = 238
    Height = 102
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'lblCaption'
    Enabled = False
    ParentColor = True
    TabOrder = 4
    AutoHide = False
  end
  object chkAutoJoin: TCheckBox
    Left = 52
    Top = 168
    Width = 235
    Height = 17
    Caption = '   Auto Join'
    TabOrder = 0
    OnClick = chkAutoJoinClick
    OnMouseEnter = chkAutoJoinMouseEnter
    OnMouseLeave = chkAutoJoinMouseLeave
  end
  object btnDelete: TExGraphicButton
    Left = 44
    Top = 120
    Width = 183
    Height = 26
    BorderWidth = 0
    Caption = 'Delete'
    Orientation = gboRightOf
    ImageEnabled.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000001974455874536F6674776172650041646F626520496D616765526561
      647971C9653C000002D94944415478DA63FCFFFF3F032D01E3A80523D8820FF1
      1E271E9CBB69AEE8617CB4EC335FFCCC19F3EEA2ABF9BBBE5BEFE9A2FDB63F38
      B96FD7BE943EB4E9F8DA9FDFBF3DFE4F9405EFAC8DCE9CBDF9D898539C85814D
      42797B1FBF4CF28A752B9E83E4FECF2E66FA7CF29AF7BB77AF5BFF5FFB26D0A5
      A81577F117F3F99B17F77F7EFBE6D53FA22C38D596E97E6FCBF540E17BB7D2D8
      F8FE30FE6291D8BB585927454052FC69BFF887F2734B77957233B1726F3735EB
      5EF2E0C76A212EE63B7BF7AEFF44741069B9BAB1F2FFE611F0FCFFC5C7EDDBC3
      86EFAF3EC8F18BC99CE2D096B9FE75CF99F81F4CAC5FCFDA5ACE58F5E2C7F65F
      5F7EDC6465FAF5ECF8F1BDFF88B60004F44D9C985E7D61610C3312B28BBAF7A8
      FFC9ABFBFA6CCC7F198458793EAD95D5EFDBFFE3EF01CE3F5CF79F3F7BF5FCFE
      FD7DBF498A6474B0DFC57EE9B307B7A3787FFF646091927ABC5454ABF2EA9B2F
      7B1F5C7BF3FAC387937F494E4570B0BB4EF0CDCA0BDD9BD69E8893E1E2F8CFA2
      2A71FBE9C93B6A02462A7B1671C964AFDEBDEE3E3EEDF82DB83855E9C1D43D93
      37AF38EA25C7CAC6F0D2CB66EED2473FB6B83C7F64E5F6E349D1DB00A789DD57
      7F364B4BB27E5CB264D57FD22CB83687F7CD8EB3330F4DDE1AF2E9E977569970
      DBFD4DCF1826BF79FFEB9C9EB2F0A7C80737278B3E7EE6DCA8A2E97BF399F0C5
      07F79691180787FA0CCE264E3C7FF1C71F062311DED7CBE4357A0FBCFDBDEDF5
      33D55BF7EF4FF8B9AE28CA5BF6D0B5898F15C5B7175FE4AFB97F6BD547922C98
      9CE8A6E476FAE1828FCF3F5A72C43B9D2DB9F6B3E5F58B8F27CF5FD8F31A243F
      BDA54AC0E5CEF5D21FBCCCEAD127BF147333FD797AFCC49E3F24C54181BB9F26
      F3C72F8EEFA584BF5F7FF3E7CCBBFF2F6FDF3C7CEC074C3E3128514498EF9FFA
      9E8BAF1FFFFDF3F3F9E5CB7B7F9364010898D83BB3FFFDCEC6C5CEC4F3FBFC35
      856F3F3F75A36426358350167EE91F2CB2ACEC3FD76D58F39F640B2805A3160C
      BC05005FD59BE043A847720000000049454E44AE426082}
    ImageDisabled.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000001974455874536F6674776172650041646F626520496D616765526561
      647971C9653C000002CC4944415478DAED93DD4F527118C7CFE128AF4B0E08A7
      6001BA9A0BAB8BD2292DCABAA9B636D7D64593F5175473FD015ED9D66C5E37DD
      6CAB8B36679473D3042175BC1C5051406D88F122F226E239470211388797E0C2
      8BBC70B0D5BAC8CFEDF37B7E9FED79BE0F582A9580BF09782AF88F051F86875E
      F87C3EA9FC726B601EB58E8D8C8CE0C7DF584D06D1BA63B519A4D1B039B3C53F
      A39B2910045EAA4AF07670B0D7E5769F67321940A340E876B85C9FD56A75B252
      FBA6F90A4643613986630FC82CC95CDBFC3146241291E5655B0EC3B0EA04EF86
      875ADCAE8D2BB94CA6138268209DC1F406A23B6A044192F7EF76DD311B4D5D4C
      26937E4092866587738DCD66E31ACD74B6EA11752A1450C39906A6442C928B84
      827B07C9142C4490105FD018DFF66FB5158A4592C6602C38D6D6DDB95C6EAFFC
      4FD2643296AA165450286E8087990CD8D1DED6DC241677878241114803016E03
      371BC53053301CF1B1586C22168BA59C4E7BA1A6251FA7BFAFAF673B10B8561E
      17C085E14420B2A389EDEE7A239168DAEFF7166B4ED111C6393D6BCBEB7FA8D3
      E9DB1AF97C80CB83319FC72B90C8641E97C73B313935499CD47FA260C5B6C077
      D8561E6935DA4B7C1E0F1088444B2BCED50D98C3699288CEDD128A45E679133A
      CBE3C1D9D1D1D1524D02A7DDC6F07BBC8FF533FAAB044E40D73BDA7D7346339A
      4A1D44643269567216795420C98B8E0DF7FB1C99DF4151636D3B58B29AC5139F
      BEBC8CC6624093549A0EC5E306DF56C04DA7B3309D6E3AFFFA55BF9C3ACC74E7
      81D2E6AC01D55A2CA66C4D82DEE7CFF808CC7BB2BFBF2F6B69958727B5BA591C
      C78356AB255DA9BF191860C11C765739AEC28F63EA2908827E96635AAC5A50E1
      A94A8550247501AAAFA3E27B58182770CC61B7E78FEAAA1E150786B9C2B5F5EF
      098AA2528B8B0B859A04156E2A95752000D6972FB5904E93148ACEFFD6A054DE
      A6D5D543B472080AE3E3E3B51DDA9FE054F0EF05BF00DF149FE09C0FAB970000
      000049454E44AE426082}
    ImagePushed.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000001974455874536F6674776172650041646F626520496D616765526561
      647971C9653C000002CC4944415478DAED93DD4F527118C7CFE128AF4B0E08A7
      6001BA9A0BAB8BD2292DCABAA9B636D7D64593F5175473FD015ED9D66C5E37DD
      6CAB8B36679473D3042175BC1C5051406D88F122F226E239470211388797E0C2
      8BBC70B0D5BAC8CFEDF37B7E9FED79BE0F582A9580BF09782AF88F051F86875E
      F87C3EA9FC726B601EB58E8D8C8CE0C7DF584D06D1BA63B519A4D1B039B3C53F
      A39B2910045EAA4AF07670B0D7E5769F67321940A340E876B85C9FD56A75B252
      FBA6F90A4643613986630FC82CC95CDBFC3146241291E5655B0EC3B0EA04EF86
      875ADCAE8D2BB94CA6138268209DC1F406A23B6A044192F7EF76DD311B4D5D4C
      26937E4092866587738DCD66E31ACD74B6EA11752A1450C39906A6442C928B84
      827B07C9142C4490105FD018DFF66FB5158A4592C6602C38D6D6DDB95C6EAFFC
      4FD2643296AA165450286E8087990CD8D1DED6DC241677878241114803016E03
      371BC53053301CF1B1586C22168BA59C4E7BA1A6251FA7BFAFAF673B10B8561E
      17C085E14420B2A389EDEE7A239168DAEFF7166B4ED111C6393D6BCBEB7FA8D3
      E9DB1AF97C80CB83319FC72B90C8641E97C73B313935499CD47FA260C5B6C077
      D8561E6935DA4B7C1E0F1088444B2BCED50D98C3699288CEDD128A45E679133A
      CBE3C1D9D1D1D1524D02A7DDC6F07BBC8FF533FAAB044E40D73BDA7D7346339A
      4A1D44643269567216795420C98B8E0DF7FB1C99DF4151636D3B58B29AC5139F
      BEBC8CC6624093549A0EC5E306DF56C04DA7B3309D6E3AFFFA55BF9C3ACC74E7
      81D2E6AC01D55A2CA66C4D82DEE7CFF808CC7BB2BFBF2F6B69958727B5BA591C
      C78356AB255DA9BF191860C11C765739AEC28F63EA2908827E96635AAC5A50E1
      A94A8550247501AAAFA3E27B58182770CC61B7E78FEAAA1E150786B9C2B5F5EF
      098AA2528B8B0B859A04156E2A95752000D6972FB5904E93148ACEFFD6A054DE
      A6D5D543B472080AE3E3E3B51DDA9FE054F0EF05BF00DF149FE09C0FAB970000
      000049454E44AE426082}
    OnClick = btnDeleteClick
    OnMouseEnter = btnDeleteMouseEnter
    OnMouseLeave = btnDeleteMouseLeave
  end
  object btnRename: TExGraphicButton
    Left = 44
    Top = 98
    Width = 183
    Height = 26
    BorderWidth = 0
    Caption = 'Rename'
    Orientation = gboRightOf
    ImageEnabled.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000001974455874536F6674776172650041646F626520496D616765526561
      647971C9653C000002F74944415478DADD955D48536118C7FFDB596E657E4C33
      757E65CA0A9D9A4C8A202A83EC4221442BEFEA46C2424AB10FC2C83E2E0AA92E
      2C8330D0C08B504BBD288BCC2E12C954C26C448ACE69EAD6E6DCCEDCD934777A
      0E4E305037C52EEA853FEF39E7799FFFEFBCDF229EE7F1378BE8FF038844224F
      390CC9872424CE92E6966AB4E0BB5A009308049589C5D5329E1FBDCEF397BB00
      0B7D77AD07804902E4456271F9919D312783CC56FECDB8A9F828504531BBBB47
      6B06307B81E07C09732B4319991F62B6C1386EC20805BE01A74F01B5F4C82DEE
      C96A004C1A0D4B818429CB888F38136E73606CD4002D0514A4C17915D688C5B5
      1D2E9775614EBC05302940E0390973ED709CA250C1CD40A7D3638C0221241D49
      70F423F5496577EA9355E5ED9FBACC424FBC01888E035B32818BE9718A928839
      1786B413D053209824404CA400928CD42F91602C3BFBEED5BABA527A75780360
      8A95112927B60674ABF52C06FA4760761B0A10032908F3EB75807286C8A71D78
      D906E47805C848DFE59F97BBAF4019B8F97668DB30D8E6D7901A26F1936213EE
      2112368496DA7FA7BA83E7ABC9BC881E59611E3C0118B52A26B4FC52DE97D068
      55906BA32FF0B401EC93E718E63884BADB8D52ADA1FC8FB454DF0125F46AF366
      9245590755817959BB6F6E8B8E3AAB884C85DD3109D66284A5BE15B286F79873
      38314E803ECAED042AC9FCCA62738F809CCCFD5105B969838AE824862723CE62
      00CB4DC2C1B110B5F4C0DAF2195D2C07DAC515645EEA36FF6337AF04F079585E
      7A28217CE655648C1AAC7502D3163D1C76236CD3364C1959F43CEE40A7DE78A3
      17B8C7CD8FF9AA8E0ABFA6CAF31FA2A2139237D012E1A68D304E8C6064400BFB
      B41DAC5DFA7656AE795051FDA375CAC2DB9732F704905F38966ADCAE4C16EF88
      8F80A6A71BBF661D0E13CB3DD34F595FF886EFF97ABFAA46D863C249BAEC59BF
      12C0FF40ACD4101B132651272A9D4E99BCD9220D7BD4ABD1F5353536B2EE8974
      C143590920A16A1349E23612FED4E936F6FA765AEB7DE0755916B0DEE5DF07FC
      0676489AE0C7304DD90000000049454E44AE426082}
    ImageDisabled.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000001974455874536F6674776172650041646F626520496D616765526561
      647971C9653C000002FB4944415478DADD95DD4B53611CC77FE76C736F4A98B8
      5CE268736B2E26BAB1D6CB2608954C33220AFA07BA0CC2E8AAABE8A6BAAA08AC
      2EA3DB4162F64246A288B4244B73546AAE6DC7B3339DDB3967736F6EDAF31C27
      84669BBD5CD4033F38F09CDFF7F37BBEBFE785585D5D85BF3988FF0F401044B1
      1C128508054E5C29C4A6B1AEBB5D00B9ABBA5A71A4A5E5AC442CE65E0E0D3D99
      63987401F6DB00B246A5923BEDF64E9BD56A13A1FF26BCDEDE876EB707CD2D6F
      846C17406A6A6B15768BA5DD6A693E502612432412012E1E8785C545B7BBAF6F
      6C23643B00B2B6A64671D0666BB336371D56486510621860390E2ACACB21CAB2
      1063D947EF2627C7FC149559EF49A90052AD52C91C767B9BA5B9C9A994C9618E
      A68147952B150AE0781ED2990C48A5528844A30361961DF0783CA935FDE200A2
      D164521AF5FAD626B3B9B542A984204541626909147239C4130948A65282386A
      B8B012B5463378A7BBFB19CACD9502205DC78EAAF75B2C5DD5953BC1E7F3412A
      9D061912C490A56412E408242249411C873F18FC381B083C2809E07438641D1D
      AE43BBD5EAE3F94C163E4D7A61399B158471F5D8221289C7502F903D10A0A851
      24DE8B52853E140390FB4CA6F28B5D172E69753A85582281CF0830F1760CEF1A
      C076E1FFF02E0A2F2C0045D39E2F7EFF6394972DA5C9448BD32173B9DA5C9A3A
      8DC3B0D7083CCF018B2CC0ABA003416125716413160FD2F4C8ACDFFFF47BF1A2
      80F676D78E93273A2FEB0D067C2D08E21CC74212D9C35034047C5FB1DF30170A
      0DA3CA9F176C29F9A0896E5CBF66A8AAAA3C6734364014F91B43C1C7794820EF
      798E87D1D76F606A66A69F999F1F5CCEE536891703486FDFBA795E5F5FAF1689
      45A8720E985008028180B0827C7E653A3C1F1A7ED1FF6A26954A677F245E0C20
      3F73FAD4D5066303A1D56961627C1CB2D96C0E1DAEF7D1C5E8873D5A6DF8EEBD
      FBB182DF5BDEF53F03C8F43AED953A4D1DD96836E7D10EF28A2565235353D34C
      4F4F4FA698702900DCD83258BBF7F1641E1F9CC277C9AFD3AFBE07258F2D017F
      7AFCFB806FEC97DAE061B3B0100000000049454E44AE426082}
    ImagePushed.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000001974455874536F6674776172650041646F626520496D616765526561
      647971C9653C000002FB4944415478DADD95DD4B53611CC77FE76C736F4A98B8
      5CE268736B2E26BAB1D6CB2608954C33220AFA07BA0CC2E8AAABE8A6BAAA08AC
      2EA3DB4162F64246A288B4244B73546AAE6DC7B3339DDB3967736F6EDAF31C27
      84669BBD5CD4033F38F09CDFF7F37BBEBFE785585D5D85BF3988FF0F401044B1
      1C128508054E5C29C4A6B1AEBB5D00B9ABBA5A71A4A5E5AC442CE65E0E0D3D99
      63987401F6DB00B246A5923BEDF64E9BD56A13A1FF26BCDEDE876EB707CD2D6F
      846C17406A6A6B15768BA5DD6A693E502612432412012E1E8785C545B7BBAF6F
      6C23643B00B2B6A64671D0666BB336371D56486510621860390E2ACACB21CAB2
      1063D947EF2627C7FC149559EF49A90052AD52C91C767B9BA5B9C9A994C9618E
      A68147952B150AE0781ED2990C48A5528844A30361961DF0783CA935FDE200A2
      D164521AF5FAD626B3B9B542A984204541626909147239C4130948A65282386A
      B8B012B5463378A7BBFB19CACD9502205DC78EAAF75B2C5DD5953BC1E7F3412A
      9D061912C490A56412E408242249411C873F18FC381B083C2809E07438641D1D
      AE43BBD5EAE3F94C163E4D7A61399B158471F5D8221289C7502F903D10A0A851
      24DE8B52853E140390FB4CA6F28B5D172E69753A85582281CF0830F1760CEF1A
      C076E1FFF02E0A2F2C0045D39E2F7EFF6394972DA5C9448BD32173B9DA5C9A3A
      8DC3B0D7083CCF018B2CC0ABA003416125716413160FD2F4C8ACDFFFF47BF1A2
      80F676D78E93273A2FEB0D067C2D08E21CC74212D9C35034047C5FB1DF30170A
      0DA3CA9F176C29F9A0896E5CBF66A8AAAA3C6734364014F91B43C1C7794820EF
      798E87D1D76F606A66A69F999F1F5CCEE536891703486FDFBA795E5F5FAF1689
      45A8720E985008028180B0827C7E653A3C1F1A7ED1FF6A26954A677F245E0C20
      3F73FAD4D5066303A1D56961627C1CB2D96C0E1DAEF7D1C5E8873D5A6DF8EEBD
      FBB182DF5BDEF53F03C8F43AED953A4D1DD96836E7D10EF28A2565235353D34C
      4F4F4FA698702900DCD83258BBF7F1641E1F9CC277C9AFD3AFBE07258F2D017F
      7AFCFB806FEC97DAE061B3B0100000000049454E44AE426082}
    OnClick = btnRenameClick
    OnMouseEnter = btnRenameMouseEnter
    OnMouseLeave = btnRenameMouseLeave
  end
  object btnJoinTC: TExGraphicButton
    Left = 44
    Top = 142
    Width = 183
    Height = 26
    BorderWidth = 0
    Caption = 'Join Conference Room'
    Orientation = gboRightOf
    ImageEnabled.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000000467414D410000AFC837058AE90000001974455874536F6674776172
      650041646F626520496D616765526561647971C9653C000002434944415478DA
      63FCFFFF3F032D01E3F0B4A0AF3832EDF3C70FF6FFFEFDE7FBCFF09F11AF014C
      FFBFFFFDCB74814D407146FD8419EF8142FF90CDC46A41439AE794D0509F6CA0
      5A229CC8C4D0DF356DD185FB3F8BCFDEB9FB0928F2FB3F92A1D82D48F2581714
      EA1AC8C0405CF0B5364D38BCEAC4D31820F32D107F2368415D92FB96A0005B6F
      4CA3606A5143ADA575FAC9B5A79EC50399CF80F80B5116F87B1963B1003B68EB
      5E7866DDA9670940E61320FE48300E4016F8BA6978633818998FA4AD73C29AD3
      401F2402998F81F8135116F838CA7B33A0A71F64A54896744DD94ABA05DEF662
      DE8C48A6FD8792FF81A99611A29301A6B57BFA3E322CB0E2F67E7E5798E1C57D
      110671A5B70C524A6FB07807E284EED92749B720C09EDFFBCC0E15861FDFD818
      38B87E3118BBDF6660640419CB080D1D20EB3F84D536FD18E91684380B7B3FB9
      2DC8F01488A555DF31C8A8BEC7087C18AB69D221D22D887417F306BB12C5D570
      4DD0408204515D1F197110EB2DE90D0E65A00D2035300B18919DCE08A1AA3A77
      936E4142808C37C804B86B1961E642C4FE436D02B14BDB76906E414AB03CF69C
      8C483C7050D4447A3E589D1EA61282284DFFA35A00B201980F182088A1A06133
      A82C8A03329F03F167BC169C3FBC8B7BC1C48682D72F9FE8FEFDF34FEAEFBFFF
      6C40612606DCE01F132BE7B9D547EFB633204A53DC163C7B7A83B1B5BA8E6FF5
      C6DDACAF3F7CE0040A81302B1E0B7E7332B1FFF8FEEFE70720FB3B03A43EC01F
      44C09403723133D46066CC50C78895BF2083A134E11A8D9A80E616000032A2A0
      E0A20BAEE10000000049454E44AE426082}
    ImageDisabled.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000000467414D410000AFC837058AE90000001974455874536F6674776172
      650041646F626520496D616765526561647971C9653C000001DA4944415478DA
      63FCFFFF3F032D01E3F0B4A0A4B8C8E0D3A74F72FFFEFD6303CA331230E33710
      BF12161639DFDDD3F303C8FE8F6C26560B525392DD0203038C88F11D232323C3
      A44993AF3C79F274EFD56BD77E0185FE12634190B7B7971AB1C1D0DDD5FDF8D8
      89939B81CCEF201F11B420392931D4C3C35D195D1CA616E46A64D0DBDBF7ECE4
      A9D35B80CC2F40FC8B280B9C1C1D302CC005264F99FA026AC16720FE499405D6
      5696445B306BF69CE7400BB692648199A909D116CC5FB090740B8C0CF5E11680
      C21C45131A7FF19265A45BA0A3ADA9FCF7EF7F86B76FDE33088B08323033E3CE
      0E2B57AD21DD0243033DE5E7CF5E337CFFFE9D8193939341425204C307307AE9
      B215A45B606A62A4FCEBD71F86572FDF30888A0933B0B1B160040F8CBD70D112
      D22DB0B43053C617EEC860EEBC05A45B60630D49A6F80C868199B3C848A6F676
      36CAC8391616E6D8F853A7CD20DD026727E273F2A4C95349B620C0DDCD450326
      87AE063DD8264C9C4C7C5974E4F061D689132798BE78F15CF4DFDF7F3C7FFFFD
      6306A9C3E381FF6C6C6C2F0F1F397A9C8198D2F4FEFD7B0C4D8D4DEC5BB66E65
      7AF3E60D2B5008943E99F058F08F9595F5CFEFDFBF7F32402A9F7F0483881112
      7B200C733D5E1F40F15F189BA005D40434B70000BA6A96E0655D3FAC00000000
      49454E44AE426082}
    ImageSelected.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000000467414D410000AFC837058AE90000001974455874536F6674776172
      650041646F626520496D616765526561647971C9653C000004CC4944415478DA
      B5967F4C94651CC0BFEFFBDE7B1C70BF00078227BFC2358F285337163BCA6A8A
      73E6D6D45C1BABB55627CA00631A96D14C332631F9212C5911219785CD92A5B9
      2C965656D4D435AC0919EE5508A8E8083DDEF7BD7BDFB7EFF3BCC7BD87B8E53F
      BC77DF7B9EE77DDF7D3FDF5FCFF73946D334786C636931CCC1F55BDF979DCCDA
      0D5B8BBBBB9A12E7026077268D4700D786878137995138E0380E581426FCA2AA
      AA100C8520844246599621180C8288A32CC9308522491248B2444791AE65D8B6
      758B01181E19059EE711608273277D05427F5F8E2C49161242BC183252C10FF9
      AAE43E0AC331B2393E712873D9CA6F35933980608D42105E515262004646FF04
      DECC5348D7C1EA0D05CBEF2A4435FF1F0786850EDFC9DEFB8A9E3A6E8EB34EA1
      016A30A8504859C96603303A1606987878AFA6E2D9873C8BEFA5A6DEC1D5D8E4
      BB72CF9AE70ECF4B4EBE1963894527429A288B50BE39DA83B131B4DE0C66DE04
      6DAF973FBFA2203B77B6AA692033E36E7D73D7D59C878B7DE9191913B1F15659
      A66192A13CDA8321CC410CAF87A8FD8D0A6FE1F2F9EE3BAD968643DD42D6834F
      FA16A6674E38131330E798645182F22D25B756919EE4C3FB2BBD9EFBEDEE5906
      47AFA3A2D7D4D62364156EF2A56766FBED4E87286235C9222639BA8A06856B54
      B909E548DD0EAF27CFECBE25123353120539D8714EC8F03C81802CBFDDE11489
      072226B9B2B4D4000CFC3E483DE0701F1C6DD8E9F5E4AA6E264A9B16FED53446
      E73264AE3F6DF65D1016166C4440A6DFE670A003648F48B0BDACCC005CBA3C80
      F1E7C0C49AE093966AAFE7EE49F71F57926064701EA464FF0D69D97FDDC61DDD
      84E60FFA85B407D66392C30059DF682F6EAB3000172FFD82CA11801E7CDABAC7
      FB689EE8FEE9540E88013358E264585634000C43D432E1E8E04CD367073A7F15
      52F31F274946801D014120617AA9F20503D07BE1226D1104F2797B8D77F552C5
      7D7D20018650162C1A07D7A27F66057F7A56FBEECF42F2F2751460A51E04693B
      7965C7760370F6871FC144001C0B5F75D679D7E5336E6AE50CABC38870F0B570
      88F6B59E179296AEF5B9D233FC76BB1D938C80501076575519802FCE7C136972
      DF1F6DF4AEF7F06E1A6524901EC444473D6A4186D79A7B05E79235BE05AE0CBF
      0D01A411E26683BDBB5E3600274EF7E8009685F3C7DFF26E7A24D64D3444AC65
      A6F5EAF7B43089CC77357C2738F28A7C69AE74BF751A805DB7E6D56A0370ECC4
      2904B0C062F3EAFBACCD5BBCCA76FB9D6C144FE4DA59F7B510BF7825025CFE78
      BB43A46D3D1882DA3DBB0DC09163DD3A003D18E8F13DF3F4EA84254637D56602
      0881D1DB365956D59EB91A97BBCA973C3F7522DE6A93F473438103FBF61A80F6
      0F3F020EADE74DACF9F2D98F578C08FDA95220E008290A87396023BA8D1FBAD1
      3045AAC59972DD92957FDA99901088898D95154581107AD0B8BFC600B476BC8F
      D633C4034696029609FF24FBEFE4247FF3C60D33BECC023D6C545034153B3E39
      70547AD2614855D2A2AD36DB141F1313643993423C209096BA5A03D0F4763B0D
      4FB86A187C8995458953D410A32A2AE69228D6E849A6680A2AC711011A7999D4
      006B52188E45AEA6510F14155AEBEB0CC09B2DAD3A80449865C295AF974EE4B8
      A4566BD4721D8020544446A2940A3E53E83D15DE69AC1FA767ADCD9138277F5B
      5C69299DFF01917BE5C1444A759C0000000049454E44AE426082}
    ImagePushed.Data = {
      89504E470D0A1A0A0000000D4948445200000018000000180806000000E0773D
      F80000000467414D410000AFC837058AE90000001974455874536F6674776172
      650041646F626520496D616765526561647971C9653C000004EF4944415478DA
      B5967F4C55551CC0CFFD7D317E5E81F7C046494F7B5C7E396B94163322458B35
      36D9B4C23647F1CC1F44231C35CC899886A1C0F8E59244E4255656162E06CB59
      ADD84C5B6A65C518F486642DF1B1C603DFE5DDDBF79C73EF03C255FF78DFFBBE
      73EEB96FDFCFF7D7F99ECB389D4E343CF27B01BA0DD75F63A31D4C6878544161
      7189C2B12CE23810327254580EB1640D46960161C9C8302C084304195895413F
      BA416FE1D2751D7D71F6F228011495942A3C672AE6A9629EA78A2D18564C4058
      318601043158374346C3308262017A7B2E50C0E6D232052BE1791E8443216383
      CB276F5C73E8812999FC9B21B622734E07EB9663FCAC147975BEF3C1AF185EF2
      C16383020CD4D5D54701C5DBCB155EE089A50240B4A1BEFCB58F2FCB84BFFD77
      A0C193D623A7CEDDFDD0DA5321A1A1138220EA104A2360E8E883939F53C04BAF
      5628026F79C0A3891F3F2BCCCB7D200D0523FAEFD7C1BAF6817BB29E3D66B7DB
      C7EF080BD30820A0A3E39DBD1450B663A7220854B9083276A9BBE8C99CF4E4B9
      AA2C20331BD07062E8AECCF5EE858989631191917E0BD076F4340594EFAA54B0
      624110885CBFD0E57A22CBA1FEDF72AC6BF9D8B370C553EE4487632C36D63681
      D70281003AF4D687145051B547114DE558FE38F7916BF5C371EA1C8367DECF88
      5EC391339EC559056E87F35E6F4C74ECA405A86F3C41013BF7ED030F04248900
      104534F2F549D7AA8C08F51F91989D921990A6637D1E3567A37BB1D3E98D89B5
      11C01400DEAC69A780DDD5FB1511148B0090C0835FBF7CD7B5F27E5165666833
      CC5F03EA9EAC33784E9F361FBFE8495BF39C3B2929C91B63B7053DA8DADB4A01
      AFD71C502413208A121A3CFB8EEBB134BFFADBC07C746D301AD912AFA3F8C43F
      6FE10E35A1E5FD01CFD2DC4D6E3539C91B6BB3530FF4007A6D573305BC71B056
      91240C101106F59F71BBD62C0DA8E7BB1D68D22722799E1FDD97D38F686760CC
      E8C0CCA0B386CE5F3C19795BDC6A4A8AD716473DD0B4007A65473D05ECAFAF57
      64B05C94701E24F4736FBB2B37835187FBA3D05590058B46D19D8B6ECC09BE35
      ABEDB8E2599EBFCD9D929AE6B5991E68531A2A2D3F4001350D0D8A2C49C47A2C
      577A8EBAF296712AB17296D526C20CBE6186A8A6ED7B4FE6BA1200A47A6D760B
      30855E7CB99A026A1B9B145186508812F1E087EEB75DF999A24AA28C9B8B6104
      01CC4CD3CD665A7DF8A267C5D3A5EE54EC817DDA832D257B29A0AEA9599164EA
      01865CFEB4D5B5EED110156B085ACB587AE99A6192F07CCFA16F3D590565EEF4
      F42510229A839B9A865E28AE3201CD2D24C9384C582E9D3EEC7A6665E8AD77F2
      74F104AFCAA6F39EEC0DDB01901EAC224DF3A3A2ADBB4D404B33245946142282
      076D1B37AC0A5F32DD4D8DD9004C807D80E81755367E33B4BAB0C29DAC268F45
      C7C6DC2400BF869EDF5A3917304F16C5EF7A3A1F1919FA296ED2371E014D8B83
      1CB034220C49B77538E0FC4063D36316240E67AFDFDC9B9090E08B8C8AF2CF01
      D49310410EA04C654966A6B449D937EE634184499F4F8488B3B8D30AE6A1347D
      F2B14892653D223C528B8FB74F8486856BA224052C40D1361350DB8C3D801225
      10D80F3C3698610D5DE7E0886440192309B02E6200EC767C3861001C362CC719
      00350014E0395E37A30639D0D0262BC907A14CADF813884841217877E37580E3
      2E8B77BA601E4A78C42F01565A74E83DB8FF6853C40118FDB44CF16B8B2325FB
      B6BCB67CF25E43C7DF4A0DFEFC9ECC62A50000000049454E44AE426082}
    OnClick = btnJoinTCClick
    OnMouseEnter = btnJoinTCMouseEnter
    OnMouseLeave = btnJoinTCMouseLeave
  end
end
